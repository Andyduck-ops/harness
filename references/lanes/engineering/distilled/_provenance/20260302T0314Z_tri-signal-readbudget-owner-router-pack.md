# Provenance Pack: tri-signal-readbudget-owner-router-pack

timestamp_utc: 2026-03-02T03:14:32Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/tri-signal-readbudget-owner-router-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: stale run、lease 过期、backpressure 超限必须先阻断。
- 映射到 fragment: owner 优先级中的 `continuity` 首判与 `route_fanout_guard_pass`。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: requirement/assertion 映射不闭环时不得用文本解释替代断言证据。
- 映射到 fragment: `read_budget_guard_pass` 约束下的最小语义证据束与 canonical verdict。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: lineage/head/digest 必须同链一致，防止跨链拼接。
- 映射到 fragment: `evidence_pointer_map` 与 `window_replay_guard_pass` 的证据闭环约束。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like 失败需要 replay 证据，不接受并行口述裁决。
- 映射到 fragment: 非 owner 门禁必须转 pointer，禁止并行 narrative 扩写。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 长上下文召回/回滚必须受窗口与版本连续性约束。
- 映射到 fragment: `window_replay_guard_pass`，禁止跨窗口复制旧 verdict。

## Signal Compression Notes
- 阅读负担信号: 以 `read_budget_guard` 把单次裁决主证据限制在 3 份以内。
- 元问题混杂信号: 通过 `route_fanout_guard` 固定单一 owner，阻断并行门禁扩散。
- 重复叙述信号: 通过 `canonical_narrative_pass` 保留唯一 canonical 文本，其他位置只用 pointer。

## Fidelity Notes
- patterns 证据层未主改，仅读取。
- distilled 新增 fragment 仅做检索层重编码，未引入跨 lane 写入。
