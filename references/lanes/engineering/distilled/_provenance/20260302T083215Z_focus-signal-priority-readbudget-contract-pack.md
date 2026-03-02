# Provenance: focus-signal-priority-readbudget-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/focus-signal-priority-readbudget-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: stale-run/heartbeat/backpressure 的阻断通道与恢复优先级
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 的语义闭环门禁
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 的证据对账边界
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与晋级闭环门禁
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall hit ratio 与 rollback continuity 的索引连续性

## Compression Decisions
- removed_repetition:
  - 历史失败背景的全量重复叙述
  - 三信号并列铺陈导致的同义说明
- preserved_boundaries:
  - 主信号优先路由（primary signal first）
  - gate/evidence/runtime/commit 通道分离
  - 指标仅观测，不进入合同裁决

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
