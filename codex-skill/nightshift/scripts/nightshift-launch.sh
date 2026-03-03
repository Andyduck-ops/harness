#!/bin/bash
# nightshift-launch.sh — 三件套启动 nightshift 持续学习（支持独立 worktree 隔离）

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BASE_REPO="${HARNESS_DIR:-$HOME/harness}"
STATE_DIR=".nightshift"
SKILL="nightshift"
LANE_ID="engineering"
LANE_ROOT="references/lanes/${LANE_ID}"
DIRECTIONS="${1:-Agent SDK 落地实战, AI 全栈可靠性边界, PRD 到产品信息保真, AI 代码有效测试, 长运行稳定性工程}"

# --- AUTO-INJECT RESEARCH SIGNALS ---
SIGNALS_FILE="$WORK_DIR/$LANE_ROOT/research-back-signals.md"
if [ -f "$SIGNALS_FILE" ]; then
    HIGH_PRIO_SIGNALS=$(grep -i "priority: HIGH" -B 2 "$SIGNALS_FILE" | grep "meta-question" | sed 's/.*meta-question: //g' | tr '\n' ',' | sed 's/,$//')
    if [ -n "$HIGH_PRIO_SIGNALS" ]; then
        echo "[nightshift] Detected HIGH priority research signals from Sleep: $HIGH_PRIO_SIGNALS"
        DIRECTIONS="$DIRECTIONS (深度攻坚: $HIGH_PRIO_SIGNALS)"
    fi
fi
# ------------------------------------

# 隔离配置（默认开启）
USE_WORKTREE="${NIGHTSHIFT_USE_WORKTREE:-1}"
WORKTREE_ROOT="${NIGHTSHIFT_WORKTREE_ROOT:-$HOME/harness-worktrees}"
WORKTREE_DIR="${NIGHTSHIFT_WORKTREE_DIR:-$WORKTREE_ROOT/engineering}"
WORKTREE_BRANCH="${NIGHTSHIFT_BRANCH:-nightshift/engineering}"

if [ ! -d "$BASE_REPO" ]; then
    echo "[ERROR] Base repo not found at $BASE_REPO"
    echo "Set HARNESS_DIR env var or clone the repo first."
    exit 1
fi

if [ "$USE_WORKTREE" = "1" ]; then
    if [ ! -d "$BASE_REPO/.git" ] && [ ! -f "$BASE_REPO/.git" ]; then
        echo "[ERROR] Base repo is not a git repository: $BASE_REPO"
        exit 1
    fi

    mkdir -p "$WORKTREE_ROOT"

    if [ -d "$WORKTREE_DIR/.git" ] || [ -f "$WORKTREE_DIR/.git" ]; then
        WORK_DIR="$WORKTREE_DIR"
    else
        if [ -e "$WORKTREE_DIR" ] && [ ! -d "$WORKTREE_DIR/.git" ] && [ ! -f "$WORKTREE_DIR/.git" ]; then
            echo "[ERROR] Worktree path exists but is not a git worktree: $WORKTREE_DIR"
            exit 1
        fi

        if git -C "$BASE_REPO" show-ref --verify --quiet "refs/heads/$WORKTREE_BRANCH"; then
            git -C "$BASE_REPO" worktree add "$WORKTREE_DIR" "$WORKTREE_BRANCH"
        else
            git -C "$BASE_REPO" worktree add -b "$WORKTREE_BRANCH" "$WORKTREE_DIR" HEAD
        fi
        WORK_DIR="$WORKTREE_DIR"
    fi
else
    WORK_DIR="$BASE_REPO"
fi

mkdir -p "$WORK_DIR/$STATE_DIR"
mkdir -p "$WORK_DIR/$LANE_ROOT/distilled" "$WORK_DIR/$LANE_ROOT/sources"

if [ ! -e "$WORK_DIR/$LANE_ROOT/patterns" ]; then
    mkdir -p "$WORK_DIR/$LANE_ROOT/patterns"
fi

if [ ! -f "$WORK_DIR/$LANE_ROOT/_master_index.md" ]; then
    cat > "$WORK_DIR/$LANE_ROOT/_master_index.md" <<'EOT'
# Engineering Pattern Master Index

（初始化完成，待 nightshift 运行填充）
EOT
fi

# 检查是否已在运行
for s in nightshift nightshift-watchdog nightshift-reporter; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "[nightshift] Session '$s' already running. Kill all first:"
        echo "  for s in nightshift nightshift-watchdog nightshift-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
        exit 1
    fi
done

PROMPT="$(cat <<EOT
\$nightshift

大方向:
$DIRECTIONS

在 $WORK_DIR 工作。读取现有 lane 知识地图，
只在 ${LANE_ROOT}/ 范围内读写（禁止修改其他 lane）。
读取 ${LANE_ROOT}/_master_index.md 识别空白区域，
组建 Scout+Analyst+Cartographer 团队，开始持续探索。

每轮更新 morning-brief.md，每轮 git commit。
不要 push。不要修改 PRD/ 和 generator/。跨 lane 只允许写 references/bridges/ 摘要。
直到我手动停止为止。
EOT
)"

echo "[nightshift] Starting three-piece daemon..."
echo "[nightshift] Directions: $DIRECTIONS"
echo "[nightshift] Base repo: $BASE_REPO"
echo "[nightshift] Working dir: $WORK_DIR"
if [ "$USE_WORKTREE" = "1" ]; then
    echo "[nightshift] Isolated branch: $WORKTREE_BRANCH"
fi
echo ""

# 1. Runner（主进程）
tmux new-session -d -s nightshift \
    "cd $WORK_DIR && codex exec --full-auto -s workspace-write \"$PROMPT\" 2>&1 | tee -a $STATE_DIR/session.log"
echo "[nightshift] Runner   → tmux attach -t nightshift"

# 2. Watchdog（看门狗）
tmux new-session -d -s nightshift-watchdog \
    "$SCRIPT_DIR/watchdog.sh nightshift $WORK_DIR $STATE_DIR $SKILL \"$DIRECTIONS\" 2>&1 | tee -a $WORK_DIR/$STATE_DIR/watchdog.log"
echo "[nightshift] Watchdog → tmux attach -t nightshift-watchdog"

# 3. Reporter（报告器）
tmux new-session -d -s nightshift-reporter \
    "$SCRIPT_DIR/reporter.sh $WORK_DIR $STATE_DIR $LANE_ID 2>&1 | tee -a $WORK_DIR/$STATE_DIR/reporter.log"
echo "[nightshift] Reporter → tmux attach -t nightshift-reporter"

echo ""
echo "[nightshift] All three sessions launched."
echo "[nightshift] Check progress:  cat $WORK_DIR/morning-brief.md"
echo "[nightshift] Reporter logs:   tail -f $WORK_DIR/$STATE_DIR/reporter.log"
echo "[nightshift] Stop all:        for s in nightshift nightshift-watchdog nightshift-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
