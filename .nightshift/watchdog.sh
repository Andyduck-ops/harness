#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="/home/eric/harness"
LOG_FILE="$HARNESS_DIR/.nightshift/watchdog.log"
SESSION_NAME="nightshift"
CHECK_INTERVAL_SECONDS=3600   # 1小时检查一次
STALL_THRESHOLD_SECONDS=7200  # 2小时无日志更新视为卡住

mkdir -p "$HARNESS_DIR/.nightshift"

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

append_log() {
  echo "[$(now_iso)] $*" >> "$LOG_FILE"
}

start_nightshift() {
  local prompt
  prompt="$(cat "$HARNESS_DIR/.nightshift/restart_prompt.txt")"

  tmux new-session -d -s "$SESSION_NAME" \
    "cd $HARNESS_DIR && codex exec --full-auto -s workspace-write \"$prompt\" 2>&1 | tee -a .nightshift/session.log"

  append_log "ACTION: started tmux session '$SESSION_NAME'"
}

check_once() {
  local session_log="$HARNESS_DIR/.nightshift/session.log"
  local now_epoch
  now_epoch="$(date +%s)"

  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    append_log "WARN: session '$SESSION_NAME' not found"
    start_nightshift
    return
  fi

  if [[ ! -f "$session_log" ]]; then
    append_log "WARN: session log missing, creating placeholder"
    touch "$session_log"
  fi

  local mtime size age
  mtime="$(stat -c %Y "$session_log")"
  size="$(stat -c %s "$session_log")"
  age="$((now_epoch - mtime))"

  append_log "CHECK: session alive, session.log size=${size}B age=${age}s"

  if (( age > STALL_THRESHOLD_SECONDS )); then
    append_log "WARN: session appears stalled (> ${STALL_THRESHOLD_SECONDS}s). restarting..."
    tmux kill-session -t "$SESSION_NAME" || true
    sleep 2
    start_nightshift
  fi
}

append_log "Watchdog started (interval=${CHECK_INTERVAL_SECONDS}s, stall=${STALL_THRESHOLD_SECONDS}s)"

while true; do
  check_once
  sleep "$CHECK_INTERVAL_SECONDS"
done
