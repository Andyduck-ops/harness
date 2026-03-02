---
name: background-agent-dag-checkpoint-resume-idempotency-gate
topic: autonomous-ops
evidence_band: medium
verified_count: 18
sources:
  - background-agent-runplane-lease-heartbeat-dlq-backpressure (cycle 128 baseline)
  - background-agents.com product site
  - Background Agents Docs (backgroundagents.dev)
  - Cursor Docs: Background Agent executions and resume flow
  - Cursor Docs: restoring queued or failed tasks
  - LangGraph Docs: persistence/checkpointer/thread_id
  - Inngest Docs: multi-step function idempotent replay
  - Scout/Analyst/Cartographer team synthesis (cycle 131)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
  - Microsoft Agent Framework Docs: background responses and continuation token
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Microsoft Agent Framework Docs: continuation token expiry window
  - Analyst/Cartographer L2/L5 verdict (cycle 138)
  - OpenAI Docs: background mode guide (status + stream resume cursor)
  - OpenAI Docs: webhooks guide (response.completed 签名校验)
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
  - Scout/Analyst/Cartographer team synthesis (cycle 147)
  - lane long-run recovery incident notes (cycle 131)
last_verified: 2026-03-02
rank: 3
---

## 元问题

长任务系统即使有 lease/heartbeat，仍会在 DAG 依赖、checkpoint 断点和重放幂等上失守：
恢复后重复执行副作用步骤，或跳过关键前置节点，导致“任务完成但状态损坏”。

## 核心解法

建立 `Background-Agent DAG Checkpoint-Resume-Idempotency Contract`：

1. **DAG 闭包执行**
   - 每个节点执行前验证依赖闭包，禁止“未满足依赖先执行”。
2. **Checkpoint 单调性**
   - checkpoint 必须单调前进并绑定 `run_id + dag_node + step_seq + head_sha`。
3. **Resume 最近可验证点**
   - 恢复只能从 `last_good_checkpoint` 开始，禁止从不可信游标恢复。
4. **幂等重放审计**
   - 对可副作用节点要求 `idempotency_key`，重放后状态摘要必须稳定。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `dag_run_manifest.json` | `run_id`, `dag_id`, `node_id`, `deps[]`, `deps_satisfied`, `head_sha` | 依赖未满足仍执行节点 |
| `checkpoint_manifest.json` | `run_id`, `thread_id`, `node_id`, `step_seq`, `checkpoint_digest`, `checkpoint_id`, `created_at_utc`, `last_good`, `continuation_token`, `token_issued_at`, `token_expires_at_utc`, `token_scope` | checkpoint 逆序、thread 锚点缺失、continuation token 缺失、过期或 scope 不合法 |
| `resume_replay_report.json` | `run_id`, `resume_from_checkpoint`, `replayed_nodes[]`, `replay_pass`, `drift_detected`, `resumed_by_token`, `token_match_pass` | 恢复点非法、token 不匹配或重放漂移 |
| `idempotency_audit_report.json` | `run_id`, `node_id`, `idempotency_key`, `state_digest_before`, `state_digest_after`, `idempotency_pass` | 副作用节点无幂等键或重放不稳定 |
| `step_run_manifest.json` | `run_id`, `thread_id`, `step_id`, `step_idempotency_key`, `side_effect_count`, `out_of_step_effects[]` | step 粒度幂等键缺失或副作用发生在 step 外 |

## 阻断门禁

- `dag_dependency_closure_pass`
  - 失败条件：任一节点 `deps_satisfied=false` 仍继续执行。
- `checkpoint_continuity_pass`
  - 失败条件：checkpoint 不连续、`last_good` 不可定位。
- `thread_checkpoint_scope_pass`
  - 失败条件：恢复链缺失 `thread_id + checkpoint_id` 锚点或发生跨 thread 回放。
- `continuation_token_resume_integrity_pass`
  - 失败条件：恢复请求缺少 `continuation_token`，或 `token_scope` 与 `run_id/thread_id` 不一致。
- `continuation_token_expiry_pass`
  - 失败条件：`token_expires_at_utc <= now` 仍尝试恢复，或 token 过期窗口不可审计。
- `resume_idempotency_pass`
  - 失败条件：恢复后出现状态漂移或 `idempotency_pass=false`。
- `single_side_effect_step_pass`
  - 失败条件：关键副作用步骤 `side_effect_count != 1` 或出现 `out_of_step_effects`。

## 最小验收矩阵

- 正常：依赖闭包满足，checkpoint 连续，恢复重放稳定 -> 允许晋级。
- 边界：恢复成功但出现非关键节点重复执行 -> 警告并限期修复。
- 异常：关键节点重放非幂等或依赖断裂 -> 阻断。

