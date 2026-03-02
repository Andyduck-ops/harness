# Provenance: signal-metric-verdict-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/signal-metric-verdict-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 语义评分仅用于支持分析，最终晋级仍由门禁裁决承载。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 证据链与 digest 对账是独立门禁，不被评分叙述替代。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 闭环判断必须保留场景合同，不可降级为单一分值。
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行连续性和 backpressure 判定独立于评分体系。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性维持独立阻断条件，避免被指标叙述吞并。

## Compression Decisions
- removed_repetition:
  - 跨轮重复解释分数细节但不产出恢复动作
  - 把评分波动和 commit 边界错误写在同段叙述
- preserved_boundaries:
  - `gate_verdict_matrix` 与 `metric_observation_ledger` 双通道隔离
  - 指标 `observation_only=true`，禁止进入最终布尔裁决
  - 无增量场景写 `nochange_commit_receipt`，显式记录不提交原因

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
