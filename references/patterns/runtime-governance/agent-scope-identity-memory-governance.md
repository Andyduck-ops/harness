---
name: agent-scope-identity-memory-governance
topic: runtime-governance
confidence: 0.85
verified_count: 16
sources:
  - OpenAI Agent Platform docs (Python/TypeScript/Go support) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (2026-03-01)
  - OpenAI Agents SDK Handoffs docs (2026-03-01)
  - OpenAI Agents SDK Human-in-the-loop guide（RunState serialize/deserialize + resume）(2026-03-01)
  - OpenAI Agents SDK Running agents docs（error handling / lifecycle exceptions）(2026-03-01)
  - OpenAI API Background mode guide (2026-03-01)
  - OpenAI API Conversations / conversation state docs (2026-03-01)
  - Anthropic Agent SDK / tool use docs (2026-03-01)
  - Anthropic API compaction docs（beta + non-ZDR constraints）(2026-03-01)
  - CrewAI Flows persistence docs (2026-03-01)
  - CrewAI Event Listeners docs（event bus instrumentation）(2026-03-01)
  - Kode Agent SDK README（stateful sessions / retry / multi-agent traceability）(2026-03-01)
  - HN top/show/new snapshots (2026-03-01)
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (redirect verified 2026-03-01)
last_verified: 2026-03-01
rank: 3
---

## 元问题

Demo 能跑不等于 production 能跑。
多 agent 链路里最常见的隐性故障是三类漂移叠加：
- 权限边界漂移（scope drift）
- 交接主体漂移（identity drift）
- 长会话记忆漂移（memory drift）

## 核心解法

统一为 `scope-identity-memory` 三联门禁，并把“状态、通信、恢复”拆开治理：

1. **状态层（State Plane）**
   - 会话必须可持久、可恢复（session persistence / flow persistence）。
   - 禁止只依赖进程内临时上下文。
2. **通信层（Communication Plane）**
   - agent 间交接必须显式合同化（handoff contract + input filter）。
   - 默认全量透传历史是高风险配置。
3. **恢复层（Recovery Plane）**
   - 长任务采用后台异步执行 + 状态轮询 + 可取消。
   - 失败恢复必须基于 checkpoint/replay，而不是“继续猜测”。
4. **压缩层（Compaction Plane）**
   - 压缩后必须做 continuity replay，确认关键语义未丢失。

## Demo -> Production 断裂点（SDK 对照）

| 断裂点 | 文档信号 | 治理动作 |
|---|---|---|
| 进程重启后上下文丢失 | OpenAI Agents SDK Sessions、CrewAI `@persist` | 会话后端外置（DB/Conversation API），恢复时强制 replay 关键状态 |
| 多 agent 交接串台 | OpenAI Handoffs（工具化交接 + input filter）、Anthropic Agent SDK tool contract | 交接包最小化 + 主体签名 + 仅传必要输入 |
| 长任务超时/断连 | OpenAI background mode（queued/in_progress/final + cancel） | 用异步任务 ID 做幂等恢复，禁止“重跑覆盖” |
| 长跑上下文退化 | Anthropic tool runner 自动状态管理/自动 compaction、OpenAI conversation state | 压缩触发阈值 + 压缩前后不变量校验 + 回放抽检 |

## SDK 落地抽象（本轮同化）

- OpenAI：Agent Platform 明确给出 Python/TypeScript/Go 三栈 SDK，适合作为统一控制面入口；落地时仍需把会话存储与后台任务状态外置化。
- Claude：Agent SDK 与 tool use 规则强调工具定义和输入约束，落地重点是“交接合同可验证”，而不是只靠提示词约定。
- CrewAI：Flow `@persist` 将状态持久化变成显式机制，生产上应配合 replay/checkpoint 才能避免恢复漂移。
- Kode SDK：官方仓库 README 已明确“内建状态管理与重试机制、默认持久化 session、可追踪多 agent 工作流”；可同化到三联门禁，不必新建 pattern。

## Cycle 90 压缩同化增量

- **OpenAI Sessions 的生产边界更清晰**：`OpenAIConversationsSession` 与 `MemorySession` 的角色区分是核心断裂点；后者仅适合本地开发，生产需替换为可恢复的外部会话后端。
- **Compaction 不是“纯优化”，是一致性风险面**：`OpenAIResponsesCompactionSession` 会清空并重写底层会话，且文档明确不应与 `OpenAIConversationsSession` 组合。上线前必须把 compaction 作为状态迁移来验收（replay + invariant）。
- **Handoff 必须合同化而不是提示词化**：`handoff()` 明确支持 `inputType` 与 `inputFilter`，可把“交接最小输入”从软约定升级为硬约束。
- **后台长任务恢复模型已可标准化**：background mode 的 `background=true + poll + cancel` 给出统一恢复面；并且存在约 10 分钟数据保留与 ZDR 不兼容约束，需在合规层前置分流。
- **会话跨设备/跨作业复用可直接落地**：Conversations API 的 durable identifier 能把“单进程记忆”升级为“跨运行单元记忆”。

