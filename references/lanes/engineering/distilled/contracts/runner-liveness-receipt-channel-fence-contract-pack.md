# Runner Liveness / Receipt Channel Fence Contract Pack

## Target Meta-Problem
恢复轮若把 `state=running` 声明、runner 活性探针、以及 commit 失败回执混成同一结论层，会同时触发三类信号：
- 阅读负担信号：首屏没有“活性是否成立”的直接裁决，必须反查 state/pid/log 才能下结论。
- 元问题混杂信号：runtime claim 缺证被误写成 evidence/semantic gate 失败。
- 重复叙述信号：同一 `runner-claim-vs-receipt-mismatch` 指纹跨轮重复回放历史报错，增量事实不可见。

## 60s Compression Path
1. 首屏固定 `runner_liveness_verdict_card`，先给三门合同裁决与下一动作。
2. `state=running` 仅作为声明，必须绑定 `pid_witness_card` 与 `runner_pulse_card` 才可提升为 liveness-pass。
3. commit 结果只写 `commit_receipt_card`，禁止写回 runtime verdict 通道。
4. 同签名重试仅发布 `mismatch_delta_card`，历史全文下沉 `history_pointer_card`。
5. `meta_scope_router` 强制 runtime/evidence/receipt 三通道隔离。

## Fence Contract
1. Runner claim verdict first（强约束）
`runner_liveness_verdict_card.json` 必含 `cycle_id,state_claim,liveness_verdict,next_action`。
2. Witness hard bind（强约束）
`pid_witness_card.json` 必含 `pid_value,pid_exists,process_probe_at`；`runner_pulse_card.json` 必含 `pulse_source,pulse_at,freshness_pass`。
3. Receipt isolation（强约束）
`commit_receipt_card.json` 必含 `commit_attempted,receipt_status,error_class,lock_scope`，且 `mutates_liveness_verdict=false`。
4. Delta-only replay（强约束）
`mismatch_delta_card.json` 必含 `fingerprint,new_fact,unchanged_context`，禁止内联历史全文。
5. Scope router（强约束）
`meta_scope_router.json` 必含 `runtime_scope,evidence_scope,receipt_scope,cross_scope_write=false`。

## Minimal Evidence Bundle
- `runner_liveness_verdict_card.json`
- `pid_witness_card.json`
- `runner_pulse_card.json`
- `commit_receipt_card.json`
- `mismatch_delta_card.json`
- `history_pointer_card.json`
- `meta_scope_router.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭本碎片可回答“runner 是否活着、阻断在哪、下一步怎么做”。
- `Fidelity`: 保留 runtime/evidence/receipt 边界与反模式映射，不以观测指标替代裁决。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern 主证据。

任一 gate fail：进入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 仅凭 `state.json.status=running` 输出“守护进程稳定运行”。
- 将 `index.lock permission denied` 写成 Fidelity 或 Index Integrity 失败原因。
- 同签名轮次重复粘贴完整历史报错而不发布 delta。
- 用“指标改善”替代三门合同裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
