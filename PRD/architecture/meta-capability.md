# Meta-Capability — 自进化执行环境框架

## 核心定位

Harness 的元能力不是"存储最佳实践"，而是**持续校准最佳实践**。



世界是运动与变化的。AI coding 的最佳实践每天都在变——
X 上的大佬发新玩法、官方更新 API、社区发现新 pattern。
任何静态系统都会在几周内过时。

**元能力 = 让 Harness 自己跟上变化的能力。**

---

## 三层知识与腐化速度

| 层级 | 内容 | 腐化速度 | 更新方式 |
|------|------|---------|----------|
| **Bedrock（地基）** | 第一性原理、信息论、形式化方法 | 几乎不变 | 范式转移时才改 |
| **Patterns（模式）** | 已验证的工程模式 | 季度级 | calibrate + compound 沉淀 |
| **Practices（实践）** | 具体工具/API/玩法 | 周级~日级 | Scout 持续探索 |

---

## 5 个能力模块

### 1. Scout（冲浪探索）

**职责：从外部世界获取新知识。**



**信源分类与评分：**

| 类型 | 初始可信度 | 示例 |
|------|-----------|------|
| official | 0.9 | OpenAI blog, Anthropic docs, Claude Code changelog |
| framework | 0.8 | LangChain, CrewAI, Semantic Kernel |
| practitioner | 0.7 | @ryancarson, @_lopopolo, DTX Systems |
| community | 0.5 | 一般博客、Medium 文章 |

信源 rerank：持续产出高质量内容 → 分数上升。长期无产出 → 分数衰减。

---

### 2. Distill（蒸馏压缩）

**职责：将原始发现压缩为结构化知识模块。**

每条发现蒸馏为 **Skill 格式**（可索引、可排序、可热插拔）：



**核心设计：知识大部分是同构的。** 不同文章说的往往是同一个元问题的不同解法。
蒸馏的目标是找到元问题，而非堆积具体方案。

---

### 3. Analyze（第一性原理分析）

**职责：无人化验证新知识的质量和价值。**



**关键：这一步完全无人化。** Agent 自己运用第一性原理判断。
人不参与逐条审核——只在早上看汇总简报。

---

### 4. Rank（评分排序）

**职责：维护知识的 rerank 排序。**

多维评分体系：

| 维度 | 权重 | 说明 |
|------|------|------|
| 来源可信度 | 0.2 | 官方 > 大佬 > 社区 |
| 证据强度 | 0.3 | 定量 > 案例 > 经验 |
| 实践验证次数 | 0.25 | compound 反馈的使用频率 |
| 时效性 | 0.15 | 近期发现加分，Lindy 效应也加分 |
| 原理一致性 | 0.1 | 与 bedrock 原理的对齐程度 |

排序对象：
- **Patterns**：每个 pattern 的 rank 决定生成时的优先级
- **Sources**：每个信源的 rank 决定 Scout 的优先级
- **Articles**：每篇蒸馏文章的 rank 决定是否保留

**定期衰减：** 90 天无引用、无验证 → 分数自动衰减 → 最终归档。

---

### 5. Merge（压缩合并）

**职责：防止知识膨胀，保持知识库精简。**



**合并原则：同一个元问题只保留一条 pattern，包含所有实现变体。**

---

## 知识升级路径



**实践论，不教条。** 每个 pattern 都带实现变体，generator 根据项目特征选择最合适的变体。
不是"这是唯一正确的做法"，而是"这个元问题有 3 种解法，你的项目适合变体 B"。

---

## 双循环：内外知识进化



**compound 成熟教训的自动升级协议：**



---

## 自迭代：Harness 改进 Harness

Harness 本身也是一个项目。它的 Meta-Agent 模块也在 patterns/ 的管辖范围内：



当 nightshift 发现更好的 Scout/Distill/Rank/Merge 方法时：
1. 蒸馏为 pattern → 存入 meta-framework/
2. Analyze 验证与 bedrock 一致
3. generator 可以用新 pattern 更新自己的模块

**有界自改进：** 只改进知识获取和处理方式，不改变核心原则（bedrock）。

---

## 跨平台设计

### 通用层（平台无关）



全部是 Markdown + YAML。任何 AI agent（Claude Code、Codex、Cursor）都能读。

### 平台适配层（生成产物）

| 目标平台 | 生成目录 | Hook 机制 | Agent 机制 | 命令机制 |
|---------|---------|----------|-----------|----------|
| **Claude Code** | `.claude/` | Python hooks（4 种事件） | `.claude/agents/*.md` | `.claude/commands/` |
| **Codex** | `.agents/` | 无原生 hook（用 AGENTS.md 指令替代） | `.agents/skills/*/SKILL.md` | Skill 内嵌指令 |
| **Cursor** | `.cursor/` | 无原生 hook（用 rules 替代） | 无独立 agent | `.cursor/rules/` |

### Generator 的平台适配逻辑



### 降级策略

| 能力 | Claude Code | Codex | Cursor |
|------|------------|-------|--------|
| 强制注入 | ✅ Hook | ⚠️ AGENTS.md 指令 | ⚠️ Rules 文件 |
| 质量门 | ✅ SubagentStop hook | ❌ 无（靠 CI） | ❌ 无（靠 CI） |
| 渐进注入 | ✅ JSONL + Hook | ⚠️ Skill 三级加载 | ❌ 全量 rules |
| 夜间学习 | ✅ background agent | ✅ async task | ❌ 无 |

Claude Code 是完整体验，其他平台是降级但可用。
