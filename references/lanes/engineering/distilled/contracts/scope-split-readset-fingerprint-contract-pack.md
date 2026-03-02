# Scope-Split Readset Fingerprint Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述三信号叠加时，单条记录常同时承载事实、推理和裁决，导致 owner 漂移、读集失控与多版本正文并存。

## 60s Compression Path
1. 将单条混合记录拆分为 `fact_scope_card / inference_scope_card / verdict_scope_card` 三段。
2. 全窗口强制单一 `meta_problem_tag`，禁止跨 continuity/semantic/lineage 混写。
3. 由 `readset_window_manifest` 约束主证据预算，超限时回退重路由。
4. 使用 `narrative_fingerprint_ledger` 对同窗口叙述去重，禁止多版本正文再发布。
5. 外部响应仅返回 `verdict_pointer_card`，正文只保留 canonical 位置。

## Scope-Split Readset Contract
1. Scope split schema lock:
`scope_card` 必含 `incident_window_id,lineage_id,scope_type,meta_problem_tag,owner_gate,head_sha,evidence_pointer`。
2. Single-tag invariant:
同一 `incident_window_id` 的全部 scope_card 只能绑定一个 `meta_problem_tag`。
3. Windowed readset budget:
`primary_evidence_count <= 3`，且必须声明 `read_window_start_utc/read_window_end_utc`。
4. Fingerprint dedup guard:
同窗口内相同 `narrative_fingerprint` 不得映射不同 `verdict_digest`。
5. Pointer lineage parity:
`verdict_pointer_card` 必须与 `lineage_id + head_sha + digest_set_id` 同源。

## Minimal Evidence Bundle
- `scope_split_manifest.json`
- `readset_window_manifest.json`
- `narrative_fingerprint_ledger.json`
- `verdict_pointer_card.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `scope_split_self_contained_pass`
- `meta_problem_single_tag_pass`
- `windowed_readset_budget_pass`
- `narrative_fingerprint_dedup_pass`
- `pointer_lineage_parity_pass`

任一失败：阻断 `promote/merge`，并冻结该 `incident_window_id` 的新 verdict 发布。

## Anti-Patterns
- 单条记录混写事实、推理、裁决并直接广播到多个 gate。
- 同一窗口同时出现 `continuity + semantic` 多标签。
- 为补充“完整性”无限扩展主证据读集。
- 通过改写长文发布新版本，而非 pointer 化交付。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
