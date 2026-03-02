# Provenance Pack: fact-inference-verdict-separation-pack

timestamp_utc: 2026-03-02T03:50:59Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/fact-inference-verdict-separation-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: freshness 与 backpressure 信号是事实层输入，不应与裁决文本混写。
- 映射到 fragment: `fact_signal_ledger` 与 `fact_inference_layer_isolation_pass`。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: 语义问题必须有显式断言映射与可解释推理链。
- 映射到 fragment: `inference_trace_map` 与 `meta_problem_scope_pass`。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 同链一致性要求裁决指针与证据指针严格绑定。
- 映射到 fragment: `single_verdict_pointer` + `evidence_pointer_map` 的同链闭环。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: runtime/prod-like 失败需要保留可复现推理与独立 verdict 出口。
- 映射到 fragment: router 独占写 `single_verdict_pointer`，非 router 禁止写最终裁决。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 召回分片漂移会制造同义多版本叙述。
- 映射到 fragment: `narrative_fingerprint_index` 去重并受 `recall_manifest` 约束。

## Signal Compression Notes
- 阅读负担信号: 从“单条混写三层语义”压缩为 `fact/inference/verdict` 三层独立检索。
- 元问题混杂信号: 强制 `inference_trace_card` 单标签，避免跨类问题混写。
- 重复叙述信号: `narrative_fingerprint` 去重，重复结论只更新 pointer 不再扩写文本。

## Fidelity Notes
- patterns 证据层未主改，仅读取并映射。
- 本轮新增仅写入 lane 内 `distilled/contracts` 与 `distilled/_provenance`。
