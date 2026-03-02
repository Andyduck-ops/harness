# Engineering Lane Master Index

> lane 目标：围绕工程场景沉淀可执行模式，聚焦长上下文、持续后台执行、验收门禁与 AI 代码真实场景验证。  
> 最后更新：2026-03-02（cycle 159）  
> 当前有效 patterns：13（已校准为仅指向真实文件）

## Entry Points

- [patterns/_master_index.md](./patterns/_master_index.md)
- [cross-lane bridge summary](../../bridges/cross-lane-links.md)
- [sources/](./sources/)（证据输入池，cycle 159 完成 live round-2 window closure + blocker-zero readiness snapshot 合同同化）
- [distilled/](./distilled/)（蒸馏沉淀池，当前为空）

## Active Topics Map

| Topic | Count | Index |
|---|---:|---|
| autonomous-ops | 2 | [patterns/autonomous-ops/_index.md](./patterns/autonomous-ops/_index.md) |
| evidence-governance | 2 | [patterns/evidence-governance/_index.md](./patterns/evidence-governance/_index.md) |
| fullstack-engineering | 4 | [patterns/fullstack-engineering/_index.md](./patterns/fullstack-engineering/_index.md) |
| product-delivery | 2 | [patterns/product-delivery/_index.md](./patterns/product-delivery/_index.md) |
| runtime-governance | 3 | [patterns/runtime-governance/_index.md](./patterns/runtime-governance/_index.md) |

## Execution Contract

1. 新增或同化 pattern 时，先更新对应 topic 的 `_index.md`。
2. 再同步 `patterns/_master_index.md` 的 Top Patterns、Topics 和统计。
3. 涉及跨 lane 价值时，只追加 `references/bridges/cross-lane-links.md` 摘要，不直接写其他 lane。
4. 每轮必须更新 `morning-brief.md` 并执行一次本地 git commit（禁止 push）。

## Validation Commands

```bash
# 1) 检查 lane 内 markdown 链接目标是否存在（简单相对链接）
grep -RhoE '\]\(\./[^)]+\.md\)' "references/lanes/engineering/patterns" \
  | sed -E 's/^\]\(\.\/|\.md\)$//g' >/tmp/engineering_links.txt

# 2) 检查 patterns 文件总数（不含 _index）
find "references/lanes/engineering/patterns" -type f -name "*.md" \
  | grep -v "/_index.md$" | grep -v "/_master_index.md$" | wc -l
```

## Current Gap Radar（cycle 159）

