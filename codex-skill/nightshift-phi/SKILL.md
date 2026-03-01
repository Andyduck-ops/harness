---
name: nightshift-phi
description: |
  哲学与方法论持续学习守护进程。探索人类智慧中的不变量——系统论、认识论、决策论、
  复杂性科学、精益思想等。提取跨时代的元方法论，半衰期以十年计。
hooks:
  stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift-phi/scripts/stop-guard.py"
  subagent_stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift-phi/scripts/stop-guard.py"
  pre_tool_use:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift-phi/scripts/saturation-guard.py"
  pre_compact:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift-phi/scripts/pre-compact-compress.py"
---

# Nightshift-Phi — 哲学与方法论持续学习守护进程

> **提取人类智慧中的不变量。半衰期以十年计的知识，才值得系统化学习。**

---

## 与 nightshift 的关系

| | nightshift | nightshift-phi |
|---|---|---|
| **领域** | AI 工程实践 | 哲学与方法论 |
| **半衰期** | 1-3 年 | 10-100 年 |
| **目标** | 怎么做（How） | 为什么这样做（Why） |
| **消费场景** | 具体实现时检索 | 决策和思考时检索 |
| **架构** | 共享 L1-L7 约束 | 共享 L1-L7 约束 |

两个 skill 完全独立运行，知识库物理隔离。跨域关联在人审核时发现。

---

## 激活

直接对话模式或 codex exec 非交互模式。

---

## Step 0: 初始化

读取项目状态：

1. 检查 `$CWD` 是否有 harness 仓库结构
2. 读取现有知识地图：
   - `references/patterns/_master_index.md` — 已有 patterns
   - `references/sources/{topic}.yaml` — 信源评分
   - `.nightshift-phi/state.json` — 上次状态（如存在，断点续传）
3. 从用户 prompt 提取**大方向**（seeds）
4. 创建 `.nightshift-phi/` 目录（如不存在）

---

## Step 1: 组建 Team

使用 `spawn_team` 创建三角色团队：

| 角色 | 职责 | 模型 |
|------|------|------|
| cartographer | 知识制图、方向决策、压缩合并 | gpt-5.3-codex |
| scout | 搜索探索、信源采集 | gpt-5.2 |
| analyst | 第一性原理验证、蒸馏 | gpt-5.3-codex |

通过 agent role config 实现模型差异化：
- `~/.codex/agents/scout.toml` 中设置 `model = "gpt-5.2"`
- cartographer 和 analyst 继承全局 `gpt-5.3-codex`

---

## Step 2: Cartographer 启动循环

Cartographer 是 Lead，执行持续循环。

**状态一致性要求**：每轮 cycle 开始时，必须写 `state.json` 的 `status: "running"`；cycle 结束（commit 后）写 `status: "idle"`。合法停止时写 `status: "paused"` 或 `status: "exhausted"`。Watchdog 依赖此字段判断进程状态。

### 知识地图分析（空白识别）

Cartographer 读取 `_master_index.md`，对每个 topic 目录评估：

| 信号 | 含义 |
|------|------|
| topic 目录下 < 3 patterns | 薄弱区域，优先探索 |
| 最近 10 轮无新 pattern | 停滞区域，换角度探索 |
| 多个 `[CONFLICT]` 标记 | 学派争议，需要更多证据 |
| 用户大方向未覆盖 | 全新区域，初始探索 |
| pattern 平均 confidence < 0.6 | 低置信区域，需要更多验证 |

### 探索指令格式

Cartographer → Scout 的消息包含：方向、搜索角度、已知 patterns（避免重复）。

---

## Step 3: Scout 探索循环

Scout 持续执行搜索。

### Scout 的关键行为

- **追溯源头**：优先找原始著作和原始作者，而非二手解读
- **跨文化**：同一方法论在东西方可能有不同表述（如精益 vs 丰田生产方式）
- **历史脉络**：追踪思想的演化链（谁影响了谁）
- **意外发现（Serendipity）**：与当前方向无关但有价值的内容，标记 `[SERENDIPITY]`
- **去重**：跳过 `sources/{topic}.yaml` 中 score < 0.4 的信源

### 搜索偏好

| 优先级 | 信源类型 | 示例 |
|--------|---------|------|
| 高 | 原始著作/论文 | Meadows《系统之美》、Boyd OODA 原文 |
| 高 | 经典教材 | 《第五项修炼》、《反脆弱》 |
| 中 | 一手实践报告 | Toyota Way 实际案例、NASA 事故报告 |
| 中 | 高质量综述 | Stanford Encyclopedia of Philosophy |
| 低 | 二手解读文章 | 博客、Medium 文章 |
| 忽略 | 纯观点无证据 | "我觉得 XX 很重要" |

---

## Step 4: Analyst 验证循环

### Analyze 检查表

