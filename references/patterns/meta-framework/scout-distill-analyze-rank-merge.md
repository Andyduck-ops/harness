---
name: scout-distill-analyze-rank-merge
topic: meta-framework
confidence: 0.75
verified_count: 2
sources:
  - Harness PRD meta-capability design (2026-02)
  - Compound Engineering + OpenAI patterns synthesis (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

AI coding 的最佳实践每天都在变——
新文章、新工具、新 API、新 pattern 持续涌现。
任何静态知识库在几周内就会过时。

**知识库需要自己能进化。**

## 核心解法

5 个能力模块形成知识处理流水线：



| 模块 | 职责 | 输入 | 输出 |
|------|------|------|------|
| **Scout** | 从信源列表 + 关键词搜索获取新知 | sources.yaml + keywords | 原始文章/发现 |
| **Distill** | 蒸馏为 Skill 格式的结构化模块 | 原始发现 | YAML frontmatter + 元问题 + 解法 + 证据 |
| **Analyze** | 第一性原理交叉验证 | 蒸馏结果 + bedrock/ | confidence 评分 + 一致性标记 |
| **Rank** | 多维评分 + rerank 排序 | 所有 patterns | 全局排序 + 信源排序 |
| **Merge** | 同构知识合并 + 过期清理 | 所有 patterns | 压缩后的知识库 |

## 三层知识与腐化速度

| 层级 | 内容 | 腐化速度 | 更新方式 |
|------|------|---------|----------|
| **Bedrock** | 第一性原理（Brooks/Lamport/Taleb） | 几乎不变 | 范式转移时才改 |
| **Patterns** | 已验证的工程模式 | 季度级 | calibrate + compound |
| **Practices** | 具体工具/API/玩法 | 周级~日级 | Scout 持续探索 |

## 关键设计决策

**1. 无人化第一性原理验证**

Analyze 模块完全无人化。Agent 运用 bedrock/ 中的第一性原理自行判断：
- 新发现是否与已知原理一致？
- 证据强度如何？（定量 > 案例 > 经验）
- 是否是已有 pattern 的变体？

人不参与逐条审核——只在早上看汇总简报（nightshift 产出）。

**2. 知识同构性**

不同文章说的往往是同一个元问题的不同解法。
Distill 的核心任务是**找到元问题**，而非堆积具体方案。
同一元问题只保留一条 pattern，包含所有实现变体。

**3. 衰减与归档**

- 90 天无引用、无验证 → 分数衰减
- patterns/ 超 100 条时触发强制合并
- 矛盾的 patterns → 标记 [CONFLICT]，不自动解决
- 单篇文章蒸馏上限 500 词

**4. 有界自改进**

meta-framework/ topic 存储元框架自身的改进 pattern。
当 nightshift 发现更好的 Scout/Distill/Rank 方法时，
可以更新自己的处理模块——但不可修改 bedrock 原理。

## 证据

- **Compound Engineering**: 夜间学习循环 = Scout + Distill 的初始形态
- **OpenAI**: "feed struggles back into the repository" = 内循环 compound
- **Harness PRD**: 18 轮 Trellis 分析确认了静态知识库的不可持续性

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: 命令触发** | `/calibrate` 手动触发 Scout→Distill→Analyze→Rank→Merge | 日常使用 |
| **B: Nightshift** | 夜间自动运行全流水线，产出 morning brief | 持续学习 |
| **C: 事件触发** | 新信源发布 / pattern 被引用 / compound 沉淀 → 触发局部更新 | 实时响应 |

## 反模式

- 只 Scout 不 Merge（知识无限膨胀）
- 只 Distill 不 Analyze（缺乏质量控制）
- 人工审核每一条（带宽瓶颈，不可扩展）
- Bedrock 可被自动修改（失去稳定锚点）
- 没有衰减机制（过时知识永远存在）
