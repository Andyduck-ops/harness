# Provenance: publication-state-commit-boundary-separation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/publication-state-commit-boundary-separation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: runtime 连续性（lease/heartbeat/backpressure）仅保留在 runtime 通道
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义裁决保持 gate 通道独立
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest 对账语义保留在 evidence 通道
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与边界一致性留在 gate 通道，不与 commit 失败混写
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性与 index 完整性保持 index 通道独立

## Compression Decisions
- removed_repetition:
  - 同签名 `index.lock permission denied` 跨轮全量复述
  - 把“内容完成/提交完成”混成单一 completed 结论
- preserved_boundaries:
  - `publication_state_card` 首屏拆分 content 与 commit 状态
  - runtime/gate/index/commit 四通道 verdict 隔离
  - patterns 证据层只读，新增仅写入 distilled 检索层

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
