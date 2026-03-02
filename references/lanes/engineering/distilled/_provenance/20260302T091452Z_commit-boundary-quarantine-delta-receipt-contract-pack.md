# Provenance: commit-boundary-quarantine-delta-receipt-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/commit-boundary-quarantine-delta-receipt-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/backpressure 的运行连续性边界，不与 commit 通道混写
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义裁决只在 gate 通道生效
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 证据对账边界
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与 runtime boundary parity 的硬门禁
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性与索引一致性边界

## Compression Decisions
- removed_repetition:
  - 同一 `index.lock permission denied` 签名跨轮全文重叙
  - 将 commit 边界异常反复解释为语义失败的叙述
- preserved_boundaries:
  - runtime/gate/commit/index 四通道隔离
  - commit 失败时强制 `deferred_or_nochange_receipt`
  - patterns 证据层只读，新增仅写入 distilled 检索层

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
