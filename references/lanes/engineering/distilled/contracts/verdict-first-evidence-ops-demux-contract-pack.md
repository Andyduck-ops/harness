# Verdict-First Evidence/Ops Demux Contract Pack

## Target Meta-Problem
恢复轮若把 `ops` 诊断噪声、`evidence` 映射、`gate` 裁决写在同一叙述层，会同时放大三类信号：
- 阅读负担信号：首屏需要穿越运行细节才能定位可执行结论。
- 元问题混杂信号：运行面故障排查与知识面合同裁决互相污染。
- 重复叙述信号：同一阻断签名跨轮全量复述，增量事实不可见。

## 60s Compression Path
1. 首屏固定 `gate_verdict_triplet`，只写三门合同结论与下一步动作。
2. `ops_trace_channel` 与 `distill_evidence_channel` 强制双通道，禁止跨写。
3. 同签名重试只发布 `delta_fact_capsule`，历史解释仅通过 `history_pointer` 引用。
4. 仅允许 fragment/provenance/index 进入 `evidence_allowlist`。
5. 若 commit 边界受阻，仅写 `commit_receipt`，不得回滚或覆写门禁 verdict。

## Demux Contract
1. Verdict-first surface（强约束）
`gate_verdict_triplet.json` 必含 `self_containment,fidelity,index_integrity,next_action`。
2. Evidence/Ops separation（强约束）
`channel_partition.json` 必含 `ops_trace_channel,distill_evidence_channel,cross_write=false`。
3. Delta-only replay（强约束）
`delta_fact_capsule.json` 必含 `fingerprint,new_fact,unchanged_context,history_pointer`。
4. Source allowlist（强约束）
`evidence_allowlist.json` 必含 `distilled/contracts,distilled/_provenance,distilled/_distilled_index.md`。
5. Commit boundary isolation（强约束）
`commit_receipt.json` 必含 `commit_attempted,lock_scope,error_class,gate_verdict_unchanged=true`。

## Minimal Evidence Bundle
- `gate_verdict_triplet.json`
- `channel_partition.json`
- `delta_fact_capsule.json`
- `evidence_allowlist.json`
- `commit_receipt.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 能回答“当前轮可执行结论是什么，下一步是什么”。
- `Fidelity`: 保留边界条件、反模式和证据映射，不用伪精度指标裁决。
- `Index Integrity`: fragment/provenance/index 命名一致，可回链 5 个 pattern 源路径。

任一 gate fail：转入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 首屏先写运行日志，再在末尾补门禁 verdict。
- 把 runtime 探针结果等同于语义合同裁决。
- 同签名重试持续全量复述，不输出增量事实。
- 用“指标变好”替代三门合同通过判定。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
