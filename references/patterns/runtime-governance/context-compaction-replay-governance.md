---
name: context-compaction-replay-governance
topic: runtime-governance
confidence: 0.81
verified_count: 14
sources:
  - OpenAI API Conversation state docs (`store=true`, conversation id continuity) (2026-03-01)
  - OpenAI API Background mode docs (queued/in_progress/completed + poll/cancel) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (`MemorySession` vs persistent session backends) (2026-03-01)
  - OpenAI Agents SDK JS Sessions docs (`sessionInputCallback` + compaction scheduling guidance) (2026-03-01)
  - OpenAI Agents SDK JS Handoffs docs (`inputFilter`, default full history forwarding) (2026-03-01)
  - OpenAI Agents SDK JS Running agents docs (`reasoningItemIdPolicy` strict-provider recovery) (2026-03-01)
  - Anthropic Claude Code SDK docs（context window management + auto-compacting strategies）(2026-03-01)
  - HN top/show/new snapshots (2026-03-01)
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (redirect verified 2026-03-01)
  - HN news（MCP server context-preservation field report）(2026-03-01)
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
