# Provenance: blocked-reason-delta-capsule-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/blocked-reason-delta-capsule-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T06:32:17Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: runtime 阻塞通道必须显式区分 lease/heartbeat/dlq/backpressure
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: contract 修复队列以 requirement/assertion 语义映射为准
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: blocked 影响域必须携带 lineage/digest 同源约束
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: repair action 完成需保留 prod-like replay 与边界同构证据
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 恢复轮最小读集依赖 recall/rollback 连续性

## Compression Decisions
- removed_repetition:
  - 删除“每轮整段复述故障史”写法，改为三段 delta capsule
  - 删除“阻塞原因=验收失败”的混合结论
- preserved_boundaries:
  - 固化 `blocked_reason_delta -> repair_action_delta -> evidence_impact_delta`
  - 仅在 `contracts_pass && commit_ok && index_linked` 时放行 closed 决策
  - 保留通道失败局部化，不跨层吞并

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
