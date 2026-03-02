# Promotion Freeze Single Verdict Router Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述同时出现时，`promote/merge` 常被 continuity、semantic、lineage、prod-like 多门禁各自产出一版“可晋级结论”，最终形成并行裁决和追责失焦。

## 60s Router Path
1. 先冻结写路径：进入争议窗口后只允许一个 `promotion_verdict_router` 接受写入。
2. 再定主门禁：按 `continuity -> semantic -> lineage -> runtime_boundary` 固定裁决优先级。
3. 所有门禁输出转为 `gate_signal_card`，禁止直接改写最终结论。
4. 仅 router 生成 `single_promotion_verdict`，其余文档只允许 pointer 引用。

## Single-Verdict Contract
1. Router exclusivity:
同一 `lineage_id + head_sha + promotion_epoch` 只允许一个 router 实例可写。
2. Gate signal normalization:
每个门禁必须提交结构化 `gate_signal_card`（`gate_name`, `signal_type`, `decision`, `evidence_ref`）。
3. Canonical verdict uniqueness:
同一 promotion epoch 只能存在一个 `single_promotion_verdict_id`。
4. Freeze-before-promote discipline:
当任一高优先级门禁为 fail，router 必须写 `freeze_decision`，禁止后续门禁覆盖。

## Minimal Evidence Bundle
- `promotion_router_registry.json`
- `gate_signal_card_set.json`
- `single_promotion_verdict.json`
- `promotion_freeze_attestation.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `router_exclusivity_pass`
- `gate_signal_normalization_pass`
- `single_verdict_uniqueness_pass`
- `freeze_before_promote_pass`

任一失败，禁止 `promote/merge` 与跨窗口复用该 verdict。

## Anti-Patterns
- 多门禁各自写“最终结论”并在汇总文档二次裁剪。
- 先晋级后补 `freeze_attestation`。
- 用叙述性解释替代 `gate_signal_card` 的结构化证据。
- 在 `freeze_decision` 后继续让低优先级门禁改写 verdict。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
