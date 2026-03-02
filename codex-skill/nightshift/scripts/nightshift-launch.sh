#!/bin/bash
# nightshift-launch.sh — 三件套启动 nightshift 持续学习（支持独立 worktree 隔离）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER_WRAPPER="$(cd "$SCRIPT_DIR/../../scripts" && pwd)/runner-with-ledger.sh"
BASE_REPO="${HARNESS_DIR:-$HOME/harness}"
STATE_DIR=".nightshift"
SKILL="nightshift"
SESSION_NAME="nightshift"
WATCHDOG_SESSION="${SESSION_NAME}-watchdog"
REPORTER_SESSION="${SESSION_NAME}-reporter"
LANE_ID="engineering"
LANE_ROOT="references/lanes/${LANE_ID}"
DIRECTIONS="${1:-Agent SDK 落地实战, AI 全栈可靠性边界, PRD 到产品信息保真, AI 代码有效测试, 长运行稳定性工程}"

# 隔离配置（默认开启）
USE_WORKTREE="${NIGHTSHIFT_USE_WORKTREE:-1}"
WORKTREE_ROOT="${NIGHTSHIFT_WORKTREE_ROOT:-$HOME/harness-worktrees}"
WORKTREE_DIR="${NIGHTSHIFT_WORKTREE_DIR:-$WORKTREE_ROOT/engineering}"
WORKTREE_BRANCH="${NIGHTSHIFT_BRANCH:-nightshift/engineering}"

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
mkdir -p "$WORK_DIR/$LANE_ROOT/distilled" "$WORK_DIR/$LANE_ROOT/sources"

if [ ! -e "$WORK_DIR/$LANE_ROOT/patterns" ]; then
    mkdir -p "$WORK_DIR/$LANE_ROOT/patterns"
fi

if [ ! -f "$WORK_DIR/$LANE_ROOT/_master_index.md" ]; then
    cat > "$WORK_DIR/$LANE_ROOT/_master_index.md" <<'EOT'
# Engineering Pattern Master Index

（初始化完成，待 nightshift 运行填充）
EOT
fi

for s in "$SESSION_NAME" "$WATCHDOG_SESSION" "$REPORTER_SESSION"; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "[nightshift] Session '$s' already running. Kill all first:"
        echo "  for s in $SESSION_NAME $WATCHDOG_SESSION $REPORTER_SESSION; do tmux kill-session -t \$s 2>/dev/null; done"
        exit 1
    fi
done

LAUNCH_PROMPT_FILE="$WORK_DIR/$STATE_DIR/launch_prompt.txt"
cat > "$LAUNCH_PROMPT_FILE" <<EOT
\$nightshift

大方向:
$DIRECTIONS

在 $WORK_DIR 工作。读取现有 lane 知识地图，
只在 ${LANE_ROOT}/ 范围内读写（禁止修改其他 lane）。
读取 ${LANE_ROOT}/_master_index.md 识别空白区域，
组建 Scout+Analyst+Cartographer 团队，开始持续探索。

每轮更新 morning-brief.md，每轮 git commit。
不要 push。不要修改 PRD/ 和 generator/。跨 lane 只允许写 references/bridges/ 摘要。
直到我手动停止为止。
EOT

RESTART_PROMPT_FILE="$WORK_DIR/$STATE_DIR/restart_prompt.txt"
cat > "$RESTART_PROMPT_FILE" <<EOT
\$${SKILL}

继续从 cycle {{CYCLE}} 开始。读取 ${STATE_DIR}/state.json 恢复状态。

大方向:
{{DIRECTIONS}}

在 ${WORK_DIR} 工作。读取现有 lane 知识地图，
只在 ${LANE_ROOT}/ 范围内读写（禁止修改其他 lane）。
读取 ${LANE_ROOT}/_master_index.md 识别空白区域，
组建 Scout+Analyst+Cartographer 团队，开始持续探索。

每轮更新 morning-brief.md，每轮 git commit。
不要 push。不要修改 PRD/ 和 generator/。跨 lane 只允许写 references/bridges/ 摘要。
直到我手动停止为止。
EOT

python3 - "$WORK_DIR/$STATE_DIR/state.json" <<'PY'
import datetime
import json
from pathlib import Path
import sys

state_file = Path(sys.argv[1])
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

launch = state.get("launch")
if not isinstance(launch, dict):
    launch = {}
launch["session"] = "nightshift"
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

RUN_CMD="$(printf '%q ' "$RUNNER_WRAPPER" "$WORK_DIR" "$STATE_DIR" "$SESSION_NAME" "$SKILL" "$CYCLE" "$LAUNCH_PROMPT_FILE" "0")"

echo "[nightshift] Starting three-piece daemon..."
echo "[nightshift] Directions: $DIRECTIONS"
echo "[nightshift] Base repo: $BASE_REPO"
echo "[nightshift] Working dir: $WORK_DIR"
if [ "$USE_WORKTREE" = "1" ]; then
    echo "[nightshift] Isolated branch: $WORKTREE_BRANCH"
fi
echo ""

# 1. Runner（主进程，按轮日志 + 事件账本）
tmux new-session -d -s "$SESSION_NAME" "$RUN_CMD"
echo "[nightshift] Runner   → tmux attach -t $SESSION_NAME"

# 2. Watchdog（看门狗）
tmux new-session -d -s "$WATCHDOG_SESSION" \
    "$SCRIPT_DIR/watchdog.sh $SESSION_NAME $WORK_DIR $STATE_DIR $SKILL \"$DIRECTIONS\" 2>&1 | tee -a $WORK_DIR/$STATE_DIR/watchdog.log"
echo "[nightshift] Watchdog → tmux attach -t $WATCHDOG_SESSION"

# 3. Reporter（报告器）
tmux new-session -d -s "$REPORTER_SESSION" \
    "$SCRIPT_DIR/reporter.sh $WORK_DIR $STATE_DIR $LANE_ID $SESSION_NAME"
echo "[nightshift] Reporter → tmux attach -t $REPORTER_SESSION"

echo ""
echo "[nightshift] All three sessions launched."
echo "[nightshift] Check progress:  cat $WORK_DIR/morning-brief.md"
echo "[nightshift] Reporter logs:   tail -f $WORK_DIR/$STATE_DIR/reporter.log"
echo "[nightshift] Runner ledger:   tail -f $WORK_DIR/$STATE_DIR/events.jsonl"
echo "[nightshift] Stop all:        for s in $SESSION_NAME $WATCHDOG_SESSION $REPORTER_SESSION; do tmux kill-session -t \$s 2>/dev/null; done"
