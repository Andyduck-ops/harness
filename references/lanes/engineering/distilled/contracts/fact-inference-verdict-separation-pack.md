# Fact Inference Verdict Separation Pack

## Target Meta-Problem
同一门禁条目里混写事实信号、推理过程与最终裁决，导致单条记录阅读负担过大、元问题边界漂移、同义结论反复重述。

## 60s Compression Path
1. 门禁先写 `fact_signal_card`，只允许观测事实与窗口上下文，不写建议。
2. 推理阶段写 `inference_trace_card`，明确假设、约束与反例，不直接晋级。
3. 裁决阶段仅 `verdict_router` 可写 `single_verdict_pointer`，其余位置只能引用 pointer。
4. 同义裁决由 `narrative_fingerprint_index` 去重，重复出现只更新证据指针。

## FIV Separation Contract
1. Layer isolation:
`fact / inference / verdict` 三层必须拆分为独立 artifact，禁止单文件跨层混写。
2. Meta-problem single scope:
每条 `inference_trace_card` 只能绑定一个 `meta_problem_tag`（`continuity|semantic|lineage|runtime`）。
3. Verdict single writer:
同一 `incident_window_id + lineage_id` 仅一个 `single_verdict_pointer_id` 有效，非 router 写入视为冲突。
4. Fingerprint dedup:
`narrative_fingerprint = hash(meta_problem_tag + signal_digest + decision)`，重复指纹禁止生成新 verdict 文本。

## Minimal Evidence Bundle
- `fact_signal_ledger.json`
- `inference_trace_map.json`
- `single_verdict_pointer.json`
- `narrative_fingerprint_index.json`
- `evidence_pointer_map.json`
- `recall_manifest.json`

## Hard Gates
- `fact_inference_layer_isolation_pass`
- `meta_problem_scope_pass`
- `single_verdict_writer_pass`
- `narrative_fingerprint_dedup_pass`

任一失败：阻断 `promote/merge`，并冻结当前窗口 verdict 复用。

## Anti-Patterns
- 在同一段落同时写监控事实、归因推理、晋级结论。
- 把 `meta_problem_tag` 当多选字段，导致责任路由漂移。
- 非 router 门禁直接输出最终 verdict。
- 同义结论只改措辞重复发布，不做指纹去重。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
