# Focus-Signal Priority Readbudget Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述同时出现时，如果仍按“并列平铺”输出，agent 首屏会失去主因优先级：
先读到的是背景，最后才看到阻断点，导致同一轮反复重述与误路由。

## 60s Compression Path
1. 首屏固定 `primary_signal_router_card`，只给 `primary_signal + gate_verdict + blocker_channel + next_action`。
2. 其余信号写入 `supporting_signal_ledger`，禁止与主裁决同段混写。
3. 证据回链固定五源 pattern，正文只写本轮 `delta_packet`，历史走 pointer。
4. 指标统一进入 `observation_ledger` 并声明 `observation_only=true`。
5. 三门合同通过后才允许 index 发布；commit 失败只进入 `vcs_channel_receipt`。

## Priority Router Contract
1. Primary signal bound（强约束）  
`primary_signal_router_card.json` 必含 `cycle_id,primary_signal,gate_verdict,blocker_channel,next_action`。
2. Supporting split bound（强约束）  
`supporting_signal_ledger.json` 必含 `secondary_signals[],impact_scope[]`，不得覆盖主裁决字段。
3. Delta-only narrative（强约束）  
`delta_packet.json` 必含 `what_changed,why_now,evidence_ref`；历史全文必须通过 `history_pointer` 引用。
4. Metric fence（强约束）  
`observation_ledger.json` 必含 `metric_name,metric_value,observation_only`，禁止参与合同布尔裁决。
5. Commit isolation（强约束）  
`vcs_channel_receipt.json` 仅记录 `git_status,commit_attempted,commit_error`，不得写入 gate verdict。

## Minimal Evidence Bundle
- `primary_signal_router_card.json`
- `supporting_signal_ledger.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `observation_ledger.json`
- `vcs_channel_receipt.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可直接回答“主信号是什么、阻断在哪个通道、下一步动作是什么”。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like replay、recall/rollback 边界完整保留，且 commit 通道与 gate 通道隔离。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `closed` 结论。

## Anti-Patterns
- 三信号并列铺陈，导致主因后置。
- 把 commit 阻塞或运行阻塞改写成 gate 失败。
- 用伪精度分数替代三门合同布尔裁决。
- 继续复制历史长段而不写本轮 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
