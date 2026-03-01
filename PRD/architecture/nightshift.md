# Nightshift — 持续自主学习守护进程

## 设计目标

Agent 持续冲浪学习，每轮 3-5 分钟，直到人主动停止。
morning-brief.md 增量更新，人随时打开都能看到最新进展。

**不是批处理任务，是持续运行的学习守护进程。**

---

## 两个 Nightshift 的关系

Harness 有两个独立的 nightshift 实现：

| | nightshift | nightshift-phi |
|---|---|---|
| **领域** | AI 工程实践 | 哲学与方法论 |
| **半衰期** | 1-3 年 | 10-100 年 |
| **目标** | 怎么做（How） | 为什么这样做（Why） |
| **消费场景** | 具体实现时检索 | 决策和思考时检索 |
| **架构** | 共享 L1-L7 约束 | 共享 L1-L7 约束 |

两个 skill 完全独立运行，知识库物理隔离。跨域关联在人审核时发现。

---

## 执行模型

### 三角色 Team 架构

使用 `spawn_team` 创建三角色团队：

| 角色 | 职责 | 模型 |
|------|------|------|
| cartographer | 知识制图、方向决策、压缩合并 | gpt-5.3-codex |
| scout | 搜索探索、信源采集 | gpt-5.2 |
| analyst | 第一性原理验证、蒸馏 | gpt-5.3-codex |

**Cartographer 是 Lead**，执行持续循环。

### 持续循环（非批处理）

Cartographer 读取知识地图 → 识别空白 → 指派 Scout 探索 → Scout 搜索信源 → Analyst 验证蒸馏 → Cartographer 合并压缩 → 更新 morning-brief → Git commit → 下一轮

**没有时间上限。** 世界是运动与变化的，学习不应有人为截止时间。

### 目标选择策略（轮转）

1. sources.yaml 中分数最高、距上次扫描最久的信源
2. 信源扫完 → 二级探索（从 pattern 关键词出发搜索新信源）
3. 二级也穷尽 → 等待/退出（极少发生）

---

## 每个学习单元

| 步骤 | 耗时 | 动作 |
|------|------|------|
| Scout | 1-2 min | WebFetch/WebSearch 信源，提取 findings |
| Distill | 1 min | 压缩为 Skill 格式，找到元问题 |
| Analyze | 1 min | 对照 bedrock 验证，评分 |
| Rank+Merge | <1 min | 写入/合并 patterns，更新 index |
| Brief | <1 min | 增量追加 morning-brief.md |

可并行：Scout A 和 Distill+Analyze B 交错执行。

---

## Morning Brief 格式

`$HARNESS_HOME/morning-brief.md`（增量追加，人随时可看）：



---

## 执行环境

### Claude Code



### Codex



---

## 停止条件

| 条件 | 行为 |
|------|------|
| 人主动停止 | 写最终 brief → commit → 退出 |
| 连续 5 次错误 | 写 `[INTERRUPTED]` brief → commit → 退出 |
| 所有信源 + 二级探索穷尽 | 写 `[EXHAUSTED]` brief → commit → 等待 |
| Git 冲突 / 磁盘满 | 写错误日志 → 退出 |

---

## 安全边界

### 可以做（自主执行）

| 操作 | 说明 |
|------|------|
| WebFetch / WebSearch | 读取信源内容 |
| 创建/更新 references/ | 知识库更新 |
| 创建/更新 patterns/ | 模式更新 |
| 移动到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量简报 |
| 写 .nightshift/ 日志 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### 不可以做（硬性禁止）

| 操作 | 原因 |
|------|------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 发消息 / 创建 PR | 不打扰人 |
| 删除非 archive 的 patterns | 防止误删 |

---

## 质量保障

### 防止知识污染

1. **Noise Filter**: Distill 标记 [NOISE] 的直接丢弃
2. **Confidence Threshold**: < 0.4 不写入 patterns/
3. **Conflict Detection**: 矛盾写入 conflicts.md，不自动解决
4. **Bedrock Guard**: 与核心原理冲突 → 不写入，等人处理

### 防止膨胀

1. **Merge 压缩**: 同构知识强制合并
2. **Decay 机制**: 90 天无引用 → 分数衰减 → 归档
3. **总量控制**: patterns/ > 100 条时触发强制合并
4. **质量控制**: 靠 Analyze 阶段的第一性原理验证，不靠字数限制

### 防止自迭代失控

1. **有界自改进**: 只改知识获取/处理方式，不改核心原则
2. **[SELF_MODIFY] 标签**: morning brief 高亮
3. **回滚能力**: 所有变更通过 git commit，可随时回退

---

## 学习原则（Anti-Governance-Recursion）

> **来自 nightshift 第一轮运行的教训：87 cycles，103 patterns 膨胀到 33 topics。**
> **76 个碎片 pattern 本质是同一主题的不同切面。根因是只 split 不 merge。**

以下 7 条原则是硬约束，Cartographer 必须在每个 cycle 遵守。

### L1: 学习是压缩不是积累（饱和门）

**per-topic pattern 上限 = 5。** 超过 5 个时，必须先 merge 再添加。
新 pattern 必须证明它和已有 5 个解决的是不同的具体问题。

### L2: 默认同化，例外创建（Assimilate-First）

发现新信息后，Cartographer 必须先执行 3 问比较：

1. 列出新发现能解决的 3 个具体场景
2. 逐个检查：已有 patterns 能解决这些场景吗？
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

---

## 与 calibrate 的关系

| 命令 | 触发 | 范围 | 持续 |
|------|------|------|------|
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** |
| `/harness:calibrate` | 手动，白天 | 聚焦 1 个 URL/topic | ~20 min |
| `/harness:init` 内置 | 新项目初始化 | 最近 7 天轻量检查 | ~10 min |

nightshift 是持续学习守护进程，calibrate 是按需定向校准。
