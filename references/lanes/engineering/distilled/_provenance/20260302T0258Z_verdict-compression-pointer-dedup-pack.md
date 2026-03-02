# Provenance Pack: verdict-compression-pointer-dedup-pack

timestamp_utc: 2026-03-02T02:58:06Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/verdict-compression-pointer-dedup-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: continuity 门禁先判、stale run 与 lease 过期必须先阻断。
- 映射到 fragment: owner gate 优先序与 `window_reuse_guard_pass`。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: requirement/assertion 映射必须可执行，不能只靠解释文本。
- 映射到 fragment: `evidence_pointer_closure_pass` 与语义结论指针化。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: lineage/head/digest 一致性是证据可追溯核心。
- 映射到 fragment: pointer map 必须落到实际 artifact，禁止裸文本裁决。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like replay 需要可复现证据，不接受口头闭环。
- 映射到 fragment: 运行时边界结论只能由 `promotion_closure` 与 replay 证据承载。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 长上下文回滚与召回需要版本连续与窗口约束。
- 映射到 fragment: `window_reuse_guard_pass`，禁止跨窗口复用旧裁决。

## Signal Compression Notes
- 阅读负担信号: 从“跨多文档拼装裁决”收敛到单文件 `verdict_pointer_card`。
- 元问题混杂信号: 强制单一 `owner_gate`，其余门禁改为指针引用。
- 重复叙述信号: 通过 `narrative_dedup_lint` 将重复文字裁决改为 canonical pointer。

## Fidelity Notes
- patterns 证据层未主改，仅读取。
- distilled 新增 fragment 为检索层重编码，不覆盖 source 事实边界。
