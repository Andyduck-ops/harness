# Provenance Pack: canonical-brief-pointer-budget-pack

timestamp_utc: 2026-03-02T03:34:45Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/canonical-brief-pointer-budget-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: stale-run 与 backpressure 异常会产生“活性存在但结论不可信”的窗口噪声。
- 映射到 fragment: 高优先级 fail 时触发 `freeze_pointer_lock_pass`，后续只允许追加 pointer。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: 需求断言映射不闭环时，语义结论容易被重复改写掩盖。
- 映射到 fragment: 强制 `delta_signal_card` 仅写变化项，避免门禁全文复写 verdict。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 晋级裁决必须和同一 lineage/head/digest 链对账。
- 映射到 fragment: `canonical_brief` 与 `artifact_lineage_manifest` 绑定，阻断错链引用。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like 失败场景要求冻结后回放，不允许叙述层提前晋级。
- 映射到 fragment: router 之前只允许 delta 与 pointer，不允许写最终晋级结论。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: recall 命中分片错误会让同义叙述反复出现且版本不一致。
- 映射到 fragment: `pointer_budget_report` 要求每个 pointer 绑定同窗 `recall_manifest`。

## Signal Compression Notes
- 阅读负担信号: 用 `canonical_brief + delta_signal_card` 代替多文档全量叙述，缩短复盘路径。
- 元问题混杂信号: 检测层只产出 delta，裁决层只在 router 形成单一 verdict。
- 重复叙述信号: 通过 `pointer_budget_report` 与 `freeze_pointer_lock` 抑制同义改写。

## Fidelity Notes
- patterns 证据层未主改，仅读取映射。
- 本轮仅新增 lane 内 distilled fragment 与 provenance。
