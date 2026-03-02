# Provenance: readpath-thread-evidence-nucleus-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/readpath-thread-evidence-nucleus-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度、stale run 阻断、backpressure 冻结信号
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement→assertion 映射完整性与 conformance 阻断门
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 一致性与 digest 校验
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like parity 与 replay 可重放闭环
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall 命中门、rollback continuity replay、drift 冻结

## Compression Decisions
- removed_repetition:
  - 删除同窗口多次复述完整 incident 结论
  - 删除在单卡里同时写事实/推理/裁决的混写段
- preserved_boundaries:
  - readload/meta/repetition 三信号卡分离
  - evidence nucleus 与 decision delta pointer 分层
  - closure 失败即冻结发布

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
