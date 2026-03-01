# /harness:nightshift — 持续自主学习守护进程

持续冲浪学习，直到人主动停止。每轮 3-5 分钟。
morning-brief.md 增量更新，人随时打开都能看到最新进展。

**无时间上限。持续运行。人叫停才停。**

---

## When to Use

- 睡前启动：`/harness:nightshift` → 挂着，早上看 morning-brief.md
- 任何空闲时间：开个终端挂着，让 agent 持续学习
- 白天也可以跑——不限于夜间

---

## Prerequisites



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

## 执行模型：三角色 Team 架构

### Step 1: 组建 Team

使用 `spawn_team` 创建三角色团队：

| 角色 | 职责 | 模型 |
|------|------|------|
| cartographer | 知识制图、方向决策、压缩合并 | gpt-5.3-codex |
| scout | 搜索探索、信源采集 | gpt-5.2 |
| analyst | 第一性原理验证、蒸馏 | gpt-5.3-codex |

**Cartographer 是 Lead**，执行持续循环。

### 核心循环

Cartographer 读取知识地图 → 识别空白 → 指派 Scout 探索 → Scout 搜索信源 → Analyst 验证蒸馏 → Cartographer 合并压缩 → 更新 morning-brief → Git commit → 下一轮

### 目标选择策略（轮转）



---

## 每个学习单元（3-5 分钟）

### Step 1: Scout



如果用 WebSearch（二级探索）：


### Step 2: Distill

将每个 finding 压缩为 pattern 格式：



**核心：找到元问题。** 不同文章说的往往是同一个底层问题的不同解法。

### Step 3: Analyze

读取 `$HARNESS_HOME/references/bedrock/first-principles.md`，对每个 finding 检查：

| 检查 | 通过 | 未通过 |
|------|------|--------|
| 与 bedrock 原理一致？ | 继续 | 标记 `[BEDROCK_CONFLICT]` → conflicts.md |
| 不是已有 pattern 的重复？ | 新建 | 合并为已有 pattern 的变体 |
| 有实际证据（非纯观点）？ | 继续 | confidence -= 0.15 |
| 可操作（非纯理论）？ | 继续 | 标记 `[THEORY_ONLY]`，降 rank |
| confidence ≥ 0.4？ | 写入 | 丢弃 |
| 关于 meta-framework 自身？ | 标记 `[SELF_MODIFY]` | — |

### Step 4: Rank & Merge

读取 `_master_index.md`：

- **同一元问题已存在** → 合并为实现变体，更新 sources/verified_count/confidence
- **新元问题** → 创建新 pattern 文件，更新 _master_index.md
- **与已有 pattern 矛盾** → 写入 conflicts.md，不自动解决

信源评分更新：
- 产出高质量 finding → score += 0.02（上限 0.95）
- 大部分是 noise → score -= 0.03（下限 0.3）
- 无新内容 → 不变

### Step 5: 增量更新 Morning Brief

每个学习单元完成后**立即追加**到 `$HARNESS_HOME/morning-brief.md`：



### Step 6: Git Commit

每轮自动 commit（不 push）：


---

## 并行加速（可选）

当一个信源的 Scout 返回多个 finding 时，可以并行处理：



这样可以实现**流水线并行**：Scout 和 Distill+Analyze 交错执行。

---

## Decay Sweep（每 10 轮）



---

## 停止条件

| 条件 | 行为 |
|------|------|
| **人主动停止**（Ctrl+C / 发消息） | 写最终 brief → commit → 退出 |
| **连续 5 次错误** | 写 `[INTERRUPTED]` brief → commit → 退出 |
| **所有信源 + 二级探索穷尽** | 写 `[EXHAUSTED]` brief → commit → 等待（极少发生） |
| **Git 冲突 / 磁盘满** | 写错误日志 → 退出 |

**没有时间上限。** 可以跑一晚上，也可以跑一周。

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|--------|-------|
| WebFetch / WebSearch | 只读，信源 URL 和搜索 |
| 创建/更新 references/patterns/ | 知识库 |
| 创建/更新 references/sources.yaml | 信源评分 |
| 移动 patterns 到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量报告 |
| 写 .nightshift/ 日志 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### CANNOT do（硬性禁止）

