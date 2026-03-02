# Provenance Pack: signal-ledger-ttl-dedup-pack

timestamp_utc: 2026-03-02T03:40:08Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/signal-ledger-ttl-dedup-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: stale-run 与 backpressure 异常需要结构化信号追踪，避免“看起来活着”但语义失真。
- 映射到 fragment: `signal_ledger_card` 强制包含新鲜度与窗口绑定，过期信号必须 GC。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: 需求-断言语义映射缺位时，重复叙述会掩盖真实缺口。
- 映射到 fragment: `signal_card_schema_pass` 要求每张卡片包含 requirement/assertion 关联指针。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 晋级证据必须在同一 lineage/head/digest 集合内对账。
- 映射到 fragment: `lineage_digest_parity_pass` 约束 `lineage_id + head_sha + digest_set_id` 一致。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like 回放失败时必须冻结晋级并保留复现路径。
- 映射到 fragment: 仅 router 可输出 verdict，门禁层只能追加结构化 signal，不得提前晋级。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 召回分片版本漂移会放大跨文档重复叙述与错链引用。
- 映射到 fragment: `window_gc_manifest + recall_manifest` 共同约束跨窗口读路径与版本一致性。

## Signal Compression Notes
- 阅读负担信号: 用 `signal_digest_rollup` 替代门禁层长文本复述，缩短检索路径。
- 元问题混杂信号: 检测层与裁决层职责隔离，router 独占最终 verdict。
- 重复叙述信号: `window_ttl_gc_pass` 拦截过期卡片复用，防止同义多版本扩散。

## Fidelity Notes
- patterns 证据层未主改，仅读取映射。
- 本轮新增仅写入 lane 内 `distilled/contracts` 与 `distilled/_provenance`。
