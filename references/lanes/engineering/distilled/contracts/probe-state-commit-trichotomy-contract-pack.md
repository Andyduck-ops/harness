# Probe-State-Commit Trichotomy Contract Pack

## Target Meta-Problem
恢复轮里若把 `state.status=running`、runtime 探针结果与 commit 可写性结论压成单一“执行状态”，会同时触发三类噪声：
- 阅读负担：首屏无法判断“正在运行”“仅状态声明运行”还是“内容已生成但提交阻塞”。
- 元问题混杂：runtime freshness、gate verdict、commit boundary 三通道被混成一个修复动作。
- 重复叙述：同一 `index.lock` 指纹跨轮重复全量叙述，新增证据淹没在历史解释里。

## 60s Compression Path
1. 首屏固定三分卡：`runtime_probe_card`、`state_claim_card`、`commit_writability_card`。
2. 先给 `trichotomy_decision_card`：分别输出 `runtime_verdict`、`gate_verdict`、`commit_verdict`，禁止跨通道覆写。
3. commit 不可写时仅发布 `deferred_commit_receipt`，不回滚已通过的 gate/index 结论。
4. 同签名重试只写 `attempt_window_delta`，历史解释统一走 `history_pointer`。
5. 先落 fragment/provenance，再更新 `_distilled_index.md` 并写 `index_snapshot_attestation`。

## Trichotomy Contract
1. Runtime probe bind（强约束）
`runtime_probe_card.json` 必含 `tmux_session_alive,codex_exec_count,pane_children,probe_at_utc`。
2. State claim bind（强约束）
`state_claim_card.json` 必含 `cycle,status_claim,updated_at,mode,claim_source`。
3. Commit writability bind（强约束）
`commit_writability_card.json` 必含 `gitdir,index_lock_path,writable,preflight_at_utc,failure_signature`。
4. Trichotomy decision bind（强约束）
`trichotomy_decision_card.json` 必含 `runtime_verdict,gate_verdict,commit_verdict,cross_override=false`。
5. Delta-only repetition fence（强约束）
`attempt_window_delta.json` 必含 `drift_fingerprint,new_information,unchanged_sections,history_pointer,next_retry_at_utc`。

## Minimal Evidence Bundle
- `runtime_probe_card.json`
- `state_claim_card.json`
- `commit_writability_card.json`
- `trichotomy_decision_card.json`
- `deferred_commit_receipt.json`
- `attempt_window_delta.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可独立回答“系统是否仍在运行、门禁是否仍有效、提交为何延后、何时重试”。
- `Fidelity`: runtime/gate/commit 三通道边界不被覆写，且保留反模式与证据映射。
- `Index Integrity`: fragment/provenance/index 命名一致，可回链 5 个 pattern 源路径。

任一 gate fail：进入 `deferred-reconcile`，禁止宣告 `publish_decision=closed`。

## Anti-Patterns
- 把 `status=running` 直接当成 runtime 活跃 verdict。
- 用 commit 阻塞结论覆写 gate/index 已通过结果。
- 同签名无新增信息仍重复全量叙述。
- 用伪精度分数替代三门合同裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
