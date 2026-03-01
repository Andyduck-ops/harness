---
name: context-compaction-replay-governance
topic: runtime-governance
confidence: 0.83
verified_count: 17
sources:
  - OpenAI API Conversation state docs (`store=true`, conversation id continuity) (2026-03-01)
  - OpenAI API Conversation state docs（`previous_response_id` 与 `conversation` 互斥；response 对象默认 30 天保留）(2026-03-01)
  - OpenAI API Background mode docs (queued/in_progress/completed + poll/cancel) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (`MemorySession` vs persistent session backends) (2026-03-01)
  - OpenAI Agents SDK JS Sessions docs (`sessionInputCallback` + compaction scheduling guidance) (2026-03-01)
  - OpenAI Agents SDK JS Sessions docs（`OpenAIResponsesCompactionSession` 与 `OpenAIConversationsSession` 不兼容；`runCompaction` 支持 `store` 与 `responseId`）(2026-03-01)
  - OpenAI Agents SDK JS Sessions docs（自动 compaction 会等待 compact 完成后再结束 stream）(2026-03-01)
  - OpenAI Agents SDK JS Handoffs docs (`inputFilter`, default full history forwarding) (2026-03-01)
  - OpenAI Agents SDK JS Running agents docs (`reasoningItemIdPolicy` strict-provider recovery) (2026-03-01)
  - Anthropic Claude Code SDK docs（context window management + auto-compacting strategies）(2026-03-01)
  - Anthropic Claude Code Subagents docs（每次调用新实例 + 独立上下文窗口 + resume 继承完整历史）(2026-03-01)
  - Anthropic Claude Code Subagents docs（subagent transcripts 独立持久化且不并入主对话 compaction）(2026-03-01)
  - Anthropic Claude Code Hooks docs（`stop_hook_active` 防递归触发）(2026-03-01)
  - OpenAI Agents SDK JS Running agents docs（`errorHandlers` 当前仅支持 `maxTurns`）(2026-03-01)
  - OpenAI Agents SDK Python Handoffs docs（无显式 filter 时回落到 `default_handoff_input_filter`）(2026-03-01)
  - CrewAI Event Listeners docs（监听器需在 `crew.py` / `flow.py` 导入以完成加载）(2026-03-01)
  - CrewAI Flows docs（`@persist` 重启恢复）(2026-03-01)
  - nlpodyssey/openai-agents-go README（SessionStore backends + `MaxTurnsExceededError`）(2026-03-01)
  - HN top/show/new snapshots (2026-03-01)
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (redirect verified 2026-03-01)
  - HN news（MCP server context-preservation field report）(2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top item id: 47202730, title: "Ask HN: What kind of product should OpenAI release next?")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top item id: 47201816, title: "Show HN: DreamBOMB")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top item id: 47203831, title: "A Transition Experiment by reaching back in internet history")
  - OpenAI Agents SDK JS Sessions docs（streaming 会先写入 user input，完成后再写 assistant outputs；`runCompaction` 为 best-effort）(2026-03-01)
  - Anthropic Context Windows docs（compaction block 必须在后续请求原样回传；compact 前旧块将被忽略）(2026-03-01)
  - Anthropic Context Windows docs（compaction beta header `context-1m-2025-08-07`；文档声明支持 ZDR arrangement）(2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top item id: 47206745, title: "MCP server that reduces Claude Code context consumption by 98%")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top item id: 47203334, title: "Show HN: Memctl v0.1: Persistent memory and context management for coding agents")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top item id: 47207987, title: "How to split your context window in two")
  - context-governance cluster (cycles 45-80)
  - comprehension-governance cluster (cycles 45-80)
last_verified: 2026-03-01
rank: 3
---

## 元问题

上下文压缩后如果没有回放合同，Agent 会“看起来继续跑，实际丢关键语义”。

## 核心解法

压缩必须绑定 replay continuity：
1. compaction 前后关键状态校验；
2. 理解债务超阈值触发 freeze；
3. 恢复时必须重放最小证据集。

## Cycle 93 同化增量（长运行稳定性）

