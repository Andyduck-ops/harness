#!/bin/bash
# nightshift-phi-launch.sh — 三件套启动哲学方法论持续学习（支持独立 worktree 隔离）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER_WRAPPER="$(cd "$SCRIPT_DIR/../../scripts" && pwd)/runner-with-ledger.sh"
BASE_REPO="${HARNESS_DIR:-$HOME/harness}"
STATE_DIR=".nightshift-phi"
SKILL="nightshift-phi"
SESSION_NAME="nightshift-phi"
WATCHDOG_SESSION="${SESSION_NAME}-watchdog"
REPORTER_SESSION="${SESSION_NAME}-reporter"
LANE_ID="philosophy"
LANE_ROOT="references/lanes/${LANE_ID}"
DIRECTIONS="${1:-系统论与控制论, 认识论与知识验证, 决策论, 复杂性科学与涌现, 精益与约束理论, 演化与适应, 中国哲学方法论}"

# 隔离配置（默认开启）
USE_WORKTREE="${NIGHTSHIFT_PHI_USE_WORKTREE:-1}"
WORKTREE_ROOT="${NIGHTSHIFT_PHI_WORKTREE_ROOT:-$HOME/harness-worktrees}"
WORKTREE_DIR="${NIGHTSHIFT_PHI_WORKTREE_DIR:-$WORKTREE_ROOT/philosophy}"
WORKTREE_BRANCH="${NIGHTSHIFT_PHI_BRANCH:-nightshift/philosophy}"

if [ ! -x "$RUNNER_WRAPPER" ]; then
    echo "[ERROR] runner wrapper not found: $RUNNER_WRAPPER"
    exit 1
fi

if [ ! -d "$BASE_REPO" ]; then
    echo "[ERROR] Base repo not found at $BASE_REPO"
    echo "Set HARNESS_DIR env var or clone the repo first."
    exit 1
fi

if [ "$USE_WORKTREE" = "1" ]; then
    if [ ! -d "$BASE_REPO/.git" ] && [ ! -f "$BASE_REPO/.git" ]; then
        echo "[ERROR] Base repo is not a git repository: $BASE_REPO"
        exit 1
    fi

    mkdir -p "$WORKTREE_ROOT"

    if [ -d "$WORKTREE_DIR/.git" ] || [ -f "$WORKTREE_DIR/.git" ]; then
        WORK_DIR="$WORKTREE_DIR"
    else
        if [ -e "$WORKTREE_DIR" ] && [ ! -d "$WORKTREE_DIR/.git" ] && [ ! -f "$WORKTREE_DIR/.git" ]; then
            echo "[ERROR] Worktree path exists but is not a git worktree: $WORKTREE_DIR"
            exit 1
        fi

        if git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$WORKTREE_BRANCH"; then
            git -C "$BASE_REPO" worktree add "$WORKTREE_DIR" "$WORKTREE_BRANCH"
        else
            git -C "$BASE_REPO" worktree add -b "$WORKTREE_BRANCH" "$WORKTREE_DIR" HEAD
        fi
        WORK_DIR="$WORKTREE_DIR"
    fi
else
    WORK_DIR="$BASE_REPO"
fi

mkdir -p "$WORK_DIR/$STATE_DIR"
mkdir -p "$WORK_DIR/$STATE_DIR/runs"
mkdir -p "$WORK_DIR/$LANE_ROOT/patterns" "$WORK_DIR/$LANE_ROOT/sources" "$WORK_DIR/$LANE_ROOT/distilled" "$WORK_DIR/$LANE_ROOT/bedrock"

if [ ! -f "$WORK_DIR/$LANE_ROOT/_master_index.md" ]; then
    cat > "$WORK_DIR/$LANE_ROOT/_master_index.md" <<'PHI_INDEX_EOF'
# Philosophy Pattern Master Index

（初始化完成，待 nightshift-phi 运行填充）
PHI_INDEX_EOF
fi

for s in "$SESSION_NAME" "$WATCHDOG_SESSION" "$REPORTER_SESSION"; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "[nightshift-phi] Session '$s' already running. Kill all first:"
        echo "  for s in $SESSION_NAME $WATCHDOG_SESSION $REPORTER_SESSION; do tmux kill-session -t \$s 2>/dev/null; done"
        exit 1
    fi
done

PROMPT_FILE="$WORK_DIR/$STATE_DIR/launch_prompt.txt"
RESTART_PROMPT_FILE="$WORK_DIR/$STATE_DIR/restart_prompt.txt"

cat > "$PROMPT_FILE" <<PHI_PROMPT_EOF
\$nightshift-phi

继续 nightshift-phi 循环，从当前 $STATE_DIR/state.json 的 cycle 断点继续。
严格遵循三角色协议：cartographer / scout / analyst。

大方向:
$DIRECTIONS

在 $WORK_DIR 工作。只在 $LANE_ROOT/ 范围内读写（禁止写其他 lane）。
读取 $LANE_ROOT/_master_index.md 识别空白区域并持续探索。

核心目标：提取跨时代的元方法论——半衰期以十年计的不变量。
优先追溯原始著作和原始作者，而非二手解读。
学派矛盾写入 conflicts.md，不自动裁决。

