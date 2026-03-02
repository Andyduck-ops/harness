# Freshness Lane Demultiplex Verdict Fence Contract Pack

## Target Meta-Problem
在同一轮压缩里把 runtime freshness、assertion freshness、artifact freshness、recall freshness 混成一个“freshness 结论”，会让首屏先解释背景再给决策，导致阅读负担上升、元问题混杂和重复叙述回放。

## 60s Compression Path
1. 首屏固定 `decision_lane_card`：只给 `primary_freshness_lane + gate_verdict + blocker_channel + next_action`。
2. 新鲜度按四条 lane 拆分：runtime / semantic / evidence / recall，禁止同段合并裁决。
3. 元问题进入 `meta_problem_ledger`，只描述混杂风险，不写 gate verdict。
4. 历史信息只通过 `history_pointer`，正文仅保留 `delta_packet`。
5. 指标进入 `observation_ledger` 并声明 `observation_only=true`；合同裁决只认三门 gate。

## Freshness Demultiplex Contract
1. Runtime freshness lane（强约束）
`runtime_freshness_card.json` 必含 `lease_expire_at, heartbeat_at, cursor_lag_seconds, stale_run`；`stale_run=true` 不得晋级。
2. Semantic freshness lane（强约束）
`semantic_freshness_card.json` 必含 `requirement_id, assertion_id, assertion_age_hours, freshness_window_hours`；过期断言不得参与 promote。
3. Evidence freshness lane（强约束）
`evidence_freshness_card.json` 必含 `lineage_id, head_sha, digest_set_id, produced_at_utc`；head 不一致或超窗阻断。
4. Recall freshness lane（强约束）
`recall_freshness_card.json` 必含 `query_id, shard_epoch, actual_hit_ratio, min_hit_ratio`；命中率不足触发 freeze。
5. Lane router verdict（强约束）
`freshness_router_receipt.json` 必含 `primary_lane, secondary_lanes, gate_verdict, blocker_channel`，并保证“单主裁决 + 多辅解释”。

## Minimal Evidence Bundle
- `decision_lane_card.json`
- `runtime_freshness_card.json`
- `semantic_freshness_card.json`
- `evidence_freshness_card.json`
- `recall_freshness_card.json`
- `freshness_router_receipt.json`
- `meta_problem_ledger.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `observation_ledger.json`
- `contract_gate_receipt.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 就能回答主 freshness 裁决、阻断通道与下一步动作。
- `Fidelity`: lease/heartbeat、requirement-assertion、artifact lineage digest、recall/rollback 边界全部保留且不互相覆盖。
- `Index Integrity`: fragment/provenance/index 命名一致并可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `closed`。

## Anti-Patterns
- 把四类 freshness 合并成单一分数后直接裁决。
- 用“指标高低”替代合同门 pass/fail。
- secondary lane 解释反向改写 primary lane verdict。
- 复述历史背景而不输出本轮 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
