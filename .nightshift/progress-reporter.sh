#!/usr/bin/env bash
set -u
set -o pipefail

HARNESS_DIR="/home/eric/harness"
NS_DIR="$HARNESS_DIR/.nightshift"
REPORT_FILE="$NS_DIR/progress-report.md"
LATEST_FILE="$NS_DIR/progress-latest.md"
REPORTER_LOG="$NS_DIR/reporter.log"
INTERVAL_SECONDS=1200

mkdir -p "$NS_DIR"

now_iso(){ date -u +"%Y-%m-%dT%H:%M:%SZ"; }
now_local(){ date +"%Y-%m-%d %H:%M:%S %Z"; }

log(){ echo "[$(now_iso)] $*" >> "$REPORTER_LOG"; }

file_age(){
  local f="$1"
  if [[ ! -f "$f" ]]; then echo "NA"; return; fi
  echo $(( $(date +%s) - $(stat -c %Y "$f" 2>/dev/null || echo 0) ))
}

snapshot(){
  local ns wd
  tmux has-session -t nightshift 2>/dev/null && ns="RUNNING" || ns="STOPPED"
  tmux has-session -t nightshift-watchdog 2>/dev/null && wd="RUNNING" || wd="STOPPED"

  local cycle updated
  read -r cycle updated < <(python3 - <<'PY'
import json,os
p='/home/eric/harness/.nightshift/state.json'
if not os.path.exists(p):
    print('NA NA')
else:
    d=json.load(open(p,encoding='utf-8'))
    print(d.get('cycle','NA'), d.get('updated_at','NA'))
PY
)

  local last_commit
  last_commit="$(git -C "$HARNESS_DIR" log -1 --format='%h %s' 2>/dev/null || echo 'NA')"

  cat <<TXT
## [$(now_iso)] Nightshift 20min 检查
- 本地时间: $(now_local)
- 会话状态: nightshift=${ns}, watchdog=${wd}
- 日志年龄(s): session=$(file_age "$NS_DIR/session.log"), runner=$(file_age "$NS_DIR/runner.log"), watchdog=$(file_age "$NS_DIR/watchdog.log"), reporter=$(file_age "$NS_DIR/reporter.log")
- 状态文件: cycle=${cycle}, updated_at=${updated}
- 最近提交: ${last_commit}
TXT
}

log "Reporter started (interval=${INTERVAL_SECONDS}s)"
while true; do
  S="$(snapshot)"
  echo "$S" > "$LATEST_FILE"
  { echo "$S"; echo; [[ -f "$REPORT_FILE" ]] && cat "$REPORT_FILE"; } | awk 'NR<=450' > "$REPORT_FILE.tmp" && mv "$REPORT_FILE.tmp" "$REPORT_FILE"
  log "CHECK: snapshot written"
  sleep "$INTERVAL_SECONDS"
done
