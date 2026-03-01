#!/bin/bash
# watchdog.sh — 看门狗：codex 进程退出后自动重启
#
# 用法: watchdog.sh <session_name> <work_dir> <state_dir> <skill_name> <directions>
#
# 每 60 秒检查一次主 session 是否还有活跃进程。
# 如果进程退出且 state.json 的 status != "exhausted"，自动重启。

set -euo pipefail

SESSION="${1:?Usage: watchdog.sh <session> <work_dir> <state_dir> <skill> <directions>}"
WORK_DIR="${2:?}"
STATE_DIR="${3:?}"
SKILL="${4:?}"
DIRECTIONS="${5:-}"
CHECK_INTERVAL=60
MAX_RESTARTS=10
RESTART_COUNT=0

log() { echo "[watchdog:$SESSION] $(date '+%H:%M:%S') $*"; }

log "Started. Monitoring session '$SESSION', work_dir=$WORK_DIR"
log "Max restarts: $MAX_RESTARTS, check interval: ${CHECK_INTERVAL}s"

while true; do
    sleep "$CHECK_INTERVAL"

    # 检查主 session 是否还有活跃进程
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        # 检查 pane 里是否有进程在跑
        PANE_PID=$(tmux list-panes -t "$SESSION" -F '#{pane_pid}' 2>/dev/null | head -1)
        if [ -n "$PANE_PID" ]; then
            # 检查该 pid 是否还有子进程（codex）
            CHILDREN=$(pgrep -P "$PANE_PID" 2>/dev/null | wc -l)
            if [ "$CHILDREN" -gt 0 ]; then
                # 还在跑，重置计数
                RESTART_COUNT=0
                continue
            fi
        fi
    else
        log "Session '$SESSION' gone. Recreating..."
    fi

    # 进程已退出，检查是否应该重启
    STATE_FILE="$WORK_DIR/$STATE_DIR/state.json"
    if [ -f "$STATE_FILE" ]; then
        STATUS=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('status','unknown'))" 2>/dev/null || echo "unknown")
        if [ "$STATUS" = "exhausted" ]; then
            log "Status is 'exhausted'. Not restarting."
            continue
        fi
        CYCLE=$(python3 -c "import json; print(json.load(open('$STATE_FILE')).get('cycle', 0))" 2>/dev/null || echo "?")
    else
        STATUS="no-state"
        CYCLE="0"
    fi

    # 检查重启次数
    RESTART_COUNT=$((RESTART_COUNT + 1))
    if [ "$RESTART_COUNT" -gt "$MAX_RESTARTS" ]; then
        log "ERROR: Max restarts ($MAX_RESTARTS) reached. Giving up."
        log "Manual intervention needed. Check $WORK_DIR/$STATE_DIR/session.log"
        break
    fi

    log "Process exited (status=$STATUS, cycle=$CYCLE). Restarting ($RESTART_COUNT/$MAX_RESTARTS)..."

    # 构建 prompt
    PROMPT="\$$SKILL

继续从 cycle $CYCLE 开始。读取 $STATE_DIR/state.json 恢复状态。
方向: $DIRECTIONS
不要停，直到我手动停止。"

    # 重启
    if tmux has-session -t "$SESSION" 2>/dev/null; then
        tmux send-keys -t "$SESSION" "cd $WORK_DIR && codex exec --full-auto -s workspace-write \"$PROMPT\" 2>&1 | tee -a $STATE_DIR/session.log" Enter
    else
        tmux new-session -d -s "$SESSION" \
            "cd $WORK_DIR && codex exec --full-auto -s workspace-write \"$PROMPT\" 2>&1 | tee -a $STATE_DIR/session.log"
    fi

    log "Restarted. Waiting ${CHECK_INTERVAL}s before next check."
done

log "Watchdog exiting."