| 检查 | 通过 | 未通过 |
|------|------|--------|
| 与 bedrock 原理一致？ | 继续 | `[BEDROCK_CONFLICT]` → conflicts.md |
| 不是已有 pattern 的重复？（L2 同化检查） | 新建 | **默认合并**为已有 pattern 的变体 |
| 有实际证据（历史案例/实验/数学证明）？ | 继续 | 降级为 low confidence |
| 可迁移（能应用到具体决策/设计）？ | 继续 | `[PURE_ABSTRACTION]`，降 rank |
| 检索测试通过？（L5：什么决策场景会用到？） | 继续 | 不入库 |
| 关于 meta-framework 自身？ | `[SELF_MODIFY]` | — |

### Distill 核心原则

> 不同思想家说的往往是同一个元问题的不同表述。
> Distill 的核心任务是**找到跨学派的元问题**，而非堆积各家观点。
> 同一元问题只保留一条 pattern，包含所有学派的表述变体。

**同化优先**：新发现默认归入已有 pattern，除非能证明解决了全新的具体问题。
**检索信噪比**：同化前问「搜这个问题命中目标 pattern 能直接得到答案吗？」跨元问题维度不同化。
**检索测试**：写完自问"面对什么决策时会查这个？"——模糊则不入库。

---

## Step 5: Rank & Merge（Cartographer 执行）

收到 Analyst 的验证结果后，**必须按以下顺序执行**：

### 5a: 饱和门检查（L1）

该 topic 已有 ≥5 patterns？→ 必须先 merge 已有 patterns 腾出空间，才能继续。

### 5b: 同化优先（L2）

对新发现执行 3 问比较：
1. 列出它能应用的 3 个具体决策/设计场景
2. 已有 patterns 能覆盖吗？
3. 判定：全覆盖→更新 sources；部分覆盖→合并；全新→创建

**信噪比检查**：同化前问「搜这个问题命中目标 pattern 能直接得到答案吗？」
跨元问题维度 → 不同化，创建或归入更合适的 topic。

### 5c: 检索测试（L5）

新 pattern 写完后立即自测："面对什么决策时会查这个？能得到什么具体指导？"
回答模糊或重复 → 不入库。

### 5d: 执行写入

- **同化** → 更新已有 pattern 的 sources 和学派变体
- **创建** → 新建 pattern 文件 + 原子 4 层索引更新
- **矛盾** → 写入 conflicts.md，不自动解决（学派争议尤其不可自动裁决）
- **Serendipity** → 评估是否开辟新 topic（需 L3 方向上限检查）

信源评分更新：
- 产出有用 finding → score 提升（上限 high）
- 大部分是 noise → score 降低（下限 low）
- 无新内容 → 不变

---

## Step 6: Morning Brief 增量更新

### 滚动窗口策略（防 24h 膨胀）

**`morning-brief.md` 只保留最近 50 条**，旧条目自动归档。

每轮 Merge 后：
1. 追加新条目到 `morning-brief.md` 头部
2. 如果超过 50 条 → 尾部溢出条目移入 `.nightshift-phi/briefs/{date}.md`
3. 人随时打开 morning-brief.md 都是**最近 50 条**
4. 完整历史在 `.nightshift-phi/briefs/` 按日期分文件

---

## Step 7: Decay Sweep（每 10 轮）

Cartographer 每 10 个 cycle 执行一次：

1. 扫描所有 patterns，找连续 10 cycles 无引用无更新的 → 标记 dormant
2. 已 dormant 超过 30 cycles → 移入 `archive/`
3. 更新 `_master_index.md`
4. **不使用时间（天/月），使用 cycle 计数**——运行频率不固定

---

## 停止条件

| 条件 | 行为 |
|------|------|
| **人主动停止**（Ctrl+C / 发消息） | 写最终 brief → commit → close_team → 退出 |
| **连续 5 次 Scout 错误** | 写 `[INTERRUPTED]` brief → commit → 退出 |
| **所有方向 + 二级探索穷尽** | 写 `[EXHAUSTED]` brief → 等待新指令 |
| **Git 冲突 / 磁盘满** | 写错误日志 → 退出 |

**没有时间上限。** 可以跑一晚上，也可以跑一周。

stop-guard.py hook 确保 agent 不会因为"觉得做完了"而自行退出——
只有上述 4 个条件才是合法的停止理由。

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|--------|-------|
| WebSearch / WebFetch | 只读，搜索和读取 |
| 创建/更新 references/patterns/ | 知识库写入 |
| 创建/更新 references/sources/{topic}.yaml | 信源评分（按 topic 分） |
| 移动 patterns 到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量报告 |
| 写 .nightshift-phi/ 日志和状态 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### CANNOT do（硬性禁止）

| 操作 | 原因 |
|--------|--------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目源代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 删除非 archive 的 patterns | 防止误删 |
| **裁决学派争议** | 学派矛盾写入 conflicts.md，人裁决 |

---

## 状态持久化 & 分形索引架构

**24h 连续运行 ≈ 300-480 轮。必须有分形多层索引 + 膨胀控制。**

