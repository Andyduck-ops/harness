# Provenance: continuity-and-liveness-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/continuity-and-liveness-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/DLQ/backpressure 四件套
  - retained: freshness 与 backpressure 阻断门禁
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard/recall/rollback 三合同
  - retained: recall 命中阈值与 continuity replay 阻断

## Compression Decisions
- removed_repetition:
  - 各文档重复的“元问题/核心解法/最小证据协议/检索测试(L5)”模板描述
  - 跨文档重复词串：`lineage`, `replay`, `contract`, `manifest`
- preserved_boundaries:
  - freshness 失败不可晋级
  - recall 低命中不可写入新状态
  - rollback 后必须 replay 验证

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
