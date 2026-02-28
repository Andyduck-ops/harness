#!/usr/bin/env bash
set -u
set -o pipefail

HARNESS_DIR="/home/eric/harness"
LOG_FILE="$HARNESS_DIR/.nightshift/watchdog.log"
SESSION_NAME="nightshift"
RUNNER_SCRIPT="$HARNESS_DIR/.nightshift/nightshift-runner.sh"
CHECK_INTERVAL_SECONDS=3600   # 1小时检查一次
STALL_THRESHOLD_SECONDS=7200  # 2小时无进展视为卡住

mkdir -p "$HARNESS_DIR/.nightshift"

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

append_log() {
  echo "[$(now_iso)] $*" >> "$LOG_FILE"
}

start_nightshift() {
  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true
    sleep 1
  fi

  tmux new-session -d -s "$SESSION_NAME" "bash '$RUNNER_SCRIPT'"

  if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    append_log "ACTION: started tmux session '$SESSION_NAME' via runner script"
    return 0
  fi

  append_log "ERROR: failed to start tmux session '$SESSION_NAME'"
  return 1
}

get_file_age_seconds() {
  local file="$1"
  local now_epoch mtime
  now_epoch="$(date +%s)"

  if [[ ! -f "$file" ]]; then
    echo 999999
    return
  fi

  mtime="$(stat -c %Y "$file" 2>/dev/null || echo 0)"
  echo $((now_epoch - mtime))
}

get_last_commit_age_seconds() {
  local now_epoch last_commit
  now_epoch="$(date +%s)"
  last_commit="$(git -C "$HARNESS_DIR" log -1 --format=%ct 2>/dev/null || echo 0)"
  echo $((now_epoch - last_commit))
}

check_once() {
  local session_log runner_log
  session_log="$HARNESS_DIR/.nightshift/session.log"
  runner_log="$HARNESS_DIR/.nightshift/runner.log"

  if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    append_log "WARN: session '$SESSION_NAME' not found"
    start_nightshift || append_log "ERROR: restart attempt failed"
    return
  fi

  local pane_dead
  pane_dead="$(tmux list-panes -t "$SESSION_NAME" -F '#{pane_dead}' 2>/dev/null | tr -d '\n' || true)"
  if [[ "$pane_dead" == *"1"* ]]; then
    append_log "WARN: detected dead pane in '$SESSION_NAME', restarting"
    start_nightshift || append_log "ERROR: restart attempt failed"
    return
  fi

  local session_age runner_age commit_age
  session_age="$(get_file_age_seconds "$session_log")"
  runner_age="$(get_file_age_seconds "$runner_log")"
  commit_age="$(get_last_commit_age_seconds)"

  append_log "CHECK: alive, session_age=${session_age}s, runner_age=${runner_age}s, commit_age=${commit_age}s"

  if (( session_age > STALL_THRESHOLD_SECONDS && runner_age > STALL_THRESHOLD_SECONDS )); then
    append_log "WARN: no log progress for > ${STALL_THRESHOLD_SECONDS}s, restarting"
    start_nightshift || append_log "ERROR: restart attempt failed"
    return
  fi

  if (( commit_age > (STALL_THRESHOLD_SECONDS * 2) )); then
    append_log "WARN: no new commits for ${commit_age}s (soft warning)"
  fi
}

append_log "Watchdog started (interval=${CHECK_INTERVAL_SECONDS}s, stall=${STALL_THRESHOLD_SECONDS}s)"

if ! tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
  append_log "INIT: nightshift session missing on startup, launching"
  start_nightshift || append_log "ERROR: initial start failed"
fi

while true; do
  check_once
  sleep "$CHECK_INTERVAL_SECONDS"
done