## Cycle 91 同化增量（Agent SDK 落地 + 长跑稳定性）

- **Session 选型必须环境分层**：OpenAI Sessions 文档将 `OpenAIConversationsSession`（持久会话）与 `MemorySession`（本地开发）分离；生产默认应外置会话并禁止把内存 session 当持久层。
- **Handoff 输入边界可硬编码**：`handoff()` 的 `inputType + inputFilter + onHandoff` 已覆盖“schema 化交接 + 历史裁剪 + 交接审计”，可直接作为多 agent 通信合同。
- **Compaction 属于状态迁移，不是纯优化**：`OpenAIResponsesCompactionSession` 会清空并重写底层 session，且不可与 `OpenAIConversationsSession` 组合；上线前必须跑 continuity replay 与 invariant 校验。
- **异步恢复要纳入合规模型**：OpenAI background mode 明确了 polling/cancel 路径，同时文档给出“结果保留约 10 分钟 + 不支持 Zero Data Retention”约束，需在 prod 分流合规流量。
- **Claude 工具回路是天然恢复点**：Anthropic tool use 规范里 `stop_reason=tool_use` 与“执行工具后回传结果”的闭环，适合作为 checkpoint 粒度。
- **CrewAI 与 Kode 可被同一门禁吸收**：CrewAI 强调 state 生命周期与可持久化恢复；Kode README 强调 stateful sessions/retry/traceability。两者都落在 `scope-identity-memory` 三联门禁里，无需新增主题。

## Cycle 94 同化增量（Agent SDK 生产恢复链）

- **人工审批不再是“会话断点”**：OpenAI Human-in-the-loop 的 `RunState` 支持 serialize/deserialize，审批前后可恢复同一运行态；治理上应把人工确认纳入可回放状态机，而不是旁路聊天确认。
- **错误恢复从“重试”升级为“分层处置”**：OpenAI Running agents 文档将错误来源显式拆到 agent/tool/guardrail/lifecycle hook；生产上应按来源映射 retry budget 与降级动作，避免统一粗暴重跑。
- **通信链路需要事件级可观测性**：CrewAI Event Listeners 提供 event bus 监听点；多 agent 通信需要把 handoff 与异常事件统一打点，才能定位 identity drift 的真正来源。
- **压缩能力也要过合规门**：Anthropic compaction 文档给出 beta 与 non-ZDR 约束，说明“自动压缩”不是纯性能特性；上线时应把 compaction 路径纳入数据治理分流。
- **社区一线正在收敛到状态分区治理**：HN show 的 `SQLite for Rivet Actors`（每 agent/tenant/document 独立数据库）与 HN newest 的 `Agentation` 信号表明，state cell 化是 demo->production 的共同升级路径。

## 合并来源

- agent scope drift severity budget
- external identity lease replay
- agent state cell replay envelope
- agent memory partition least-privilege
- OpenAI/CrewAI/Anthropic 官方文档 + Kode Agent SDK 官方仓库 README 中关于 state persistence、handoff、async recovery 的一手规范
- HN top/show/new 与 OPML 作为“实践热区”信号，不单独作为入库依据

## 检索测试

- 查询：`多 agent 交接后状态串台怎么治理`  
  命中：本 pattern  
  动作：收敛到 `handoff input filter + identity lease + replay checkpoint`
- 查询：`长任务断线后怎么恢复`  
  命中：本 pattern  
  动作：收敛到 `background job id + polling + cancel + replay`
- 查询：`session compaction 后上下文一致性如何验收`  
  命中：本 pattern  
  动作：收敛到 `compaction before/after invariants + continuity replay + non-conversations-session rewrite check`
- 查询：`Claude/CrewAI/Kode 多 agent 长跑如何统一治理`  
  命中：本 pattern  
  动作：收敛到 `scope-identity-memory 三联门禁 + tool checkpoint + persisted session + retry budget`
- 查询：`RunState 人工审批后如何无损恢复`  
  命中：本 pattern  
  动作：收敛到 `serialize/deserialize run_state + approval checkpoint + replay resume`
