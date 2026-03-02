#!/bin/bash
# nightshift-clear.sh
# 最小骨架：stop/status/collect/backfill

set -euo pipefail

BASE_REPO="${HARNESS_DIR:-$HOME/harness}"
WORKTREE_ROOT="${NIGHTSHIFT_WORKTREE_ROOT:-$HOME/harness-worktrees}"
STATE_REPORT_DIR="$BASE_REPO/.nightshift-clear/reports"
INBOX_DIR="$BASE_REPO/.nightshift-clear/inbox"
APPLY=0

TARGET_BRANCH="main"
FROM_BRANCH=""
TO_BRANCH=""

usage() {
  cat <<'EOF'
Usage:
  nightshift-clear.sh status
  nightshift-clear.sh stop [--apply]
  nightshift-clear.sh collect [--target <branch>] [--apply] [--cherry-pick-head]
  nightshift-clear.sh backfill --from <inbox_branch> --to <target_branch> [--apply]

Notes:
  - 默认 dry-run，只有 --apply 才执行写操作。
  - 不执行 push。
EOF
}

log() { echo "[nightshift-clear] $*"; }

ensure_repo() {
  if [ ! -d "$BASE_REPO/.git" ] && [ ! -f "$BASE_REPO/.git" ]; then
    echo "[nightshift-clear] ERROR: not a git repo: $BASE_REPO" >&2
    exit 1
  fi
}

timestamp() { date -u '+%Y%m%dT%H%M%SZ'; }

declare -a SESSIONS=(
  "nightshift"
  "nightshift-watchdog"
  "nightshift-reporter"
  "nightshift-phi"
  "nightshift-phi-watchdog"
  "nightshift-phi-reporter"
  "nightshift-sleep-engineering"
  "nightshift-sleep-engineering-watchdog"
  "nightshift-sleep-engineering-reporter"
)

declare -a SOURCE_BRANCHES=(
  "nightshift/engineering"
  "nightshift/philosophy"
  "nightshift-sleep/engineering"
)

status_report() {
  ensure_repo
  mkdir -p "$STATE_REPORT_DIR"
  local ts report
  ts="$(timestamp)"
  report="$STATE_REPORT_DIR/${ts}-status.md"

  {
    echo "# Nightshift Clear Status"
    echo
    echo "- generated_at_utc: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "- base_repo: $BASE_REPO"
    echo "- worktree_root: $WORKTREE_ROOT"
    echo
    echo "## tmux sessions"
    echo
    for s in "${SESSIONS[@]}"; do
      if tmux has-session -t "$s" 2>/dev/null; then
        echo "- [x] $s"
      else
        echo "- [ ] $s"
      fi
    done
    echo
    echo "## branches"
    echo
    for b in "${SOURCE_BRANCHES[@]}"; do
      if git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$b"; then
        local head
        head="$(git -C "$BASE_REPO" log -1 --pretty=format:'%h %ad %s' --date=iso-strict "$b")"
        echo "- $b: $head"
      else
        echo "- $b: <missing>"
      fi
    done
  } > "$report"

  log "status report written: $report"
  cat "$report"
}

stop_sessions() {
  local killed=0
  for s in "${SESSIONS[@]}"; do
    if tmux has-session -t "$s" 2>/dev/null; then
      if [ "$APPLY" -eq 1 ]; then
        tmux kill-session -t "$s"
        log "killed session: $s"
      else
        log "would kill session: $s"
      fi
      killed=$((killed + 1))
    fi
  done
  log "session count matched: $killed"
}

