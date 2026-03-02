# Watchdog Restart Cycle Drift Channel Contract Pack

## Target Meta-Problem
watchdog 在同一轮次重启后，`state=running`、`runtime=stopped`、`commit_blocked` 容易被写成一条长叙述，三类信号同时放大：
- 阅读负担：需要跨 `state.json`、watchdog log、report 三处对账才能判断本轮是否闭环。
- 元问题混杂：运行连续性漂移、语义门禁结果、提交写边界失败被混成同一因果链。
- 重复叙述：相同 restart/lock 签名在多轮重复扩写，新增信息很少。

## 60s Compression Path
1. 固化四卡：`runtime_pulse_card -> cycle_transition_receipt -> commit_boundary_receipt -> closure_gate_matrix`。
2. 先判断连续性通道（runtime/state/cycle），再判断门禁通道（semantic/evidence/prod-like/index）。
3. `index.lock permission denied` 只进入 `commit_boundary_receipt`，禁止污染语义与证据 verdict。
4. 同签名仅更新 `restart_delta_receipt`，正文只保留 pointer。
5. 仅当 `runtime_drift=false` 且 `commit_boundary_ok=true` 时允许发布 `closed`。

## Restart-Drift Channel Contract
1. Runtime pulse hard bind:
`runtime_pulse_card.json` 必含 `cycle_id`, `state_status`, `runtime_status`, `drift_flag`, `checked_at_utc`。
2. Cycle transition hard bind:
`cycle_transition_receipt.json` 必含 `cycle_id`, `previous_cycle`, `transition_reason`, `watchdog_event`, `continuity_pass`。
3. Commit boundary hard bind:
`commit_boundary_receipt.json` 必含 `cycle_id`, `git_dir`, `index_lock_path`, `commit_exit_code`, `stderr_fingerprint`, `boundary_pass`。
4. Closure matrix hard bind:
`closure_gate_matrix.json` 必含 `gate_id`, `verdict`, `blocking_reason`, `channel`。
5. Publish barrier:
`self_containment_pass=true && fidelity_pass=true && index_integrity_pass=true && continuity_pass=true && boundary_pass=true` 才允许 `publish_decision=closed`。

## Minimal Evidence Bundle
- `runtime_pulse_card.json`
- `cycle_transition_receipt.json`
- `commit_boundary_receipt.json`
- `restart_delta_receipt.json`
- `closure_gate_matrix.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看四卡即可回答“本轮是否连续、主阻塞通道是什么、下一步恢复动作是什么”。
- `Fidelity`: 保留连续性、语义、证据、提交边界四通道，不把环境写失败误判为语义失败。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 命名与回链一致。

任一 gate fail：只允许 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 把 `runtime drift` 与 `semantic fail` 合并成单一失败原因。
- 将 `index.lock permission denied` 写入语义门禁结论。
- 每轮重复粘贴完整 watchdog 错误历史而不产出 delta receipt。
- 未完成 provenance 回链就先更新 index。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
