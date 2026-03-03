---
name: nightshift
description: |
  持续自主学习守护进程。给定几个大方向，Agent Team 自主探索、发现、蒸馏、验证，
  动态填充知识地图。无时间上限，人叫停才停。
hooks:
  stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/stop-guard.py"
  subagent_stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/stop-guard.py"
  pre_tool_use:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/saturation-guard.py"
  pre_compact:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/pre-compact-compress.py"
---

# Nightshift — 持续自主学习守护进程

> **不知疲倦的知识制图者。给几个大方向，自己探索整片大陆。**

---

## Lane Namespace（硬约束）

- lane_id: **engineering**
- 默认读写范围：`references/lanes/engineering/`
- 跨 lane 只允许写：`references/bridges/` 摘要
- 禁止直接写：`references/patterns/`、`references/sources/`（旧路径）
- 可与 `nightshift-phi` 并跑，彼此状态与知识仓隔离

---

## Step 0: 初始化

读取项目状态：

1. 检查 `$CWD` 是否有 `.harness/` 或 harness 仓库结构
2. 读取现有知识地图：
   - `references/lanes/engineering/_master_index.md` — 已有 patterns
   - `references/lanes/engineering/sources/{topic}.yaml` — 信源信誉带
3. **关键：读取研究令 (Research Back Signals)**：
   - 检查并读取同目录下的 `research-back-signals.md`。
   - 如果存在标记为 `HIGH` 优先级的信号（通常由 `Sleep` 进程生成），**必须**将其优先注入本轮探索方向。
4. 从用户 prompt 提取**大方向**（seeds）
5. 创建 `.nightshift/` 目录（如不存在）

---

## Step 1: 组建 Team

使用 `spawn_team` 创建三角色团队：
- Cartographer: `gpt-5.3-codex` (Lead, 拓扑决策)
- Scout: `gpt-5.2` (搜索探索)
- Analyst: `gpt-5.3-codex` (第一性原理验证)

---

## Step 2: Cartographer 启动循环

Cartographer 读取 `_master_index.md` 和 `research-back-signals.md`，进行**空白识别与逻辑补齐**：

| 信号 | 含义 |
|------|------|
| `research-back-signals` (HIGH) | **[最高优先级]** Sleep 发现的逻辑断层，必须优先攻坚 |
| topic 目录下 < 3 patterns | 薄弱区域，优先探索 |
| 多个 `[CONFLICT]` 标记 | 争议区域，需要更多证据 |
| pattern 证据链普遍偏弱 | 低稳健区域，需要补证与重构 |

---

## Step 3: Scout 探索循环

Scout 持续执行搜索。对于来自 `research-back-signals` 的任务，必须在搜索 Prompt 中包含：*“针对 Sleep 进程发现的逻辑断层 [元问题 ID]，寻找能够填补空缺或解释矛盾的核心证据。”*

---

## Step 4: Analyst 验证循环

Analyst 在进行 `Distill` 时，如果新发现填补了 `research-back-signals` 中的缺口，**必须**在输出中标记 `[LOGIC_RECOVERY]`，并明确指出该发现如何增强了方法论的鲁棒性。

---

## Step 5: Rank & Merge（Cartographer 执行）

在 Merge 之后，Cartographer 需要更新 `research-back-signals.md` 的状态：
- 如果某个信号对应的缺口已被填补，将其标记为 `DONE`。
- 如果发现新的逻辑矛盾，追加新信号。

---

## Step 6: Morning Brief 增量更新

在 `morning-brief.md` 中，优先列出 `[LOGIC_RECOVERY]` 类的发现。这代表了系统**“智慧”**的增长，而不仅仅是信息的累加。

---

## 安全边界

### CAN do
- 读写 `references/lanes/engineering/` 及其子目录
- 更新 `research-back-signals.md` 的状态
- 写入 `morning-brief.md`
- Git commit（不 push）

### CANNOT do
- 修改 `PRD/` 和 `bedrock/`（除通过人工审计）
- 忽略 `research-back-signals.md` 中的高优先级指令
- 修改项目业务代码
