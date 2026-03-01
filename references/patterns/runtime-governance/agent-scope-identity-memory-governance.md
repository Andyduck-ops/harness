---
name: agent-scope-identity-memory-governance
topic: runtime-governance
confidence: 0.85
verified_count: 14
sources:
  - OpenAI Agent Platform docs (Python/TypeScript/Go support) (2026-03-01)
  - OpenAI Agents SDK Sessions docs (2026-03-01)
  - OpenAI Agents SDK Handoffs docs (2026-03-01)
  - OpenAI API Background mode guide (2026-03-01)
  - OpenAI API Conversations / conversation state docs (2026-03-01)
  - Anthropic Agent SDK / tool use docs (2026-03-01)
  - CrewAI Flows persistence docs (2026-03-01)
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
- Kode SDK：本轮未检索到稳定的一手官方文档证据链，暂不单列为新 pattern，维持同化待补证据状态。

## Cycle 90 压缩同化增量

- **OpenAI Sessions 的生产边界更清晰**：`OpenAIConversationsSession` 与 `MemorySession` 的角色区分是核心断裂点；后者仅适合本地开发，生产需替换为可恢复的外部会话后端。
- **Compaction 不是“纯优化”，是一致性风险面**：`OpenAIResponsesCompactionSession` 会清空并重写底层会话，且文档明确不应与 `OpenAIConversationsSession` 组合。上线前必须把 compaction 作为状态迁移来验收（replay + invariant）。
- **Handoff 必须合同化而不是提示词化**：`handoff()` 明确支持 `inputType` 与 `inputFilter`，可把“交接最小输入”从软约定升级为硬约束。
- **后台长任务恢复模型已可标准化**：background mode 的 `background=true + poll + cancel` 给出统一恢复面；并且存在约 10 分钟数据保留与 ZDR 不兼容约束，需在合规层前置分流。
- **会话跨设备/跨作业复用可直接落地**：Conversations API 的 durable identifier 能把“单进程记忆”升级为“跨运行单元记忆”。

## 合并来源

- agent scope drift severity budget
- external identity lease replay
- agent state cell replay envelope
- agent memory partition least-privilege
- OpenAI/CrewAI/Anthropic/ADK 官方文档中关于 state persistence、handoff、async recovery 的一手规范
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
