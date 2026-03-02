# Provenance: freshness-lane-demultiplex-verdict-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/freshness-lane-demultiplex-verdict-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/stale-run 与 backpressure 阻断优先级
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射与 assertion freshness 窗口
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 的同链对账和 24h 新鲜度约束
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重现与 runtime boundary parity
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard_epoch recall 命中率与 rollback continuity freeze

## Compression Decisions
- removed_repetition:
  - 四类 freshness 反复合并叙述的长段背景
  - 同一轮内“指标解释 + 裁决解释”重复播报
- preserved_boundaries:
  - freshness 四 lane 拆分，primary verdict 单一通道
  - observation_only 指标护栏，不参与合同布尔裁决
  - patterns 证据层只读，distilled 检索层写入

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
