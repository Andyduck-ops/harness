# Narrative Normal Form and Delta Ledger Pack

## Target Meta-Problem
同一 incident 在多门禁被长文本重复叙述，且连续性/语义/血缘/运行时问题混写，导致读路径过长、责任边界漂移、裁决复用失败。

## 60s Compression Path
1. 所有门禁输出统一为 `gate_delta_card`，禁止自由文本重写结论。
2. 每张卡只能声明一个 `meta_problem_tag`（`continuity|semantic|lineage|runtime`）。
3. 用 `delta_signature` 对同义卡去重，重复信号仅允许 pointer 更新。
4. 由 `narrative_compiler` 生成唯一 `canonical_brief`，router 基于 brief 输出唯一 verdict。

## Normal-Form Contract
1. Schema lock:
每张 `gate_delta_card` 必须包含 `incident_window_id,lineage_id,owner_gate,meta_problem_tag,signal_digest,evidence_ref,next_action`。
2. Single-tag discipline:
一张卡只允许一个 `meta_problem_tag`，跨类问题拆成多卡，禁止在同一卡混写。
3. Signature dedup:
`delta_signature = hash(incident_window_id + owner_gate + meta_problem_tag + signal_digest)`；同签名二次写入只允许更新 `evidence_ref`。
4. Pointer-only replay:
`canonical_brief` 只聚合指针与差量，不复制门禁原文；最终 verdict 仅 router 可写。

## Minimal Evidence Bundle
- `gate_delta_cards.json`
- `narrative_normal_form_schema.json`
- `delta_signature_index.json`
- `canonical_brief.json`
- `evidence_pointer_map.json`
- `single_promotion_verdict.json`

## Hard Gates
- `normal_form_schema_pass`
- `meta_problem_single_tag_pass`
- `delta_signature_dedup_pass`
- `evidence_pointer_resolve_pass`

任一失败：阻断 `promote/merge`，并冻结本窗口 verdict 复用。

## Anti-Patterns
- 同一门禁在每轮贴完整结论，造成阅读负担持续增长。
- 一张卡同时写 continuity 与 semantic，导致路由歧义。
- 重复信号改写措辞后重复入库，形成同义多版本。
- `evidence_ref` 不可解析却仍输出晋级建议。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
