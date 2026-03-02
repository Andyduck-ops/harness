# Signal Metric Verdict Fence Contract Pack

## Target Meta-Problem
同一轮次中把 `coverage/precision/freshness` 等数值指标直接当成最终裁决，会触发三类信号同时恶化：
- 阅读负担：先读长段评分解释，才能定位真实阻断门。
- 元问题混杂：观测指标、合同门禁、提交边界在同一段叙述里串线。
- 重复叙述：每轮重复解释分数波动，但对恢复动作没有新增信息。

## 60s Compression Path
1. 先写 `gate_verdict_matrix`，只给出 `pass/fail + blocking_reason + channel`。
2. 指标统一写进 `metric_observation_ledger`，明确 `observation_only=true`。
3. 用 `score_to_gate_mapping_receipt` 记录“指标支持哪个门禁分析”，禁止“分数直接裁决”。
4. 本轮无代码增量时，必须写 `nochange_commit_receipt`，把未提交原因留在 commit 通道。
5. 索引发布前仅看三门合同结论，不以任何伪精度分数替代裁决。

## Metric-Verdict Fence Contract
1. Gate verdict hard bind:
`gate_verdict_matrix.json` 必含 `cycle_id,gate_id,verdict,blocking_reason,channel,decided_at_utc`。
2. Observation ledger hard bind:
`metric_observation_ledger.json` 必含 `cycle_id,metric_name,metric_value,interpretation_window,observation_only`。
3. Mapping receipt hard bind:
`score_to_gate_mapping_receipt.json` 必含 `cycle_id,metric_name,supporting_gate,causal_limit,misuse_block`。
4. No-change commit hard bind:
`nochange_commit_receipt.json` 必含 `cycle_id,content_delta_present,commit_required,commit_status,reason_if_no_commit`。
5. Publish barrier:
`self_containment_pass && fidelity_pass && index_integrity_pass` 才允许发布，`metric_value` 不参与布尔裁决。

## Minimal Evidence Bundle
- `gate_verdict_matrix.json`
- `metric_observation_ledger.json`
- `score_to_gate_mapping_receipt.json`
- `nochange_commit_receipt.json`
- `requirement_closure_attestation.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看四卡可回答“本轮阻断门是什么、指标只提供什么信息、为什么 commit 成功或失败”。
- `Fidelity`: 保留观测层与裁决层边界，不把分数波动误判为门禁结论。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 命名一致，回链可检索。

任一 gate fail：只允许 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 直接用 `conformance_score` 替代 `gate_verdict_matrix`。
- 把 `commit permission denied` 解释成语义门禁失败。
- 每轮重复贴分数细节，不写可执行恢复动作。
- 指标字段缺 `observation_only` 仍参与最终裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
