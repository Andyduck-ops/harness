---
name: long-context-index-sharding-recall-rollback-contract
topic: runtime-governance
evidence_band: medium
verified_count: 8
sources:
  - context-compaction-replay-governance (cycle 127 cross-check)
  - agent-scope-identity-memory-governance (cycle 127 cross-check)
  - control-plane-conflict-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
  - Temporal Docs: continue-as-new
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Analyst/Cartographer L2/L5 verdict (cycle 139)
last_verified: 2026-03-02
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
| `history_budget_report.json` | `lineage_id`, `event_history_count`, `history_size_bytes`, `continue_as_new_threshold`, `segment_seq`, `rollover_pass` | 超预算未分段或未触发 continue-as-new |

## 阻断门禁

- `context_continuity_pass`
  - 失败条件：分片版本断链、摘要不一致、回滚后关键断言失败。
- `index_recall_fidelity_pass`
  - 失败条件：召回命中率低于阈值、召回分片与 lineage 不同源。
- `rollback_integrity_pass`
  - 失败条件：回滚目标 epoch 未签名、checkpoint 摘要不一致。
- `history_budget_rollover_pass`
  - 失败条件：`event_history_count/history_size_bytes` 超预算且未执行 `continue-as-new`。

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

## Cycle 137 同化增量（History Budget Rollover）

### 空白判定

此前仅覆盖 shard/recall/rollback 一致性，缺少“长运行历史预算”超阈后的分段续跑合同，恢复链在超长运行下仍有失稳风险。

### 核心补丁

- 新增 `history_budget_report.json`，记录 `event_history_count/history_size_bytes/continue_as_new_threshold/segment_seq`。
- 新增 `history_budget_rollover_pass`，明确超预算必须 `continue-as-new`，否则阻断。

## Cycle 139 同化增量（Budget Overflow Telemetry）

### 空白判定

cycle 137 已有预算超阈阻断，但缺少“超阈前告警/硬超阈事件”的可审计字段，
无法区分“提前收敛失败”与“突发超限”。

### 核心补丁

- `history_budget_report.json` 新增：
  - `warn_limit_events`
  - `hard_limit_events`
  - `hard_limit_bytes`
  - `rollover_triggered_at`
- `history_budget_rollover_pass` 增加失败条件：
  - `hard_limit_events > 0` 且 `rollover_triggered_at` 缺失；
  - `hard_limit_bytes` 超阈但未进入下一段 `segment_seq+1`。

## 合并来源

- compaction recovery contract
- agent scope identity memory governance
- control-plane conflict governance
- cycle 128 空白补齐（runtime-governance）
