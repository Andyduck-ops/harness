#!/bin/bash
# runner-with-ledger.sh
# 用法:
#   runner-with-ledger.sh <work_dir> <state_dir> <session> <skill> <cycle> <prompt_file> [max_minutes] [tail_lines] [sandbox_mode]

set -euo pipefail

WORK_DIR="${1:?}"
STATE_DIR="${2:?}"
SESSION_NAME="${3:?}"
SKILL_NAME="${4:?}"
CYCLE_RAW="${5:?}"
PROMPT_FILE="${6:?}"
MAX_MINUTES="${7:-0}"
TAIL_LINES="${8:-160}"
SANDBOX_MODE_RAW="${9:-}"

STATE_PATH="$WORK_DIR/$STATE_DIR"
EVENTS_FILE="$STATE_PATH/events.jsonl"
SESSION_FILE="$STATE_PATH/session.log"
SANDBOX_MODE_FILE="$STATE_PATH/sandbox.mode"

resolve_sandbox_mode() {
  local mode=""
  if [ -n "$SANDBOX_MODE_RAW" ]; then
    mode="$SANDBOX_MODE_RAW"
  elif [ -n "${NIGHTSHIFT_CODEX_SANDBOX:-}" ]; then
    mode="$NIGHTSHIFT_CODEX_SANDBOX"
  elif [ -f "$SANDBOX_MODE_FILE" ]; then
    mode="$(tr -d "[:space:]" < "$SANDBOX_MODE_FILE")"
  elif [ -f "$WORK_DIR/.git" ] && [ ! -d "$WORK_DIR/.git" ]; then
    # git worktree 的 gitdir 常在主仓库路径下，workspace-write 沙箱无法写 index.lock
    mode="danger-full-access"
  else
    mode="workspace-write"
  fi

  case "$mode" in
    workspace-write|danger-full-access|read-only)
      printf "%s" "$mode"
      ;;
    *)
      echo "[runner-ledger] WARN: invalid sandbox mode '$mode', fallback to workspace-write" >&2
      printf "%s" "workspace-write"
      ;;
  esac
}

SANDBOX_MODE="$(resolve_sandbox_mode)"

if [ ! -f "$PROMPT_FILE" ]; then
  echo "[runner-ledger] prompt file not found: $PROMPT_FILE" >&2
  exit 2
fi

CYCLE_PAD="$(python3 - "$CYCLE_RAW" <<'PY'
import sys
raw = sys.argv[1]
try:
    c = int(raw)
except Exception:
    c = 0
print(f"{c:04d}")
PY
)"

RUN_ID="$(date -u '+%Y%m%dT%H%M%SZ')"
RUN_DIR="$STATE_PATH/runs/cycle-$CYCLE_PAD"
RUN_LOG="$RUN_DIR/run-${RUN_ID}.log"
mkdir -p "$RUN_DIR"

append_event() {
  local event_name="$1"
  local code_value="${2:-}"
  python3 - "$EVENTS_FILE" "$event_name" "$SESSION_NAME" "$SKILL_NAME" "$CYCLE_RAW" "$RUN_ID" "$RUN_LOG" "$code_value" "$SANDBOX_MODE" <<'PY'
import datetime
import json
from pathlib import Path
import sys

file_path = Path(sys.argv[1])
event_name = sys.argv[2]
session = sys.argv[3]
skill = sys.argv[4]
cycle = sys.argv[5]
run_id = sys.argv[6]
run_log = sys.argv[7]
code = sys.argv[8]
sandbox = sys.argv[9]

record = {
    "ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "event": event_name,
    "session": session,
    "skill": skill,
    "cycle": cycle,
    "run_id": run_id,
    "run_log": run_log,
    "sandbox": sandbox,
}
if event_name == "run_end":
    try:
        record["code"] = int(code)
    except Exception:
        record["code"] = code

file_path.parent.mkdir(parents=True, exist_ok=True)
with file_path.open("a", encoding="utf-8") as f:
    f.write(json.dumps(record, ensure_ascii=False) + "\n")
PY
}

