# Provenance — incident-capsule-delta-fanout-contract-pack

timestamp_utc: 2026-03-02T04:13:39Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/incident-capsule-delta-fanout-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease 唯一性、heartbeat 新鲜度、backpressure 阻断条件
  - mapped_to: `incident_capsule.owner_gate`, `gate_delta_cards.gate_name`, `capsule_self_contained_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement/assertion 单语义约束与 conformance 判定
  - mapped_to: `incident_capsule.meta_problem_tag`, `meta_problem_single_tag_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 同源锁与对账门禁
  - mapped_to: `artifact_lineage_manifest`, `pointer_lineage_parity_pass`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: replayable closure 与 runtime boundary parity
  - mapped_to: `canonical_brief_card`, `response_pointer_card`, `canonical_brief_singleton_pass`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall/rollback 下的 shard 一致性与漂移冻结
  - mapped_to: `narrative_fingerprint_set`, `narrative_dedup_zero_rewrite_pass`

## Distillation Notes
- patterns 证据层未主改，仅做读取与字段映射。
- 本轮将“多 gate 长叙述”压缩为 `incident_capsule + gate_delta_card` 双层结构，降低检索噪声。

## Fidelity Notes
- 保留边界条件：single owner、single tag、lineage parity、pointer-only response。
- 保留反模式：多标签混写、多版本正文复写、跨 gate 全量叙述复制。
- 保留证据映射：5/5 pattern 完整映射到合同字段与门禁。
