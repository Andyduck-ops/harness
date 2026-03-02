# Provenance — signal-router-readset-capsule-contract-pack

timestamp_utc: 2026-03-02T04:24:49Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/signal-router-readset-capsule-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat 新鲜度与 backpressure 阻断
  - mapped_to: `continuity_liveness_recall_pass`, `runplane_lease_registry`, `heartbeat_status`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement->assertion 语义映射与 conformance 阈值
  - mapped_to: `semantic_closure_card`, `single_meta_problem_tag_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 同源锁
  - mapped_to: `pointer_lineage_dedup_pass`, `artifact_lineage_manifest`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: prod-like replay 闭环与可重放要求
  - mapped_to: `split_closure_integrity_pass`, `semantic_closure_card`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall hit ratio 与 rollback 连续性阻断
  - mapped_to: `evidence_capsule_manifest`, `continuity_liveness_recall_pass`

## Distillation Notes
- patterns 证据层未主改，仅抽取约束字段并重组到 distilled 检索层。
- 本轮压缩骨架：`query_atom + readset_capsule + split_closure + pointer_publish + liveness_recall`。

## Fidelity Notes
- 保留边界条件：single-tag、readset budget、lineage parity、freshness/recall 双达标。
- 保留反模式：多标签混写、证据无限扩读、正文复写替代 pointer。
- 保留证据映射：5/5 pattern 全映射到合同字段与门禁。
