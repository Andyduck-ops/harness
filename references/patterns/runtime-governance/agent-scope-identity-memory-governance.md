---
name: agent-scope-identity-memory-governance
topic: runtime-governance
confidence: 0.82
verified_count: 12
sources:
  - OpenAI Agents SDK Sessions docs (2026-03-01)
  - OpenAI Agents SDK Handoffs docs (2026-03-01)
  - OpenAI API Background mode guide (2026-03-01)
  - OpenAI API Conversations / conversation state docs (2026-03-01)
  - Anthropic tool runner docs (2026-03-01)
  - CrewAI Flows persistence docs (2026-03-01)
  - Google ADK Go quickstart + A2A quickstart (2026-03-01)
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
| 多 agent 交接串台 | OpenAI Handoffs（工具化交接 + input filter）、ADK A2A | 交接包最小化 + 主体签名 + 仅传必要输入 |
| 长任务超时/断连 | OpenAI background mode（queued/in_progress/final + cancel） | 用异步任务 ID 做幂等恢复，禁止“重跑覆盖” |
| 长跑上下文退化 | Anthropic tool runner 自动状态管理/自动 compaction、OpenAI conversation state | 压缩触发阈值 + 压缩前后不变量校验 + 回放抽检 |

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
