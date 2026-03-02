# Provenance: runloop-lease-lock-reentry-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/runloop-lease-lock-reentry-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: runplane lease/heartbeat/backpressure 是重入治理的基线约束
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: commit 发布前保留 requirement->assertion conformance 门禁
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: distill 与 commit 都需绑定同一 lineage/head_sha/digest_set
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: commit 结果卡必须保留 replay/prod-like 闭环状态
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: deferred commit 也需记录 recall/rollback continuity 证明

## Compression Decisions
- removed_repetition:
  - 删除同一 cycle 对 distill/commit/watchdog 的重复全量叙述
  - 删除锁失败后的长文重放，仅保留 lock failure delta
- preserved_boundaries:
  - 单写者 lease + 锁失败增量发布
  - distill 与 commit 分离建模
  - lineage parity 与 rollback continuity 强制保留

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
