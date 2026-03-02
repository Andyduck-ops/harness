# Provenance: statefile-runtime-drift-reconciliation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/statefile-runtime-drift-reconciliation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度先于“运行中”声明
  - retained: stale-run/backpressure 下禁止晋级语义
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: closure 结论必须绑定 requirement->assertion 语义符合证据
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: drift 恢复后的 commit/index 必须维持 lineage digest 同源锁
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 不能被“状态仍在运行”替代
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index row 与 shortcut 发布前必须通过 recall 连续性

## Compression Decisions
- removed_repetition:
  - 历史轮次对“running 但无活跃 session”的重复长叙述
  - 把 runtime 失活误写成语义失败的混合 narrative
- preserved_boundaries:
  - state snapshot 与 runtime probe 分离，不互相替代
  - drift_detected=true 时只能发布 deferred
  - closure 必须后置到 commit/index 收据完成之后

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
