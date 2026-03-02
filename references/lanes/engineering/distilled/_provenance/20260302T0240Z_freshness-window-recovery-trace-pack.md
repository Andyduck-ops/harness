# Provenance: freshness-window-recovery-trace-pack

- fragment: `references/lanes/engineering/distilled/contracts/freshness-window-recovery-trace-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: heartbeat/backpressure 新鲜度阻断语义
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion freshness 与语义闭环阻断
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 同链锁定
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重现与边界一致性
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性与 checkpoint 完整性

## Compression Decisions
- removed_repetition:
  - 各文档重复出现的 freshness 描述合并为 `24h/48h/7d` 三桶
  - 各门禁分散的恢复记录字段收敛为 `recovery_trace_card` 单格式
- preserved_boundaries:
  - 主门禁优先级不变：`continuity > semantic > lineage > runtime-boundary`
  - 回滚后 replay 失败仍保持硬阻断，不允许“软放行”
  - 证据跨 `head_sha` 混用保持阻断

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