- **状态连续性从“文本连续”升级为“标识连续”**：
  - Conversation state 明确了 `conversation` 与 `previous_response_id` 的续跑路径；
  - 结论：compaction 后必须验收“标识链连续”，不能只看回答语义看似一致。
- **后台执行把恢复窗口显式化**：
  - Background mode 提供 `queued / in_progress / completed`、poll、cancel；
  - 结论：恢复策略要绑定 job lifecycle，而不是在超时后直接重提问。
- **会话实现要分环境，不得混用开发态内存会话**：
  - Agents Sessions 将 `MemorySession` 与持久会话后端能力拆分；
  - 结论：生产场景禁止把内存会话作为 durability 假象。
- **社区一线信号表明“上下文保真”优先级继续上升**：
  - HN 实战贴将 MCP server 用于降上下文占用并保留文件状态；
  - 结论：compaction 的目标不是“压更小”，而是“丢失最少关键状态”。
- **Claude 侧验证 compaction 是一等运行时能力**：
  - SDK 文档把 context window management 和 auto-compacting 放进默认能力层；
  - 结论：需要把 compaction 纳入统一运行时门禁，而非临时优化脚本。

## Cycle 110 同化增量（压缩调度 + 通信裁剪 + 严格回放）

- **压缩时机会直接影响流式完成延迟**：
  - OpenAI Agents JS `OpenAIResponsesCompactionSession` 文档明确：自动 compact 可能延后 stream completion 回调；生产建议可关闭自动 compact，改为“轮次间”调度压缩；
  - 结论：compaction 不能只看 token 节省，必须纳入延迟预算与回调 SLA。
- **上下文窗口应在调用前按策略裁剪，而不是事后补救**：
  - `sessionInputCallback` 支持按模型调用前动态决定发送给模型的历史窗口；
  - 结论：长跑会话要显式配置“发送窗口策略”，避免上下文累积导致退化。
- **跨 agent 默认透传历史是通信噪声源**：
  - Handoffs 文档说明默认会把完整消息历史转发到下一个 agent，`inputFilter`（如 `removeAllTools`）可裁掉不必要上下文；
  - 结论：多 agent 通信必须合同化最小输入，避免 compaction 后噪声再注入。
- **严格后端下的 replay 需要 ID 去耦策略**：
  - Running agents 文档给出 `reasoningItemIdPolicy='omit'` 可避免部分模型提供方对历史 reasoning item id 的 400 错误；
  - 结论：回放合同应定义“ID 透传策略位”，在 strict provider 上优先 `omit` 保证恢复链可用。
- **社区窗口信号继续支持“上下文治理先于功能扩张”**：
  - HN `top/show/newest` 同窗条目仍高频聚焦 context 管理与 agent coding 实践；
  - 结论：本轮不新建 pattern，继续同化到 compaction canonical pattern 可提升检索信噪比。

## Cycle 112 同化增量（压缩语义一致性 + 保留期边界）

- **手动链路与会话链路不能混搭**：
  - OpenAI conversation state 文档明确：`previous_response_id` 与 `conversation` 不能同时使用；
  - 结论：恢复合同必须先声明“response-chain 模式”或“conversation 模式”，禁止混合提交导致链路歧义。
- **保留期要按对象类型分层治理**：
  - 文档明确 response 对象默认保留 30 天，而 conversation 对象及其 items 不受该 30 天保留期影响；
  - 结论：长跑恢复不能只依赖 response id，必须把关键状态沉淀到 conversation 层或外部持久层。
- **Compaction Session 与 Conversations Session 存在结构不兼容**：
  - OpenAI Agents JS 文档明确 `OpenAIResponsesCompactionSession` 不应包装 `OpenAIConversationsSession`；
  - 结论：压缩治理要显式区分“本地可压缩会话”和“远端持久会话”，避免双重状态源冲突。
- **Compaction 的存储策略必须显式化**：
  - `runCompaction({ store, responseId })` 提供“是否存储 compact 结果”和“链路锚点 responseId”策略位；
  - 结论：长会话需把 `store` 与 `responseId` 作为必填恢复字段，禁止默认值隐式漂移。