collect_to_inbox() {
  ensure_repo
  mkdir -p "$INBOX_DIR"
  local ts inbox_branch manifest do_pick=0
  ts="$(timestamp)"
  inbox_branch="nightshift/inbox-$ts"
  manifest="$INBOX_DIR/${inbox_branch//\//_}.md"

  while [ "$#" -gt 0 ]; do
    case "$1" in
      --cherry-pick-head) do_pick=1; shift ;;
      *) break ;;
    esac
  done

  if [ "$APPLY" -eq 1 ]; then
    git -C "$BASE_REPO" checkout "$TARGET_BRANCH" >/dev/null
    git -C "$BASE_REPO" checkout -b "$inbox_branch" >/dev/null
    log "created inbox branch: $inbox_branch (from $TARGET_BRANCH)"
  else
    log "dry-run: would create inbox branch $inbox_branch from $TARGET_BRANCH"
  fi

  {
    echo "# Nightshift Inbox Manifest"
    echo
    echo "- generated_at_utc: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    echo "- target_branch: $TARGET_BRANCH"
    echo "- inbox_branch: $inbox_branch"
    echo "- apply: $APPLY"
    echo "- cherry_pick_head: $do_pick"
    echo
    echo "## candidates"
    echo
  } > "$manifest"

  for b in "${SOURCE_BRANCHES[@]}"; do
    if ! git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$b"; then
      echo "- $b: missing" >> "$manifest"
      continue
    fi
    local sha msg
    sha="$(git -C "$BASE_REPO" rev-parse "$b")"
    msg="$(git -C "$BASE_REPO" log -1 --pretty=format:'%h %s' "$b")"
    if git -C "$BASE_REPO" merge-base --is-ancestor "$sha" "$TARGET_BRANCH"; then
      echo "- $b: already-contained ($msg)" >> "$manifest"
      continue
    fi
    echo "- $b: candidate ($msg)" >> "$manifest"
    if [ "$APPLY" -eq 1 ] && [ "$do_pick" -eq 1 ]; then
      if git -C "$BASE_REPO" cherry-pick -x "$sha" >/dev/null 2>&1; then
        echo "  - cherry-pick: ok $sha" >> "$manifest"
      else
        echo "  - cherry-pick: conflict $sha" >> "$manifest"
        log "cherry-pick conflict on $b ($sha), resolve manually in $BASE_REPO"
        return 2
      fi
    fi
  done

  log "manifest written: $manifest"
  cat "$manifest"
}

backfill_from_inbox() {
  ensure_repo
  if [ -z "$FROM_BRANCH" ] || [ -z "$TO_BRANCH" ]; then
    echo "[nightshift-clear] ERROR: backfill requires --from and --to" >&2
    exit 2
  fi

  if ! git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$FROM_BRANCH"; then
    echo "[nightshift-clear] ERROR: missing from branch: $FROM_BRANCH" >&2
    exit 2
  fi
  if ! git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$TO_BRANCH"; then
    echo "[nightshift-clear] ERROR: missing to branch: $TO_BRANCH" >&2
    exit 2
  fi

  local commits
  commits="$(git -C "$BASE_REPO" rev-list --reverse "${TO_BRANCH}..${FROM_BRANCH}" || true)"
  if [ -z "$commits" ]; then
    log "no commits to backfill: $FROM_BRANCH -> $TO_BRANCH"
    return 0
  fi

  log "backfill plan: $FROM_BRANCH -> $TO_BRANCH"
  git -C "$BASE_REPO" log --oneline --reverse "${TO_BRANCH}..${FROM_BRANCH}"

  if [ "$APPLY" -eq 0 ]; then
    log "dry-run only. use --apply to execute cherry-pick."
    return 0
  fi

  git -C "$BASE_REPO" checkout "$TO_BRANCH" >/dev/null
  if git -C "$BASE_REPO" cherry-pick -x $commits; then
    log "backfill done: $FROM_BRANCH -> $TO_BRANCH"
  else
    log "backfill conflict: resolve manually in $BASE_REPO"
    return 3
  fi
}

if [ "$#" -lt 1 ]; then
  usage
  exit 1
fi

CMD="$1"
shift

while [ "$#" -gt 0 ]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --target) TARGET_BRANCH="${2:?}"; shift 2 ;;
    --from) FROM_BRANCH="${2:?}"; shift 2 ;;
    --to) TO_BRANCH="${2:?}"; shift 2 ;;
    *) break ;;
  esac
done

case "$CMD" in
  status) status_report ;;
  stop) stop_sessions ;;
  collect) collect_to_inbox "$@" ;;
  backfill) backfill_from_inbox ;;
  *) usage; exit 1 ;;
esac

