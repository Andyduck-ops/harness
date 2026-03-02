# Provenance: owner-handoff-integrity-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/owner-handoff-integrity-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T02:49:29Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: continuity owner 的 freshness 与 lease 有效性前置条件
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: semantic owner 的 requirement->assertion 闭环阈值
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage owner 切换前的 head_sha/digest_set 一致性
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall fidelity 与 rollback continuity 的交接前置约束

## Compression Decisions
- removed_repetition:
  - 各 pattern 中重复的 owner 归属说明、阻断模板与来源段落
  - freshness/replay/lineage 的跨文重复解释
- preserved_boundaries:
  - owner 交接必须显式 attestation，不允许隐式切换
  - 上游主门禁未恢复时禁止向下游交接
  - 交接与晋级都受 `owner_handoff_integrity_pass` 约束

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
