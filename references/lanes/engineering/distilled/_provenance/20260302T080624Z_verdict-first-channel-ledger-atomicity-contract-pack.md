# Provenance: verdict-first-channel-ledger-atomicity-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/verdict-first-channel-ledger-atomicity-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/dlq/backpressure 作为 runtime 通道独立因果，不并入语义结论。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义裁决必须先给 verdict，再给证据映射。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage + digest 仅以 evidence delta 记录，不与 commit 异常混写。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like e2e 闭环保持独立 gate 证据，不被运行日志覆盖。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 一致性只在 runtime/evidence 通道表达。

## Compression Decisions
- removed_repetition:
  - 删除跨轮背景复述，改为 verdict-first + delta-only。
  - 删除 commit 错误在 gate 通道中的重复描述。
- preserved_boundaries:
  - gate/evidence/runtime/commit 四通道硬隔离。
  - 指标只观测，不参与合同布尔裁决。
  - 发布动作仅由三门合同控制。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
