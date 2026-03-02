# Gate Intent Trace Delta Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述并发时，同一 incident 常把 observe/diagnose/decide/recover 的意图混写在一段 narrative 里，导致检索路径过长、门禁归属漂移、结论重复回放。

## 60s Compression Path
1. 先声明 `intent_query_card`：只写 `incident_window_id + phase_intent + owner_gate + target_action`。
2. 再拆四张 intent capsule：`observe_intent_capsule`、`diagnose_intent_capsule`、`decide_intent_capsule`、`recover_intent_capsule`。
3. 全阶段共享单一 `evidence_anchor`：`lineage_id + head_sha + digest_set_id + shard_epoch`。
4. 发布层仅允许 `intent_delta_pointer`，禁止重复回放长 narrative。
5. 任一闭环失败（freshness/conformance/lineage/prod-like/rollback）即 `intent_release_frozen`。

## Intent Trace Contract
1. Intent-first routing:
`intent_query_card` 必含 `incident_window_id,phase_intent,owner_gate,target_action,query_digest`。
2. Phase-intent purity:
`observe/diagnose/decide/recover` 四类 capsule 必须独立成文，单卡不得跨阶段混写结论。
3. Anchor fidelity parity:
全部 capsule 必须绑定同一 `lineage_id + head_sha + digest_set_id + shard_epoch`。
4. Delta-only publication:
同一 `incident_window_id + phase_intent` 每轮仅允许一条 `intent_delta_pointer`。
5. Closure freeze:
`background_freshness_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && rollback_integrity_pass` 全为 true 才允许发布。

## Minimal Evidence Bundle
- `intent_query_card.json`
- `observe_intent_capsule.json`
- `diagnose_intent_capsule.json`
- `decide_intent_capsule.json`
- `recover_intent_capsule.json`
- `intent_delta_pointer.json`
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
- `intent_self_containment_pass`
- `phase_intent_purity_pass`
- `anchor_fidelity_parity_pass`
- `delta_publication_single_writer_pass`
- `closure_freeze_pass`

任一失败：阻断 `promote/merge/write`，并标记 `incident_window_id` 为 `intent_release_frozen`。

## Anti-Patterns
- 同一段文本同时给出观测现象、根因推理、晋级结论与恢复指令。
- 四阶段 capsule 使用不同 `head_sha` 或不同 `digest_set_id`。
- 每轮重复发布完整说明而不走 `intent_delta_pointer`。
- recall 命中不足或 rollback replay 失败仍继续发布 decide/recover。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
