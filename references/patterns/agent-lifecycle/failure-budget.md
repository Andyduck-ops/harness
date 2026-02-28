---
name: failure-budget
topic: agent-lifecycle
confidence: 0.90
verified_count: 4
sources:
  - SPARV 3-Failure Protocol (2026-02)
  - Trellis ralph-loop analysis (2026-02)
  - Code Factory risk management (2026-02)
  - OpenAI Harness Engineering (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

Agent 遇到失败时会无限重试同一策略，
直到 token 耗尽或上下文窗口溢出。
无限循环是 Agent 最常见的灾难模式。

## 核心解法

给每个任务设定**失败预算**（failure budget），
同类失败超过预算则强制升级处理策略，而非继续重试。

三级升级协议：

| 同类失败次数 | 处理 |
|-------------|------|
| 第 1 次 | 重试，换策略（禁止同策略重试超过 1 次） |
| 第 2 次 | 触发 debug agent（引入独立视角） |
| 第 3 次 | 升级人工（附完整失败证据链） |

**关键：计数器按"同类失败"累加，不因中间引入 oracle/debug 而重置。**

## 证据

- **SPARV**: 3-Failure Protocol 在 18 轮 Trellis 分析中被一致推荐（6/6 agents）
- **Trellis ralph-loop**: 无上限 debug 循环是已知缺陷，MAX_ITERATIONS 兜底不够精细
- **Code Factory**: Ryan Carson 用风险分级决定允许的重试次数——高风险任务失败预算更小
- **OpenAI**: "Agents should know when to stop and ask" — 结构化升级优于无限自治

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: dispatch 计数器** | dispatch agent 维护 debug_count，超限触发升级 | Trellis/Harness pipeline |
| **B: task.json 预算字段** | 每个任务定义 max_failures，执行器检查 | 任何有任务元数据的系统 |
| **C: 外部状态文件** | `.state.json` 记录失败历史，hook 读取判断 | 任何有 hook 的平台 |

## 反模式

- 无失败预算的无限重试（Agent 最常见灾难）
- 预算过大（≥5 次同类失败说明策略根本错误）
- oracle 介入后重置计数器（衡量的是"当前策略有效性"）
- 只计总失败不区分类别（不同错误需要不同处理）
