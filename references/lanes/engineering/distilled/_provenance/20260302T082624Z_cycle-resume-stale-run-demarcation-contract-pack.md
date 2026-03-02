# Provenance: cycle-resume-stale-run-demarcation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/cycle-resume-stale-run-demarcation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: runplane/lease/heartbeat 运行边界独立保留在 runtime 通道，不进入 gate 裁决字段。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义边界持续映射在 gate 通道，拒绝指标替代裁决。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/digest 对账保留 evidence 通道，避免与恢复叙述混写。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 闭环要求保留为独立证据束，不随摘要裁剪。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性与分片索引边界保留为 runtime+evidence 双向约束。

## Compression Decisions
- removed_repetition:
  - 删除跨轮重复背景全文，仅保留 `history_pointer` 与本轮 `delta_packet`。
  - 删除把运行态卡顿与合同裁决并段叙述的长文本。
- preserved_boundaries:
  - 首屏收敛为 `cycle_resume_router_card`。
  - `run_boundary_receipt` 与 `contract_gate_receipt` 分离，不交叉覆盖。
  - 指标仅观测（`observation_only=true`），不进入合同裁决。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
