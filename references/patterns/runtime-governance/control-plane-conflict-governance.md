---
name: control-plane-conflict-governance
topic: runtime-governance
confidence: 0.80
verified_count: 10
sources:
  - OpenAI API Background mode docs（cancel idempotency / store=true requirement / stream cursor resume constraints）(2026-03-01)
  - OpenAI Agents SDK running config docs（nest_handoff_history default-off + handoff_history_mapper precedence）(2026-03-01)
  - OpenAI Agents SDK handoffs docs（handoff input_filter override and transcript shaping）(2026-03-01)
  - Anthropic Claude Code hooks docs（Stop/SubagentStop decision control + stop_hook_active）(2026-03-01)
  - Anthropic Claude Code subagents docs（separate context window）(2026-03-01)
  - CrewAI Flows docs（@persist for state recovery）(2026-03-01)
  - CrewAI Event Listeners docs（event bus + BaseEventListener）(2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "How to write deterministic code and tests with AI (2025)")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: llm-d: Kubernetes-Native Distributed Inference at Scale")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "How to write deterministic code and tests with AI (2025)")
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01)
  - control-plane-governance cluster (cycles 70-87)
  - ci-governance cluster (cycles 70-87)
last_verified: 2026-03-01
rank: 3
---

## 元问题

冲突治理常见失败是：入口不完整、仲裁无时限、恢复后重复进入僵局。

## 核心解法

把冲突治理做成控制面合同：
- 冲突入口结构化必填；
- 冲突账本冻结 + SLA tombstone；
- 仲裁后走双相复验（reverify + reapprove）。

## Cycle 108 同化增量：停止/取消/压缩并发冲突的优先级合同

目标：解决长跑会话里最常见的控制面冲突
（`cancel`、`stop hook`、`compact`、`handoff` 同时发生时谁先执行、谁可覆盖）。

1. 取消语义必须是可重放且幂等
   - OpenAI background mode 明确 `cancel` 可重复调用并返回最终 Response；
   - 控制面动作：把 `cancel_request_id` 和最终 `final_status` 记录为同一冲突项，禁止重复取消触发二次副作用。
2. 恢复能力与“无状态模式”天然冲突
   - OpenAI background mode 明确后台采样要求 `store=true`，无状态请求会被拒绝；
   - 控制面动作：把 `durability_mode` 作为冲突入口必填字段，显式在“可恢复”与“最小留存”之间做仲裁。
3. 流式恢复存在创建时前置条件
   - OpenAI background mode 要求只有创建时 `stream=true` 的后台任务才能后续重连流式事件；
   - 控制面动作：冲突账本必须记录 `stream_capability`，否则恢复策略默认降级为 poll-only。
4. 交接压缩策略需要明确优先级
   - OpenAI Agents SDK 中 `nest_handoff_history` 默认关闭，且显式 `input_filter` 优先于 run-level 映射；
   - 控制面动作：仲裁矩阵固定为 `handoff.input_filter > run.handoff_history_mapper > default history`，避免不同 agent 配置互相覆盖。
5. 停止钩子必须有防递归保护位
   - Anthropic hooks 文档给出 `Stop/SubagentStop` 可阻止停止，并提供 `stop_hook_active` 防止无限循环；
   - 控制面动作：`stop_hook_active=true` 时禁止再次发起阻塞型 stop 决策，直接转人工或超时 tombstone。
6. 事件总线与持久化是冲突取证基线
   - CrewAI event bus + `BaseEventListener`、Flows `@persist` 说明冲突事件应先落盘再仲裁；
   - 控制面动作：未落盘事件不得进入“仲裁完成”状态，防止事后不可审计。

## 最小冲突账本字段（新增）

| 字段 | 说明 | 阻断条件 |
|---|---|---|
| `conflict_id` | 冲突唯一 ID | 缺失 |
| `action_set[]` | 并发控制动作（cancel/stop/compact/handoff） | 空集合 |
| `priority_matrix_version` | 仲裁优先级版本 | 未登记 |
| `durability_mode` | `stateful` / `stateless` | 未声明 |
| `stream_capability` | `stream_resumable` / `poll_only` | 与恢复策略不一致 |
| `stop_hook_active_seen` | 是否触发过 stop 递归保护 | 冲突后未记录 |
| `arbitration_decision` | 最终仲裁动作 | 空值 |
| `reverify_pass` | 双相复验结果 | `false` 仍放行 |

## 合并来源

- conflict intake required form
- contradiction ledger freeze / SLA tombstone
- conflict arbitration dual-phase contract
- required-check pending deadlock
- background cancel idempotency + stream resumability constraints
- nested handoff precedence + stop-hook recursion guard
- event-bus evidence persistence before arbitration

## Cycle 108 检索锚点（L5）

- `background cancel idempotent store=true conflict`
- `stream=true cursor resume background response`
- `stream=true starting_after resume events`
- `nest_handoff_history input_filter precedence`
- `Stop SubagentStop stop_hook_active recursion`
- `stop_hook_active SubagentStop recursion`
- `event bus persist before arbitration`

## 检索测试

- 查询：`cancel 与 stop hook 同时触发怎么裁决`
  - 命中：本 pattern
  - 动作：执行 `priority_matrix`（cancel/stop/compact/handoff）并写入 `arbitration_decision`
- 查询：`为什么背景任务恢复失败但轮询可用`
  - 命中：本 pattern
  - 动作：检查 `store=true` 与 `stream_capability`，必要时降级 `poll_only`
- 查询：`handoff 历史压缩配置冲突怎么排查`
  - 命中：本 pattern
  - 动作：按 `input_filter > handoff_history_mapper > default` 复验并回放
