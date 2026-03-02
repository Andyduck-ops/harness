# Provenance: gate-surface-readpath-attestation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/gate-surface-readpath-attestation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat freshness、DLQ 完整性、backpressure 节流阻断
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射与 conformance score 阈值门
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage + head_sha + digest_set_id 锁定与 freshness 窗口
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like parity、replay 可重放、promotion closure
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard/recall/rollback 合同、drift freeze 触发条件

## Compression Decisions
- removed_repetition:
  - 各 pattern 中重复出现的“通过检查但未闭环”叙述
  - 各门禁重复定义的晋级阻断语句
- preserved_boundaries:
  - freshness 与 semantic 边界分离
  - evidence lineage 与 prod-like replay 边界分离
  - recall/rollback 失败即冻结发布

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
