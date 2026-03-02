# Provenance Pack: incident-window-canonical-ledger-pack

timestamp_utc: 2026-03-02T03:24:42Z
lane: engineering
fragment: `references/lanes/engineering/distilled/contracts/incident-window-canonical-ledger-pack.md`

## Source Mapping

1. `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- 提取要点: lease/heartbeat/backpressure 失真会制造“活着但不可裁决”的连续性噪声。
- 映射到 fragment: `window_owner_consistency_pass` 先锁 continuity owner，禁止并行漂移。

2. `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- 提取要点: requirement/assertion 缺映射时，文本补叙无法替代断言证据。
- 映射到 fragment: `canonical_narrative_registry` 强制叙述只引用 canonical verdict，不再多版本扩写。

3. `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- 提取要点: lineage/head/digest 同链一致是晋级闭环前提。
- 映射到 fragment: `ledger_evidence_closure_pass` 要求每条 ledger entry 绑定同链证据。

4. `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- 提取要点: prod-like 失败必须保留 replay 证据，不能用并行解释掩盖。
- 映射到 fragment: 非 owner 门禁只能补 pointer，不允许生成并行 verdict 文本。

5. `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- 提取要点: 召回和回滚必须受窗口/版本连续性约束。
- 映射到 fragment: `window_freshness_replay_pass` 禁止跨窗口直接复用旧 verdict。

## Signal Compression Notes
- 阅读负担信号: 统一到 `incident_window_ledger` 单入口，减少跨文档反复拼接。
- 元问题混杂信号: 固定 owner 切换纪律，把“谁负责裁决”从隐式语义改为显式 attestation。
- 重复叙述信号: 引入 `canonical_narrative_registry`，同义结论只保留唯一 canonical 叙述。

## Fidelity Notes
- patterns 证据层未主改，仅读取。
- 本轮仅向 distilled 检索层写入 fragment/provenance，不引入跨 lane 写入。
