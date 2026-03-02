#!/bin/bash
# reporter.sh — 定期报告 nightshift-phi 状态（含 runtime 对账）
#
# 用法: reporter.sh <work_dir> <state_dir> [lane_id] [session_name]

set -euo pipefail

WORK_DIR="${1:?Usage: reporter.sh <work_dir> <state_dir> [lane_id] [session_name]}"
STATE_DIR="${2:?}"
LANE_ID="${3:-philosophy}"
SESSION_NAME="${4:-nightshift-phi}"
INTERVAL="${REPORTER_INTERVAL:-300}"
LOG_FILE="$WORK_DIR/$STATE_DIR/reporter.log"
SNAPSHOT_FILE="$WORK_DIR/$STATE_DIR/progress-latest.md"
STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"

log() {
    MSG="[reporter] $(date '+%Y-%m-%d %H:%M:%S') $*"
    echo "$MSG"
    echo "$MSG" >> "$LOG_FILE"
}

write_snapshot() {
    local now_utc now_local runtime_status codex_count tmux_alive pane_children
    local cycle status mode dirs drift patterns topics last_commit
    now_utc="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    now_local="$(date '+%Y-%m-%d %H:%M:%S %Z')"

    readarray -t state_lines < <(python3 - "$STATE_FILE" <<'PY'
import json
from pathlib import Path
import sys

state_file = Path(sys.argv[1])
if not state_file.exists():
    print("NA")
    print("missing")
    print("NA")
    print("0")
    raise SystemExit(0)

try:
    d = json.loads(state_file.read_text(encoding="utf-8"))
except Exception:
    d = {}

print(d.get("cycle", "NA"))
print(d.get("status", "unknown"))
print(d.get("mode", "unknown"))
print(len(d.get("active_directions", [])))
PY
    )
    cycle="${state_lines[0]:-NA}"
    status="${state_lines[1]:-unknown}"
    mode="${state_lines[2]:-unknown}"
    dirs="${state_lines[3]:-0}"

    codex_count="$(ps -eo comm=,args= | awk -v wd="$WORK_DIR" '
      $1 == "codex" && index($0, "exec --full-auto -s") && index($0, wd) { c++ }
      END { print c+0 }
    ')"

    if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
        tmux_alive="yes"
        pane_pid="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_pid}' 2>/dev/null | head -1)"
        if [ -n "$pane_pid" ]; then
            pane_children="$(pgrep -P "$pane_pid" 2>/dev/null | wc -l | tr -d ' ')"
        else
            pane_children="0"
        fi
    else
        tmux_alive="no"
        pane_children="0"
    fi

    if [ "$codex_count" -gt 0 ]; then
        runtime_status="running"
    elif [ "$tmux_alive" = "yes" ] && [ "$pane_children" -gt 0 ]; then
        runtime_status="busy-no-codex"
    elif [ "$tmux_alive" = "yes" ]; then
        runtime_status="idle"
    else
        runtime_status="stopped"
    fi

    drift="no"
    if [ "$status" != "$runtime_status" ]; then
        drift="yes"
    fi

    PATTERN_DIR="$WORK_DIR/references/lanes/$LANE_ID/patterns"
    if [ -d "$PATTERN_DIR" ]; then
        topics="$(find "$PATTERN_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '_*' | wc -l | tr -d ' ')"
        patterns="$(find "$PATTERN_DIR" -mindepth 2 -name '*.md' -not -name '_*' | wc -l | tr -d ' ')"
    else
        topics="0"
        patterns="0"
    fi

    last_commit="$(cd "$WORK_DIR" && git log --oneline -1 2>/dev/null || echo "no commits")"

    cat > "$SNAPSHOT_FILE" <<SNAPSHOT_EOF
## [${now_utc}] Nightshift-Phi Reporter 快照
- 本地时间: ${now_local}
- 会话: ${SESSION_NAME} (tmux_alive=${tmux_alive}, pane_children=${pane_children})
- 运行态: runtime=${runtime_status}, codex_exec=${codex_count}
- 状态文件: cycle=${cycle}, status=${status}, mode=${mode}, directions=${dirs}
- 状态一致性: drift=${drift}
- 知识地图: lane=${LANE_ID}, patterns=${patterns}, topics=${topics}
- 最近提交: ${last_commit}
SNAPSHOT_EOF

    log "cycle=${cycle} state=${status} runtime=${runtime_status} drift=${drift} mode=${mode} dirs=${dirs} | lane=${LANE_ID} patterns=${patterns} topics=${topics} | last: ${last_commit}"
}

mkdir -p "$WORK_DIR/$STATE_DIR"
log "Started. Monitoring $WORK_DIR, lane=${LANE_ID}, session=${SESSION_NAME}, interval=${INTERVAL}s"
write_snapshot

while true; do
    sleep "$INTERVAL"
    write_snapshot
done
