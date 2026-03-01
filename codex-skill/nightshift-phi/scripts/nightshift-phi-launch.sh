#!/bin/bash
# nightshift-phi-launch.sh — 三件套启动哲学方法论持续学习
#
# 启动:
#   ./nightshift-phi-launch.sh "系统论, 认识论, 决策论"
#   ./nightshift-phi-launch.sh  # 使用默认方向
#
# 停止:
#   for s in nightshift-phi nightshift-phi-watchdog nightshift-phi-reporter; do tmux kill-session -t $s 2>/dev/null; done

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PHI_DIR="${PHI_DIR:-$HOME/harness-phi}"
STATE_DIR=".nightshift-phi"
SKILL="nightshift-phi"
DIRECTIONS="${1:-系统论与控制论, 认识论与知识验证, 决策论, 复杂性科学与涌现, 精益与约束理论, 演化与适应, 中国哲学方法论}"
PROMPT_FILE="$PHI_DIR/$STATE_DIR/launch_prompt.txt"

# 初始化 harness-phi 仓库（如不存在）
if [ ! -d "$PHI_DIR" ]; then
    echo "[nightshift-phi] Initializing philosophy knowledge repo at $PHI_DIR..."
    mkdir -p "$PHI_DIR"
    cd "$PHI_DIR"
    git init
    mkdir -p references/patterns references/sources $STATE_DIR

    cat > references/patterns/_master_index.md << 'INDEXEOF'
# 哲学与方法论知识地图

> 提取人类智慧中的不变量。半衰期以十年计。

## Topics

（暂无——nightshift-phi 将自主探索并填充）
INDEXEOF

    cat > morning-brief.md << 'BRIEFEOF'
# Morning Brief — 哲学与方法论

> 最近 50 条发现。完整历史在 .nightshift-phi/briefs/

（等待 nightshift-phi 首次运行...）
BRIEFEOF

    git add -A
    git commit -m "Init harness-phi: philosophy & methodology knowledge base"
    echo "[nightshift-phi] Repo initialized."
fi

mkdir -p "$PHI_DIR/$STATE_DIR"

# 检查是否已在运行
for s in nightshift-phi nightshift-phi-watchdog nightshift-phi-reporter; do
    if tmux has-session -t "$s" 2>/dev/null; then
        echo "[nightshift-phi] Session '$s' already running. Kill all first:"
        echo "  for s in nightshift-phi nightshift-phi-watchdog nightshift-phi-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
        exit 1
    fi
done

# 构建 prompt（落盘，避免 shell 对 "$nightshift-phi" 发生二次展开）
cat > "$PROMPT_FILE" <<EOF
\$nightshift-phi

继续 nightshift-phi 循环，从当前 $STATE_DIR/state.json 的 cycle 断点继续。
严格遵循三角色协议：cartographer / scout / analyst。

大方向:
$DIRECTIONS

在 $PHI_DIR 工作。读取现有 references/patterns/ 知识地图，
识别空白区域，组建 Scout+Analyst+Cartographer 团队，开始持续探索。

核心目标：提取跨时代的元方法论——半衰期以十年计的不变量。
优先追溯原始著作和原始作者，而非二手解读。
学派矛盾写入 conflicts.md，不自动裁决。

每轮更新 morning-brief.md，每轮 git commit（不 push）。
不要修改 bedrock。不要修改业务源代码。
不要停，直到我手动停止为止。
EOF

echo "[nightshift-phi] Starting three-piece daemon..."
echo "[nightshift-phi] Directions: $DIRECTIONS"
echo "[nightshift-phi] Working dir: $PHI_DIR"
echo ""

# 1. Runner（主进程）
tmux new-session -d -s nightshift-phi \
    "cd $PHI_DIR && codex exec --full-auto -s workspace-write \"\$(cat $STATE_DIR/launch_prompt.txt)\" 2>&1 | tee -a $STATE_DIR/session.log"
echo "[nightshift-phi] Runner   → tmux attach -t nightshift-phi"

# 2. Watchdog（看门狗）
tmux new-session -d -s nightshift-phi-watchdog \
    "$SCRIPT_DIR/watchdog.sh nightshift-phi $PHI_DIR $STATE_DIR $SKILL \"$DIRECTIONS\" 2>&1 | tee -a $PHI_DIR/$STATE_DIR/watchdog.log"
echo "[nightshift-phi] Watchdog → tmux attach -t nightshift-phi-watchdog"

# 3. Reporter（报告器）
tmux new-session -d -s nightshift-phi-reporter \
    "$SCRIPT_DIR/reporter.sh $PHI_DIR $STATE_DIR 2>&1 | tee -a $PHI_DIR/$STATE_DIR/reporter.log"
echo "[nightshift-phi] Reporter → tmux attach -t nightshift-phi-reporter"

echo ""
echo "[nightshift-phi] All three sessions launched."
echo "[nightshift-phi] Check progress:  cat $PHI_DIR/morning-brief.md"
echo "[nightshift-phi] Reporter logs:   tail -f $PHI_DIR/$STATE_DIR/reporter.log"
echo "[nightshift-phi] Stop all:        for s in nightshift-phi nightshift-phi-watchdog nightshift-phi-reporter; do tmux kill-session -t \$s 2>/dev/null; done"