- **自动 compaction 会影响流完成语义**：
  - 文档指出自动 compact 会在 stream 结束前等待 compact 完成；
  - 结论：流式 SLA 需要并联“模型输出延迟”和“compaction 延迟”两条预算，不得只看首 token 时延。
- **强制信源侧证（当窗）继续同向**：
  - HN `news`（id=47224755）、`show`（id=47225679）、`newest`（id=47226766）与 OPML 锚点同窗验证：社区持续聚焦“上下文持久化与恢复一致性”。
  - 判定：仍为同一元问题，执行同化，不新建 pattern。

## Cycle 116 同化增量（子代理转录隔离 + 压缩恢复双轨合同）

- **子代理上下文隔离是压缩治理边界，不是实现细节**：
  - Anthropic Subagents 文档明确子代理使用独立上下文窗口，且每次调用都会创建新实例；
  - 结论：主会话 compaction 不能默认覆盖子代理记忆面，必须维护 `main_context` 与 `subagent_context` 双轨账本。
- **resume 语义要求“转录连续”与“主会话连续”分开验收**：
  - 同文档明确可 `resume` 到已有 subagent，并保留完整交互历史；
  - 结论：恢复验收需并联两条 continuity check：`conversation continuity` + `subagent transcript continuity`。
- **subagent transcripts 的持久化与主对话 compaction 解耦**：
  - 文档明确 subagent transcripts 独立保存，不会被压缩进主对话；
  - 结论：compact 后若只验证主会话标识链，会漏检“子代理历史失配”。
- **运行时错误处理面在 SDK 间并不对称，需外层仲裁矩阵补齐**：
  - OpenAI Agents JS 文档明确 `errorHandlers` 目前仅支持 `maxTurns`；
  - 结论：非 `maxTurns` 异常（含交接/工具/外部 provider 失败）必须由外层控制面统一仲裁，不能假设 SDK 内建兜底。
- **交接输入过滤的兜底链必须显式写入恢复合同**：
  - OpenAI Python Handoffs 文档明确：当 handoff 未配置 `input_filter` 且 run 级 mapper 也缺失时，会回落到 `default_handoff_input_filter`；
  - 结论：恢复回放必须记录“本轮实际命中的 filter 层级”，避免重放时输入面漂移。
- **事件监听与状态持久化要在压缩前闭环**：
  - CrewAI 文档要求监听器在 `crew.py/flow.py` 导入加载，Flows `@persist` 支持重启恢复；
  - 结论：未加载监听器或未持久化状态时禁止进入自动 compaction，先补证据链再压缩。
- **Go 执行面同样落在同一元问题**：
  - `openai-agents-go` README 给出 `SessionStore`（memory/sqlite/redis）与 `MaxTurnsExceededError`；
  - 结论：多语言栈都需要统一 `compaction + replay + budget` 合同，而不是按语言分裂 pattern。
- **强制信源侧证（本轮）**：
  - `https://t.co/dwAiIjlXet` 重定向到 HN Popular Blogs OPML Gist；
  - HN `news/show/newest` 当窗条目继续聚焦 agent 生产化与长跑实践，支持本轮“同化不新建”判定。

## Cycle 121 同化增量（流式双阶段写入 + compaction 回传合同）

- **流式会话写入是双阶段，不是单事务**：
  - OpenAI Agents SDK JS Sessions 文档明确：streaming 过程中会先把 user input 写入 session，待流式完成后再写 assistant outputs；
  - 结论：恢复合同必须增加 `orphan_input_check`（输入已写入但输出未落盘）检测，避免重放时出现“半轮次”错判。
- **Compaction 执行语义是 best-effort，不应与主流程原子绑定**：
  - 同文档说明 `runCompaction` 可能因瞬时错误失败；
  - 结论：应将 compaction 失败记为 `compaction_debt` 并延后重试，而不是让主对话链路直接失败。
- **Claude 的 compaction 是“语义回传协议”，不是“自动黑箱”**：
  - Anthropic context windows 文档要求：收到 compaction block 后，后续请求必须原样回传该 block；compact 前旧上下文块会被忽略；
  - 结论：回放验收需新增 `compaction_block_echo_pass`，缺失即判定语义链断裂。
