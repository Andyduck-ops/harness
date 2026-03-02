#!/bin/bash
# watchdog.sh — Nightshift-Sleep 看门狗（语义等价重放）
#
# 用法: watchdog.sh <session_name> <work_dir> <state_dir> <lane_id> [focus] [max_minutes]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER_WRAPPER="$(cd "$SCRIPT_DIR/../../scripts" && pwd)/runner-with-ledger.sh"

SESSION="${1:?Usage: watchdog.sh <session> <work_dir> <state_dir> <lane_id> [focus] [max_minutes]}"
WORK_DIR="${2:?}"
STATE_DIR="${3:?}"
LANE_ID="${4:?}"
FOCUS="${5:-阅读负担信号, 元问题混杂信号, 重复叙述信号}"
MAX_MINUTES="${6:-45}"
SKILL="nightshift-sleep"
CHECK_INTERVAL="${SLEEP_WATCHDOG_INTERVAL_SECONDS:-60}"
MAX_RESTARTS="${SLEEP_WATCHDOG_MAX_RESTARTS:-20}"
RESTART_COUNT=0
STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"
RESTART_PROMPT_FILE="$WORK_DIR/$STATE_DIR/restart_prompt.txt"
SESSION_LOG_FILE="$WORK_DIR/$STATE_DIR/session.log"

log() { echo "[sleep-watchdog:$SESSION] $(date '+%H:%M:%S') $*"; }

if [ ! -x "$RUNNER_WRAPPER" ]; then
  log "ERROR: runner wrapper not found: $RUNNER_WRAPPER"
  exit 1
fi

update_state_status() {
  local new_status="$1"
  local reason="$2"
  python3 - "$STATE_FILE" "$new_status" "$reason" <<'PY'
import datetime
import json
from pathlib import Path
import sys

state_path = Path(sys.argv[1])
new_status = sys.argv[2]
reason = sys.argv[3]

if state_path.exists():
    try:
        state = json.loads(state_path.read_text(encoding="utf-8"))
        if not isinstance(state, dict):
            state = {}
    except Exception:
        state = {}
else:
    state = {}

now = datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
state.setdefault("version", "1.1")
state.setdefault("cycle", 0)
state.setdefault("lane_id", "unknown")
state["status"] = new_status
state["updated_at"] = now

watchdog = state.get("watchdog")
if not isinstance(watchdog, dict):
    watchdog = {}
watchdog["last_event"] = reason
watchdog["updated_at"] = now
state["watchdog"] = watchdog

state_path.parent.mkdir(parents=True, exist_ok=True)
state_path.write_text(json.dumps(state, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
PY
}

read_state_status_cycle() {
  python3 - "$STATE_FILE" <<'PY'
import json
from pathlib import Path
import sys

state_path = Path(sys.argv[1])
if not state_path.exists():
    print("no-state")
    print("0")
    raise SystemExit(0)

try:
    data = json.loads(state_path.read_text(encoding="utf-8"))
except Exception:
    data = {}

print(data.get("status", "unknown"))
print(data.get("cycle", 0))
PY
}

build_restart_prompt() {
  local cycle="$1"
  local fallback
  fallback="\$$SKILL

继续从 cycle $cycle 开始。读取 $STATE_DIR/state.json 恢复状态。

进入 lane=$LANE_ID 的 sleep 压缩模式，严格执行 Dual-Store。
Focus signals:
$FOCUS

在 $WORK_DIR 工作，只允许写 references/lanes/$LANE_ID/（跨 lane 仅允许 references/bridges/ 摘要）。
必须执行 Self-Containment / Fidelity / Index Integrity 三门合同。
每轮完成后必须 git commit（若本轮无变更，需在报告记录原因）。
不要 push。不要退出，直到我手动停止。"

  if [ -f "$RESTART_PROMPT_FILE" ]; then
    python3 - "$RESTART_PROMPT_FILE" "$cycle" "$FOCUS" "$fallback" <<'PY'
from pathlib import Path
import sys

template_file = Path(sys.argv[1])
cycle = sys.argv[2]
focus = sys.argv[3]
fallback = sys.argv[4]

try:
    template = template_file.read_text(encoding="utf-8")
except Exception:
    print(fallback)
    raise SystemExit(0)

if not template.strip():
    print(fallback)
    raise SystemExit(0)

result = template.replace("{{CYCLE}}", cycle).replace("{{FOCUS}}", focus)
print(result)
PY
  else
    echo "$fallback"
  fi
}

is_runner_active() {
  local codex_count
  codex_count="$(ps -eo comm=,args= | awk -v wd="$WORK_DIR" '
    $1 == "codex" && index($0, "exec --full-auto -s") && index($0, wd) { c++ }
    END { print c+0 }
  ')"
  [ "$codex_count" -gt 0 ]
}

start_runner() {
  local prompt="$1"
  local cycle="$2"
  local prompt_file cmd
  prompt_file="$WORK_DIR/$STATE_DIR/watchdog_prompt.active.txt"
  printf '%s\n' "$prompt" > "$prompt_file"

  cmd="$(printf '%q ' "$RUNNER_WRAPPER" "$WORK_DIR" "$STATE_DIR" "$SESSION" "$SKILL" "$cycle" "$prompt_file" "$MAX_MINUTES")"

  if tmux has-session -t "$SESSION" 2>/dev/null; then
    tmux send-keys -t "$SESSION" "$cmd" Enter
  else
    tmux new-session -d -s "$SESSION" "$cmd"
  fi
}

log "Started. lane=$LANE_ID, work_dir=$WORK_DIR, interval=${CHECK_INTERVAL}s, max_restarts=$MAX_RESTARTS"

while true; do
  sleep "$CHECK_INTERVAL"

  if is_runner_active; then
    RESTART_COUNT=0
    readarray -t state_lines < <(read_state_status_cycle)
    STATUS="${state_lines[0]:-unknown}"
    if [ "$STATUS" != "running" ]; then
      update_state_status "running" "watchdog_detected_live_runner"
    fi
    continue
  fi

  if ! tmux has-session -t "$SESSION" 2>/dev/null; then
    log "Session '$SESSION' gone. Recreating..."
  fi

  readarray -t state_lines < <(read_state_status_cycle)
  STATUS="${state_lines[0]:-unknown}"
  CYCLE="${state_lines[1]:-0}"

  case "$STATUS" in
    paused|exhausted|completed)
      log "Status=$STATUS. Not restarting."
      continue
      ;;
  esac

  RESTART_COUNT=$((RESTART_COUNT + 1))
  if [ "$RESTART_COUNT" -gt "$MAX_RESTARTS" ]; then
    log "ERROR: Max restarts reached ($MAX_RESTARTS). Giving up."
    log "Manual intervention needed. Check $SESSION_LOG_FILE"
    update_state_status "error" "watchdog_max_restart_exceeded"
    break
  fi

  PROMPT="$(build_restart_prompt "$CYCLE")"
  log "Runner stopped (status=$STATUS, cycle=$CYCLE). Restarting ($RESTART_COUNT/$MAX_RESTARTS)..."
  update_state_status "running" "watchdog_restart"
  start_runner "$PROMPT" "$CYCLE"
done

log "Watchdog exit."
