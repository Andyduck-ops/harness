# Phase Cardinality Delta Bridge Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述三信号叠加时，常见退化是同一 incident 在 `observe/diagnose/decide/recover` 四阶段被反复全量复述，且阶段边界失真：事实、推理、裁决与恢复动作混写，导致读路径膨胀与 owner 漂移。

## 60s Compression Path
1. 先声明 `phase_ledger_card`：`incident_window_id + current_phase + phase_owner + owner_gate`。
2. 四阶段各保留一张 `phase_capsule`，同阶段仅允许单活跃版本（single cardinality）。
3. 阶段切换只发布 `phase_delta_bridge_pointer`，禁止回放前序全量 narrative。
4. 全部阶段共享 `evidence_anchor`：`lineage_id + head_sha + digest_set_id + shard_epoch`。
5. 任一闭环失败（freshness/conformance/lineage/prod-like/rollback）即冻结 `decide/recover` 发布。

## Phase Contract
1. Phase cardinality lock:
同一 `incident_window_id + phase_name` 只能存在一张 active capsule。
2. Phase purity:
`observe` 仅写症状，`diagnose` 仅写归因假设，`decide` 仅写裁决，`recover` 仅写回滚/修复动作。
3. Delta bridge only:
阶段跃迁必须通过 `phase_delta_bridge_pointer`，不得复写历史长文。
4. Anchor parity:
所有 phase capsule 的 `lineage_id + head_sha + digest_set_id + shard_epoch` 必须一致。
5. Freeze-on-closure-fail:
`background_freshness_pass && requirement_conformance_pass && artifact_lineage_lock_pass && prodlike_e2e_pass && rollback_integrity_pass` 全为 true 才允许进入 `decide/recover`。

## Minimal Evidence Bundle
- `phase_ledger_card.json`
- `observe_phase_capsule.json`
- `diagnose_phase_capsule.json`
- `decide_phase_capsule.json`
- `recover_phase_capsule.json`
- `phase_delta_bridge_pointer.json`
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
- `phase_cardinality_lock_pass`
- `phase_scope_purity_pass`
- `phase_delta_pointer_only_pass`
- `evidence_anchor_parity_pass`
- `closure_freeze_gate`

任一失败：阻断 `promote/merge/write`，并标记 `incident_window_phase_frozen`。

## Anti-Patterns
- 在 `observe` 阶段写入最终晋级结论。
- 任何阶段直接复制上阶段全量 narrative 而非发布 delta pointer。
- 同一窗口并存多个 `decide_phase_capsule` 版本。
- `recover` 阶段缺失 rollback attestation 仍宣告闭环。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
