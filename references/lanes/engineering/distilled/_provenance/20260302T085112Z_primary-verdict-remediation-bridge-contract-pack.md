# Provenance: primary-verdict-remediation-bridge-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/primary-verdict-remediation-bridge-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/stale-run 与 backpressure 的主阻断优先级
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射与 semantic conformance 的晋级边界
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 的同链对账与 24h 新鲜度约束
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重现与 runtime boundary parity
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard_epoch recall 命中率、rollback checkpoint 和 freeze 条件

## Compression Decisions
- removed_repetition:
  - 首屏里 verdict/remediation/history 的重复背景解释
  - 同轮内对同一 blocker 的多版本叙述
- preserved_boundaries:
  - primary verdict 与 remediation bridge 双通道隔离
  - observation_only 指标护栏，不参与合同裁决
  - patterns 证据层保持只读，distilled 检索层写入

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