每轮更新 morning-brief.md，每轮 git commit（不 push）。
不要修改 PRD/、generator/ 和其他 lane。
跨 lane 只允许写 references/bridges/ 摘要。
不要停，直到我手动停止为止。
PHI_PROMPT_EOF

cat > "$RESTART_PROMPT_FILE" <<PHI_RESTART_EOF
\$${SKILL}

继续从 cycle {{CYCLE}} 开始。读取 ${STATE_DIR}/state.json 恢复状态。
严格遵循三角色协议：cartographer / scout / analyst。

大方向:
{{DIRECTIONS}}

在 ${WORK_DIR} 工作。只在 ${LANE_ROOT}/ 范围内读写（禁止写其他 lane）。
读取 ${LANE_ROOT}/_master_index.md 识别空白区域并持续探索。

核心目标：提取跨时代的元方法论——半衰期以十年计的不变量。
优先追溯原始著作和原始作者，而非二手解读。
学派矛盾写入 conflicts.md，不自动裁决。

每轮更新 morning-brief.md，每轮 git commit（不 push）。
不要修改 PRD/、generator/ 和其他 lane。
跨 lane 只允许写 references/bridges/ 摘要。
不要停，直到我手动停止为止。
PHI_RESTART_EOF

python3 - "$WORK_DIR/$STATE_DIR/state.json" "$SESSION_NAME" "$LANE_ID" "$WORK_DIR" "$WORKTREE_BRANCH" <<'PY'
import datetime
import json
from pathlib import Path
import sys

state_file = Path(sys.argv[1])
session_name = sys.argv[2]
lane_id = sys.argv[3]
work_dir = sys.argv[4]
worktree_branch = sys.argv[5]

if state_file.exists():
    try:
        state = json.loads(state_file.read_text(encoding="utf-8"))
        if not isinstance(state, dict):
            state = {}
    except Exception:
        state = {}
else:
    state = {}

now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state.setdefault("version", "1.1")
state.setdefault("cycle", 0)
state["status"] = "running"
state["updated_at"] = now
state["lane_id"] = lane_id

launch = state.get("launch")
if not isinstance(launch, dict):
    launch = {}
launch["session"] = session_name
launch["lane_id"] = lane_id
launch["work_dir"] = work_dir
launch["worktree_branch"] = worktree_branch
launch["updated_at"] = now
state["launch"] = launch

state_file.parent.mkdir(parents=True, exist_ok=True)
state_file.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

CYCLE="$(python3 - "$WORK_DIR/$STATE_DIR/state.json" <<'PY'
import json, sys
from pathlib import Path
p=Path(sys.argv[1])
try:
    d=json.loads(p.read_text(encoding='utf-8'))
except Exception:
    d={}
print(d.get('cycle',0))
PY
)"

RUN_CMD="$(printf '%q ' "$RUNNER_WRAPPER" "$WORK_DIR" "$STATE_DIR" "$SESSION_NAME" "$SKILL" "$CYCLE" "$PROMPT_FILE" "0")"

echo "[nightshift-phi] Starting three-piece daemon..."
echo "[nightshift-phi] Directions: $DIRECTIONS"
echo "[nightshift-phi] Base repo: $BASE_REPO"
echo "[nightshift-phi] Working dir: $WORK_DIR"
if [ "$USE_WORKTREE" = "1" ]; then
    echo "[nightshift-phi] Isolated branch: $WORKTREE_BRANCH"
fi
echo "[nightshift-phi] Lane root: $LANE_ROOT"
echo ""

# 1. Runner（按轮日志 + 事件账本）
tmux new-session -d -s "$SESSION_NAME" "$RUN_CMD"
echo "[nightshift-phi] Runner   → tmux attach -t $SESSION_NAME"

# 2. Watchdog
tmux new-session -d -s "$WATCHDOG_SESSION" \
    "$SCRIPT_DIR/watchdog.sh $SESSION_NAME $WORK_DIR $STATE_DIR $SKILL \"$DIRECTIONS\" 2>&1 | tee -a $WORK_DIR/$STATE_DIR/watchdog.log"
echo "[nightshift-phi] Watchdog → tmux attach -t $WATCHDOG_SESSION"

# 3. Reporter（单写链路，避免重复日志）
tmux new-session -d -s "$REPORTER_SESSION" \
    "$SCRIPT_DIR/reporter.sh $WORK_DIR $STATE_DIR $LANE_ID $SESSION_NAME"
echo "[nightshift-phi] Reporter → tmux attach -t $REPORTER_SESSION"

echo ""
echo "[nightshift-phi] All three sessions launched."
echo "[nightshift-phi] Check progress:  cat $WORK_DIR/morning-brief.md"
echo "[nightshift-phi] Reporter logs:   tail -f $WORK_DIR/$STATE_DIR/reporter.log"
echo "[nightshift-phi] Runner ledger:   tail -f $WORK_DIR/$STATE_DIR/events.jsonl"
echo "[nightshift-phi] Stop all:        for s in $SESSION_NAME $WATCHDOG_SESSION $REPORTER_SESSION; do tmux kill-session -t \$s 2>/dev/null; done"
