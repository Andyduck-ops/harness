#!/bin/bash
# reporter.sh — Nightshift-Sleep 状态报告器（含 runtime 对账）
#
# 用法: reporter.sh <work_dir> <state_dir> <lane_id> [session_name]

set -euo pipefail

WORK_DIR="${1:?Usage: reporter.sh <work_dir> <state_dir> <lane_id> [session_name]}"
STATE_DIR="${2:?}"
LANE_ID="${3:?}"
SESSION_NAME="${4:-nightshift-sleep-${LANE_ID}}"
INTERVAL="${SLEEP_REPORT_INTERVAL_SECONDS:-180}"
LOG_FILE="$WORK_DIR/$STATE_DIR/reporter.log"
SNAPSHOT_FILE="$WORK_DIR/$STATE_DIR/progress-latest.md"
STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"

log() {
    local msg="[sleep-reporter] $(date '+%Y-%m-%d %H:%M:%S') $*"
    echo "$msg"
    echo "$msg" >> "$LOG_FILE"
}

write_snapshot() {
    local now_utc now_local runtime_status codex_count tmux_alive pane_children drift
    local cycle status mode candidates processed
    local fragments topics archive_count report_status last_commit

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
    print("unknown")
    print("0")
    print("0")
    raise SystemExit(0)

try:
    d = json.loads(state_file.read_text(encoding="utf-8"))
except Exception:
    d = {}

print(d.get("cycle", "NA"))
print(d.get("status", "unknown"))
print(d.get("mode", "unknown"))
print(d.get("candidates", 0))
print(d.get("processed", 0))
PY
    )

    cycle="${state_lines[0]:-NA}"
    status="${state_lines[1]:-unknown}"
    mode="${state_lines[2]:-unknown}"
    candidates="${state_lines[3]:-0}"
    processed="${state_lines[4]:-0}"

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

    DISTILLED_DIR="$WORK_DIR/references/lanes/$LANE_ID/distilled"
    PATTERN_DIR="$WORK_DIR/references/lanes/$LANE_ID/patterns"

    if [ -d "$DISTILLED_DIR" ]; then
        fragments="$(find "$DISTILLED_DIR" -mindepth 2 -name '*.md' -not -name '_*' | wc -l | tr -d ' ')"
        topics="$(find "$DISTILLED_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '_*' -not -name '_provenance' | wc -l | tr -d ' ')"
    else
        fragments="0"
        topics="0"
    fi

    archive_count="0"
    if [ -d "$PATTERN_DIR/_archive" ]; then
        archive_count="$(find "$PATTERN_DIR/_archive" -mindepth 2 -name '*.md' | wc -l | tr -d ' ')"
    fi

    REPORT_FILE="$WORK_DIR/$STATE_DIR/sleep-report.md"
    if [ -f "$REPORT_FILE" ]; then
        report_status="ready"
    else
        report_status="pending"
    fi

    last_commit="$(cd "$WORK_DIR" && git log --oneline -1 2>/dev/null || echo "no commits")"

    cat > "$SNAPSHOT_FILE" <<SLEEP_SNAPSHOT_EOF
## [${now_utc}] Nightshift-Sleep Reporter 快照
- 本地时间: ${now_local}
- 会话: ${SESSION_NAME} (tmux_alive=${tmux_alive}, pane_children=${pane_children})
- 运行态: runtime=${runtime_status}, codex_exec=${codex_count}
- 状态文件: cycle=${cycle}, status=${status}, mode=${mode}, candidates=${candidates}, processed=${processed}
- 状态一致性: drift=${drift}
- 压缩产物: lane=${LANE_ID}, distilled_fragments=${fragments}, distilled_topics=${topics}, archived_patterns=${archive_count}, report=${report_status}
- 最近提交: ${last_commit}
SLEEP_SNAPSHOT_EOF

    log "cycle=${cycle} state=${status} runtime=${runtime_status} drift=${drift} mode=${mode} candidates=${candidates} processed=${processed} | lane=${LANE_ID} distilled_fragments=${fragments} distilled_topics=${topics} archived_patterns=${archive_count} report=${report_status} | last: ${last_commit}"
}

mkdir -p "$WORK_DIR/$STATE_DIR"
log "Started. lane=${LANE_ID}, session=${SESSION_NAME}, interval=${INTERVAL}s, state_dir=${STATE_DIR}"
write_snapshot

while true; do
    sleep "$INTERVAL"
    write_snapshot
done
