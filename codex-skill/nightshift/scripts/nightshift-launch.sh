#!/bin/bash
# nightshift-launch.sh — 后台启动 nightshift 持续学习
#
# 用法:
#   ./nightshift-launch.sh "AI agent 工作流, 知识管理, 代码质量"
#   ./nightshift-launch.sh  # 使用默认方向
#
# 停止:
#   tmux kill-session -t nightshift
#   或 tmux attach -t nightshift 然后 Ctrl+C

set -euo pipefail

HARNESS_DIR="${HARNESS_DIR:-$HOME/harness}"
DIRECTIONS="${1:-AI agent workflows, knowledge management systems, code quality enforcement}"

# 确保 harness 仓库存在
if [ ! -d "$HARNESS_DIR" ]; then
    echo "[ERROR] Harness repo not found at $HARNESS_DIR"
    echo "Set HARNESS_DIR env var or clone the repo first."
    exit 1
fi

# 确保 .nightshift 目录存在
mkdir -p "$HARNESS_DIR/.nightshift"

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

echo "[nightshift] Starting continuous learning daemon..."
echo "[nightshift] Directions: $DIRECTIONS"
echo "[nightshift] Working dir: $HARNESS_DIR"
echo "[nightshift] Check progress: cat $HARNESS_DIR/morning-brief.md"
echo "[nightshift] Stop: tmux kill-session -t nightshift"
echo ""

# 用 tmux 后台运行
if tmux has-session -t nightshift 2>/dev/null; then
    echo "[nightshift] Session already running. Kill it first:"
    echo "  tmux kill-session -t nightshift"
    exit 1
fi

tmux new-session -d -s nightshift \
    "cd $HARNESS_DIR && codex exec --full-auto -s workspace-write \"$PROMPT\" 2>&1 | tee .nightshift/session.log"

echo "[nightshift] Launched in tmux session 'nightshift'"
echo "[nightshift] Attach: tmux attach -t nightshift"
echo "[nightshift] Logs:   tail -f $HARNESS_DIR/.nightshift/session.log"
