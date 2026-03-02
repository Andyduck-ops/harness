# Deferred Closure Freshness Recall Pack

## Target Meta-Problem
守护循环处于 `deferred` 时，若把 closure verdict、freshness/recall 校验与恢复动作写在同一层叙述：
- 阅读负担：读者无法快速判断“这是闭环失败、召回失真，还是恢复执行计划”；
- 元问题混杂：语义闭环、证据时效、索引连续性三类问题被误判为单一故障；
- 重复叙述：每轮回放全量叙述而不是追加差量，导致索引噪声上升。

## 60s Compression Path
1. 三卡分离：`closure_verdict_card`、`freshness_recall_card`、`deferred_action_card` 分层记录。
2. 闭环冻结：任一 freshness/recall 失败时冻结 `completed` 语义，仅允许 `deferred|blocked`。
3. 连续性绑定：`lineage_digest + shard_epoch + recall_hit_ratio` 三元绑定后才允许恢复升级。
4. 差量回放：恢复轮只追加 `closure_delta + recall_delta + action_delta`。
5. 读集预算：超过三张增量卡标记 `narrative_replay_overflow=true`。

## Deferred Closure Contract
1. Closure verdict card:
`closure_verdict_card.json` 必含 `cycle_id,semantic_pass,evidence_pass,prodlike_pass,rollback_pass,final_state`。
2. Freshness-recall card:
`freshness_recall_card.json` 必含 `freshness_window_pass,recall_min_hit_ratio,recall_actual_hit_ratio,shard_epoch`。
3. Deferred action card:
`deferred_action_card.json` 必含 `blocked_reason,recovery_owner,next_retry_at_utc,delta_scope`。
4. Triad parity lock:
`lineage_digest_pass && shard_continuity_pass && recall_fidelity_pass` 缺一不可。
5. Delta-only replay budget:
恢复轮最多读取三张增量卡，超出预算必须转入裁剪模式。

## Minimal Evidence Bundle
- `closure_verdict_card.json`
- `freshness_recall_card.json`
- `deferred_action_card.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Hard Gates
- `Self-Containment`: 仅凭 fragment 可回答“本轮为何 deferred、缺哪一类闭环、下一轮最小恢复读集是什么”。
- `Fidelity`: 保留 requirement/assertion、lineage digest、shard epoch、recall 阈值、rollback 连续性边界。
- `Index Integrity`: contract/provenance/index/retrieval shortcut 四点必须可双向回链。

任一 gate fail：禁止发布 completed 结论，仅允许 `deferred delta`。

## Anti-Patterns
- 在同一段混写 closure verdict、freshness/recall 与执行动作。
- `recall_actual_hit_ratio < recall_min_hit_ratio` 仍输出可恢复完成。
- 不写 `blocked_reason` 与 `next_retry_at_utc` 直接要求下一轮继续。
- 恢复轮重复粘贴全量 narrative，未输出差量卡。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
