# Gate Surface Readpath Attestation Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂与重复叙述叠加时，常见根因是同一条 incident 叙述同时承担 freshness、semantic、evidence、prod-like、recall/rollback 五类门禁说明，导致读路径膨胀与裁决不可复用。

## 60s Compression Path
1. 先写 `gate_query_card`，只声明 `incident_window_id + owner_gate + target_decision`。
2. 立即拆成五个 gate capsule：`freshness`、`semantic`、`evidence_lineage`、`prodlike_replay`、`recall_rollback`。
3. 五个 capsule 共用单一 `evidence_nucleus`，禁止各自复制证据字段。
4. 同窗口只发布 `verdict_delta_pointer`，禁止重复全量叙述。
5. 发布前执行 replay+parity 联合门，失败即 `release_frozen`。

## Gate Surface Contract
1. Query-to-gate routing:
`gate_query_card` 必含 `incident_window_id,lineage_id,owner_gate,target_decision,query_digest`。
2. Surface separation:
五类 gate capsule 必须单独成文，单文档不得混写跨 gate 结论。
3. Shared evidence nucleus:
全部 capsule 必须绑定同一 `head_sha + digest_set_id + evidence_epoch`。
4. Delta-only verdict ledger:
同一 `incident_window_id + owner_gate` 每轮只允许一条 `verdict_delta_pointer`。
5. Replay before release:
`continuity_replay_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && index_recall_fidelity_pass` 全为 true 才可发布。

## Minimal Evidence Bundle
- `gate_query_card.json`
- `freshness_gate_capsule.json`
- `semantic_gate_capsule.json`
- `evidence_lineage_gate_capsule.json`
- `prodlike_replay_gate_capsule.json`
- `recall_rollback_gate_capsule.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `replay_repro_bundle.json`
- `recall_manifest.json`
- `rollback_attestation.json`
- `verdict_delta_pointer.json`

## Hard Gates
- `surface_self_contained_pass`
- `surface_boundary_separation_pass`
- `shared_evidence_parity_pass`
- `delta_verdict_dedup_pass`
- `release_replay_parity_pass`

任一失败：阻断 `promote/merge/write`，并标记 `incident_window_id` 为 `surface_release_frozen`。

## Anti-Patterns
- 一段长文同时解释 lease freshness、语义断言、artifact 对账、E2E 回放与 recall 回滚。
- 不同 gate capsule 使用不同 `head_sha` 或 `digest_set_id`。
- 同窗口反复发布全量结论而不走 `verdict_delta_pointer`。
- recall/rollback 失败后仍继续发布新的裁决叙述。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
