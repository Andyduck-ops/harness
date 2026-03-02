# Signal Lens Router Fidelity Freeze Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述三信号并发时，常见退化是同一事件在不同角色视角下被重复改写；事实、推理、裁决被塞进同一叙述，导致读路径过长、责任边界漂移、冻结条件失真。

## 60s Compression Path
1. 先发布 `lens_router_card`：声明 `incident_window_id + audience_lens + question_type + owner_gate`。
2. 拆为三类独立 capsule：`readload_capsule`、`meta_scope_capsule`、`repetition_capsule`。
3. 三 capsule 必须共享 `fidelity_anchor`：`lineage_id + head_sha + digest_set_id + shard_epoch`。
4. 发布层仅追加 `verdict_delta_pointer`，禁止再次下发全量 narrative。
5. 任一闭环失败（freshness/conformance/lineage/prod-like/rollback）即 `release_frozen`。

## Lens Contract
1. Router-before-story:
`lens_router_card` 必含 `audience_lens,question_type,owner_gate,target_decision`。
2. Scope purity:
signal capsule 只写症状与边界，不写最终裁决。
3. Fidelity anchor parity:
所有 capsule 的 `lineage_id + head_sha + digest_set_id + shard_epoch` 必须一致。
4. Delta-only verdict:
同一 `incident_window_id + owner_gate + audience_lens` 每轮仅允许一条 `verdict_delta_pointer`。
5. Freeze-on-closure-fail:
`background_freshness_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && rollback_integrity_pass` 全为 true 才允许发布。

## Minimal Evidence Bundle
- `lens_router_card.json`
- `readload_capsule.json`
- `meta_scope_capsule.json`
- `repetition_capsule.json`
- `verdict_delta_pointer.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `replay_repro_bundle.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Hard Gates
- `lens_router_presence_gate`
- `scope_purity_gate`
- `fidelity_anchor_parity_gate`
- `delta_single_writer_gate`
- `closure_freeze_gate`

任一失败：阻断 `promote/merge/write`，并标记 `incident_window_frozen`。

## Anti-Patterns
- 同一文本同时承载 operator/auditor/product 三个视角的完整结论。
- capsule 使用不同 `head_sha` 或不同 `digest_set_id`。
- 每轮重放完整 narrative，而非仅发布 `verdict_delta_pointer`。
- rollback continuity 失败后仍继续晋级。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