append_meta_event() {
  local event_name="$1"
  local reason="${2:-}"
  local sha="${3:-}"
  local detail="${4:-}"
  python3 - "$EVENTS_FILE" "$event_name" "$SESSION_NAME" "$SKILL_NAME" "$CYCLE_RAW" "$RUN_ID" "$RUN_LOG" "$SANDBOX_MODE" "$reason" "$sha" "$detail" <<'PY'
import datetime
import json
from pathlib import Path
import sys

file_path = Path(sys.argv[1])
event_name = sys.argv[2]
session = sys.argv[3]
skill = sys.argv[4]
cycle = sys.argv[5]
run_id = sys.argv[6]
run_log = sys.argv[7]
sandbox = sys.argv[8]
reason = sys.argv[9]
sha = sys.argv[10]
detail = sys.argv[11]

record = {
    "ts": datetime.datetime.now(datetime.timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
    "event": event_name,
    "session": session,
    "skill": skill,
    "cycle": cycle,
    "run_id": run_id,
    "run_log": run_log,
    "sandbox": sandbox,
}
if reason:
    record["reason"] = reason
if sha:
    record["sha"] = sha
if detail:
    record["detail"] = detail

file_path.parent.mkdir(parents=True, exist_ok=True)
with file_path.open("a", encoding="utf-8") as f:
    f.write(json.dumps(record, ensure_ascii=False) + "\n")
PY
}

auto_commit_after_run() {
  local auto_commit="${NIGHTSHIFT_AUTO_COMMIT:-1}"
  local -a targets=()
  local commit_msg out reason sha detail

  COMMIT_EVENT="commit_skip"
  COMMIT_REASON="auto_commit_disabled"
  COMMIT_SHA=""
  COMMIT_DETAIL=""

  if [ "$auto_commit" != "1" ]; then
    return 0
  fi

  if ! git -C "$WORK_DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    COMMIT_REASON="not_a_git_repo"
    return 0
  fi

  for rel in \
    "references/lanes" \
    "references/bridges" \
    "$STATE_DIR/state.json" \
    "$STATE_DIR/sleep-report.md" \
    "$STATE_DIR/research-back-signals.md"
  do
    if [ -e "$WORK_DIR/$rel" ]; then
      targets+=("$rel")
    fi
  done

  if [ "${#targets[@]}" -eq 0 ]; then
    COMMIT_REASON="no_commit_targets"
    return 0
  fi

  if ! git -C "$WORK_DIR" add -A -- "${targets[@]}" >/dev/null 2>&1; then
    COMMIT_EVENT="commit_fail"
    COMMIT_REASON="git_add_failed"
    return 0
  fi

  if git -C "$WORK_DIR" diff --cached --quiet -- "${targets[@]}"; then
    COMMIT_REASON="no_staged_changes_in_targets"
    return 0
  fi

  commit_msg="nightshift(${SESSION_NAME}) cycle ${CYCLE_RAW}: auto-commit run ${RUN_ID}"
  if out="$(git -C "$WORK_DIR" commit -m "$commit_msg" -- "${targets[@]}" 2>&1)"; then
    COMMIT_EVENT="commit_ok"
    COMMIT_REASON=""
    COMMIT_SHA="$(git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null || true)"
    COMMIT_DETAIL="$(printf '%s' "$out" | tail -n 1 | cut -c1-240)"
  else
    COMMIT_EVENT="commit_fail"
    reason="$(printf '%s' "$out" | tail -n 1 | tr '\n' ' ' | cut -c1-240)"
    COMMIT_REASON="${reason:-git_commit_failed}"
    COMMIT_SHA=""
    COMMIT_DETAIL="$(printf '%s' "$out" | tail -n 3 | tr '\n' ' ' | cut -c1-500)"
  fi
}

{
  echo "[runner-ledger] ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ') event=run_start session=$SESSION_NAME skill=$SKILL_NAME cycle=$CYCLE_RAW run_id=$RUN_ID sandbox=$SANDBOX_MODE"
  echo "[runner-ledger] run_log=$RUN_LOG"
} > "$SESSION_FILE"

append_event "run_start"

PROMPT_CONTENT="$(cat "$PROMPT_FILE")"

cd "$WORK_DIR"

set +e
if command -v timeout >/dev/null 2>&1 && [[ "$MAX_MINUTES" =~ ^[0-9]+$ ]] && [ "$MAX_MINUTES" -gt 0 ]; then
  timeout "${MAX_MINUTES}m" codex exec --full-auto -s "$SANDBOX_MODE" "$PROMPT_CONTENT" 2>&1 | tee -a "$RUN_LOG"
  CODE=${PIPESTATUS[0]}
else
  codex exec --full-auto -s "$SANDBOX_MODE" "$PROMPT_CONTENT" 2>&1 | tee -a "$RUN_LOG"
  CODE=${PIPESTATUS[0]}
fi
set -e

append_event "run_end" "$CODE"
auto_commit_after_run
append_meta_event "$COMMIT_EVENT" "$COMMIT_REASON" "$COMMIT_SHA" "$COMMIT_DETAIL"

{
  echo "[runner-ledger] ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ') event=run_end session=$SESSION_NAME skill=$SKILL_NAME cycle=$CYCLE_RAW run_id=$RUN_ID code=$CODE sandbox=$SANDBOX_MODE"
  echo "[runner-ledger] run_log=$RUN_LOG"
  echo "[runner-ledger] commit_event=$COMMIT_EVENT commit_sha=${COMMIT_SHA:-none} commit_reason=${COMMIT_REASON:-none}"
  echo
  echo "--- tail -n $TAIL_LINES $RUN_LOG ---"
  tail -n "$TAIL_LINES" "$RUN_LOG" 2>/dev/null || true
} > "$SESSION_FILE"

exit "$CODE"
