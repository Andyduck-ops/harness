# Cycle-Resume Stale-Run Demarcation Contract Pack

## Target Meta-Problem
恢复轮从 cycle 51 继续执行时，若 `run_start` 长时间无 `run_end` 且首屏继续混写 gate/evidence/runtime/commit，会同时放大阅读负担、元问题混杂和重复叙述，导致下一轮动作无法快速落点。

## 60s Compression Path
1. 首屏先落 `cycle_resume_router_card`，只包含 `cycle_id + gate_verdict + blocker_channel + next_action`。
2. `run_boundary_receipt` 与 `contract_gate_receipt` 强制分离，避免 runtime 阻塞污染 gate 裁决。
3. 历史内容只保留 `history_pointer`，正文只写本轮 `delta_packet`。
4. 指标统一进入 `signal_observation_ledger`，显式 `observation_only=true`。
5. 仅当三门合同通过且索引回链完整才发布 index 增量。

## Tri-Signal Router Contract
1. Resume-bound first screen（强约束）  
`cycle_resume_router_card.json` 必含 `cycle_id,resume_from,primary_gate_verdict,blocker_channel,next_action`。
2. Stale-run demarcation（强约束）  
`run_boundary_receipt.json` 必含 `run_id,last_progress_ts,stale_window,status`，且与 gate 裁决字段隔离。
3. Delta-only narrative（强约束）  
`delta_packet.json` 必含 `what_changed,why_now,evidence_ref`；历史全文必须通过 `history_pointer` 引用。
4. Metric fence（强约束）  
`signal_observation_ledger.json` 必含 `metric_name,metric_value,observation_only`，禁止参与合同布尔裁决。
5. Publish barrier（强约束）  
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass` 为 true 时允许更新 `_distilled_index.md`。

## Minimal Evidence Bundle
- `cycle_resume_router_card.json`
- `run_boundary_receipt.json`
- `contract_gate_receipt.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `signal_observation_ledger.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 能回答“本轮裁决、阻断通道、下一步动作”。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like replay、recall/rollback 边界完整保留且不串通道。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链到 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `closed` 结论。

## Anti-Patterns
- 用 runtime 卡顿叙述覆盖 gate 裁决。
- 把 commit 异常或运行超时误写成合同失败。
- 用伪精度分数替代三门合同布尔判定。
- 跨轮复制历史长段而不写本轮 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
