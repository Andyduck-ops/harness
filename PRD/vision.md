# Vision — 为什么需要 Harness

## 问题

AI Agent 写代码的能力已经够强。真正的瓶颈不是模型——是模型工作的环境。

| 症状 | 根因 |
|------|------|
| Agent 重复犯同样的错误 | 没有持久化的教训系统 |
| 生成的代码不符合项目规范 | 规范没有被机械化强制注入 |
| 长任务链中途崩溃 | 串行依赖、无失败预算、无逃逸机制 |
| 修了 A 破了 B | 缺乏跨模块验证闭环 |
| 不同 Agent 做同一件事结果不同 | 上下文注入不一致 |
| 人类被迫当全职 babysitter | Agent 不知道何时该自主、何时该求助 |

这些问题的共同根因：**Agent 缺少一个结构化的执行环境（Harness）。**

## 核心论点

### 论点 1：Harness 是核心资产，代码是副产品

OpenAI 用 3 名工程师、0 行手写代码、5 个月产出 1M 行代码和 1500 个 PR。
他们维护的不是代码——是让代码可靠产出的 **执行环境**。

> "When the agent struggles, don't try harder—diagnose what's missing in the environment
> and have the agent build that capability into the repo." — OpenAI

### 论点 2：意图工程 > 代码工程

从信息论角度：代码是高维业务逻辑在特定技术栈下的低维投影。
维护投影（代码）不如维护投影源（意图 + 约束 + 架构决策）。

但有严格边界（圆桌辩论共识）：
- 代码中隐含的 "why" 必须被显式记录（design docs）
- 生产环境的生存证据不可替代（Lindy 效应）
- 本质复杂度无法消除，只能被理解和管理
- "代码可抛弃" 仅在：纯函数 + 无状态 + 低失败成本 + 高测试覆盖时成立

### 论点 3：强制执行 > 文档建议

> "In a human-first workflow, strict linting rules might feel pedantic.
> With agents, they become multipliers." — OpenAI

Agent 不会"自觉遵守"文档。有效的约束必须是机械化的：
- Hook 拦截（PreToolUse / PostToolUse / SubagentStop）
- Custom linters（架构不变量的编程验证）
- CI gates（合并前的自动化质量门）
- Structural tests（命名规范、文件大小、依赖方向）

### 论点 4：知识复利是最大杠杆

> "Each encoded capability becomes infrastructure for all future tasks,
> compounding over time." — OpenAI

每次任务完成后，系统应该变得更好：
- 新教训 → 编码到 spec / linter / hook
- 新模式 → 编码到 agent prompt / structural test
- 新失败 → 编码到 escalation threshold

### 论点 5：知识是流动的，环境必须自进化

AI coding 的最佳实践每天都在变——X 上的大佬发新玩法、官方更新 API、社区发现新 pattern。
任何静态系统都会在几周内过时。

因此 Harness 不是一个固定的工具集，而是一个**自进化系统**：
- **外循环（calibrate）**：持续从外部世界获取新知识，蒸馏、验证、融合
- **内循环（compound）**：从自己的任务经验中提取教训，沉淀为模式
- **夜间自主学习（nightshift）**：Agent 在人睡觉时自主冲浪，早上产出 morning brief
- **自迭代**：Harness 的元能力模块本身也在进化范围内

> 世界是运动与变化的。静态系统维护知识，动态系统进化知识。

## 北极星

**Harness 的成功标准不是"写了多少代码"，而是"系统每天变得更聪明了多少"。**

量化指标：
- **ICR（Intent Coverage Ratio）**：关键意图被可执行验证覆盖的比例
- **Agent Self-Resolution Rate**：Agent 无需人工介入完成任务的比例
- **Knowledge Compound Rate**：每 N 个任务产出的可复用教训数
- **Drift Detection Latency**：从意图变更到全链路一致的中位时长

## 与前身的关系

| 前身 | 继承 | 抛弃 |
|------|------|------|
| **Trellis** | Hook 强制注入、JSONL 渐进注入、ralph-loop 质量门、spec 知识体系 | 820 行 inject 单文件、字符串匹配协议、过度串行 |
| **myclaude** | 多后端思想、拓扑并发概念、SPARV 失败协议 | Go 实现（重新设计）、无数据流的任务间通信 |
| **暴论 v2** | 意图工程哲学、Intent ID 体系、双向闸门、漂移治理 | "代码可抛弃" 的极端立场 |
| **OpenAI Harness** | Progressive disclosure、mechanical enforcement、garbage collection、repo as brain | 特定技术选型（他们用的是 Codex + 内部工具） |

Harness = Trellis 的经验 + myclaude 的野心 + 暴论的哲学 + OpenAI 的模式 + 自进化的元能力。
