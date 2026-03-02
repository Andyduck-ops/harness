#!/bin/bash
# nightshift-sleep-launch.sh — 启动 lane 级 Sleep 压缩任务（runner + reporter，可选 watchdog）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER_WRAPPER="$(cd "$SCRIPT_DIR/../../scripts" && pwd)/runner-with-ledger.sh"
BASE_REPO="${HARNESS_DIR:-$HOME/harness}"
LANE_ID="${1:-engineering}"
FOCUS="${2:-阅读负担信号, 元问题混杂信号, 重复叙述信号}"
STATE_DIR=".nightshift-sleep-${LANE_ID}"
LANE_ROOT="references/lanes/${LANE_ID}"
SESSION="nightshift-sleep-${LANE_ID}"
REPORTER_SESSION="${SESSION}-reporter"
WATCHDOG_SESSION="${SESSION}-watchdog"
SKILL="nightshift-sleep"

# <=0 表示不设置 timeout（可长期运行，手动停止）
MAX_MINUTES="${SLEEP_MAX_MINUTES:-45}"
# 默认关闭 watchdog（人工编排优先），可显式开启
ENABLE_WATCHDOG="${SLEEP_ENABLE_WATCHDOG:-0}"

# 隔离配置（默认开启）
USE_WORKTREE="${NIGHTSHIFT_SLEEP_USE_WORKTREE:-1}"
WORKTREE_ROOT="${NIGHTSHIFT_SLEEP_WORKTREE_ROOT:-$HOME/harness-worktrees}"
WORKTREE_DIR="${NIGHTSHIFT_SLEEP_WORKTREE_DIR:-$WORKTREE_ROOT/sleep-${LANE_ID}}"
WORKTREE_BRANCH="${NIGHTSHIFT_SLEEP_BRANCH:-nightshift-sleep/${LANE_ID}}"

if [ ! -x "$RUNNER_WRAPPER" ]; then
  echo "[nightshift-sleep] ERROR: runner wrapper not found: $RUNNER_WRAPPER"
  exit 1
fi

if [[ ! "$LANE_ID" =~ ^[a-z][a-z0-9-]*$ ]]; then
  echo "[nightshift-sleep] ERROR: invalid lane_id '$LANE_ID'"
  exit 2
fi

if [ ! -d "$BASE_REPO" ]; then
  echo "[nightshift-sleep] ERROR: Harness repo not found at $BASE_REPO"
  echo "Set HARNESS_DIR env var or clone the repo first."
  exit 1
fi

if [ "$USE_WORKTREE" = "1" ]; then
  if [ ! -d "$BASE_REPO/.git" ] && [ ! -f "$BASE_REPO/.git" ]; then
    echo "[nightshift-sleep] ERROR: Base repo is not a git repository: $BASE_REPO"
    exit 1
  fi

  mkdir -p "$WORKTREE_ROOT"

  if [ -d "$WORKTREE_DIR/.git" ] || [ -f "$WORKTREE_DIR/.git" ]; then
    WORK_DIR="$WORKTREE_DIR"
  else
    if [ -e "$WORKTREE_DIR" ] && [ ! -d "$WORKTREE_DIR/.git" ] && [ ! -f "$WORKTREE_DIR/.git" ]; then
      echo "[nightshift-sleep] ERROR: Worktree path exists but is not a git worktree: $WORKTREE_DIR"
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

PROMPT_FILE="$WORK_DIR/$STATE_DIR/launch_prompt.txt"
RESTART_PROMPT_FILE="$WORK_DIR/$STATE_DIR/restart_prompt.txt"

mkdir -p "$WORK_DIR/$STATE_DIR"
mkdir -p "$WORK_DIR/$STATE_DIR/runs"
mkdir -p "$WORK_DIR/$LANE_ROOT/patterns/_archive" "$WORK_DIR/$LANE_ROOT/distilled/_provenance" "$WORK_DIR/$LANE_ROOT/sources"

if [ ! -f "$WORK_DIR/$LANE_ROOT/patterns/_master_index.md" ]; then
  cat > "$WORK_DIR/$LANE_ROOT/patterns/_master_index.md" <<SLEEP_PATTERN_INDEX_EOF
# ${LANE_ID^} Pattern Master Index

（初始化完成，待 nightshift / sleep 运行填充）
SLEEP_PATTERN_INDEX_EOF
fi

if [ ! -e "$WORK_DIR/$LANE_ROOT/_master_index.md" ]; then
  (cd "$WORK_DIR/$LANE_ROOT" && ln -s patterns/_master_index.md _master_index.md)
fi

if [ ! -f "$WORK_DIR/$LANE_ROOT/distilled/_distilled_index.md" ]; then
  cat > "$WORK_DIR/$LANE_ROOT/distilled/_distilled_index.md" <<SLEEP_DISTILLED_INDEX_EOF
# ${LANE_ID^} Distilled Index

（初始化完成，待 nightshift-sleep 运行填充）
SLEEP_DISTILLED_INDEX_EOF
fi

cat > "$WORK_DIR/$STATE_DIR/context.json" <<SLEEP_CONTEXT_EOF
{
  "lane_id": "$LANE_ID",
  "state_dir": "$STATE_DIR",
  "started_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "focus": "$FOCUS"
}
SLEEP_CONTEXT_EOF

python3 - "$WORK_DIR/$STATE_DIR/state.json" "$LANE_ID" "$SESSION" "$WORK_DIR" "$WORKTREE_BRANCH" <<'PY'
import datetime
import json
from pathlib import Path
import sys

state_file = Path(sys.argv[1])
lane_id = sys.argv[2]
session = sys.argv[3]
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
state.setdefault("mode", "foreground")
state.setdefault("candidates", 0)
state.setdefault("processed", 0)
state.setdefault("last_contract_cycle", 0)
state["lane_id"] = lane_id
state["status"] = "running"
state["updated_at"] = now

