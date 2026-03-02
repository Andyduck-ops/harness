# Manual-Stop Liveness / Closure Demarcation Contract Pack

## Target Meta-Problem
守护式运行场景下，`status=running` 与“本轮已闭环”经常被同段叙述，且“不要退出直到手动停止”的运行策略会放大三类信号：
- 阅读负担信号：首屏无法直接判断“进程活性”与“轮次闭环”是否是同一结论。
- 元问题混杂信号：手动停机策略被误写成 Self-Containment/Fidelity 失败原因。
- 重复叙述信号：同一长跑约束在每轮重复解释，增量事实被覆盖。

## 60s Compression Path
1. 首屏固定 `liveness_claim_card` 与 `cycle_closure_card` 双卡分栏，禁止并句。
2. `manual_stop_policy_card` 仅描述运行策略，不得参与 gate 判定。
3. 三门合同仅读取 `contract_gate_card`，理由域限定 `contracts`。
4. `runtime_boundary_receipt` 独立记录持续运行约束与提交边界异常。
5. 同签名长跑态只发布 `delta_progress_card`，历史通过 `history_pointer_card` 回链。

## Demarcation Contract
1. Liveness claim isolation（强约束）
`liveness_claim_card.json` 必含 `cycle_id,status_claim,pid_witness,heartbeat_freshness,scope=runtime`。
2. Closure evidence isolation（强约束）
`cycle_closure_card.json` 必含 `cycle_id,run_start_seen,run_end_seen,closure_verdict,scope=runpair`。
3. Manual-stop policy isolation（强约束）
`manual_stop_policy_card.json` 必含 `stop_mode=manual,auto_exit=false,policy_scope=ops`，且 `mutates_gate_reason=false`。
4. Gate purity（强约束）
`contract_gate_card.json` 必含 `self_containment,fidelity,index_integrity,reason_scope=contracts`。
5. Delta-only replay（强约束）
`delta_progress_card.json` 必含 `fingerprint,new_fact,unchanged_context`，禁止全文重放。

## Minimal Evidence Bundle
- `liveness_claim_card.json`
- `cycle_closure_card.json`
- `manual_stop_policy_card.json`
- `contract_gate_card.json`
- `runtime_boundary_receipt.json`
- `delta_progress_card.json`
- `history_pointer_card.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单碎片可独立回答“是否在跑、是否闭环、阻塞域在哪里”。
- `Fidelity`: 保留 runtime/closure/policy/contracts 四通道边界，禁止跨通道推导。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 主证据路径。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 用 `status=running` 直接推导 `closure=closed`。
- 把“手动停止策略”当成合同门失败理由。
- 在报告中重复粘贴“持续运行约束”全文而无增量事实。
- 以观察指标分数替代合同裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
