# Query Atom Owner-Bind Readset Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述并发时，入口查询常把“症状、归因、裁决请求”混在一条文本里，导致门禁先并行解释再补证据，读路径持续膨胀。

## 60s Compression Path
1. 先做 `query_atomization`：把输入拆成 `symptom_atom / scope_atom / decision_atom` 三类原子。
2. 每个 atom 只能绑定一个 `meta_problem_tag`，禁止单 atom 混写 continuity/semantic/lineage/runtime。
3. 由 `owner_bind_router` 选出单一 owner gate，非 owner 只允许提供 pointer 证据。
4. 生成 `minimal_readset_manifest`，单次裁决最多读取 3 份主证据，超限必须回退重路由。
5. 响应只交付 `response_pointer_card`，禁止复述多版本 verdict 文本。

## Owner-Bind Readset Contract
1. Query atom schema lock:
`query_atom` 必含 `incident_window_id,lineage_id,atom_type,meta_problem_tag,signal_digest,evidence_hint`。
2. Single-scope atom discipline:
单 atom 只允许一个 `meta_problem_tag`，混写直接阻断。
3. Owner-first routing:
同一 `incident_window_id` 只能有一个 `owner_gate`，优先级固定 `continuity > semantic > lineage > runtime-boundary`。
4. Minimal readset budget:
`primary_evidence_count <= 3`；超限视为阅读负担失控，必须重建 readset。
5. Pointer-only response:
最终输出必须是 `response_pointer_card`，正文结论只能存在 canonical verdict 位置。

## Minimal Evidence Bundle
- `query_atom_manifest.json`
- `owner_bind_manifest.json`
- `minimal_readset_manifest.json`
- `response_pointer_card.json`
- `recall_manifest.json`
- `artifact_lineage_manifest.json`

## Hard Gates
- `query_atomization_pass`
- `meta_scope_atom_single_tag_pass`
- `owner_bind_uniqueness_pass`
- `minimal_readset_budget_pass`
- `response_pointer_only_pass`

任一失败：阻断 `promote/merge`，并冻结当前窗口的新 verdict 写入。

## Anti-Patterns
- 输入未拆 atom 就并发触发多个门禁解释。
- 同一 atom 同时绑定 `continuity + semantic` 导致 owner 漂移。
- 为“看起来完整”跨窗口拼接超过 3 份主证据。
- 在多个文档重复改写同一结论而不是交付 pointer。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