### 核心原则：渐进披露（Progressive Disclosure）

每一层都是下一层的摘要，每一层都自包含可读。
人在任何层级停下来都能获得完整的理解，往下钻才看到更多细节。

### 层间一致性规则

**每次写入 Level 3（pattern）时，必须同步更新 Level 2 和 Level 1：**

1. 写入/更新 `{topic}/{pattern}.md` (L3)
2. 更新 `{topic}/_index.md` (L2) — 添加或更新该 pattern 行
3. 更新 `_master_index.md` (L1) — 更新该 topic 的统计摘要
4. 追加 `morning-brief.md` (L0) — 添加新发现条目

**这是原子操作——4 层全更新后才 git commit。**

### 膨胀控制规则

| 层级 | 文件 | 上限 | 触发动作 |
|------|------|------|----------|
| L0 | `morning-brief.md` | 50 条 | 溢出 → `.nightshift-phi/briefs/{date}.md` |
| L1 | `_master_index.md` | 每 topic ≤ 8 行 | topic 太多 → 分组 |
| L2 | `{topic}/_index.md` | 5 patterns/topic（L1 饱和门） | 超限 → 先 merge，非拆分 |
| L3 | `{pattern}.md` | 300 行 | 拆分为子 pattern（同目录） |
| L4 | `sources/{topic}.yaml` | 50 条 | 低分归档 → `sources/archive/` |
| — | `state.json` | 覆盖式 | 永远 < 5KB |

### Cartographer 健康检查（每 5 轮）

1. **压缩周期（L4）**：遍历所有 topics，merge 可合并的 patterns，跨 topic 去重
2. 检查各层文件大小 → 触发归档
3. 验证层间一致性 → L2 每条都能指向 L3 文件
4. **饱和扫描**：哪些 topic 接近 5 pattern 上限？提前规划 merge

---

## Pattern 格式（哲学方法论适配）



---

## 学习原则（Anti-Governance-Recursion）

> **来自 nightshift v1 的教训：87 cycles 产出 103 个碎片 pattern。**
> **76 个碎片 pattern 本质是同一主题的不同切面。根因是只 split 不 merge。**

以下 7 条原则是硬约束，Cartographer 必须在每个 cycle 遵守。

### L1: 学习是压缩不是积累（饱和门）

**per-topic pattern 上限 = 5。** 超过 5 个时，必须先 merge 再添加。
新 pattern 必须证明它和已有 5 个解决的是不同的具体问题。

### L2: 默认同化，例外创建（Assimilate-First）

发现新信息后，Cartographer 必须先执行 3 问比较：

1. 列出新发现能应用的 3 个具体决策/设计场景
2. 逐个检查：已有 patterns 能覆盖这些场景吗？
3. 判定：
   - 3 个场景全部已被覆盖 → **不入库**，更新已有 pattern 的 sources
   - 1-2 个场景已覆盖 → **合并**到最相关的已有 pattern
   - 3 个场景全新 → **创建**新 pattern

**默认路径是同化，不是创建。**

**检索信噪比约束**：同化的目标是让未来检索更高效，不是减少文件数。
判断是否同化时，问："有人搜这个问题时，命中这个 pattern 能直接得到答案吗？"
- 同 topic 同元问题 → 同化（信噪比不变或提升）
- 跨 topic 或不同元问题维度 → 优先创建新 pattern（避免信噪比下降）
- 一个 pattern 不应承载超过一个元问题——否则它变成噪声源而非知识源

### L3: 注意力有限（方向上限）

**active_directions 硬上限 = 15。**
- 新方向只能从 dormant 槽位释放或 serendipity 产生
- 无空槽时，必须先收缩或合并一个方向

### L4: 周期性压缩（Compression Cycle）

**每 5 cycles 强制执行一次压缩：**
1. 遍历所有 topics，找可合并的 patterns → merge
2. 跨 topic 检查：本质相同但散在不同 topic 的 → 合并或重新归类
3. 输出 compression_report（合并了什么、为什么）

这模拟人脑睡眠时的 replay + compression。

### L5: 检索测试 + 功能去重

新 pattern 写完后，立即自测：

> "面对什么决策/设计选择时，我会查这个 pattern？查了能得到什么具体指导？"

- 如果回答模糊 → pattern 不够具体，不入库
- 如果回答和已有 pattern 重复 → 同化到已有 pattern
- 如果能给出已有 pattern 无法覆盖的具体指导 → 入库

### L6: 显式衰减

- 10 cycles 无引用无更新 → 标记 dormant
- 30 cycles 仍 dormant → 移入 archive/
- 不使用时间（天/月），使用 cycle 计数——因为运行频率不固定

### L7: 不量化不可量化的

- **可量化的**：pattern 数量、cycle 数、source 个数、方向数量
- **不可量化的**："相似度"、"重要性"、"新颖程度"
- 不可量化的东西用**功能性判断**替代数值判断
- confidence 分数只保留粗粒度（高/中/低），不伪精确到小数点
