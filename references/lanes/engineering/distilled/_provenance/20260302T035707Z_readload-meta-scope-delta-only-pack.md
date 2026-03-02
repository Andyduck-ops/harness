# Provenance Pack: readload-meta-scope-delta-only-pack

timestamp_utc: 2026-03-02T03:57:07Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/readload-meta-scope-delta-only-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: freshness/backpressure 信号必须先作为事实输入再做裁决。
- 映射到 fragment: `canonical_fact_brief` 与 `readload_triage_pass`。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: 语义问题必须单独映射断言链，避免和其他问题族混写。
- 映射到 fragment: `meta_scope_inference_map` 与 `meta_scope_single_tag_pass`。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 裁决需要同链证据指针闭环，不允许叙述脱离 evidence lineage。
- 映射到 fragment: `delta_only_verdict_pointer` + `evidence_pointer_map` 同链绑定。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: runtime/prod-like 失败复核应通过差量证据更新，而不是重复写整段结论。
- 映射到 fragment: `delta_only_verdict_pass` 与 `narrative_fingerprint_reuse_pass`。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 长上下文恢复后重复召回会触发叙述多版本扩散。
- 映射到 fragment: `narrative_fingerprint_index` 去重与窗口差量复用约束。

## Signal Compression Notes
- 阅读负担信号: 从“混写后再人工拆题”改为 `readload_triage -> canonical_fact_brief` 先拆后判。
- 元问题混杂信号: 强制单 `meta_problem_tag`，跨类问题拆成多卡。
- 重复叙述信号: 复用 `narrative_fingerprint`，只允许差量更新 pointer。

## Fidelity Notes
- patterns 证据层未主改，仅读取并映射。
- 本轮新增仅写入 lane 内 `distilled/contracts` 与 `distilled/_provenance`。
