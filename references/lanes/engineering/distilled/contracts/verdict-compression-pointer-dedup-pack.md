# Verdict Compression and Pointer Dedup Pack

## Target Meta-Problem
在连续性、语义闭环、证据血缘、prod-like 边界四类门禁并行时，阅读路径膨胀、元问题混杂、重复叙述会把同一 incident 的裁决变成多版本文本。

## 60s Compression Path
1. 先选唯一主门禁：`continuity > semantic > lineage > runtime-boundary`。
2. 只读取主门禁最小证据束（2-3 份），其他门禁降级为引用指针。
3. 生成单一裁决卡 `verdict_pointer_card.json`，禁止二次口述复制。
4. 使用 `narrative_dedup_lint.json` 检查“同一判定语句”是否跨文档重复。

## Pointer-First Contract
1. Single owner verdict:
同一 `incident_id` 在一个裁决窗口内只能有一个 `owner_gate`。
2. Evidence pointer closure:
每条结论必须绑定 `evidence_pointer_map`，指向实际 artifact，不允许裸文本结论。
3. Narrative dedup:
同义裁决语句只保留一份 canonical text，其余位置只允许引用 pointer id。
4. Window reuse guard:
跨窗口复用历史结论前，必须重新验证 freshness 与 head 一致性。

## Minimal Evidence Bundle
- `verdict_pointer_card.json`
- `evidence_pointer_map.json`
- `narrative_dedup_lint.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `promotion_closure.json`

## Hard Gates
- `owner_gate_uniqueness_pass`
- `evidence_pointer_closure_pass`
- `narrative_dedup_pass`
- `window_reuse_guard_pass`

任一失败，禁止继续晋级与跨门禁交接。

## Anti-Patterns
- 多门禁并发给出完整文字裁决，导致“多版本真相”。
- 复述结论但不绑定 artifact 指针，无法追溯证据。
- 复用旧窗口结论，不重验 freshness/head。
- 用“解释更长”替代“证据更闭环”。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
