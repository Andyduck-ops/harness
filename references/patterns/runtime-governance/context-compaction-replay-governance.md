---
name: context-compaction-replay-governance
topic: runtime-governance
confidence: 0.81
verified_count: 11
sources:
  - OpenAI API Conversation state docs (`store=true`, conversation id continuity) (2026-03-01)
  - OpenAI API Background mode docs (queued/in_progress/completed + poll/cancel) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (`MemorySession` vs persistent session backends) (2026-03-01)
  - Anthropic Claude Code SDK docs（context window management + auto-compacting strategies）(2026-03-01)
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
