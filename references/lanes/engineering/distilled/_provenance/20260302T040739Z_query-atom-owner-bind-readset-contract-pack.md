# Provenance — query-atom-owner-bind-readset-contract-pack

timestamp_utc: 2026-03-02T04:07:39Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/query-atom-owner-bind-readset-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: stale-run freshness, lease ownership exclusivity, backpressure freeze
  - mapped_to: `owner_bind_manifest`, `owner_bind_uniqueness_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement/assertion semantic scope lock
  - mapped_to: `query_atom_manifest.meta_problem_tag`, `meta_scope_atom_single_tag_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest parity and same-chain attestation
  - mapped_to: `artifact_lineage_manifest`, `response_pointer_card` evidence closure

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: replayable closure and promotion decision should consume normalized evidence
  - mapped_to: `minimal_readset_manifest`, `response_pointer_only_pass`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: shard recall fidelity and rollback continuity under long context
  - mapped_to: `minimal_readset_budget_pass`, `recall_manifest`

## Distillation Notes
- patterns 证据层未主改，仅读取并映射到 distilled 合同字段。
- 本轮输出聚焦“入口原子化 + 单 owner 路由 + 读集预算”以压缩三信号叠加下的检索噪声。

## Fidelity Notes
- 保留边界条件：single owner、single tag、lineage parity、pointer-only。
- 保留反模式：atom 混写、并发 owner 裁决、跨窗口拼接过量证据、重复改写 verdict。
- 保留证据映射：5/5 pattern 全量映射到合同门与字段。
