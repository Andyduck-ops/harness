# Provenance Pack: narrative-normal-form-delta-ledger-pack

timestamp_utc: 2026-03-02T03:46:22Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/narrative-normal-form-delta-ledger-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: stale-run/backpressure 信号需要结构化表达，否则同一运行态被多次口语化重述。
- 映射到 fragment: `gate_delta_card` 固定字段与 `delta_signature_dedup_pass`，限制重复叙述。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: 需求语义缺口常被检查项叙述掩盖，必须显式标注语义类问题。
- 映射到 fragment: `meta_problem_tag` 强制单标签，避免语义问题被混写。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 证据映射若不统一会出现“做过但对不上账”。
- 映射到 fragment: `evidence_pointer_map` 与 `evidence_pointer_resolve_pass`，保证指针可回链。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: runtime 问题需和其他门禁解耦，否则会把复现失败写成语义失败。
- 映射到 fragment: `meta_problem_tag=runtime` 单独成卡，避免跨类混杂。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 分片召回与回滚漂移会放大同义多版本文本。
- 映射到 fragment: `delta_signature_index` 统一去重入口，收敛检索路径。

## Signal Compression Notes
- 阅读负担信号: 把长文本叙述压缩为 `gate_delta_card`，同义内容只保留 signature 与 pointer。
- 元问题混杂信号: 单卡单标签，禁止一张卡承担多类问题裁决。
- 重复叙述信号: `delta_signature` 去重，重复信号不再产出新结论文本。

## Fidelity Notes
- patterns 证据层未主改，仅读取映射。
- 本轮新增仅写入 lane 内 `distilled/contracts` 与 `distilled/_provenance`。
