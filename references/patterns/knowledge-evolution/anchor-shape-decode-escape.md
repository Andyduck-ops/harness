---
name: anchor-shape-decode-escape
topic: knowledge-evolution
confidence: 0.90
verified_count: 3
sources:
  - Trellis 16th-round first-principles debate (2026-02)
  - Agent-Skills-for-Context-Engineering (2026-01)
  - OpenAI Agent legibility patterns (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

教训（lessons）的分类维度应该是什么？

传统方法按人类行为规范（NEVER/ALWAYS/CHECK）或技术领域（frontend/backend）分类，
但 Agent 不是人——是 "Text-in / Text-out Brain in a Vat"。
用人类的组织方式给机器看的知识分类，是**拟人化谬误**。

## 核心解法

Agent 有 4 种根本架构缺陷，教训应该按**缺陷类型**分类：

| 类型 | 修补的缺陷 | Agent 读到后的行为改变 | 示例 |
|------|-----------|---------------------|------|
| **ANCHOR** | 幻觉（Hallucination） | 停止生成假设，转而观察真实状态 | "修改文件前必须先 Read" |
| **SHAPE** | 窗口限制 & 语法死板 | 改变生成策略，适配约束 | "不要 cat 大文件" |
| **DECODE** | 感知黑盒（Blindness） | 停止盲推，追加二次验证 | "sed 无输出 ≠ 成功" |
| **ESCAPE** | 局部最优（Looping） | 放弃当前思路，换方向 | "连续失败 2 次改策略" |

**教训不是"行为规范"，而是针对架构缺陷的运行时补丁。**

## 证据

- **Trellis 第 16 轮辩论**: 6 agent 一致否决 NEVER/ALWAYS/CHECK（覆盖率 40-50%），
  ANCHOR/SHAPE/DECODE/ESCAPE 覆盖率 100%
- **Agent-Skills-for-CE**: Observation Masking pattern 证实了 SHAPE（输出适配）的独立性
- **OpenAI Agent Legibility**: "code LLMs write should be easy to review" — 隐含 DECODE（信号可解码性）

## 验证：100% 归类

| 教训 | 旧框架困惑 | 新框架归类 |
|------|-----------|----------|
| 修改文件前先 Read | MUST? CHECK? | **ANCHOR** |
| 不要 cat 大文件 | NEVER? | **SHAPE** |
| sed 无输出 ≠ 成功 | CHECK? | **DECODE** |
| 连续失败 2 次改策略 | 无法归类 | **ESCAPE** |
| 优先 Edit 而非 Write | PREFER? | **SHAPE** |
| multi-session 状态隔离 | 条件性？ | **SHAPE** |

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: 独立文件** | ANCHOR.md / SHAPE.md / DECODE.md / ESCAPE.md | 推荐（清晰、可索引） |
| **B: 单文件标签** | 所有教训在一个文件，用 `[ANCHOR]` 标签 | 极小项目 |
| **C: JSONL 格式** | 每条教训一个 JSON 行，含 type 字段 | 需要程序化处理时 |

## 反模式

- 按人类行为规范分类（NEVER/ALWAYS — 拟人化谬误）
- 按技术领域分类（frontend/backend — 面向生产者而非消费者）
- 不分类（扁平列表 — 无法精确注入）
- 过度分类（>4 类 — Agent 注意力有限，少即是多）
