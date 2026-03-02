# Statefile Runtime Drift Reconciliation Contract Pack

## Target Meta-Problem
恢复轮中 `state.json.status=running` 往往被直接当作“系统仍在运行”的结论；当 tmux/codex 进程已失活时，这会把运行态、提交态与闭环态混写：
- 阅读负担：读者需要跨 state、session、index 三处反查才知道真实状态；
- 元问题混杂：runtime 失活被误判为语义或证据问题；
- 重复叙述：每轮重复解释历史阻塞，而不是发布本轮 drift 增量。

## 60s Compression Path
1. 固化三卡对账：`runtime_probe_card -> state_snapshot_card -> drift_decision_card`。
2. `state=running` 仅可作为候选信号，必须经 runtime probe 复核后才能升级为 liveness 结论。
3. `drift_detected=true` 时只允许发布 `deferred`，并产出恢复动作与重试周期。
4. 提交与索引更新后置：仅在 `drift_resolved && commit_status=success && index_receipt_ok` 后允许 closure claim。
5. 恢复轮发布 delta-only：禁止复制历史长叙述，改用 provenance 指针。

## Drift Reconciliation Contract
1. Runtime probe hard bind:
`runtime_probe_card.json` 必含 `tmux_session_alive`, `codex_exec_count`, `pane_children`, `probe_at_utc`。
2. State snapshot hard bind:
`state_snapshot_card.json` 必含 `cycle`, `status`, `updated_at`, `mode`。
3. Drift decision hard bind:
`drift_decision_card.json` 必含 `drift_detected`, `drift_reason`, `decision`, `retry_after_cycle`。
4. Decision fence:
当 `status=running` 且 `tmux_session_alive=false && codex_exec_count=0` 时，`decision` 必须是 `deferred`。
5. Closure release fence:
`closure_claim` 仅在 `drift_detected=false` 且 `commit_status=success` 且 `index_row_added=true && shortcut_added=true` 时允许。

## Minimal Evidence Bundle
- `runtime_probe_card.json`
- `state_snapshot_card.json`
- `drift_decision_card.json`
- `commit_receipt_card.json`
- `index_receipt_card.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭三张 drift 卡即可回答“是否真在运行、是否可闭环、下一轮如何恢复”。
- `Fidelity`: 保留 lease/heartbeat 新鲜度、semantic conformance、lineage digest、prod-like replay、recall fidelity 边界。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 四点回链一致。

任一 gate fail：禁止发布 `closed`，仅允许 `deferred`。

## Anti-Patterns
- 将 `state.status=running` 直接等同于 runtime 活跃。
- runtime 已失活但仍输出“本轮持续运行并完成”。
- commit 或 index 收据缺失时提前发布 closure 语义。
- 恢复轮复制历史全文而不发布 drift delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
