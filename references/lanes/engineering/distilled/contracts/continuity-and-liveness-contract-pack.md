# Continuity and Liveness Contract Pack

## Target Meta-Problem
如何避免“系统看起来在运行，但实际已失真/失活/失配版本”的隐性失败。

## One-Page Contract
1. Ownership continuity:
`lease_owner + lease_expire_at + lease_version` 必须可核对，过期租约提交一律阻断。
2. Liveness continuity:
`heartbeat_at + cursor_lag_seconds + stale_run` 必须持续新鲜，`stale_run=true` 禁止晋级。
3. Memory continuity:
`lineage_id + shard_epoch + shard_digest` 必须连续，召回必须产出 `recall_manifest`。
4. Recovery continuity:
回滚必须绑定 `rollback_target_epoch + checkpoint_digest`，回滚后必须 `continuity_replay_pass=true`。
5. Pressure continuity:
队列深度/错误率越界后必须降并发并冻结非恢复路径，避免债务扩散。

## Minimal Evidence Bundle
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `backpressure_report.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Blocking Gates (Hard)
- `background_freshness_pass`
- `backpressure_guard_pass`
- `index_recall_fidelity_pass`
- `rollback_integrity_pass`

任一失败，停止 `promote/merge/write`。

## Fast Triage Playbook
1. 先查 freshness：`stale_run`、`cursor_lag_seconds`、`lease_expire_at`。
2. 再查 recall：`actual_hit_ratio` 是否低于 `min_hit_ratio`。
3. 最后查 rollback：`checkpoint_digest` 与 `continuity_replay_pass`。

## Anti-Patterns
- 仅看“进程存活”不看 freshness。
- 允许过期 lease 继续写结果。
- 召回未达阈值仍继续写新状态。
- 回滚后不做 continuity replay。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
