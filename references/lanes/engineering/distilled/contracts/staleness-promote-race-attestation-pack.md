# Staleness Promote Race Attestation Pack

## Target Meta-Problem
在 sleep 压缩长跑中，`stale-run` 信号与 `promote` 判定常发生时序竞态：
- 阅读负担：需要跨 heartbeat、semantic、recall、artifact 四组工件才能判断“到底能不能晋级”；
- 元问题混杂：运行时新鲜度失败与语义/证据闭环失败被混写为同一个问题；
- 重复叙述：每轮重复回放全量门禁说明，而不是写明确的竞态差量。

## 60s Compression Path
1. 三卡拆分：`staleness_card`、`promotion_intent_card`、`attestation_card`。
2. 同 epoch 栅栏：`lease_epoch == shard_epoch == digest_epoch` 才允许进入晋级判定。
3. 单裁决写口：仅 `attestation_card` 可给出最终 `promote|defer|block`。
4. 语义冻结：任一 freshness/recall 失败时强制冻结 `completed` 语义。
5. 差量叙述：恢复轮仅允许追加 `race_delta + verdict_delta + retry_delta`。

## Race Attestation Contract
1. Staleness card:
`staleness_card.json` 必含 `cycle_id,lease_owner,heartbeat_at,cursor_lag_seconds,stale_run,lease_epoch`。
2. Promotion intent card:
`promotion_intent_card.json` 必含 `cycle_id,promote_requester,semantic_pass,evidence_pass,prodlike_pass,requested_at_utc`。
3. Final attestation card:
`attestation_card.json` 必含 `cycle_id,shard_epoch,digest_epoch,recall_hit_ratio,decision,blocked_reason,next_retry_at_utc`。
4. Epoch parity barrier:
`lease_epoch == shard_epoch == digest_epoch` 失败即 `decision=block`。
5. Deferred replay budget:
恢复轮最多读取三张增量卡，超预算标记 `narrative_replay_overflow=true`。

## Minimal Evidence Bundle
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `staleness_card.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `attestation_card.json`

## Hard Gates
- `Self-Containment`: 仅凭 fragment 可回答“本轮为何不能 promote、阻断落在哪一层、下一轮最小恢复读集是什么”。
- `Fidelity`: 保留 lease/heartbeat 新鲜度、requirement/assertion 语义闭环、artifact digest 同源、shard/recall 连续性与 prod-like 边界。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 四点双向回链一致。

任一 gate fail：禁止输出 `completed` 结论，只允许 `defer/block + delta`。

## Anti-Patterns
- 在同一段同时混写 stale-run、semantic conformance、promotion verdict。
- `stale_run=true` 或 `recall_hit_ratio` 未达阈值时仍输出 `promote`。
- 缺少 `blocked_reason` 与 `next_retry_at_utc` 直接要求下一轮继续。
- 恢复轮继续粘贴全量 narrative，不输出竞态差量。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