- Done: 索引声明与真实文件数一致性门禁（`map_integrity_pass`，cycle 131 已落地）。
- Done: Augment 长上下文 memory/indexing 专项门禁（`augment_memory_index_parity_pass`，cycle 131 已落地）。
- Done: background-agents DAG/checkpoint/resume/idempotency 门禁（cycle 131 已落地）。
- Done: sources/distilled 持续证据输入机制（`sources_distilled_ingest_pass`，cycle 132 已落地）。
- Done: requirement→assertion→执行结果运行账本闭环门禁（cycle 130 已落地）。
- Done: AI 代码潜在 bug 前置发现门禁（fault injection/fuzz/replay，cycle 130 已落地）。
- Done: anti-fake-test property/mutation/stateful 三角门禁（`anti_fake_test_closure_pass`，cycle 132 已落地）。
- Done: OpenAPI Link 驱动 stateful 序列闭环门禁（`openapi_link_stateful_sequence_pass`，cycle 133 已落地）。
- Done: 阈值注册表与 gate runner 绑定合同（`threshold_registry_complete_pass` + `gate_runner_binding_pass`，cycle 134 已同化到 runtime/product/fullstack/evidence）。
- Done: 阈值 shadow 发布与 hidden holdout 自动收敛合同（`shadow_convergence_pass` + `holdout_drift_guard_pass` + `threshold_promote_rollback_guard_pass`，cycle 135 已同化）。
- Done: round-2 replay identity 合同已补齐（`runner_env_fingerprint` + `required_checks_snapshot_sha256`，cycle 138 已同化到 evidence-governance）。
- Done: background continuation token 过期窗口合同已补齐（`token_expires_at_utc`，cycle 138 已同化到 autonomous-ops）。
- Done: prod-like trace 摘要完整性与 incremental cache 作用域合同已补齐（cycle 138 已同化到 fullstack-engineering）。
- Done: round-2 matrix 可审计字段已补齐（`pass_matrix` + `independent_source_count` + `gate_digest_replay_identity`，cycle 139 已同化到 evidence-governance）。
- Done: round-2 执行证据硬化已补齐（`rerun_identity_consistency_pass` + `branch_divergence_audit_pass` + `attestation_offline_verify_pass`，cycle 140 已同化到 evidence-governance）。
- Done: round-2 连续窗口合同已补齐（`round2_consecutive_window_pass` + `round2_promotion_blocker_trace_pass`，cycle 141 已同化到 evidence-governance）。
- Done: context projection budget + matchLayer 审计合同已补齐（`context_projection_budget_guard_pass` + `retrieval_matchlayer_audit_pass` + `progressive_search_throttle_pass`，cycle 142 已同化到 runtime-governance）。
- Done: context/indexing 触发阈值 + fallback 链路 + 截断/代码块完整性 + PreToolUse 路由绑定合同已补齐（`intent_filter_activation_guard_pass` + `retrieval_fallback_chain_integrity_pass` + `truncation_integrity_guard_pass` + `code_block_exactness_guard_pass` + `progressive_throttle_state_machine_pass` + `pretooluse_route_binding_pass`，cycle 143 已同化到 runtime-governance）。
- Done: context/indexing tool-path 决策矩阵 + throttle cap 一致性 + projection fixture 可复验 + hook attestation 完整性已补齐（`tool_path_decision_integrity_pass` + `throttle_cap_consistency_pass` + `projection_fixture_reproducibility_pass` + `pretooluse_route_binding_pass`，cycle 144 已同化到 runtime-governance）。
- Done: context/indexing strict/fallback/safe-baseline trade-off 对账 + deterministic safe mode 引用完整性已补齐（`retrieval_mode_traceability_pass` + `benchmark_tradeoff_consistency_pass` + `deterministic_safe_mode_citation_integrity_pass`，cycle 145 已同化到 runtime-governance）。
- Done: context/indexing retrieval trace 链路对账 + benchmark fixture lineage/coverage disclosure 已补齐（`retrieval_trace_linkage_pass` + `benchmark_fixture_lineage_pass` + `benchmark_coverage_disclosure_pass`，cycle 146 已同化到 runtime-governance）。
- Done: round-2 样本充足度与升档 epoch 对账合同已补齐（`round2_live_sample_sufficiency_pass` + `evidence_uplift_epoch_alignment_pass`，cycle 147 已同化到 evidence-governance）。
- Done: continuation token 时钟偏差守卫合同已补齐（`continuation_token_clock_skew_guard_pass`，cycle 147 已同化到 autonomous-ops）。
- Done: round-2 provenance 可追根合同已补齐（`cross_runner_round2_live_artifact_pass` + `round2_consecutive_pair_integrity_pass` + `promotion_evidence_bundle_integrity_pass`，cycle 148 已同化到 evidence-governance）。
- Done: decision->artifact 双向追溯与重取回放合同已补齐（`round2_artifact_retention_window_pass` + `decision_to_artifact_bidirectional_trace_pass` + `artifact_rehydration_replay_pass`，cycle 148 已同化到 evidence-governance）。
- Done: requirement_id -> runtime trace/regression 对账合同已补齐（`assertion_runtime_evidence_alignment_pass` + `requirement_runtime_traceability_pass` + `requirement_runtime_fidelity_pass`，cycle 148 已同化到 product-delivery）。
- Done: round-2 live 样本真实性锁已补齐（`round2_non_synthetic_evidence_pass` + `round2_workflow_ref_lock_pass`，cycle 149 已同化到 evidence-governance）。
- Done: round-2 工件重取回执覆盖合同已补齐（`round2_rehydration_coverage_pass` + `artifact_fetch_receipt_integrity_pass`，cycle 149 已同化到 evidence-governance）。
- Done: round-2 run-id canonical join 与 rehydration/promotion epoch 对账合同已补齐（`round2_run_id_canonical_join_pass` + `rehydration_promotion_epoch_alignment_pass` + `round2_run_id_alias_consistency_pass`，cycle 150 已同化到 evidence-governance）。
- Done: round-2 连续样本链可回放与升档证据反查合同已补齐（`round2_sample_chain_continuity_pass` + `promotion_evidence_backtrace_pass` + `promotion_replay_query_consistency_pass` + `duplicate_cycle150_baseline_guard_pass`，cycle 151 已同化到 evidence-governance）。
- Done: round-2 样本-运行绑定摘要与链时间间隔、promotion replay 结果摘要锁及 duplicate 样本级阻断证据合同已补齐（`round2_sample_run_binding_integrity_pass` + `round2_chain_temporal_spacing_pass` + `promotion_replay_result_digest_lock_pass` + `duplicate_blocking_evidence_trace_pass`，cycle 152 已同化到 evidence-governance）。
- Done: round-2 cross-runner live pair 资格、promotion 候选包四向 join 与 replay/bundle 摘要一致性合同已补齐（`cross_runner_live_pair_qualification_pass` + `promotion_epoch_four_way_join_pass` + `promotion_candidate_bundle_epoch_join_pass` + `promotion_replay_bundle_digest_consistency_pass` + `rolling_duplicate_sample_guard_pass`，cycle 153 已同化到 evidence-governance）。
- Done: live pair 唯一性 + round-2 quorum 缺口量化追踪 + candidate bundle receipt-join 闭环合同已补齐（`cross_runner_live_pair_uniqueness_pass` + `round2_live_run_quorum_pass` + `evidence_high_promotion_deficit_trace_pass` + `promotion_candidate_bundle_rehydration_pass` + `promotion_replay_bundle_receipt_join_pass` + `promotion_decision_blocker_enforcement_pass`，cycle 154 已同化到 evidence-governance）。
- Done: attempt-scope job 链、merge-group/source pin、rerun 权限语义、trusted-root 新鲜度与 retention 覆盖升档窗口合同已补齐（`round2_attempt_scoped_job_chain_pass` + `merge_group_head_sha_binding_pass` + `rerun_privilege_semantics_pass` + `attestation_trusted_root_freshness_pass` + `promotion_retention_horizon_pass` + `candidate_bundle_live_receipt_integrity_pass` + `promotion_blocker_resolution_enforcement_pass`，cycle 155 已同化到 evidence-governance）。
- Done: `evidence_high_promotion_pass=false` 的缺口已结构化（`uplift_deficit_structured_trace_pass` + `round2_epoch_missing_pair_trace_pass` + `promotion_blocker_structural_consistency_pass`，cycle 156 已同化到 evidence-governance）。
- Done: 证据带迁移就绪 token 字段已补齐（`target_evidence_band` + `band_transition_readiness_pass` + `band_transition_blocker_alignment_pass` + `band_transition_decision_consistency_pass`，cycle 156 已同化到 evidence-governance）。
- Done: uplift_deficit 已补齐缺口-动作-回执闭环（`uplift_deficit_actionability_pass` + `deficit_burndown_monotonicity_pass` + `missing_set_recomputable_pass`，cycle 157 已同化到 evidence-governance）。
- Done: band blocker 已补齐对象化追踪与 gate 证据锚点（`band_transition_blocker_resolution_trace_pass` + `transition_gate_evidence_integrity_pass` + `uplift_manifest_token_binding_pass`，cycle 157 已同化到 evidence-governance）。
- Done: deficit 动作到 canonical run/receipt 摘要闭环已补齐（`deficit_action_execution_trace_pass` + `window_runset_digest_lock_pass` + `missing_to_run_closure_pass` + `non_duplicate_live_increment_pass` + `promotion_readiness_snapshot_binding_pass`，cycle 158 已同化到 evidence-governance）。
- Done: band transition 样本地板与 blocker 同 epoch 对齐已补齐（`band_transition_sample_floor_attested_pass` + `blocker_action_epoch_alignment_pass` + `blocker_receipt_closure_integrity_pass`，cycle 158 已同化到 evidence-governance）。
- Done: live round-2 窗口闭合判定已补齐（`live_round2_window_closure_pass` + `sampling_plan_lock_pass` + `qualified_pair_run_binding_pass` + `consecutive_live_round2_attested_pass`，cycle 159 已同化到 evidence-governance）。
- Done: band transition blocker-zero 就绪判定已补齐（`band_transition_blocker_zero_pass` + `transition_readiness_snapshot_consistency_pass` + `promotion_decision_ready_state_enforcement_pass`，cycle 159 已同化到 evidence-governance）。
- Done: long-context history budget 溢出遥测字段已补齐（`warn_limit_events/hard_limit_events/rollover_triggered_at`，cycle 139 已同化到 runtime-governance）。
- Done: requirement->assertion 元数据完整性合同已补齐（`normative_source_ref/spec_version_applicability`，cycle 139 已同化到 product-delivery）。
- P1: `evidence_high_promotion_pass` 仍缺 cross-runner round-2 连续复现实测通过样本（现已具备 window 级闭合判定与缺口动作绑定，可直接定位未闭合窗口），暂未升至 `medium-high/high`。
- P2: high/medium-high 证据带样本仍为 0；虽已补齐 blocker-zero readiness 判定字段，但 `p2_transition_ready_pass` 仍未满足。
