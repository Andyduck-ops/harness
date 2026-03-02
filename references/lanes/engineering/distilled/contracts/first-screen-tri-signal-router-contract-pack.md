# First-Screen Tri-Signal Router Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述在同一轮并发时，首屏若仍是长叙述，agent 需要先做二次拆题才能定位阻断门，导致检索与执行同时变慢。

## 60s Compression Path
1. 首屏只输出 `first_screen_router_card`：`gate_verdict + blocker_channel + next_action`。
2. 把内容严格拆到四通道：`gate/evidence/runtime/commit`，禁止同段混写。
3. 历史失败仅保留 `history_pointer`，正文只写本轮 `delta_packet`。
4. 指标统一进入 `signal_observation_ledger`，明确 `observation_only=true`。
5. 三门合同仅看布尔裁决，不接受伪精度分数替代。

## Tri-Signal Router Contract
1. First-screen bound（强约束）  
`first_screen_router_card.json` 必含 `cycle_id,primary_gate_verdict,blocker_channel,primary_cause,next_action`。
2. Channel split bound（强约束）  
`gate/evidence/runtime/commit` 四通道必须分别落盘，不得复用同一 verdict 字段。
3. Delta-only narrative（强约束）  
`delta_packet.json` 必含 `what_changed,why_now,evidence_ref`；历史内容只能通过 `history_pointer` 引用。
4. Metric fence（强约束）  
`signal_observation_ledger.json` 必含 `metric_name,metric_value,observation_only`，且禁止进入门禁裁决。
5. Publish barrier（强约束）  
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass` 才允许发布索引更新。

## Minimal Evidence Bundle
- `first_screen_router_card.json`
- `channel_split_receipt.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `signal_observation_ledger.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可直接回答“本轮裁决是什么、阻断在哪个通道、下一步动作是什么”。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like replay、recall/rollback 边界完整保留且不串通道。
- `Index Integrity`: fragment/provenance/index 命名与链接一一对应，可回链到 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止输出 `closed`。

## Anti-Patterns
- 首屏先贴长解释，导致 gate 判定入口后置。
- 把 commit 错误改写成 gate 失败。
- 用评分波动替代布尔裁决。
- 每轮重复复制历史失败全文而不写本轮 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
