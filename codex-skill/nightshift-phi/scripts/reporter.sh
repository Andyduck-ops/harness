#!/bin/bash
# reporter.sh — 定期报告 nightshift 状态
#
# 用法: reporter.sh <work_dir> <state_dir>
#
# 每 5 分钟输出状态摘要到终端 + 追加到 reporter.log

set -euo pipefail

WORK_DIR="${1:?Usage: reporter.sh <work_dir> <state_dir>}"
STATE_DIR="${2:?}"
INTERVAL=300  # 5 分钟
LOG_FILE="$WORK_DIR/$STATE_DIR/reporter.log"

log() {
    MSG="[reporter] $(date '+%Y-%m-%d %H:%M:%S') $*"
    echo "$MSG"
    echo "$MSG" >> "$LOG_FILE"
}

log "Started. Monitoring $WORK_DIR, interval=${INTERVAL}s"

while true; do
    sleep "$INTERVAL"

    STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"

    if [ ! -f "$STATE_FILE" ]; then
        log "No state.json yet"
        continue
    fi

    # 提取关键指标
    INFO=$(python3 -c "
import json
with open('$STATE_FILE') as f:
    s = json.load(f)
cycle = s.get('cycle', 0)
status = s.get('status', 'unknown')
mode = s.get('mode', 'unknown')
dirs = len(s.get('active_directions', []))
print(f'cycle={cycle} status={status} mode={mode} directions={dirs}')
" 2>/dev/null || echo "parse error")

    # 统计 patterns
    PATTERN_DIR="$WORK_DIR/references/patterns"
    if [ -d "$PATTERN_DIR" ]; then
        TOPICS=$(find "$PATTERN_DIR" -mindepth 1 -maxdepth 1 -type d -not -name '_*' | wc -l)
        PATTERNS=$(find "$PATTERN_DIR" -mindepth 2 -name '*.md' -not -name '_*' | wc -l)
    else
        TOPICS=0
        PATTERNS=0
    fi

    # 最近 commit
    LAST_COMMIT=$(cd "$WORK_DIR" && git log --oneline -1 2>/dev/null || echo "no commits")

    log "$INFO | patterns=$PATTERNS topics=$TOPICS | last: $LAST_COMMIT"
done
