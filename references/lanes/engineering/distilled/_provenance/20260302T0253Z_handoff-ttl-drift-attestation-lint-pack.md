# Provenance: handoff-ttl-drift-attestation-lint-pack

- fragment: `references/lanes/engineering/distilled/contracts/handoff-ttl-drift-attestation-lint-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T02:53:36Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: freshness/lease 失效时禁止沿用旧交接结论
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 语义门禁未闭环时交接不可复用
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: attestation 必须保持同链同 head 的字段一致性
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 窗口内需要防 owner 漂移

## Compression Decisions
- removed_repetition:
  - 多文档重复出现的 owner 交接说明与 freshness 解释
  - 重复模板段（元问题/检索测试/来源段）
- preserved_boundaries:
  - 交接结论存在时效窗口，不可跨窗复用
  - 同一 incident owner 切换需受漂移预算约束
  - attestation 字段缺省属于硬阻断，不可“默认通过”

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
