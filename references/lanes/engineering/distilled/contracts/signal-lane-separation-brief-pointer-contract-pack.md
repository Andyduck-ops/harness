# Signal-Lane Separation Brief Pointer Contract Pack

## Target Meta-Problem
三信号并发轮中，如果把主裁决、元问题解释与历史背景放在同一叙述通道，agent 会先读到说明文本而不是执行结论，造成阅读负担上升、元问题混杂和重复叙述回放。

## 60s Compression Path
1. 首屏只发布 `decision_lane_card`：`primary_signal + gate_verdict + blocker_channel + next_action`。
2. 元问题解释进入 `meta_problem_ledger`，禁止与主裁决同段。
3. 历史上下文只保留 `history_pointer + delta_packet`，正文不重复旧叙述。
4. 指标进入 `observation_ledger` 并标注 `observation_only=true`。
5. 三门合同通过后才发布 index；VCS 失败只写 `vcs_receipt`，不改 gate 结论。

## Lane Separation Contract
1. Decision lane first（强约束）
`decision_lane_card.json` 必含 `cycle_id,primary_signal,gate_verdict,blocker_channel,next_action`。
2. Meta-problem isolation（强约束）
`meta_problem_ledger.json` 必含 `meta_problem_id,mixing_risk,disambiguation_rule`，不得写 gate verdict。
3. Delta-only narrative（强约束）
`delta_packet.json` 必含 `what_changed,why_now,evidence_ref`；历史信息只能通过 `history_pointer` 引用。
4. Observation fence（强约束）
`observation_ledger.json` 必含 `metric_name,metric_value,observation_only`，禁止参与合同布尔裁决。
5. VCS channel isolation（强约束）
`vcs_receipt.json` 仅记录 `git_status,commit_attempted,commit_error`，不得覆盖 `contract_gate_receipt`。

## Minimal Evidence Bundle
- `decision_lane_card.json`
- `meta_problem_ledger.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `observation_ledger.json`
- `contract_gate_receipt.json`
- `vcs_receipt.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可直接回答主裁决、阻断通道与下一步动作。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like replay、recall/rollback 边界保持完整，且 VCS 与 gate 通道隔离。
- `Index Integrity`: fragment/provenance/index 三链命名一致且可回链到 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `closed`。

## Anti-Patterns
- 首屏先写背景说明，主裁决后置。
- secondary signal 改写 primary verdict。
- 用指标分数替代三门合同裁决。
- 把 commit 失败写成 gate 失败。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
