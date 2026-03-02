# Decision View Matrix Delta Ledger Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂与重复叙述高发时，常见触发点是同一 incident 文本同时承载 triage、promote、rollback 三种决策视图，导致读路径膨胀、gate 归属漂移、结论重复回放。

## 60s Compression Path
1. 先写 `decision_view_card`，只声明 `incident_window_id + decision_view + owner_gate + target_action`。
2. 按 `decision_view` 分拆为 `triage_capsule`、`promotion_capsule`、`rollback_capsule`，每个 capsule 只保留本视图裁决字段。
3. 三个 capsule 共享单一 `evidence_nucleus`（`lineage_id + head_sha + digest_set_id + evidence_epoch`）。
4. 同窗口只写一条 `window_delta_ledger_pointer`，禁止重复发完整叙述。
5. 发现视图冲突或回放失败时立即 `release_frozen`，只允许修复路径写入。

## Decision View Contract
1. View-first routing:
`decision_view_card` 必含 `incident_window_id,decision_view,owner_gate,target_action,query_digest`。
2. Capsule isolation:
`triage/promotion/rollback` 必须分文档写作，单文档不得跨视图混写结论。
3. Shared evidence parity:
三个 capsule 必须绑定同一 `lineage_id + head_sha + digest_set_id`。
4. Delta-only ledger:
同一 `incident_window_id + owner_gate + decision_view` 每轮仅允许一条 `window_delta_ledger_pointer`。
5. Release closure:
`background_freshness_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && rollback_integrity_pass` 全为 true 才可发布。

## Minimal Evidence Bundle
- `decision_view_card.json`
- `triage_capsule.json`
- `promotion_capsule.json`
- `rollback_capsule.json`
- `window_delta_ledger_pointer.json`
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

## Hard Gates
- `view_self_containment_pass`
- `view_boundary_purity_pass`
- `shared_evidence_parity_pass`
- `delta_ledger_single_writer_pass`
- `release_closure_replay_pass`

任一失败：阻断 `promote/merge/write`，并标记 `incident_window_id` 为 `decision_view_release_frozen`。

## Anti-Patterns
- 一段长文同时回答“现在先止血？”“能否晋级？”“是否回滚？”三个问题。
- triage/promotion/rollback capsule 使用不同 `head_sha` 或 `digest_set_id`。
- 同窗口重复发布完整版结论，不走 `window_delta_ledger_pointer`。
- rollback replay 失败后仍发布新的 promotion 结论。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
