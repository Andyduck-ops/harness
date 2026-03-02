# Canonical Brief Pointer Budget Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述并发时，多个门禁会各自重写“最终结论”，导致复盘路径变长、责任边界模糊、同义结论漂移。

## 60s Compression Path
1. 先产出唯一 `canonical_brief`：绑定 `lineage_id + head_sha + incident_window_id`。
2. 各门禁仅允许提交 `delta_signal_card`（新增风险、状态变化、证据指针），禁止重写完整 verdict。
3. 统一写入 `pointer_budget_report`，限制单轮叙述改写次数。
4. 仅 `promotion_verdict_router` 可基于 brief + delta 生成最终 `single_promotion_verdict`。

## Pointer-Budget Contract
1. Brief uniqueness:
同一 `incident_window_id` 只能存在一个 `canonical_brief_id`。
2. Delta-only discipline:
门禁输出必须是差量卡片，禁止复制上轮全文叙述。
3. Pointer completeness:
每个 delta 必须绑定 `evidence_ref`，且可回链到 lane 内证据文件。
4. Freeze pointer lock:
当高优先级门禁 fail 后，后续门禁只能追加 pointer，不能改写 verdict。

## Minimal Evidence Bundle
- `canonical_brief.json`
- `delta_signal_cards.json`
- `pointer_budget_report.json`
- `single_promotion_verdict.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `brief_uniqueness_pass`
- `delta_only_write_pass`
- `pointer_completeness_pass`
- `freeze_pointer_lock_pass`

任一失败，阻断 `promote/merge` 与跨窗口复用本轮结论。

## Anti-Patterns
- 门禁文档重复粘贴同一“最终结论”并轻微改词。
- 未给 `evidence_ref` 就给出升级建议。
- freeze 已触发后仍在非 router 文档改写 verdict。
- 将 `pointer_budget_report` 当日志而非门禁输入，导致读路径失控。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