## 检索测试（L5）

- 查询：`background agents dag checkpoint resume idempotency gate`
  - 命中：本 pattern
  - 动作：执行 DAG 闭包 + checkpoint 连续 + 幂等审计三联门禁。
- 查询：`resume after long task duplicated side effects`
  - 命中：本 pattern + `background-agent-runplane-lease-heartbeat-dlq-backpressure`
  - 动作：触发 `resume_idempotency_pass` 阻断并输出审计报告。
- 查询：`checkpoint corruption in queued background task`
  - 命中：本 pattern
  - 动作：定位 `last_good_checkpoint` 并执行受控恢复。

## Cycle 137 同化增量（Continuation Token Resume Integrity）

### 空白判定

cycle 136 已具备 `thread_id + checkpoint_id` 锚点，但缺少 continuation token 的签发域、恢复匹配与审计链。

### 核心补丁

- `checkpoint_manifest.json` 补 `continuation_token/token_issued_at/token_scope`。
- `resume_replay_report.json` 补 `resumed_by_token/token_match_pass`。
- 新增阻断门禁 `continuation_token_resume_integrity_pass`，把“可恢复”升级为“按正确 token 恢复”。

## Cycle 138 同化增量（Continuation Token Expiry Contract）

### 空白判定

cycle 137 已校验 token 匹配与 scope，但仍缺 token 生命周期门禁。
恢复流程若未校验过期窗口，可能在“token 结构正确”但“token 已失效”时产生伪恢复。

### 核心补丁

- `checkpoint_manifest.json` 新增 `token_expires_at_utc`。
- 新增阻断门禁 `continuation_token_expiry_pass`，将“可匹配”升级为“可匹配且未过期”。
- 对超时恢复路径强制生成 `resume_replay_report.timeout_reason`（用于后续 backfill 对账）。

## Cycle 139 同化增量（Cursor Resume + Webhook Completion）

### 空白判定

cycle 138 已补 token 过期窗口，但恢复链仍偏“轮询中心”：
缺少流式游标续传与事件完成回调的审计字段，可能出现“任务已完成但消费端漏收”。

### 核心补丁

- `resume_replay_report.json` 新增：
  - `last_sequence_number`
  - `resume_starting_after`
  - `resume_latency_ms`
  - `resume_attempt`
- 新增 `background_webhook_delivery.json`：
  - `webhook_event_type`
  - `webhook_signature_valid`
  - `response_completed_at`
  - `event_idempotency_key`
- 新增阻断门禁：
  - `stream_cursor_resume_integrity_pass`
    - 失败条件：存在恢复续传但缺少 `last_sequence_number` 或 `resume_starting_after`。
  - `webhook_completion_consistency_pass`
    - 失败条件：`response.completed` 已到达但签名校验失败或回放账本缺失。

## Cycle 147 同化增量（Continuation Token Clock Skew Guard）

### 空白判定

cycle 139 已覆盖 token 匹配、过期与回调一致性，但仍未约束“签发端与消费端时钟偏差”。
分布式执行中可能出现 token 未过期却被误判过期，或已过期但仍被放行的灰区。

### 核心补丁

- `checkpoint_manifest.json` 新增：
  - `issuer_clock_utc`
  - `token_ttl_ms`
- `resume_replay_report.json` 新增：
  - `consumer_clock_utc`
  - `clock_skew_ms`
  - `skew_budget_ms`
  - `token_ttl_remaining_ms`
- 约束：`token_ttl_remaining_ms` 的计算必须显式使用 `clock_skew_ms` 校正值。

### 新增阻断门禁

- `continuation_token_clock_skew_guard_pass`
  - 失败条件：`abs(clock_skew_ms) > skew_budget_ms`，或 `token_ttl_remaining_ms` 未基于偏差校正计算。

### 本轮状态

- token 恢复链升级为 `scope + expiry + clock_skew` 三联门禁。
- 仍需后续 round-2 连续实测工件验证该门禁在跨 runner 下的稳定性。

## 合并来源

- background runplane baseline pattern
- background-agents 公开文档与恢复语义
- LangGraph checkpointer/thread persistence
- Inngest step.run idempotent replay
- cycle 131 空白补齐（autonomous-ops）
- cycle 133 同化更新（thread anchor + step idempotency）
- Microsoft Agent Framework Docs: continuation token 24h expiry 语义
- cycle 138 Analyst/Cartographer 同化裁决（token expiry hardening）
- OpenAI background mode guide（stream cursor resume）
- OpenAI webhooks guide（completion callback + signature）
- cycle 147 Scout/Analyst/Cartographer synthesis（token clock skew 审计合同）
