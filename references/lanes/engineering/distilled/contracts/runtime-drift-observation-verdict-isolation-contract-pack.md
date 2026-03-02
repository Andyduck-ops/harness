# Runtime-Drift Observation Verdict-Isolation Contract Pack

## Target Meta-Problem
恢复轮中 `state.status=running` 与 runtime 探针漂移若被直接写成“合同失败”，会把观测通道、裁决通道与提交通道混成单一结论：
- 阅读负担：执行者无法在首屏判断“系统在跑”还是“仅状态声明在跑”。
- 元问题混杂：runtime 漂移被误路由到语义/证据门，修复动作错配。
- 重复叙述：同一漂移签名跨轮重复全量解释，新增证据被淹没。

## 60s Compression Path
1. 首屏固定三卡：`runtime_probe_card`、`state_claim_card`、`observation_partition_card`。
2. `status=running` 仅作为观测信号，必须经 runtime probe 复核，禁止直接升级为合同 verdict。
3. 漂移存在时发布 `deferred_commit_receipt` 与 `retry_condition`，不覆写已通过 gate verdict。
4. `_distilled_index.md` 更新后写 `index_snapshot_attestation`，明确检索层已可用。
5. 同漂移签名仅写 `attempt_window_delta`，历史解释统一指向 `history_pointer`。

## Observation-Verdict Isolation Contract
1. Probe card hard bind（强约束）
`runtime_probe_card.json` 必含 `tmux_session_alive,codex_exec_count,pane_children,probe_at_utc`。
2. State claim card hard bind（强约束）
`state_claim_card.json` 必含 `cycle,status_claim,updated_at,mode,claim_source`。
3. Partition card hard bind（强约束）
`observation_partition_card.json` 必含 `runtime_observation,gate_verdict,index_verdict,commit_verdict,cross_override=false`。
4. Deferred receipt hard bind（强约束）
`deferred_commit_receipt.json` 必含 `content_ready,commit_required,commit_attempted,commit_status,reason_if_no_commit,retry_condition`。
5. Delta-only repetition fence（强约束）
`attempt_window_delta.json` 必含 `drift_fingerprint,new_information,unchanged_sections,history_pointer,next_retry_at_utc`。

## Minimal Evidence Bundle
- `runtime_probe_card.json`
- `state_claim_card.json`
- `observation_partition_card.json`
- `deferred_commit_receipt.json`
- `attempt_window_delta.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可回答“当前是 runtime 真停还是状态漂移、是否允许发布、何时重试”。
- `Fidelity`: 漂移仅停留在 observation/commit 通道，不覆写 runtime/gate/index 已通过边界。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止宣告 `publish_decision=closed`。

## Anti-Patterns
- 把 `status=running` 直接当作 runtime 活跃 verdict。
- 用漂移观测结果覆写 gate/index 已通过结论。
- 同签名无新增信息仍重复全量叙述。
- 用伪精度分数替代合同布尔裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
