# Readload Meta-Scope Delta-Only Pack

## Target Meta-Problem
阅读负担信号、元问题混杂信号、重复叙述信号在同一条目叠加时，agent 需要先自行拆题再裁决，导致读路径变长且结论复用失败。

## 60s Compression Path
1. 先生成 `canonical_fact_brief`：只保留窗口事实与证据指针，不写建议。
2. 每条推理只允许一个 `meta_problem_tag`（`continuity|semantic|lineage|runtime`），跨类问题必须拆卡。
3. 最终结论由 `verdict_router` 输出 `delta_only_verdict_pointer`，非 router 仅可补证据 pointer。
4. 命中重复叙述时只更新 `evidence_ref` 和 `freshness_bucket`，禁止重写整段 verdict 文本。

## Readload-to-Delta Contract
1. Readload first-fit:
当单条记录同时出现多个问题族时，先落盘 `readload_triage_card` 再进入门禁裁决，禁止直接写结论。
2. Meta-scope lock:
每张推理卡只绑定一个 `meta_problem_tag`，多标签视为混写并阻断。
3. Delta-only verdict:
同一 `incident_window_id + lineage_id` 仅允许一个 `delta_only_verdict_pointer`，重复窗口只允许差量更新。
4. Narrative fingerprint reuse:
`narrative_fingerprint = hash(meta_problem_tag + signal_digest + verdict_class)`，重复指纹禁止生成新叙述段落。

## Minimal Evidence Bundle
- `readload_triage_card.json`
- `canonical_fact_brief.json`
- `meta_scope_inference_map.json`
- `delta_only_verdict_pointer.json`
- `narrative_fingerprint_index.json`
- `evidence_pointer_map.json`

## Hard Gates
- `readload_triage_pass`
- `meta_scope_single_tag_pass`
- `delta_only_verdict_pass`
- `narrative_fingerprint_reuse_pass`

任一失败：阻断 `promote/merge`，并冻结当前窗口 verdict 改写。

## Anti-Patterns
- 在同一段文本同时写事实、推理、裁决并跨门禁复制。
- 一张推理卡绑定多个 `meta_problem_tag` 造成 owner 漂移。
- 非 router 角色直接改写最终 verdict。
- 用改词复述替代差量更新，制造同义多版本叙述。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
