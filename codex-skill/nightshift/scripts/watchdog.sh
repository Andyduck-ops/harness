#!/bin/bash
# watchdog.sh — 看门狗：codex 进程退出后自动重启

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNNER_WRAPPER="$(cd "$SCRIPT_DIR/../../scripts" && pwd)/runner-with-ledger.sh"

SESSION="${1:?Usage: watchdog.sh <session> <work_dir> <state_dir> <skill> <directions>}"
WORK_DIR="${2:?}"
STATE_DIR="${3:?}"
SKILL="${4:?}"
DIRECTIONS="${5:-}"
CHECK_INTERVAL=60
MAX_RESTARTS=10
RESTART_COUNT=0
STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"
RESTART_PROMPT_FILE="$WORK_DIR/$STATE_DIR/restart_prompt.txt"
SESSION_LOG_FILE="$WORK_DIR/$STATE_DIR/session.log"

log() { echo "[watchdog:$SESSION] $(date '+%H:%M:%S') $*"; }

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

status = data.get("status", "unknown")
cycle = data.get("cycle", 0)
print(status)
print(cycle)
PY
}

build_restart_prompt() {
    local cycle="$1"
    local fallback
    fallback="\$$SKILL

继续从 cycle $cycle 开始。读取 $STATE_DIR/state.json 恢复状态。

大方向:
$DIRECTIONS

在 $WORK_DIR 工作。读取现有 lane 知识地图，
只在 references/lanes/engineering/ 范围内读写（禁止修改其他 lane）。
读取 references/lanes/engineering/_master_index.md 识别空白区域，
组建 Scout+Analyst+Cartographer 团队，开始持续探索。

每轮更新 morning-brief.md，每轮 git commit。
不要 push。不要修改 PRD/ 和 generator/。跨 lane 只允许写 references/bridges/ 摘要。
直到我手动停止为止。"

    if [ -f "$RESTART_PROMPT_FILE" ]; then
        python3 - "$RESTART_PROMPT_FILE" "$cycle" "$DIRECTIONS" "$fallback" <<'PY'
from pathlib import Path
import sys

template_file = Path(sys.argv[1])
cycle = sys.argv[2]
directions = sys.argv[3]
fallback = sys.argv[4]

try:
    template = template_file.read_text(encoding="utf-8")
except Exception:
    print(fallback)
    raise SystemExit(0)

if not template.strip():
    print(fallback)
    raise SystemExit(0)

result = template.replace("{{CYCLE}}", cycle).replace("{{DIRECTIONS}}", directions)
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
    cmd="$(printf '%q ' "$RUNNER_WRAPPER" "$WORK_DIR" "$STATE_DIR" "$SESSION" "$SKILL" "$cycle" "$prompt_file" "0")"

    if tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux send-keys -t "$SESSION" "$cmd" Enter
    else
        tmux new-session -d -s "$SESSION" "$cmd"
    fi
}

log "Started. Monitoring session '$SESSION', work_dir=$WORK_DIR"
log "Max restarts: $MAX_RESTARTS, check interval: ${CHECK_INTERVAL}s"

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

    if [ "$STATUS" = "exhausted" ] || [ "$STATUS" = "paused" ] || [ "$STATUS" = "completed" ]; then
        log "Status is '$STATUS'. Not restarting."
        continue
    fi

    RESTART_COUNT=$((RESTART_COUNT + 1))
    if [ "$RESTART_COUNT" -gt "$MAX_RESTARTS" ]; then
        log "ERROR: Max restarts ($MAX_RESTARTS) reached. Giving up."
        log "Manual intervention needed. Check $SESSION_LOG_FILE"
        update_state_status "error" "watchdog_max_restart_exceeded"
        break
    fi

    log "Process exited (status=$STATUS, cycle=$CYCLE). Restarting ($RESTART_COUNT/$MAX_RESTARTS)..."

    PROMPT="$(build_restart_prompt "$CYCLE")"
    update_state_status "running" "watchdog_restart"
    start_runner "$PROMPT" "$CYCLE"

    log "Restarted. Waiting ${CHECK_INTERVAL}s before next check."
done

log "Watchdog exiting."
