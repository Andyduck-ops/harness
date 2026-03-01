---
name: agent-scope-identity-memory-governance
topic: runtime-governance
confidence: 0.86
verified_count: 22
sources:
  - OpenAI Agent Platform docs (Python/TypeScript/Go support) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (2026-03-01)
  - OpenAI Agents SDK Handoffs docs (2026-03-01)
  - OpenAI Agents SDK Human-in-the-loop guide（RunState serialize/deserialize + resume）(2026-03-01)
  - OpenAI Agents SDK Running agents docs（error handling / lifecycle exceptions）(2026-03-01)
  - OpenAI Agents SDK Tracing docs（group_id trace correlation）(2026-03-01)
  - OpenAI Agents SDK Python handoffs docs（nest_handoff_history/handoff input shaping）(2026-03-01)
  - OpenAI Agents SDK RunConfig docs（groupId/handoffInputFilter）(2026-03-01)
  - OpenAI Agents SDK sessions docs（SQLiteSession transaction commit/rollback semantics）(2026-03-01)
  - OpenAI Agents SDK sessions docs（EncryptedSession API / TTL / key derivation）(2026-03-01)
  - OpenAI Agents SDK JS running agents docs（session auto history + run_state resume）(2026-03-01)
  - OpenAI Agents SDK JS RunConfig docs（groupId/handoffInputFilter/maxTurns）(2026-03-01)
  - OpenAI Agents SDK JS Lifecycle hooks docs（agent/tool/handoff hooks for runtime audit）(2026-03-01)
  - OpenAI Agents SDK Python lifecycle docs（RunHooks / AgentHooks wrappers）(2026-03-01)
  - OpenAI Agents SDK guardrails docs（run_in_parallel side-effect boundary）(2026-03-01)
  - OpenAI Agents SDK runner docs（error_handlers + max_turns lifecycle）(2026-03-01)
  - OpenAI API Background mode guide (2026-03-01)
  - OpenAI API Conversations / conversation state docs (2026-03-01)
  - Anthropic Agent SDK / tool use docs (2026-03-01)
  - Anthropic Claude Code subagents docs（separate context window isolation）(2026-03-01)
  - Anthropic Claude Code context editing docs（clear_tool_inputs / clear_tool_results controls）(2026-03-01)
  - Anthropic Agent SDK overview（tool loop + auto context management）(2026-03-01)
  - Anthropic API compaction docs（beta + non-ZDR constraints）(2026-03-01)
  - CrewAI Flows persistence docs (2026-03-01)
  - CrewAI Event Listeners docs（event bus instrumentation）(2026-03-01)
  - CrewAI Conditional Tasks docs（runtime routing for fallback/recovery paths）(2026-03-01)
  - Kode Agent SDK README（stateful sessions / retry / multi-agent traceability）(2026-03-01)
  - Kode Agent SDK architecture README（7-stage checkpoint + stateless API/stateful worker）(2026-03-01)
  - nlpodyssey/openai-agents-go README（session stores/hook callbacks/retry & telemetry）(2026-03-01)
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

## Cycle 96 同化增量（状态保真 + 通信裁剪协同）

- **交接历史策略要显式治理**：OpenAI Python handoffs 文档显示 `nest_handoff_history` 默认关闭，并可按 handoff 覆盖；生产上要把“是否保留交接轨迹”设为运行时策略而不是隐式默认。
- **通信最小化要上升到运行级配置**：`RunConfig` 支持 `handoffInputFilter` 与 `groupId`，可统一约束跨 agent 传输输入与可追踪分组，避免每个 handoff 各自实现导致漂移。
- **会话安全层应独立于业务状态层**：Sessions 文档提供 `EncryptedSession` 与 TTL 过期机制，说明“可恢复”之外还要具备“可过期/可密钥轮换”的数据治理边界。
- **恢复链路需串联人工审批断点**：Human-in-the-loop 的 `RunState.fromString` + `result.state.toString` 使审批前后恢复可回放；审批节点应纳入统一 checkpoint，而不是流程外侧补丁。
- **社区实践继续验证 state cell 化趋势**：HN top 的 `MCP server reduces context consumption by 98%` 与 HN show 的 `SQLite for Rivet Actors` 指向同一结论：先做状态分区与输入裁剪，再谈 agent 数量扩张。

## Cycle 98 同化增量（跨 SDK 恢复合同收敛）

