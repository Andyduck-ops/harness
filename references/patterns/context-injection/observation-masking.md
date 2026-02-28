---
name: observation-masking
topic: context-injection
confidence: 0.80
verified_count: 2
sources:
  - Agent-Skills-for-Context-Engineering (2026-01)
  - BrowseComp token usage study (2026-01)
last_verified: 2026-02-28
rank: 2
---

## 元问题

工具输出（test results、lint output、log files）往往非常冗长，
直接注入 Agent 上下文会浪费大量 token、淹没关键信息。

**BrowseComp 研究发现：token 使用量解释了 80% 的性能差异。**
噪声 token 不仅浪费钱，还直接降低 Agent 性能。

## 核心解法

**工具输出压缩（Observation Masking）**：
在工具输出注入 Agent 上下文前，先提取结构化摘要。

压缩策略：

| 输出类型 | 压缩方式 | 保留内容 |
|---------|---------|----------|
| 测试结果 | 只保留失败项 + 错误信息 | `FAIL: test_login — AssertionError: expected 200, got 500` |
| Lint 输出 | 按规则去重 + 计数 | `no-unused-vars: 3 files, import/order: 1 file` |
| 编译错误 | 只保留第一个错误 + 文件路径 | 级联错误只保留根因 |
| 日志文件 | 只保留 ERROR/WARN + 时间窗口 | 最近 N 行或最近 M 分钟 |
| 大文件内容 | 只注入前 N 行 + 尾部摘要 | 超过 token 预算时截断 |

**核心原则：Agent 需要的是"什么出了问题"和"在哪里"，不是完整的原始输出。**

## 证据

- **Agent-Skills-for-CE**: Observation Masking 作为独立 pattern，实现 87% token reduction
- **BrowseComp**: token usage explains 80% of performance variance, tool calls ~10%, model choice ~5%

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: PostToolUse hook** | Hook 截获工具输出，提取摘要后注入 | Claude Code |
| **B: 命令包装器** | `npm test \| summarize` 管道处理 | 任何平台 |
| **C: JSONL budget** | JSONL 声明 max_tokens_per_file，注入器自动截断 | 有 JSONL 注入的系统 |

## 反模式

- 全量注入工具输出（数千行测试日志直接塞进上下文）
- 过度压缩（只说"测试失败"不说哪个测试、什么错误）
- 压缩后丢失文件路径（Agent 需要知道"在哪修"）
- 对所有输出用同一种压缩策略（不同类型需要不同处理）
