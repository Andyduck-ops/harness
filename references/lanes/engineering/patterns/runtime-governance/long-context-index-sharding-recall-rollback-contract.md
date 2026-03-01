---
name: long-context-index-sharding-recall-rollback-contract
topic: runtime-governance
evidence_band: medium
verified_count: 4
sources:
  - context-compaction-replay-governance (cycle 127 cross-check)
  - agent-scope-identity-memory-governance (cycle 127 cross-check)
  - control-plane-conflict-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
last_verified: 2026-03-01
rank: 3
---

## 元问题

长上下文会话在持续压缩和跨轮恢复后，常见失败不是“查不到内容”，而是：
查到了错误版本、错误分片，或者回滚到不一致状态。

## 核心解法

建立 `Index-Shard Recall Rollback Contract`，把记忆索引从“隐式文本连续”升级为“可验证版本连续”：

1. **分片合同（Sharding Contract）**
   - 每个索引分片固定 `lineage_id + shard_id + shard_epoch`。
   - 分片更新必须写入 `shard_digest` 与 `generated_at_utc`。
2. **召回合同（Recall Contract）**
   - 每次召回必须产出 `recall_manifest`，记录命中的 shard 列表和分片版本。
   - 召回命中低于阈值时禁止继续执行写操作。
3. **回滚合同（Rollback Contract）**
   - 回滚必须绑定 `rollback_target_epoch` 与 `rollback_checkpoint_digest`。
   - 回滚后强制执行 `continuity replay`，验证关键断言。
4. **漂移冻结（Drift Freeze）**
   - 若 `recall_manifest` 与当前 `head_sha` 不一致，直接触发 `freeze`。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `index_shard_manifest.json` | `lineage_id`, `shard_id`, `shard_epoch`, `shard_digest`, `head_sha` | 分片摘要与当前索引不一致 |
| `recall_manifest.json` | `lineage_id`, `query_id`, `hit_shards[]`, `min_hit_ratio`, `actual_hit_ratio` | `actual_hit_ratio < min_hit_ratio` |
| `rollback_attestation.json` | `lineage_id`, `rollback_target_epoch`, `checkpoint_digest`, `continuity_replay_pass` | 回滚后 replay 失败 |

## 阻断门禁

- `context_continuity_pass`
  - 失败条件：分片版本断链、摘要不一致、回滚后关键断言失败。
- `index_recall_fidelity_pass`
  - 失败条件：召回命中率低于阈值、召回分片与 lineage 不同源。
- `rollback_integrity_pass`
  - 失败条件：回滚目标 epoch 未签名、checkpoint 摘要不一致。

## 检索测试（L5）

- 查询：`long context shard recall wrong version rollback gate`
  - 命中：本 pattern
  - 动作：执行 `recall_manifest + rollback_attestation` 双证据阻断
- 查询：`compaction after recall shard drift freeze`
  - 命中：本 pattern + `context-compaction-replay-governance`
  - 动作：召回漂移时触发 `freeze` 并停止晋级
- 查询：`lineage shard epoch continuity replay`
  - 命中：本 pattern
  - 动作：验证 `lineage_id + shard_epoch` 连续性

## 合并来源

- compaction recovery contract
- agent scope identity memory governance
- control-plane conflict governance
- cycle 128 空白补齐（runtime-governance）
