# Provenance: signal-lane-separation-brief-pointer-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/signal-lane-separation-brief-pointer-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: stale-run/backpressure 的阻断优先级与恢复通道
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 语义闭环门禁
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 对账一致性
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与晋级闭环门禁
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall 命中率与 rollback continuity 的索引连续性

## Compression Decisions
- removed_repetition:
  - 历史背景段落的重复铺陈
  - secondary signal 对 primary verdict 的复写叙述
- preserved_boundaries:
  - decision lane / meta lane / vcs lane 三通道隔离
  - 指标仅观测，不进入合同裁决
  - patterns 证据层只读，distilled 检索层写入

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
