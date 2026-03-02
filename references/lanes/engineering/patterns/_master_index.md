# Pattern Master Index

> engineering lane 的可执行 pattern 总索引（已对齐真实文件）。
> 最后更新：2026-03-02（cycle 159）

## Top Patterns

| Rank | Pattern | Topic | Evidence Band | Sources |
|---|---|---|---|---:|
| 3 | [long-context-index-sharding-recall-rollback-contract](./runtime-governance/long-context-index-sharding-recall-rollback-contract.md) | runtime-governance | medium | 8 |
| 3 | [map-integrity-filegraph-attestation-gate](./runtime-governance/map-integrity-filegraph-attestation-gate.md) | runtime-governance | medium | 11 |
| 3 | [augment-context-memory-index-parity-recall-freshness-gate](./runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md) | runtime-governance | medium | 28 |
| 3 | [background-agent-runplane-lease-heartbeat-dlq-backpressure](./autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md) | autonomous-ops | medium | 4 |
| 3 | [background-agent-dag-checkpoint-resume-idempotency-gate](./autonomous-ops/background-agent-dag-checkpoint-resume-idempotency-gate.md) | autonomous-ops | medium | 18 |
| 3 | [requirement-assertion-semantic-conformance-score-gate](./product-delivery/requirement-assertion-semantic-conformance-score-gate.md) | product-delivery | medium | 9 |
| 3 | [requirement-assertion-execution-ledger-closure-gate](./product-delivery/requirement-assertion-execution-ledger-closure-gate.md) | product-delivery | medium | 12 |
| 3 | [ai-generated-code-prodlike-e2e-closure-gate](./fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md) | fullstack-engineering | medium | 13 |
| 3 | [ai-code-fault-injection-fuzz-replay-prebug-gate](./fullstack-engineering/ai-code-fault-injection-fuzz-replay-prebug-gate.md) | fullstack-engineering | medium | 4 |
| 3 | [anti-fake-test-property-mutation-stateful-gate](./fullstack-engineering/anti-fake-test-property-mutation-stateful-gate.md) | fullstack-engineering | medium | 23 |
| 3 | [openapi-link-stateful-sequence-closure-gate](./fullstack-engineering/openapi-link-stateful-sequence-closure-gate.md) | fullstack-engineering | medium | 6 |
| 3 | [artifact-retention-reconciliation-governance](./evidence-governance/artifact-retention-reconciliation-governance.md) | evidence-governance | medium | 41 |
| 3 | [sources-distilled-ingestion-lineage-freshness-governance](./evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md) | evidence-governance | medium | 58 |

## Topics

| Topic | Patterns | 说明 |
|---|---:|---|
| [autonomous-ops/](./autonomous-ops/) | 2 | background runplane + DAG checkpoint/recovery + continuation token clock-skew 治理 |
| [evidence-governance/](./evidence-governance/) | 2 | 工件对账与晋级证据锁 + round-2 provenance 可追根 + attempt-scope quorum 闭合 + structured uplift deficit trace + deficit→action→receipt 闭环 + live window closure + blocker-zero readiness snapshot |
| [fullstack-engineering/](./fullstack-engineering/) | 4 | AI 代码 prod-like E2E + 缺陷前置发现 + anti-fake-test + shadow/holdout 收敛门禁 |
| [product-delivery/](./product-delivery/) | 2 | 需求语义符合性 + 执行账本闭环 + requirement→runtime traceability 门禁 |
| [runtime-governance/](./runtime-governance/) | 3 | 长上下文索引 + map-integrity + augment parity + threshold registry + PreToolUse route binding + tool-path/hook attestation + benchmark trade-off + retrieval trace/fixture lineage 治理 |

## 统计

- 总计：13 patterns
- evidence_band=medium：13 patterns
- evidence_band=high：0 patterns
- evidence_band=medium-high：0 patterns
- evidence_band=low-medium：0 patterns
- evidence_band=low：0 patterns

## 空白区域（Cycle 159 Scout Map）

