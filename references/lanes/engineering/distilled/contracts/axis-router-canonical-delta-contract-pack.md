# Axis Router Canonical Delta Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述同时出现时，常见失真是把 liveness、semantic、lineage 三类问题塞进同一叙述链，导致读集膨胀、门禁错配与结论复写。

## 60s Compression Path
1. 先分轴再取证：入口问题必须先落到单一 `problem_axis`（`liveness|semantic|lineage`）。
2. 证据按门禁收敛：每个 axis 只允许读取该门禁最小证据集合，不跨轴扩读。
3. 结论改为 delta：同一 `incident_window_id` 只发布 `canonical_delta_ledger` 的增量卡片。
4. 发布只走 pointer：verdict 正文不重复写，统一指向 canonical 位置。
5. 漂移立即冻结：发现 axis 漂移或 lineage 不一致时，冻结新 verdict 并回退路由。

## Axis Router Delta Contract
1. Query axis lock:
`query_axis_card` 必含 `incident_window_id,lineage_id,problem_axis,owner_gate,question_digest`。
2. Gate-scoped readset:
`gate_readset_manifest.primary_evidence_count <= 3` 且必须标注 `axis_scope`。
3. Delta-only narration:
`canonical_delta_ledger` 仅允许 append delta，不允许覆盖历史正文。
4. Pointer publish parity:
`verdict_pointer_card` 必须携带 `lineage_id + head_sha + digest_set_id + delta_id`。
5. Drift freeze:
若 `problem_axis` 与当前 gate 不匹配，或 `actual_hit_ratio < min_hit_ratio`，触发 freeze。

## Minimal Evidence Bundle
- `query_axis_card.json`
- `gate_readset_manifest.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`
- `canonical_delta_ledger.json`
- `verdict_pointer_card.json`

## Hard Gates
- `single_axis_query_pass`
- `gate_scoped_readset_pass`
- `canonical_delta_only_pass`
- `pointer_lineage_parity_pass`
- `freeze_on_axis_drift_pass`

任一失败：阻断 `promote/merge/write`，并将当前 `incident_window_id` 置为 `freeze_pending`。

## Anti-Patterns
- 一个回答同时展开 continuity、semantic、lineage 全量解释。
- 为“防遗漏”跨轴扩读证据并重复结论。
- 在 verdict 层重写正文而非发布 delta pointer。
- recall 或 freshness 不达标仍继续发布新 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