- **错误恢复必须绑定“循环预算 + 错误分层”**：OpenAI Running agents 文档给出 `max_turns` 与类型化异常（如 `MaxTurnsExceeded`）；生产上应按 `agent/tool/guardrail/lifecycle` 维度拆分 retry budget，避免无界重试。
- **多 agent 通信需要因果追踪主键**：OpenAI Tracing 的 `trace(workflow_name, group_id=...)` 可把跨 agent 事件串成同一因果链；`group_id` 应与 handoff 合同共用同一关联 ID。
- **Claude 侧把“工具回路 + 上下文管理”并入默认运行层**：Anthropic Agent SDK overview 明确基于 tool use 构建并内置 context window management；上线时应把 compaction 与上下文预算纳入运行时门禁，而非后补优化。
- **CrewAI 可观测性已具备事件级挂点**：Event Listeners 文档提供 `BaseEventListener` 与 `CrewKickoffStartedEvent`，可对 handoff/异常/恢复点做统一审计打点。
- **Kode 的长任务架构强调 checkpoint-first**：README 将架构拆为 `stateless API servers + stateful workers + shared store + queue decoupling`，并在多阶段流程中每阶段持久 checkpoint；可直接同化为“控制面无状态、执行面有状态”的恢复基线。
- **社区热区信号持续一致**：HN `top/show/newest` 同窗都在强化同一主题：先解决状态与恢复，再扩张 agent 数量和自动化范围。

## Cycle 99 同化增量（恢复合同细化：事务边界 + 条件路由）

- **通信最小化与追踪主键应在运行级统一下发**：OpenAI Agents SDK `RunConfig` 同时提供 `handoff_input_filter` 与 `group_id`，适合把“输入裁剪”和“跨 agent 因果关联”做成同一个运行时合同，而不是散落到各 handoff 实现。
- **会话持久层需要显式事务边界**：OpenAI `SQLiteSession` 文档示例体现了上下文管理器中的提交/回滚语义；生产恢复链应把“checkpoint 写入成功”视为可恢复前提，避免半写入状态导致回放漂移。
- **恢复分支需要流程级条件路由，不只依赖重试**：CrewAI `ConditionalTask` 能依据前置任务输出做分支执行，适合作为“失败降级路径/人工复核路径”的执行面编排。
- **事件审计需要覆盖 kickoff→handoff→recovery 全链路**：CrewAI Event Listeners 文档提供基于事件总线的监听挂点；应将 handoff、异常、恢复完成统一打点，和 OpenAI `group_id` 追踪做关联。
- **社区信号继续验证“先稳态再扩张”**：HN 当窗 `top`（The curious case of shell commands and language models）、`show`（Launch HN: Yood）、`newest`（Only: Free and open source app to monitor your social media feed）仍显示实践侧关注点集中在可执行链路与运行稳定性。

## Cycle 101 同化增量（副作用优先阻断 + 可恢复交接）

- **高风险工具链默认不应并行放行**：OpenAI Agents SDK guardrails 文档指出 guardrail 默认可并行执行；若 `run_in_parallel=True`，模型输出工具调用时可能先执行工具再触发 guardrail 失败。生产上对有副作用的 tool 必须改为串行阻断策略（`run_in_parallel=False`）并显式做 tool 风险分级。
- **恢复合同要绑定生命周期错误类型**：OpenAI runner 文档给出 `error_handlers`（含 `max_turns_exceeded`）可按错误类型分流恢复动作。治理上应从“统一重试”升级为“错误类型 -> 恢复策略”映射表。
- **会话恢复需要执行面自动落盘**：OpenAI JS running agents 文档说明 runner 在存在 session 时会自动补齐历史并持久化本轮输入/输出；并支持 `run_state.toString()/fromString()` 恢复。可把审批/中断恢复并入同一 checkpoint 协议。
- **Claude 子代理天然提供上下文隔离边界**：Claude Code subagents 文档明确子代理使用独立上下文窗口，且不会自动继承完整对话历史。可作为多 agent 场景的“隔离执行单元”，降低 identity/memory drift。
- **强制信源侧证继续聚焦“稳定性先于扩张”**：HN 当前窗口 `top`（Trellis: Structured language model reinforcement learning for tool use）、`show`（Show HN: No Time To Die, a game made by one person for the gameboy）、`newest`（Convergence may be impossible for this one weird reason）与 OPML 锚点（`https://t.co/dwAiIjlXet` -> `popular blogs opml`）共同提示：工程主战场仍是可恢复执行面，而不是盲目增加 agent 数。

## Cycle 102 同化增量（RunConfig 合同化 + Go 执行面补强）

- **运行级合同应一次性下发通信与预算约束**：OpenAI Agents SDK JS `RunConfig` 同时给出 `groupId`、`handoffInputFilter`、`maxTurns`。生产上应把“关联追踪 + 输入裁剪 + 回合预算”绑定为同一运行合同，避免三套策略分别漂移。
- **观测面要从日志升级为生命周期事件**：OpenAI Agents SDK JS 的 lifecycle hooks（`agent_start/end`、`handoff`、`tool_start/end`）提供了天然审计点。多 agent 通信排障应优先对接事件流，而不是靠事后日志拼图。
- **Go 执行面可纳入同一 canonical pattern**：`openai-agents-go` README 给出的 session stores（memory/sqlite/redis）+ hook callbacks + retries/backoff + OpenTelemetry，实质对应同一元问题（state + communication + recovery），应同化到本 pattern，不额外拆 topic。
- **会话持久层需要“后端可替换”而非“实现可替换”**：Go SDK 实践强调 SessionStore 接口与具体适配器分离；治理上应把 session backend 当成运行时策略位（按环境切换），而不是在业务层硬编码。
- **强制信源窗口继续给出同向侧证**：HN 当前窗口 `top`（Huge pages and garbage collection in the Java virtual machine）、`show`（Show HN: Open social network）、`newest`（DuckDB + LLMs to parse and process arbitrary CSV files）与 OPML 锚点共同表明，工程热区仍集中在“运行效率 + 可运维数据链路”，支撑“稳定性先于规模化”策略。

