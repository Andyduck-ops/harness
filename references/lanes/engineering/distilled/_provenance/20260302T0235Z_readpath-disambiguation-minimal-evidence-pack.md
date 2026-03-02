# Provenance: readpath-disambiguation-minimal-evidence-pack

- fragment: `references/lanes/engineering/distilled/contracts/readpath-disambiguation-minimal-evidence-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T02:35:33Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/backpressure 的连续性阻断条件
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement->assertion 映射与 conformance 阈值
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 三元锁
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重放与边界同构
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 的连续性回放门禁

## Compression Decisions
- removed_repetition:
  - 各 pattern 重复模板段（元问题、解法、检索测试、来源说明）逐段展开
  - 重复字段串（`lineage/replay/contract/manifest`）的跨文复述
- preserved_boundaries:
  - 多门禁触发时必须先定义唯一主门禁
  - 主门禁失败即阻断，禁止先修后证
  - 最小证据束仍保持可追溯到原 pattern

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
