# Retry Epoch Causal Window Fence Pack

## Target Meta-Problem
当 `retry ETA`、`freshness window`、`lineage digest parity` 与 `promote/defer` 裁决被混写在同一轮叙述时，会出现三重退化：
- 阅读负担：需要跨 queue、semantic、artifact、recall 四类文档反复跳读，才能回答“现在为什么不能 promote”；
- 元问题混杂：调度层（何时重试）与裁决层（是否晋级）边界坍塌，导致错误修复路径；
- 重复叙述：每轮回放全量故障背景，真正变化的 `retry_epoch_delta` 与 `freshness_delta` 被淹没。

## 60s Compression Path
1. 四卡拆分：`scheduler_retry_card`、`freshness_window_card`、`lineage_digest_card`、`promotion_verdict_card`。
2. 时序围栏：`next_retry_at_utc` 必须晚于当前 `stale_detected_at_utc` 且处于 freshness 窗口内。
3. 同源围栏：`lineage_id + head_sha + digest_set_id + shard_epoch` 任一漂移即冻结晋级。
4. 裁决单写：`promote` 只能在 `retry_ready && freshness_pass && digest_lock_pass && recall_pass` 同时为 true 时输出。
5. 差量恢复：恢复轮只追加 `retry_epoch_delta + freshness_delta + verdict_delta`。

## Retry Epoch Fence Contract
1. Scheduler retry card:
`scheduler_retry_card.json` 必含 `cycle_id,stale_detected_at_utc,next_retry_at_utc,retry_budget_remaining,backpressure_mode`。
2. Freshness window card:
`freshness_window_card.json` 必含 `cycle_id,freshness_window_hours,oldest_required_artifact_at_utc,freshness_pass`。
3. Lineage digest card:
`lineage_digest_card.json` 必含 `lineage_id,head_sha,digest_set_id,shard_epoch,digest_lock_pass`。
4. Promotion verdict card:
`promotion_verdict_card.json` 必含 `cycle_id,decision,blocked_reason,retry_ready,recall_pass,semantic_pass,evidence_pass`。
5. Delta-only replay barrier:
恢复轮读取卡片超过 4 张则标记 `narrative_replay_overflow=true` 并强制 `decision=defer`。

## Minimal Evidence Bundle
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `backpressure_report.json`
- `scheduler_retry_card.json`
- `freshness_window_card.json`
- `lineage_digest_card.json`
- `promotion_verdict_card.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `index_shard_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭 fragment 可独立回答“何时重试、为何 defer、哪一层阻断、下一轮最小读集是什么”。
- `Fidelity`: 保留 stale/backpressure 调度约束、semantic/evidence 边界、artifact digest 同源锁与 recall 连续性。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 命名一致且双向回链。

任一 gate fail：禁止 `completed`，仅允许 `defer|block + delta`。

## Anti-Patterns
- 在一段文本里混写 retry 调度、freshness 评估与 promote 裁决。
- 缺少 `next_retry_at_utc` 仍输出 `decision=defer`。
- `digest_lock_pass=false` 仍进行语义晋级裁决。
- 恢复轮回放全量背景而不发布 `*_delta`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
