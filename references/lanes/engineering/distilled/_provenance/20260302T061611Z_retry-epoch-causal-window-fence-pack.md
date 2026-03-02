# Provenance: retry-epoch-causal-window-fence-pack

- fragment: `references/lanes/engineering/distilled/contracts/retry-epoch-causal-window-fence-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`
- timestamp_utc: `2026-03-02T06:16:11Z`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: `stale_run`、`backpressure_mode`、`next_retry` 的调度阻断语义
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 映射与 `semantic_conformance` 对裁决层的硬约束
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: `lineage_id + head_sha + digest_set_id` 同源锁
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 与 runtime boundary parity 的闭环门禁
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: `shard_epoch` 连续性与 `recall_manifest` fidelity 阻断条件

## Compression Decisions
- removed_repetition:
  - 删除每轮重复回放 stale/retry 背景的全量 narrative
  - 删除把调度层与裁决层混写在单段的多义叙述
- preserved_boundaries:
  - `scheduler_retry -> freshness_window -> lineage_digest -> promotion_verdict` 四卡单向因果链
  - `retry_ready && freshness_pass && digest_lock_pass && recall_pass` 晋级合取围栏
  - 恢复轮仅允许 `retry_epoch_delta + freshness_delta + verdict_delta`

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
