#!/bin/bash
# nightshift-launch.sh — 三件套启动 nightshift 持续学习
#
# 启动:
#   ./nightshift-launch.sh "AI agent 工作流, 知识管理, 代码质量"
#   ./nightshift-launch.sh  # 使用默认方向
#
# 停止:
#   tmux kill-session -t nightshift
#   tmux kill-session -t nightshift-watchdog
#   tmux kill-session -t nightshift-reporter
#   或一键: for s in nightshift nightshift-watchdog nightshift-reporter; do tmux kill-session -t $s 2>/dev/null; done

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_DIR="${HARNESS_DIR:-$HOME/harness}"
STATE_DIR=".nightshift"
SKILL="nightshift"
DIRECTIONS="${1:-Agent SDK 落地实战, AI 全栈可靠性边界, PRD 到产品信息保真, AI 代码有效测试, 长运行稳定性工程}"

# 确保 harness 仓库存在
if [ ! -d "$HARNESS_DIR" ]; then
    echo "[ERROR] Harness repo not found at $HARNESS_DIR"
    echo "Set HARNESS_DIR env var or clone the repo first."
    exit 1
fi

mkdir -p "$HARNESS_DIR/$STATE_DIR"

# 检查是否已在运行
for s in nightshift nightshift-watchdog nightshift-reporter; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "[nightshift] Session '$s' already running. Kill all first:"
        echo "  for s in nightshift nightshift-watchdog nightshift-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
        exit 1
    fi
done

# 构建 prompt
PROMPT="$(cat <<EOF
\$nightshift

大方向:
$DIRECTIONS

在 $HARNESS_DIR 工作。读取现有 references/patterns/ 知识地图，
识别空白区域，组建 Scout+Analyst+Cartographer 团队，开始持续探索。

每轮更新 morning-brief.md，每轮 git commit。
不要 push。不要修改 PRD/ 和 generator/。
直到我手动停止为止。
EOF
)"

echo "[nightshift] Starting three-piece daemon..."
echo "[nightshift] Directions: $DIRECTIONS"
echo "[nightshift] Working dir: $HARNESS_DIR"
echo ""

# 1. Runner（主进程）
tmux new-session -d -s nightshift \
    "cd $HARNESS_DIR && codex exec --full-auto -s workspace-write \"$PROMPT\" 2>&1 | tee -a $STATE_DIR/session.log"
echo "[nightshift] Runner   → tmux attach -t nightshift"

# 2. Watchdog（看门狗）
tmux new-session -d -s nightshift-watchdog \
    "$SCRIPT_DIR/watchdog.sh nightshift $HARNESS_DIR $STATE_DIR $SKILL \"$DIRECTIONS\" 2>&1 | tee -a $HARNESS_DIR/$STATE_DIR/watchdog.log"
echo "[nightshift] Watchdog → tmux attach -t nightshift-watchdog"

# 3. Reporter（报告器）
tmux new-session -d -s nightshift-reporter \
    "$SCRIPT_DIR/reporter.sh $HARNESS_DIR $STATE_DIR 2>&1 | tee -a $HARNESS_DIR/$STATE_DIR/reporter.log"
echo "[nightshift] Reporter → tmux attach -t nightshift-reporter"

echo ""
echo "[nightshift] All three sessions launched."
echo "[nightshift] Check progress:  cat $HARNESS_DIR/morning-brief.md"
echo "[nightshift] Reporter logs:   tail -f $HARNESS_DIR/$STATE_DIR/reporter.log"
echo "[nightshift] Stop all:        for s in nightshift nightshift-watchdog nightshift-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
