#!/bin/bash
# reconcile-nightshift-lanes.sh — 合并、同步并执行“知识脱壳 (Clear & Refill)”
#
# 核心逻辑：
# 1) 将各 Lane 分支（证据层）合并到主分支（main）。
# 2) [自动脱壳]：扫描 main 中的 distilled/，识别已“毕业”的原始知识。
# 3) [回灌同步]：将 main（含最新芯片）回灌到各 Lane 分支，并清理已消化文件。

set -euo pipefail

BASE_REPO="${BASE_REPO:-$HOME/harness}"
MAIN_BRANCH="${MAIN_BRANCH:-main}"

ENG_BRANCH="${ENG_BRANCH:-nightshift/engineering}"
ENG_WORKTREE="${ENG_WORKTREE:-$HOME/harness-worktrees/engineering}"

PHI_BRANCH="${PHI_BRANCH:-nightshift/philosophy}"
PHI_WORKTREE="${PHI_WORKTREE:-$HOME/harness-worktrees/philosophy}"

PUSH="${PUSH:-0}"
RELAXED_CLEAN="${RELAXED_CLEAN:-1}"

log() {
  echo "[harness-reconcile] $*"
}

# --- 核心自动化：知识脱壳 (The Clear Logic) ---
perform_pruning() {
  local lane="$1"
  local branch="$2"
  local wt="$3"
  local lane_root="references/lanes/$lane"

  log "正在为 $lane 执行知识脱壳..."

  # 1. 查找已蒸馏的芯片溯源 (Provenance)
  # Sleep 生成的芯片会在 _provenance/ 记录它是从哪些 pattern 编译来的
  local prov_dir="$BASE_REPO/$lane_root/distilled/_provenance"
  if [ ! -d "$prov_dir" ]; then
    log "$lane 没有可用的溯源目录，跳过脱壳。"
    return
  fi

  # 提取所有被引用的原始 pattern 文件名
  local patterns_to_clear
  patterns_to_clear=$(grep -h "source_pattern:" "$prov_dir"/*.md 2>/dev/null | sed 's/.*source_pattern: //g' | sort -u)

  if [ -n "$patterns_to_clear" ]; then
    log "发现已毕业的 Pattern，准备从工作分支清理: "
    echo "$patterns_to_clear" | sed 's/^/  - /'

    for p in $patterns_to_clear; do
      local p_path="$wt/$lane_root/patterns/$p"
      if [ -f "$p_path" ]; then
        log "清理毕业知识: $p"
        git -C "$wt" rm -f "$lane_root/patterns/$p" || rm -f "$p_path"
      fi
    done
    
    # 提交脱壳变更
    git -C "$wt" commit -m "chore(clear): 自动脱壳已毕业的原始证据 [auto-clear]" || true
  else
    log "$lane 暂时没有需要清理的毕业知识。"
  fi
}

# --- 辅助函数 ---
ensure_clean() {
  local repo="$1"
  # 忽略运行态目录改动
  local dirty
  dirty=$(git -C "$repo" status --porcelain | grep -v ".nightshift" || true)
  if [ -n "$dirty" ]; then
    log "ERROR: 仓库不洁净: $repo"
    echo "$dirty"
    exit 1
  fi
}

merge_and_reconcile() {
  local lane="$1"
  local branch="$2"
  local wt="$3"

  log ">>> 处理通道: $lane"
  
  # 1. Lane -> Main (收割证据)
  log "merge $branch -> $MAIN_BRANCH"
  git -C "$BASE_REPO" checkout "$MAIN_BRANCH"
  git -C "$BASE_REPO" merge --no-ff --no-edit "$branch"

  # 2. 自动化脱壳 (在合并回灌前执行)
  if [ -d "$wt" ]; then
    perform_pruning "$lane" "$branch" "$wt"
    
    # 3. Main -> Lane (回灌芯片与基石)
    log "merge $MAIN_BRANCH -> $branch (回灌)"
    git -C "$wt" checkout "$branch"
    git -C "$wt" merge --no-ff --no-edit "$MAIN_BRANCH"
  fi
}

# --- 主流程 ---
ensure_clean "$BASE_REPO"

# 依次处理各通道
merge_and_reconcile "engineering" "$ENG_BRANCH" "$ENG_WORKTREE"
merge_and_reconcile "philosophy" "$PHI_BRANCH" "$PHI_WORKTREE"

# 4. 全局索引对账
log "更新全局索引..."
# 这里可以调用一个专门的索引同步脚本（如果以后有的话）

if [ "$PUSH" = "1" ]; then
  log "Pushing changes..."
  git -C "$BASE_REPO" push origin "$MAIN_BRANCH" "$ENG_BRANCH" "$PHI_BRANCH"
fi

log "✅ 闭环同步与脱壳完成。"
