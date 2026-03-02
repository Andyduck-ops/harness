# Provenance: staleness-promote-race-attestation-pack

- fragment: `references/lanes/engineering/distilled/contracts/staleness-promote-race-attestation-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease ownership、heartbeat freshness、stale-run 与 backpressure 阻断语义
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 映射与 semantic conformance 阈值约束
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head/digest 同源锁定与 freshness 窗口约束
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like/replay 失败不得晋级
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard epoch 连续性、recall fidelity 与 rollback 完整性

## Compression Decisions
- removed_repetition:
  - 多文档反复出现的“检查项通过但不可晋级”全量叙述
  - 跨门禁重复列举同源工件字段的长段文本
- preserved_boundaries:
  - stale-run 与 recall drift 任一触发即冻结 completed 语义
  - promote 裁决必须由单写口 `attestation_card` 输出
  - 恢复轮只允许 `race_delta + verdict_delta + retry_delta`

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