launch = state.get("launch")
if not isinstance(launch, dict):
    launch = {}
launch["session"] = session
launch["lane_id"] = lane_id
launch["work_dir"] = work_dir
launch["worktree_branch"] = worktree_branch
launch["updated_at"] = now
state["launch"] = launch

state_file.parent.mkdir(parents=True, exist_ok=True)
state_file.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY

for s in "$SESSION" "$REPORTER_SESSION" "$WATCHDOG_SESSION"; do
  if tmux has-session -t "$s" 2>/dev/null; then
    echo "[nightshift-sleep] Session '$s' already running. Kill first: tmux kill-session -t $s"
    exit 1
  fi
done

cat > "$PROMPT_FILE" <<SLEEP_PROMPT_EOF
\$nightshift-sleep

进入 lane=$LANE_ID 的 sleep 压缩模式，严格执行 Dual-Store：
- patterns 作为证据层，仅归档不主改
- distilled 作为检索层，写高密度碎片

Focus signals:
$FOCUS

在 $WORK_DIR 工作，只允许写 $LANE_ROOT/（跨 lane 仅允许 references/bridges/ 摘要）。
输出以下产物：
1) $STATE_DIR/sleep-report.md
2) $STATE_DIR/research-back-signals.md
3) $LANE_ROOT/distilled/_distilled_index.md
4) $LANE_ROOT/distilled/_provenance/*

必须执行三门合同并在报告中给出 pass/fail：
- Self-Containment
- Fidelity
- Index Integrity

指标仅做观测，不得用伪精度分数裁决。
每轮完成后必须 git commit（若本轮无变更，需在报告记录原因）。
不要 push。不要退出，直到我手动停止。
SLEEP_PROMPT_EOF

cat > "$RESTART_PROMPT_FILE" <<SLEEP_RESTART_EOF
\$${SKILL}

继续从 cycle {{CYCLE}} 开始。读取 ${STATE_DIR}/state.json 恢复状态。

进入 lane=${LANE_ID} 的 sleep 压缩模式，严格执行 Dual-Store：
- patterns 作为证据层，仅归档不主改
- distilled 作为检索层，写高密度碎片

Focus signals:
{{FOCUS}}

在 ${WORK_DIR} 工作，只允许写 ${LANE_ROOT}/（跨 lane 仅允许 references/bridges/ 摘要）。
输出以下产物：
1) ${STATE_DIR}/sleep-report.md
2) ${STATE_DIR}/research-back-signals.md
3) ${LANE_ROOT}/distilled/_distilled_index.md
4) ${LANE_ROOT}/distilled/_provenance/*

必须执行三门合同并在报告中给出 pass/fail：
- Self-Containment
- Fidelity
- Index Integrity

指标仅做观测，不得用伪精度分数裁决。
每轮完成后必须 git commit（若本轮无变更，需在报告记录原因）。
不要 push。不要退出，直到我手动停止。
SLEEP_RESTART_EOF

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

RUN_CMD="$(printf '%q ' "$RUNNER_WRAPPER" "$WORK_DIR" "$STATE_DIR" "$SESSION" "$SKILL" "$CYCLE" "$PROMPT_FILE" "$MAX_MINUTES")"

echo "[nightshift-sleep] Starting lane=$LANE_ID"
echo "[nightshift-sleep] Base repo: $BASE_REPO"
echo "[nightshift-sleep] Working dir: $WORK_DIR"
echo "[nightshift-sleep] State dir: $STATE_DIR"
if [ "$USE_WORKTREE" = "1" ]; then
  echo "[nightshift-sleep] Isolated branch: $WORKTREE_BRANCH"
fi
if [[ "$MAX_MINUTES" =~ ^[0-9]+$ ]] && [ "$MAX_MINUTES" -gt 0 ]; then
  echo "[nightshift-sleep] Max runtime: ${MAX_MINUTES}m"
else
  echo "[nightshift-sleep] Max runtime: unlimited (manual stop)"
fi

# 1) Runner（按轮日志 + 事件账本）
tmux new-session -d -s "$SESSION" "$RUN_CMD"
echo "[nightshift-sleep] Runner   → tmux attach -t $SESSION"

# 2) Reporter（单写链路，避免重复日志）
tmux new-session -d -s "$REPORTER_SESSION" \
  "$SCRIPT_DIR/reporter.sh $WORK_DIR $STATE_DIR $LANE_ID $SESSION"
echo "[nightshift-sleep] Reporter → tmux attach -t $REPORTER_SESSION"

# 3) Watchdog (optional)
if [ "$ENABLE_WATCHDOG" = "1" ]; then
  tmux new-session -d -s "$WATCHDOG_SESSION" \
    "$SCRIPT_DIR/watchdog.sh $SESSION $WORK_DIR $STATE_DIR $LANE_ID \"$FOCUS\" \"$MAX_MINUTES\" 2>&1 | tee -a $WORK_DIR/$STATE_DIR/watchdog.log"
  echo "[nightshift-sleep] Watchdog → tmux attach -t $WATCHDOG_SESSION"
else
  echo "[nightshift-sleep] Watchdog disabled (SLEEP_ENABLE_WATCHDOG=0)"
fi

echo ""
echo "[nightshift-sleep] launched."
echo "[nightshift-sleep] report: $WORK_DIR/$STATE_DIR/sleep-report.md"
echo "[nightshift-sleep] runner ledger: $WORK_DIR/$STATE_DIR/events.jsonl"
echo "[nightshift-sleep] stop: $SCRIPT_DIR/stop.sh $LANE_ID"
