# Provenance: dlq-retry-causality-attestation-pack

- fragment: `references/lanes/engineering/distilled/contracts/dlq-retry-causality-attestation-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T06:11:22Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: `failure_signature`、`stale_run`、`backpressure_mode` 的调度阻断语义
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 映射与 conformance 阈值对裁决层的硬约束
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: `lineage_id + head_sha + digest_set_id` 同源锁
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay/边界一致性对晋级决策的约束
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: `shard_epoch` 连续性与 recall fidelity 阻断条件

## Compression Decisions
- removed_repetition:
  - 删除每轮重复回放同一 poison message 背景的长段 narrative
  - 删除将调度重试与语义裁决混写在单段的多义文本
- preserved_boundaries:
  - `dlq_event -> retry_decision -> verdict_attestation` 三卡单向因果链
  - `failure_signature == retry_reason_signature` 因果锁
  - `lineage/head/digest/shard_epoch` 同步栅栏

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
