# Orphan Run Closure Receipt Channel Fence Contract Pack

## Target Meta-Problem
恢复轮出现 `run_start` 但缺失 `run_end` 时，若把 runtime 活跃性、合同裁决、提交收据写成同一“完成结论”，会稳定放大三类信号：
- 阅读负担：执行者必须先还原“这轮到底结束没、卡在哪个通道”才能定位动作。
- 元问题混杂：freshness/semantic/evidence/recall 的门禁被误和运行态漂移混为一类。
- 重复叙述：每轮重复解释“为什么状态是 running 但没有新增闭环”。

## 60s Compression Path
1. 首屏只发布 `orphan_run_card`：`cycle_id + run_state + closure_state + primary_blocker`。
2. 四通道分账：`runtime_channel`、`gate_channel`、`commit_channel`、`index_channel`。
3. 缺失 `run_end` 时生成 `closure_receipt_pending`，禁止写 `publish_decision=closed`。
4. 历史恢复细节下沉到 `history_pointer`，正文仅保留本轮 `delta_packet`。
5. 观测指标必须声明 `observation_only=true`，不得改写合同裁决。

## Orphan-Run Fence Contract
1. Orphan run detector（强约束）
`orphan_run_card.json` 必含 `cycle_id, run_id, run_start_at, run_end_present, closure_state, primary_blocker, immediate_action`。
2. Channel isolation ledger（强约束）
`channel_isolation_ledger.json` 必含 `runtime_channel, gate_channel, commit_channel, index_channel`，每通道必须带 `owner` 与 `decision_scope`。
并且必须显式声明 `runtime/gate/commit/index` 四通道互不改写 verdict。
3. Closure receipt barrier（强约束）
`closure_receipt.json` 必含 `run_id, cycle_id, receipt_state, run_end_attested_by, receipt_observed_at`；`receipt_state!=confirmed` 时禁止 `publish_decision=closed`。
4. Gate/commit independence（强约束）
`index.lock` 或 commit 失败不得写入 `semantic_conformance_report` 与 `artifact_promotion_attestation` 的 verdict 字段。
5. Publish barrier（强约束）
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass` 为 true 且 `closure_receipt.confirmed=true` 才允许发布。

## Minimal Evidence Bundle
- `orphan_run_card.json`
- `channel_isolation_ledger.json`
- `closure_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `recall_manifest.json`
- `delta_packet.json`
- `history_pointer_map.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可回答“本轮是否 orphan run、主阻断在哪个通道、立即动作是什么”。
- `Fidelity`: 保留 runtime/assertion/evidence/recall 边界，不把运行态漂移改写为语义或证据门禁失败。
- `Index Integrity`: fragment/provenance/index 命名一致，并可回链 5 个 pattern 源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 把 `status=running` 直接等价成“本轮已闭环”。
- 用 commit 通道异常覆盖 gate 主阻断原因。
- 在首屏混写 runtime 漂移、语义评分和工件对账细节。
- 每轮重复贴全量恢复叙述，不发布 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
