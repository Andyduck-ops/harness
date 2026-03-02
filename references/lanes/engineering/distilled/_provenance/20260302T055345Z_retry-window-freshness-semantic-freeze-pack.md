# Provenance: retry-window-freshness-semantic-freeze-pack

- fragment: `references/lanes/engineering/distilled/contracts/retry-window-freshness-semantic-freeze-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度与 backpressure 下的重试节流边界
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义评分必须参与 retry 裁决
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 在重试路径中保持同链对账
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 边界不可被 retry 叙述吞没
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall shard epoch 与 rollback continuity 作为恢复门禁

## Compression Decisions
- removed_repetition:
  - 删除每轮重试都重复回放全量上下文的叙述
  - 删除 retry 状态与 gate verdict 混写造成的重复解释
- preserved_boundaries:
  - retry window card / gate verdict card 双卡分离
  - freshness semantic freeze
  - retry intent ledger append-only

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