| 操作 | 原因 |
|--------|--------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 发消息 / 创建 PR | 不打扰人 |
| 删除非 archive 的 patterns | 防止误删 |

### Bedrock Guard

如果 finding 与 bedrock 原理冲突：
1. **不写入 patterns/**
2. 写入 `$HARNESS_HOME/.nightshift/conflicts.md`
3. morning-brief.md 高亮标记 `[BEDROCK_CONFLICT]`
4. 等人工判断

### Self-Modify Guard

如果 finding 关于改进 Scout/Distill/Rank/Merge 自身：
1. **仍然写入 patterns/meta-framework/**（有界自改进）
2. morning-brief.md 高亮标记 `[SELF_MODIFY]`
3. **不自动修改 generator/*.md**（需要人确认后才改）

---

## 状态文件

### `.nightshift/state.json`



### `.nightshift/metrics.jsonl`（追加式）



---

## Morning Brief 格式

`$HARNESS_HOME/morning-brief.md`（增量追加，人随时可看）：



---

## 与其他命令的关系

| 命令 | 触发 | 范围 | 持续 | 人的角色 |
|------|------|------|------|----------|
| `/harness:calibrate` | 手动，白天 | 聚焦（1 个 URL/topic） | ~20 min | 交互式 |
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** | 看 brief |
| `/harness:compound` | 任务完成后 | 内部经验 | ~10 min | 审核教训 |

**数据流：**

```
外部世界 → calibrate/nightshift → patterns/（外循环）
                                      ↓
内部经验 → compound → 新教训 → patterns/（内循环）
                                      ↓
                                   sleep（压缩）
```

---

## references/ 目录说明

**references/ 是 nightshift skill 的产物（知识库），按需加载，一般不需要读取。**

### 目录结构

```
references/
├── bedrock/              # 第一性原理（几乎不变）
├── patterns/             # 可复用模式（季度级更新）
│   ├── _master_index.md
│   └── {topic}/
├── articles/             # 长文深度分析（周级）
├── calibration/          # 校准记录
└── sources.yaml          # 信源配置
```

### 5 层分形索引架构

| 层级 | 文件 | 作用 | 何时读取 |
|------|------|------|----------|
| **L0** | claude.md | 基本认识（~100 行） | 总是注入 |
| **L1** | references/patterns/_master_index.md | 全局索引 | 需要检索时 |
| **L2** | references/patterns/{topic}/_index.md | Topic 摘要 | 定位到 topic 后 |
| **L3** | references/patterns/{topic}/{pattern}.md | 具体 pattern | 确定需要此 pattern 时 |
| **L4** | references/articles/ | 深度分析 | 需要完整上下文时 |

### 与 Nightshift 的关系

- **Nightshift 写入 references/**：Scout 探索 → Analyst 蒸馏 → Cartographer 合并 → 写入 patterns/
- **Nightshift 读取 references/**：Cartographer 读取知识地图 → 识别空白 → 指派探索方向
- **人读取 references/**：按需检索，通过 _master_index.md 定位
- **Agent 读取 references/**：通过 JSONL 精确注入，不全量加载


---

## 快速启动



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

## 核心原则

> **Nightshift 是不知疲倦的知识制图者。**
>
> 给它几个大方向，它自己探索整片大陆，动态调整路线。

> **Morning brief 是增量的，不是最后才写的。**
>
> 人随时打开 morning-brief.md 都能看到最新进展。
> 不需要等到"完成"才能看结果。

> **方向是活的，不是死的。**
>
> 探索过程中不断发现新的子领域、合并重复、淘汰穷尽的方向。

> **Commit but never push.**
>
> Git 历史提供完整审计轨迹和回滚能力。
> 人推送 = 隐式批准。

> **没有时间上限，只有停止信号。**
>
> 世界是运动与变化的。学习不应该有人为的截止时间。
> 人叫停，或者信源穷尽，才是真正的停止条件。
