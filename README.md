# Harness

> Model capability is the ceiling; the harness determines what actually ships — and the harness itself keeps getting better.

Harness 是一个 **自进化 AI Agent 执行环境工程系统**。
它不写代码——它构建让 Agent 可靠产出代码的整个环境，并持续从外部世界和内部经验中进化。

## 核心理念

- **Harness First**: Agent 遇到困难时，修环境，不修 prompt
- **Mechanical Enforcement > Documentation**: 能用 hook/linter/CI 强制的，绝不只写文档
- **Progressive Disclosure**: 入口 ~100 行目录，详情按需加载
- **Knowledge Compounding**: 每次任务完成后，系统变得更好
- **Living Knowledge**: 知识必须流动，世界是运动与变化的
- **Self-Evolving**: 方法论固定，实现动态适配，系统可以改进自己

## 文档入口

从 [PRD/index.md](./PRD/index.md) 开始阅读。

| 文档 | 内容 |
|------|------|
| [PRD/vision.md](./PRD/vision.md) | 问题、5 个论点、北极星 |
| [PRD/core-principles.md](./PRD/core-principles.md) | 14 条核心原则 |
| [PRD/architecture/](./PRD/architecture/) | 四层架构、执行模型、知识系统、元能力、夜间学习 |
| [PRD/validation/](./PRD/validation/) | 质量门、成功标准 |
| [PRD/boundaries/](./PRD/boundaries/) | 范围、安全边界、跨平台策略 |
| [references/](./references/) | 知识资产：信源、蒸馏文章、可复用模式 |

## Architecture



## Cross-Platform

| Platform | Support |
|----------|--------|
| Claude Code | Full (hooks + agents + commands) |
| Codex | Adapted (AGENTS.md + skills) |
| Cursor | Degraded (rules, no hooks) |

## Origin

Harness 诞生于对 [myclaude](https://github.com/anthropics/claude-code) 多后端调度与 [Trellis](https://github.com/mindfold-ai/Trellis) hook 工作流的 18 轮第一性原理分析，融合了：

- [OpenAI Harness Engineering](https://openai.com/index/harness-engineering/) — repo as brain, progressive disclosure, mechanical enforcement
- 意图工程暴论 — 代码是投影，意图是核心资产
- ANCHOR/SHAPE/DECODE/ESCAPE — 按 Agent 架构缺陷分类的运行时补丁框架
- 元能力框架 — 自进化的知识获取、蒸馏、校准系统

## License

MIT
