# Provenance: gitdir-writability-preflight-deferred-receipt-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/gitdir-writability-preflight-deferred-receipt-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: heartbeat/backpressure 连续性只保留在 runtime 通道，不被 commit 边界覆盖
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义裁决保持 gate 通道独立
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest 对账语义不与 lockscope 异常混写
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与边界一致性门禁独立
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性及索引完整性不被 commit 通道覆写

## Compression Decisions
- removed_repetition:
  - 同一 `index.lock permission denied` 指纹跨轮全量重述
  - 先讲历史后揭示 commit 边界失败的后置叙述
- preserved_boundaries:
  - 预检 `gitdir_writability_probe` 前置
  - runtime/gate/index/commit 四通道隔离
  - patterns 证据层只读，新增仅写入 distilled 检索层

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
