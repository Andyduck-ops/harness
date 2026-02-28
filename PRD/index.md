# Harness — PRD Index

> 这是 Harness 项目的意图资产入口。像 AGENTS.md 一样，它是目录而非百科全书。

## What is Harness?

Harness 是一个 **自进化 AI Agent 执行环境工程系统**（Self-Evolving Harness Engineering System）。
它不写代码——它构建让 Agent 可靠产出代码的整个环境，并持续从外部世界和内部经验中进化。

**一句话：Model capability is the ceiling; the harness determines what actually ships — and the harness itself keeps getting better.**

## Document Map

| 文档 | 内容 | 阅读时机 |
|------|------|----------|
| [vision.md](./vision.md) | 问题、5 个论点、北极星 | 首次了解项目 |
| [core-principles.md](./core-principles.md) | 14 条核心原则（不可违反） | 每次决策前 |
| [architecture/](./architecture/) | 系统架构、执行模型、知识系统、元能力、夜间学习 | 开发前 |
| [boundaries/](./boundaries/) | 范围内/外、安全边界、跨平台策略 | 需求讨论时 |
| [validation/](./validation/) | 质量门、成功标准、验证闭环 | 实现完成后 |
| [intent/](./intent/) | 原子化意图条目（Intent ID 体系） | 按需查阅 |
| [../references/](../references/) | 知识资产：信源、蒸馏文章、可复用模式 | 校准/生成时 |

## Quick Navigation

**我要理解这个项目** → [vision.md](./vision.md) → [core-principles.md](./core-principles.md)

**我要开发/贡献** → [architecture/system-architecture.md](./architecture/system-architecture.md) → [architecture/execution-model.md](./architecture/execution-model.md)

**我要理解元能力** → [architecture/meta-capability.md](./architecture/meta-capability.md) → [architecture/nightshift.md](./architecture/nightshift.md)

**我要验证质量** → [validation/gates.md](./validation/gates.md)

**我要了解什么不做** → [boundaries/scope.md](./boundaries/scope.md)

## Origin

Harness 诞生于对两个系统（myclaude + Trellis）的 18 轮第一性原理分析，
融合了 OpenAI Harness Engineering、意图工程暴论、以及 ANCHOR/SHAPE/DECODE/ESCAPE 运行时补丁框架。

它不是 Trellis 的分支——它是从 Trellis 的经验中提炼出的新系统。
