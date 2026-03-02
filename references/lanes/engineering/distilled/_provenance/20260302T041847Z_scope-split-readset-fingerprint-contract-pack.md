# Provenance — scope-split-readset-fingerprint-contract-pack

timestamp_utc: 2026-03-02T04:18:47Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/scope-split-readset-fingerprint-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat 新鲜度与 owner 唯一性约束
  - mapped_to: `scope_split_manifest.owner_gate`, `scope_split_self_contained_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement->assertion 单语义映射与一致性阻断
  - mapped_to: `meta_problem_tag`, `meta_problem_single_tag_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 同源对账
  - mapped_to: `artifact_lineage_manifest`, `pointer_lineage_parity_pass`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: replayable closure 与 pointer 化晋级闭环
  - mapped_to: `verdict_pointer_card`, `narrative_fingerprint_ledger`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall readset 边界、版本一致性与漂移冻结
  - mapped_to: `readset_window_manifest`, `windowed_readset_budget_pass`

## Distillation Notes
- patterns 证据层未主改，仅进行字段抽取与映射。
- 本轮压缩为 `scope_split + readset_budget + fingerprint_dedup + pointer_lineage` 四元结构。

## Fidelity Notes
- 保留边界条件：single owner、single tag、readset budget、lineage parity。
- 保留反模式：多标签混写、跨窗口扩读、正文多版本复写。
- 保留证据映射：5/5 pattern 映射到合同字段与门禁。
