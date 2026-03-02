# Provenance Pack: promotion-freeze-single-verdict-router-pack

timestamp_utc: 2026-03-02T03:29:26Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/promotion-freeze-single-verdict-router-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: lease/heartbeat 失真会制造“系统活着但裁决不可信”的假阳性窗口。
- 映射到 fragment: router 先冻结写路径，防止 stale gate 在晋级阶段并行改写。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: requirement 与 assertion 语义映射缺失会让检查通过但语义未闭环。
- 映射到 fragment: `gate_signal_normalization_pass` 要求 semantic gate 输出结构化 signal card。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: 晋级证据必须同 lineage/head/digest 链一致，否则属于对账错链。
- 映射到 fragment: `single_promotion_verdict` 必须绑定 `artifact_lineage_manifest`。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like 场景失败必须先冻结晋级，再执行回放与边界复验。
- 映射到 fragment: `freeze_before_promote_pass` 在高优先级 fail 时强制写 `freeze_decision`。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: recall/rollback 必须受版本连续性约束，错误分片会引入错误裁决依据。
- 映射到 fragment: router 输出 verdict 前必须核验 `recall_manifest` 与 `promotion_epoch` 一致。

## Signal Compression Notes
- 阅读负担信号: 将多门禁并行叙述折叠到单一 `single_promotion_verdict`，减少跨文档拼接。
- 元问题混杂信号: 把“门禁判定”与“晋级裁决”拆分为 signal card 与 router verdict 两层。
- 重复叙述信号: 非 router 文档禁止改写结论，只保留 pointer 到 canonical verdict。

## Fidelity Notes
- patterns 证据层未主改，仅读取与映射。
- 本轮仅新增 distilled fragment 与 provenance，不写跨 lane 内容。
