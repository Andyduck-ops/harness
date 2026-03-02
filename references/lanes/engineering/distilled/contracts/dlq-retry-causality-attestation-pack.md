# DLQ Retry Causality Attestation Pack

## Target Meta-Problem
当 `poison message` 重试、`backpressure` 降并发、`semantic/evidence` 闭环被写成一段叙述时，会出现三重退化：
- 阅读负担：必须在 DLQ、heartbeat、semantic、artifact、recall 五类工件之间来回跳转才能判断“为什么 defer”；
- 元问题混杂：调度层（重试/节流）和裁决层（promote/block）边界丢失；
- 重复叙述：每轮重复粘贴全量失败背景，真正变化的 `retry_delta` 被淹没。

## 60s Compression Path
1. 三卡分层：`dlq_event_card`、`retry_decision_card`、`verdict_attestation_card`。
2. 因果锁：`failure_signature -> retry_reason_signature -> blocked_reason` 必须同链闭环。
3. 同步栅栏：`lineage_id + head_sha + digest_set_id + shard_epoch` 不一致即阻断晋级。
4. 晋级禁令：`dlq_uncleared=true` 或 `backpressure_mode=hard` 时只允许 `defer|block`。
5. 差量恢复：恢复轮仅追加 `retry_delta + queue_delta + verdict_delta`。

## DLQ Causality Contract
1. DLQ event card:
`dlq_event_card.json` 必含 `cycle_id,message_id,failure_signature,retry_count,dlq_reason,dlq_uncleared`。
2. Retry decision card:
`retry_decision_card.json` 必含 `cycle_id,retry_reason_signature,next_retry_at_utc,retry_budget_remaining,backpressure_mode`。
3. Verdict attestation card:
`verdict_attestation_card.json` 必含 `cycle_id,decision,blocked_reason,semantic_pass,evidence_pass,recall_pass`。
4. Causality parity barrier:
`failure_signature == retry_reason_signature` 且 `lineage/head/digest/shard_epoch` 同步，否则 `decision=block`。
5. Delta-only recovery budget:
恢复轮最多读取三张差量卡，超预算标记 `narrative_replay_overflow=true`。

## Minimal Evidence Bundle
- `dlq_manifest.json`
- `backpressure_report.json`
- `heartbeat_status.json`
- `dlq_event_card.json`
- `retry_decision_card.json`
- `verdict_attestation_card.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `index_shard_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭 fragment 可回答“为何 defer/block、阻断在调度层还是裁决层、下一轮最小恢复读集是什么”。
- `Fidelity`: 保留 DLQ failure signature、backpressure 模式、语义闭环阈值、artifact 同源锁与 recall 连续性边界。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 可双向回链且命名一致。

任一 gate fail：禁止发布 `completed`，仅允许 `defer|block + delta`。

## Anti-Patterns
- 在同一段混写 DLQ 事件、重试决策和晋级裁决。
- `dlq_uncleared=true` 仍输出 `decision=promote`。
- 缺少 `next_retry_at_utc` 直接进入下一轮重试。
- 恢复轮回放全量 narrative，不发布差量卡。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
