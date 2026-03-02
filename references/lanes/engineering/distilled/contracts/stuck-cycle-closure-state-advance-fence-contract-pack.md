# Stuck Cycle Closure / State Advance Fence Contract Pack

## Target Meta-Problem
恢复轮出现 `run_start` 无 `run_end` 且 `state.json.cycle` 长时间不前进时，若把闭环状态、三门合同裁决与 commit 边界失败写在同一层，会同时触发三类信号：
- 阅读负担信号：读者首屏无法判断“本轮是否已闭环”。
- 元问题混杂信号：cycle 闭环问题被误写成 Fidelity / Index Integrity 失败。
- 重复叙述信号：同一冻结态在每轮全文复述，增量事实不可见。

## 60s Compression Path
1. 首屏固定 `cycle_closure_verdict_card`，先给“本轮是否闭环”与下一动作。
2. `run_start` 与 `run_end` 必须做成同轮配对证据，缺失时强制 `closure=deferred`。
3. `state_advance_card` 独立声明 cycle 是否前进，禁止由 commit 回执反向改写。
4. commit 失败只写 `commit_receipt_card`，与 gate verdict 保持通道隔离。
5. 同指纹冻结态仅发布 `freeze_delta_card`，历史全文下沉 `freeze_history_pointer`。

## Fence Contract
1. Cycle closure verdict first（强约束）
`cycle_closure_verdict_card.json` 必含 `cycle_id,run_start_seen,run_end_seen,closure_verdict,next_action`。
2. Run pair evidence bind（强约束）
`run_pair_evidence_card.json` 必含 `run_id,start_ts,end_ts_or_none,evidence_path`。
3. State advance isolation（强约束）
`state_advance_card.json` 必含 `cycle_before,cycle_after,advanced,mutates_gate_reason=false`。
4. Receipt demux（强约束）
`commit_receipt_card.json` 必含 `commit_attempted,receipt_status,error_class,lock_scope,cross_scope_write=false`。
5. Delta-only freeze replay（强约束）
`freeze_delta_card.json` 必含 `fingerprint,new_fact,unchanged_context`，禁止内联历史全文。

## Minimal Evidence Bundle
- `cycle_closure_verdict_card.json`
- `run_pair_evidence_card.json`
- `state_advance_card.json`
- `commit_receipt_card.json`
- `freeze_delta_card.json`
- `freeze_history_pointer.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单碎片可独立回答“本轮是否闭环、cycle 是否前进、阻塞点在哪”。
- `Fidelity`: 保留闭环状态/合同裁决/提交回执三通道边界，不以观测指标替代裁决。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern 主证据路径。

任一 gate fail：进入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 仅凭 `state.status=running` 判定“本轮已完成闭环”。
- 将 `index.lock permission denied` 写成 Self-Containment/Fidelity 失败理由。
- `run_start` 无 `run_end` 仍标记 `closure=closed`。
- 同一冻结态每轮全文复述，不产出 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
