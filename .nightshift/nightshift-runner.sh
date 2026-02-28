#!/usr/bin/env bash
set -u

HARNESS_DIR="/home/eric/harness"
PROMPT_FILE="$HARNESS_DIR/.nightshift/restart_prompt.txt"
SESSION_LOG="$HARNESS_DIR/.nightshift/session.log"
RUNNER_LOG="$HARNESS_DIR/.nightshift/runner.log"
SLEEP_BETWEEN_RUNS=30

mkdir -p "$HARNESS_DIR/.nightshift"
cd "$HARNESS_DIR" || exit 1

now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ"
}

runner_log() {
  echo "[$(now_iso)] $*" >> "$RUNNER_LOG"
}

runner_log "Runner started (pid=$$)."

while true; do
  if [[ ! -f "$PROMPT_FILE" ]]; then
    runner_log "ERROR: prompt file missing: $PROMPT_FILE"
    sleep 60
    continue
  fi

  PROMPT="$(cat "$PROMPT_FILE")"

  echo "" >> "$SESSION_LOG"
  echo "===== RUN START $(now_iso) =====" >> "$SESSION_LOG"
  runner_log "Launching codex exec..."

  codex exec --full-auto -s workspace-write "$PROMPT" >> "$SESSION_LOG" 2>&1
  exit_code=$?

  echo "===== RUN END   $(now_iso) code=${exit_code} =====" >> "$SESSION_LOG"
  echo "" >> "$SESSION_LOG"

  runner_log "codex exec exited with code=${exit_code}; sleeping ${SLEEP_BETWEEN_RUNS}s"
  sleep "$SLEEP_BETWEEN_RUNS"
done
