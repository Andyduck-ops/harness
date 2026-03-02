# Provenance: decision-view-matrix-delta-ledger-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/decision-view-matrix-delta-ledger-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度、DLQ 与 backpressure 触发冻结条件
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射完整性与 conformance 阻断门
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 一致性与工件新鲜度窗口
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重现与 runtime boundary parity
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall 命中门与 rollback continuity replay 失败冻结

## Compression Decisions
- removed_repetition:
  - 多 pattern 重复出现的“检查通过但决策视图混写”叙述
  - triage/promote/rollback 在同窗口重复全量回放的文本
- preserved_boundaries:
  - triage/promotion/rollback 视图边界分离
  - 证据核与裁决指针分层
  - rollback 失败即冻结发布

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
