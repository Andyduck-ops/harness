# Provenance: failure-ontology-routing-pack

- fragment: `references/lanes/engineering/distilled/contracts/failure-ontology-routing-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T02:31:44Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: freshness 与 backpressure 的连续性阻断
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 的版本连续性与回放约束
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射与语义评分门禁
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 一致性锁
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 回放可重现与边界同构

## Compression Decisions
- removed_repetition:
  - 各 pattern 重复的模板段（元问题/核心解法/最小证据协议/检索测试）逐项展开
  - 高频重复词串（`lineage`/`replay`/`contract`/`manifest`）的跨文叙述
- preserved_boundaries:
  - 失败类型必须一对一映射主门禁
  - 主门禁失败即阻断晋级，不允许“检查项全绿”绕过
  - 证据必须在同一 lineage 闭环且可回放

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
