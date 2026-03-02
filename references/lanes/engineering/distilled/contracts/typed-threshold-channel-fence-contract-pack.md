# Typed Threshold Channel Fence Contract Pack

## Target Meta-Problem
同一轮把 `seconds`、`ratio`、`score`、`bool` 四类阈值混写成一个“总分结论”，会稳定放大三类信号：
- 阅读负担：执行者必须先做单位换算，才能定位真实阻断门。
- 元问题混杂：runtime 新鲜度、语义符合性、证据对账、召回命中率被误当成同一维度。
- 重复叙述：每轮重复解释“为什么这次分数看起来低/高”，但没有新增阻断动作。

## 60s Compression Path
1. 首屏只发布 `typed_blocker_card`：`primary_gate + threshold_type + blocking_reason + immediate_action`。
2. 四类阈值分通道落账：`freshness_seconds`、`recall_ratio`、`conformance_score`、`hard_bool_gate`。
3. `unit_normalization_receipt` 只记录单位解释，不参与合同布尔裁决。
4. 历史解释下沉到 `history_pointer`，正文只保留本轮 `delta_packet`。
5. 指标与统计必须声明 `observation_only=true`。

## Typed Threshold Fence Contract
1. Typed blocker lane（强约束）
`typed_blocker_card.json` 必含 `cycle_id, primary_gate, threshold_type, threshold_value, verdict, blocker_channel, immediate_action`。
2. Unit channel ledger（强约束）
`unit_channel_ledger.json` 必含 `freshness_seconds, recall_ratio, conformance_score, hard_bool_gate`，且每项必须含 `gate_id` 与 `decision_scope`。
3. Normalization receipt（强约束）
`unit_normalization_receipt.json` 必含 `source_unit, normalized_unit, causal_limit, observation_only`；`observation_only=false` 直接阻断发布。
4. Cross-channel fence（强约束）
`conformance_score` 不得直接改写 `hard_bool_gate`；`index.lock permission denied` 不得写入语义门禁字段。
5. Publish barrier（强约束）
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass` 为 true 才允许发布。

## Minimal Evidence Bundle
- `typed_blocker_card.json`
- `unit_channel_ledger.json`
- `unit_normalization_receipt.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`
- `delta_packet.json`
- `history_pointer_map.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可回答“本轮主阻断是什么、阈值类型是什么、立即动作是什么”。
- `Fidelity`: 保留 runtime/assertion/evidence/recall 四类边界，不做跨通道改写。
- `Index Integrity`: fragment/provenance/index 命名一致，并可回链 5 个 pattern 源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 把 `conformance_score` 当作唯一晋级裁决。
- 把单位换算解释写进主裁决字段。
- 用 `commit` 通道异常覆盖 gate 失败原因。
- 每轮重复贴全量阈值说明，不发布 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
