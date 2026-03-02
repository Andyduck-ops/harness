# Readpath Thread Evidence Nucleus Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述并发时，常见故障是同一 incident 在同窗口反复发布长结论，且把“事实/推理/裁决”混写在一处，导致 owner 路由漂移、回滚判断失真、检索命中下降。

## 60s Compression Path
1. 先写 `query_router_card`：只声明 `incident_window_id + question_type + owner_gate + target_decision`。
2. 拆分三张信号卡：`readload_signal_capsule`、`meta_scope_capsule`、`repeat_delta_capsule`。
3. 三卡共享单一 `evidence_nucleus`：`lineage_id + head_sha + digest_set_id + evidence_epoch + query_id`。
4. 发布层只允许写 `decision_delta_pointer`，禁止重复发送完整叙述。
5. 任一闭环失败（freshness/conformance/lineage/prod-like/rollback）即 `release_frozen`。

## Thread Contract
1. Router-first:
`query_router_card` 必含 `incident_window_id,question_type,owner_gate,target_decision,query_digest`。
2. FIV separation:
每张 signal capsule 只写事实与边界，不在同卡内给最终裁决。
3. Shared nucleus parity:
三个 capsule 必须绑定同一 `lineage_id + head_sha + digest_set_id`。
4. Delta-only publication:
同一 `incident_window_id + owner_gate` 每轮仅允许一条 `decision_delta_pointer`。
5. Freeze-on-drift:
`background_freshness_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && rollback_integrity_pass` 全为 true 才允许 publish。

## Minimal Evidence Bundle
- `query_router_card.json`
- `readload_signal_capsule.json`
- `meta_scope_capsule.json`
- `repeat_delta_capsule.json`
- `decision_delta_pointer.json`
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
- `self_containment_gate`
- `fiv_boundary_purity_gate`
- `shared_nucleus_parity_gate`
- `delta_single_writer_gate`
- `release_closure_replay_gate`

任一失败：阻断 `promote/merge/write`，并将 `incident_window_id` 标记为 `thread_release_frozen`。

## Anti-Patterns
- 同一长文本里同时包含 triage/promote/rollback 三种裁决。
- readload/meta/repetition 三信号卡使用不同 `head_sha` 或 `digest_set_id`。
- 每轮都重发完整结论而不是只发 `decision_delta_pointer`。
- recall 命中不足或 rollback replay 失败后仍继续发布。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
