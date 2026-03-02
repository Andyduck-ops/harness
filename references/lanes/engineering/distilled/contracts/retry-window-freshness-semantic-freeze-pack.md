# Retry Window Freshness Semantic Freeze Pack

## Target Meta-Problem
守护循环进入 deferred/retry 状态后，若 `retry window`、`freshness window`、`gate verdict` 被写在同一叙述层：
- 阅读负担：读者无法在 60 秒内判断“这是新重试还是旧叙述回放”；
- 元问题混杂：调度重试、语义符合性、证据时效、回滚连续性被混为一个问题；
- 重复叙述：每轮复制全量上下文，增量变化被淹没。

## 60s Compression Path
1. 双卡分离：`retry_window_card` 与 `gate_verdict_card` 分开记录，不在同段混写。
2. 显式 epoch：每次重试写 `retry_epoch` 与 `retry_reason_code`，禁止无编号重试叙述。
3. 时效冻结：`freshness_window_pass=false` 时冻结完成语义，仅允许 `deferred|blocked`。
4. 三元对齐：`lease_freshness + lineage_digest + recall_epoch` 通过前不允许 promote 结论。
5. 增量回放：恢复轮只追加 `retry_delta + verdict_delta + evidence_delta`。

## Retry-Freshness Contract
1. Retry window card:
`retry_window_card.json` 必含 `cycle_id,retry_epoch,retry_reason_code,next_retry_at_utc,retry_budget_remaining`。
2. Gate verdict card:
`gate_verdict_card.json` 必含 `semantic_pass,evidence_pass,prodlike_pass,rollback_pass,final_state`。
3. Freshness semantic freeze:
`freshness_window_pass=false` 时，`final_state` 只能是 `deferred|blocked`。
4. Retry intent append-only:
`retry_intent_ledger.json` 仅允许追加，不得覆盖历史 `retry_epoch` 裁决。
5. Delta replay budget:
重试恢复读集最多三张增量卡，超出预算标记 `narrative_replay_overflow=true`。

## Minimal Evidence Bundle
- `retry_window_card.json`
- `gate_verdict_card.json`
- `retry_intent_ledger.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Hard Gates
- `Self-Containment`: 仅凭 fragment 可回答“本轮是否可继续重试、为何冻结、下一轮最小恢复读集是什么”。
- `Fidelity`: 保留 lease/heartbeat、新鲜度窗口、lineage digest、prod-like 边界、recall/rollback 约束映射。
- `Index Integrity`: contract、provenance、index、retrieval shortcut 四点可双向回链。

任一 gate fail：禁止输出完成结论，仅允许发布 `deferred retry delta`。

## Anti-Patterns
- 在同一段里同时描述 retry 调度、gate 裁决与恢复动作。
- `freshness_window_pass=false` 仍输出 `final_state=completed`。
- 重试轮回放全量 narrative，不写 `retry_epoch` 与 `retry_reason_code`。
- 覆盖历史 `retry_intent_ledger` 导致证据断链。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