- **ZDR 与 compaction 的文档状态需版本化跟踪**：
  - 当前 Anthropic 文档注明 compaction 仍是 beta，同时声明可用于 ZDR arrangement；
  - 结论：治理层需记录 `docs_version + beta_header`，并在升级时强制重跑合规回放，防止沿用旧结论。
- **强制信源侧证（本轮）**：
  - `https://t.co/dwAiIjlXet` 仍重定向至 HN Popular Blogs OPML；
  - HN 当窗：`news=47206745`、`show=47203334`、`newest=47207987`，社区焦点继续聚集在“上下文预算与持久记忆治理”。

## 合并来源

- compaction recovery contract
- context burn replay-freeze
- comprehension budget / debt ratchet freeze
- OpenAI / Anthropic 官方文档与 HN 一线信号同化（cycle 93）

## 检索测试

- 查询：`compact 后 previous_response_id 断链怎么处理`
  - 命中：本 pattern
  - 动作：执行 `identifier continuity check + minimal evidence replay`
- 查询：`长任务 queued in_progress completed 恢复门禁`
  - 命中：本 pattern + `agent-scope-identity-memory-governance`
  - 动作：执行 `job lifecycle poll/cancel + checkpoint replay`
- 查询：`MemorySession 能不能直接上生产`
  - 命中：本 pattern
  - 动作：执行 `session backend tiering`，生产强制外置持久层
- 查询：`OpenAIResponsesCompactionSession stream completion delayed`
  - 命中：本 pattern
  - 动作：执行 `disable auto compact + between-turn compaction scheduling`
- 查询：`sessionInputCallback trim history before model call`
  - 命中：本 pattern
  - 动作：执行 `pre-send history window policy`，限制长跑输入窗口
- 查询：`handoff inputFilter removeAllTools avoid full history`
  - 命中：本 pattern + `agent-scope-identity-memory-governance`
  - 动作：执行 `minimum-transfer contract`，禁止默认全量透传
- 查询：`reasoningItemIdPolicy omit strict provider 400`
  - 命中：本 pattern
  - 动作：执行 `replay id policy=omit`，保证恢复链稳定
- 查询：`previous_response_id and conversation cannot both be used`
  - 命中：本 pattern
  - 动作：执行 `response-chain vs conversation mode` 二选一恢复合同
- 查询：`response object retention 30 days conversation items not affected`
  - 命中：本 pattern
  - 动作：执行 `response/conversation dual retention policy`
- 查询：`OpenAIResponsesCompactionSession should not wrap OpenAIConversationsSession`
  - 命中：本 pattern
  - 动作：执行 `compaction backend separation`，禁止双层会话混搭
- 查询：`runCompaction store responseId stream waits compaction`
  - 命中：本 pattern
  - 动作：执行 `explicit compaction options + stream SLA dual-budget`
- 查询：`subagent transcripts are persisted separately and not compacted into main conversation`
  - 命中：本 pattern
  - 动作：执行 `main/subagent dual continuity checks`，阻断单轨验收
- 查询：`each subagent invocation creates a new instance with a fresh context window`
  - 命中：本 pattern
  - 动作：执行 `subagent scope rotation + explicit rehydration policy`
- 查询：`errorHandlers currently only maxTurns`
  - 命中：本 pattern + `control-plane-conflict-governance`
  - 动作：执行 `non-maxTurns external arbitration matrix`
- 查询：`if no input_filter and no handoff_history_mapper default_handoff_input_filter`
  - 命中：本 pattern
  - 动作：执行 `effective filter layer snapshot` 并写入 replay artifact
- 查询：`streaming writes user input first then assistant outputs session`
  - 命中：本 pattern
  - 动作：执行 `orphan_input_check + half-turn replay guard`
- 查询：`runCompaction is best-effort transient errors`
  - 命中：本 pattern
  - 动作：执行 `compaction_debt queue + delayed retry`
- 查询：`must pass compaction block back in subsequent requests`
  - 命中：本 pattern
  - 动作：执行 `compaction_block_echo_pass + continuity fail-fast`