## Cycle 104 同化增量（状态后端分层 + 上下文编辑防漂移）

- **会话后端要先分层再扩 agent 数量**：OpenAI Agents SDK Sessions 文档已经把 `SQLAlchemySession` 和 `AdvancedSQLiteSession` 作为可持久化后端示例；生产应把 session backend 作为运行时策略位，禁止把内存会话当持久层。
- **交接过滤应绑定运行合同而非散落实现**：OpenAI Agents SDK Handoffs 文档强调可对 transferred inputs 做过滤；结合 `group_id` 追踪可形成“最小输入 + 因果关联”的统一通信合同。
- **生命周期审计要覆盖 hook 边界**：OpenAI Agents SDK Python lifecycle 文档给出 `RunHooks` / `AgentHooks` 包装点；应把 `agent/tool/handoff` 事件纳入同一审计流，而不是只靠日志回放。
- **子代理隔离与上下文编辑要成对治理**：Anthropic 文档一方面明确 subagents 使用独立上下文窗口，另一方面 context editing 默认会清理部分 tool 结果；长跑恢复中应显式配置 `clear_tool_inputs` / `clear_tool_results` 策略，避免压缩后出现隐式依赖漂移。
- **社区热区继续指向“稳态优先”**：本轮 HN `top`（Show HN: MCPCat）、`show`（Show HN: Track nutrition by taking photos of your food）、`newest`（How can AI check software requirements and identify ambiguities?）与 OPML 锚点同向，说明一线实践焦点仍是“可恢复执行链路”而非盲目扩编 agent。

## 合并来源

- agent scope drift severity budget
- external identity lease replay
- agent state cell replay envelope
- agent memory partition least-privilege
- OpenAI/CrewAI/Anthropic 官方文档 + Kode Agent SDK 官方仓库 README 中关于 state persistence、handoff、async recovery 的一手规范
- OpenAI Agents SDK JS RunConfig/Lifecycle hooks 与 openai-agents-go README 为“运行级合同 + 事件级审计 + 可替换会话后端”提供直接证据
- HN top/show/new 与 OPML 作为“实践热区”信号，不单独作为入库依据
- OpenAI 与 CrewAI 官方文档提供运行级配置、事务边界和条件路由证据；HN 仅作为热区侧证
- OpenAI Python Sessions/Lifecycle + Anthropic context editing 文档补强了“状态后端分层 + 上下文编辑防漂移”证据链

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
- 查询：`handoff history 默认关闭如何治理`  
  命中：本 pattern  
  动作：收敛到 `nest_handoff_history policy + run-level handoffInputFilter`
- 查询：`session TTL 加密与恢复如何共存`  
  命中：本 pattern  
  动作：收敛到 `EncryptedSession tier + expiration policy + replay continuity`
- 查询：`max_turns exceeded 后如何避免死循环重试`  
  命中：本 pattern  
  动作：收敛到 `error-class retry budget + lifecycle fallback + checkpoint resume`
- 查询：`group_id tracing 怎么和 handoff 对齐`  
  命中：本 pattern  
  动作：收敛到 `shared correlation id across trace + handoff contract`
- 查询：`CrewAI 事件监听能否用于多 agent 恢复审计`  
  命中：本 pattern  
  动作：收敛到 `BaseEventListener hooks + recovery checkpoint telemetry`
- 查询：`SQLAlchemySession AdvancedSQLiteSession production session backend`  
  命中：本 pattern  
  动作：收敛到 `session backend policy tier + persistence-first recovery`
- 查询：`Anthropic clear_tool_inputs clear_tool_results context editing`  
  命中：本 pattern  
  动作：收敛到 `context editing policy + replay invariants before/after compaction`
- 查询：`OpenAI RunHooks AgentHooks audit`  
  命中：本 pattern  
  动作：收敛到 `hook event pipeline + handoff/tool lifecycle governance`
- 查询：`run_in_parallel guardrail 工具副作用`  
  命中：本 pattern  
  动作：收敛到 `high-risk tools serial guardrail + side-effect budget`
- 查询：`run_state toString fromString 恢复`  
  命中：本 pattern  
  动作：收敛到 `approval/interruption checkpoint replay protocol`
- 查询：`Claude subagents separate context window`  
  命中：本 pattern  
  动作：收敛到 `subagent isolation boundary + scoped handoff contract`
