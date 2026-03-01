---
name: background-agent-runplane-lease-heartbeat-dlq-backpressure
topic: autonomous-ops
evidence_band: medium
verified_count: 4
sources:
  - 24h-unattended-ai-loop (cycle 127 cross-check)
  - audit-gated-autonomy (cycle 127 cross-check)
  - control-plane-conflict-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
last_verified: 2026-03-01
rank: 3
---

## 元问题

Background agent 能持续运行不等于可控运行。
缺失 lease/heartbeat/DLQ/backpressure 时，系统会在“看似活着”的状态下积累不可见债务。

## 核心解法

建立 `Runplane Lease-Heartbeat-DLQ-Backpressure Contract`：

1. **Lease 所有权**
   - 每个 worker 领取任务时写入 `lease_owner`、`lease_expire_at`。
   - 失效 lease 自动回收，禁止幽灵 worker 继续提交结果。
2. **Heartbeat 新鲜度**
   - worker 周期上报 `heartbeat_at` 与 `cursor_lag_seconds`。
   - 超过滞后预算直接标记 `stale-run`。
3. **Dead Letter Queue（DLQ）**
   - 重试超过阈值或 poison message 进入 DLQ。
   - DLQ 任务必须带 `failure_signature` 和 `retry_history`。
4. **Backpressure 节流**
   - 当队列深度或错误率超阈值时自动降并发。
   - 超限时拒绝新任务晋级，只允许恢复路径执行。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `runplane_lease_registry.json` | `run_id`, `lease_owner`, `lease_expire_at`, `lease_version` | 过期 lease 仍提交结果 |
| `heartbeat_status.json` | `run_id`, `heartbeat_at`, `cursor_lag_seconds`, `stale_run` | `stale_run=true` 仍晋级 |
| `dlq_manifest.json` | `run_id`, `message_id`, `failure_signature`, `retry_count`, `dlq_reason` | poison message 未入 DLQ |
| `backpressure_report.json` | `queue_depth`, `error_rate`, `concurrency_cap`, `backpressure_mode` | 超阈值但未降并发 |

## 阻断门禁

- `background_freshness_pass`
  - 失败条件：`cursor_lag_seconds` 超预算、`stale_run=true`、lease 过期。
- `dlq_integrity_pass`
  - 失败条件：重试超阈值任务未进入 DLQ、failure signature 缺失。
- `backpressure_guard_pass`
  - 失败条件：错误率升高但并发上限未收敛、队列持续膨胀。

## 检索测试（L5）

- 查询：`background agent lease heartbeat stale run gate`
  - 命中：本 pattern
  - 动作：启用 `background_freshness_pass` 阻断
- 查询：`poison message retry dead letter queue governance`
  - 命中：本 pattern
  - 动作：写入 `dlq_manifest` 并停止主队列重试
- 查询：`backpressure queue depth error rate concurrency cap`
  - 命中：本 pattern + `audit-gated-autonomy`
  - 动作：触发 `backpressure_mode`，仅保留恢复任务

## 合并来源

- 24h unattended loop
- audit-gated autonomy
- control-plane conflict governance
- cycle 128 空白补齐（autonomous-ops）