| Priority | Blank Area | 推荐落点 |
|---|---|---|
| Done | 索引声明与真实文件一致性门禁 | `runtime-governance/map-integrity-filegraph-attestation-gate.md`（cycle 131） |
| Done | Augment 长上下文 memory/indexing 专项治理 | `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md`（cycle 131） |
| Done | background-agents DAG/checkpoint/resume/idempotency 门禁 | `autonomous-ops/background-agent-dag-checkpoint-resume-idempotency-gate.md`（cycle 131） |
| Done | sources/distilled 持续证据输入机制 | `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 132） |
| Done | anti-fake-test property/mutation/stateful 三角门禁 | `fullstack-engineering/anti-fake-test-property-mutation-stateful-gate.md`（cycle 132） |
| Done | OpenAPI Link -> Stateful 序列闭环门禁 | `fullstack-engineering/openapi-link-stateful-sequence-closure-gate.md`（cycle 133） |
| Done | 阈值注册表与 gate runner 绑定执行合同 | 已同化到 `runtime-governance` + `product-delivery` + `fullstack-engineering` + `evidence-governance`（cycle 134） |
| Done | 阈值 shadow 发布与 hidden holdout 自动收敛合同 | 已同化到 `fullstack-engineering/anti-fake-test-property-mutation-stateful-gate.md`（cycle 135） |
| Done | round-2 replay identity 与 required checks snapshot 绑定字段补齐 | 已同化到 `evidence-governance/*`（cycle 138） |
| Done | round-2 矩阵可审计字段收紧（pass_matrix + independent_source_count + gate_digest_set replay lock） | 已同化到 `evidence-governance/*`（cycle 139） |
| Done | round-2 执行证据硬化（rerun identity + branch divergence audit + attestation offline verify） | 已同化到 `evidence-governance/*`（cycle 140） |
| Done | round-2 连续窗口合同（run_attempt_chain + consecutive_round2_pass_count + promotion_blocker_code） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 141） |
| Done | context projection budget + matchLayer 审计合同（intent filter / throttling / snippet strategy） | 已同化到 `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md`（cycle 142） |
| Done | context/indexing 触发阈值 + fallback 链路 + 截断/代码块完整性 + PreToolUse 路由绑定合同 | 已同化到 `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md` + `runtime-governance/map-integrity-filegraph-attestation-gate.md`（cycle 143） |
| Done | context/indexing tool-path 决策矩阵 + throttle cap 一致性 + projection fixture 可复验 + hook attestation 完整性 | 已同化到 `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md` + `runtime-governance/map-integrity-filegraph-attestation-gate.md`（cycle 144） |
| Done | context/indexing strict/fallback/safe-baseline trade-off 对账与 deterministic safe mode 引用完整性 | 已同化到 `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md`（cycle 145） |
| Done | context/indexing retrieval trace 链路对账 + benchmark fixture lineage/coverage disclosure | 已同化到 `runtime-governance/augment-context-memory-index-parity-recall-freshness-gate.md`（cycle 146） |
| Done | round-2 live sample sufficiency + uplift epoch 对账合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 147） |
| Done | continuation token clock skew 守卫合同 | 已同化到 `autonomous-ops/background-agent-dag-checkpoint-resume-idempotency-gate.md`（cycle 147） |
| Done | round-2 provenance 可追根合同（attempt/job/runner 链 + live artifact bundle 对账） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 148） |
| Done | decision->artifact 双向追溯与工件重取回放合同 | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 148） |
| Done | requirement_id -> runtime trace/regression 证据对账合同 | 已同化到 `product-delivery/requirement-assertion-execution-ledger-closure-gate.md`（cycle 148） |
| Done | round-2 live 样本真实性锁（execution_mode + workflow_ref 一致性） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 149） |
| Done | round-2 工件重取回执覆盖合同（coverage + receipt integrity） | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 149） |
| Done | round-2 run-id canonical join + rehydration/promotion epoch 对账合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 150） |
| Done | round-2 连续样本链可回放 + 升档证据反查 + duplicate baseline 拒收合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 151） |
| Done | round-2 样本-运行绑定摘要 + 链时间间隔 + replay 结果摘要锁 + duplicate 样本级阻断证据合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 152） |
| Done | round-2 cross-runner live pair 资格 + promotion 候选包四向 join + rolling duplicate 窗口守卫合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 153） |
| Done | live pair 唯一性 + quorum 缺口量化追踪 + candidate bundle receipt-join 闭环合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 154） |
| Done | attempt-scope job 链 + merge-group/source pin + rerun 权限语义 + trusted-root freshness + retention horizon 合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` + `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 155） |
| Done | uplift_deficit 结构化缺口追踪 + round2 epoch missing pair/run 清单合同 | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 156） |
| Done | band 升档就绪 token 字段（`target_evidence_band` + `band_transition_ready_pass` + `band_transition_blockers[]`） | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 156） |
| Done | uplift_deficit 缺口-动作-回执闭环（`uplift_deficit_actionability_pass` + `deficit_burndown_monotonicity_pass` + `missing_set_recomputable_pass`） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 157） |
| Done | band blocker 对象化与 gate 证据锚点闭环（`band_transition_blocker_resolution_trace_pass` + `transition_gate_evidence_integrity_pass` + `uplift_manifest_token_binding_pass`） | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 157） |
| Done | deficit 动作到 canonical run/receipt 摘要闭环（`deficit_action_execution_trace_pass` + `window_runset_digest_lock_pass` + `missing_to_run_closure_pass` + `non_duplicate_live_increment_pass` + `promotion_readiness_snapshot_binding_pass`） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 158） |
| Done | band transition 样本地板与 blocker 同 epoch 对齐（`band_transition_sample_floor_attested_pass` + `blocker_action_epoch_alignment_pass` + `blocker_receipt_closure_integrity_pass`） | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 158） |
| Done | live round-2 窗口闭合判定（`live_round2_window_closure_pass` + `sampling_plan_lock_pass` + `qualified_pair_run_binding_pass` + `consecutive_live_round2_attested_pass`） | 已同化到 `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md`（cycle 159） |
| Done | band transition blocker-zero 就绪判定（`band_transition_blocker_zero_pass` + `transition_readiness_snapshot_consistency_pass` + `promotion_decision_ready_state_enforcement_pass`） | 已同化到 `evidence-governance/artifact-retention-reconciliation-governance.md`（cycle 159） |
| P1 | 仍缺真实 cross-runner round-2 连续复现实测通过样本达到升档阈值（已具备 window 级闭合判定，可直接定位未闭合窗口与缺口动作） | `evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md` |
| P2 | `medium-high/high` 实证样本仍为 0（已具备 blocker-zero readiness 判定，但 `p2_transition_ready_pass` 仍不满足） | `evidence-governance/artifact-retention-reconciliation-governance.md` + `promotion_token_attestation` |

## 归档状态

- 当前无 `_archive` 落地目录，历史归档信息待后续 cycle 恢复。
