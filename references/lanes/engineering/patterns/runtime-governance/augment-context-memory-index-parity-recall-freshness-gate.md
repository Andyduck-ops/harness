---
name: augment-context-memory-index-parity-recall-freshness-gate
topic: runtime-governance
evidence_band: medium
verified_count: 28
sources:
  - augmentcode context engine post (x.com status 2026907452277719230)
  - Augment Docs: Context Engine overview
  - Augment Docs: connectors and indexable sources
  - Augment Docs: MCP / remote retrieval path
  - Augment issue #924 (old/new hash mix recall drift)
  - Augment Docs: context-services MCP overview
  - long-context-index-sharding-recall-rollback-contract (cycle 129 baseline)
  - Scout/Analyst/Cartographer team synthesis (cycle 131)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
  - Augment Docs: context connectors overview (S3 + webhook/CI reindex)
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Augment Docs: workspace indexing and .augmentignore overrides
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
  - lane recall drift incident notes (cycle 131)
  - claude-context-mode repository
  - claude-context-mode README (intent filtering + matchLayer retrieval)
  - claude-context-mode BENCHMARK (context savings + progressive throttling)
  - Scout/Analyst/Cartographer team synthesis (cycle 142)
  - Scout/Analyst/Cartographer team synthesis (cycle 143)
  - Scout/Analyst/Cartographer team synthesis (cycle 144)
  - Scout/Analyst/Cartographer team synthesis (cycle 145)
  - Scout/Analyst/Cartographer team synthesis (cycle 146)
last_verified: 2026-03-02
rank: 3
---

## 元问题

长上下文系统常见失败不是“检索不到”，而是“索引已更新但召回仍命中旧块”。
当 memory 与 index 不同代时，Agent 会在看似有依据的前提下执行错误操作。

## 核心解法

建立 `Augment Context Memory-Index Parity + Recall Freshness Contract`：

1. **双轨版本锚定**
   - 每次索引构建固定 `index_epoch + shard_digest + source_revision`。
   - 每次召回返回 `recall_epoch + hit_shards + evidence_digest`。
2. **同代一致性校验**
   - `recall_epoch` 必须与允许窗口内的 `index_epoch` 对齐，禁止跨代混召回。
3. **新鲜度预算**
   - 关键路径设定 `max_staleness_minutes`，超时召回只能读、不能写。
4. **漂移冻结与重建**
   - 检测到 parity 失配时触发 `freeze + targeted reindex`，恢复后才能晋级。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `augment_index_snapshot.json` | `lineage_id`, `index_epoch`, `local_index_epoch`, `remote_default_branch_epoch`, `source_revision`, `shard_digests[]`, `built_at_utc` | 索引元数据缺失、默认分支代际缺失或摘要不完整 |
| `augment_recall_eval.json` | `query_id`, `recall_epoch`, `hit_shards[]`, `hit_hashes[]`, `mixed_hash_detected`, `evidence_digest`, `staleness_minutes` | 召回跨代、出现 mixed hash 或超新鲜度预算 |
| `augment_parity_attestation.json` | `lineage_id`, `index_epoch`, `recall_epoch`, `parity_pass`, `drift_reason` | `parity_pass=false` 仍晋级 |
| `augment_drift_freeze_log.json` | `lineage_id`, `freeze_trigger`, `reindex_job_id`, `recovery_pass` | 漂移后未冻结或恢复验证失败 |
| `mcp_context_surface_manifest.json` | `lineage_id`, `connector_type`, `repo_scope`, `branch_scope`, `source_revision`, `surface_epoch`, `connector_trigger`, `reindex_trigger_id`, `triggered_at_utc` | MCP 检索面缺少分支/来源锚点、触发链缺失或跨面漂移 |

## 阻断门禁

- `augment_memory_index_parity_pass`
  - 失败条件：`index_epoch != recall_epoch`（超允许窗口）或摘要不一致。
- `augment_recall_single_hashset_pass`
  - 失败条件：`mixed_hash_detected=true` 或 `hit_hashes` 同时命中新旧 hash 集合。
- `augment_recall_freshness_pass`
  - 失败条件：`staleness_minutes > max_staleness_minutes`。
- `mcp_surface_scope_parity_pass`
  - 失败条件：`connector_type/repo_scope/branch_scope/source_revision` 任一缺失或与召回面不一致。
- `remote_default_branch_parity_pass`
  - 失败条件：`remote_default_branch_epoch` 缺失，或与 `recall_epoch` 不在允许窗口内。
- `connector_reindex_trigger_integrity_pass`
  - 失败条件：未记录 `connector_trigger/reindex_trigger_id`，或 trigger 与索引快照无法对账。
- `augment_drift_freeze_pass`
  - 失败条件：检测到漂移但未进入 `freeze/reindex/recovery` 闭环。

## 最小验收矩阵

- 正常：同代召回且新鲜度达标，漂移日志为空 -> 允许晋级。
- 边界：轻微滞后但仍在窗口内 -> 警告并压缩窗口。
- 异常：跨代召回或漂移未冻结 -> 阻断。

## 检索测试（L5）

- 查询：`augment context memory index parity gate`
  - 命中：本 pattern
  - 动作：执行 parity 对账并校验 `augment_parity_attestation`。
- 查询：`stale recall after reindex`
  - 命中：本 pattern + `long-context-index-sharding-recall-rollback-contract`
  - 动作：触发 `augment_recall_freshness_pass` 阻断。
- 查询：`context engine drift freeze reindex`
  - 命中：本 pattern
  - 动作：执行 `freeze + targeted reindex + recovery_pass`。

## Cycle 137 同化增量（Remote Branch + Connector Trigger）

### 空白判定

cycle 136 已覆盖 hashset parity 与漂移冻结，但缺少“本地实时索引 vs 远端默认分支索引”的代际同源校验，
以及 connector 自动再索引（S3/webhook/CI）触发链的可审计字段。

### 核心补丁

- `augment_index_snapshot.json` 新增 `local_index_epoch` 与 `remote_default_branch_epoch`。
- `mcp_context_surface_manifest.json` 新增 `connector_trigger`、`reindex_trigger_id`、`triggered_at_utc`。
- 新增门禁：
  - `remote_default_branch_parity_pass`
  - `connector_reindex_trigger_integrity_pass`

## Cycle 139 同化增量（Remote/Local Index Lag Audit）

### 空白判定

cycle 137 已补 `remote_default_branch_epoch`，但仍缺少“远端默认分支索引与本地工作树索引的时差量化字段”，
导致 parity 只能判断“是否同代”，不能判断“是否接近实时”。

### 核心补丁

- `augment_index_snapshot.json` 新增：
  - `index_lag_seconds`
  - `branch_divergence_commits`
  - `index_include_globs/index_exclude_globs/gitignore_override_patterns`
- `remote_default_branch_parity_pass` 升级为“同代 + 时差可审计”双条件：
  - 失败条件新增：`index_lag_seconds` 超预算且未声明 `freeze_mode`。
- `connector_reindex_trigger_integrity_pass` 补充触发覆盖率校验：
  - 失败条件新增：`indexed_file_count` 与声明的 include/exclude 规则不一致。

## Cycle 142 同化增量（Projection Budget + MatchLayer Audit）

### 空白判定

cycle 139 已补齐 remote/local lag 审计，但仍缺“检索结果如何被压缩后进入上下文”的可审计投影链路。
当检索 fallback 到 trigram/levenshtein 或触发强节流时，若无投影字段，仍会出现“同代索引却低保真上下文”的隐性漂移。

### 核心补丁

- `augment_recall_eval.json` 新增：
  - `source_tool`
  - `raw_bytes/context_bytes/savings_ratio`
  - `intent_query`
  - `match_layer`（`porter/trigram/levenshtein/none`）
  - `snippet_strategy`
  - `truncation_policy`（`none/head60_tail40`）
  - `throttle_tier`（`t1_normal/t2_reduced/t3_blocked`）
- 新增 `context_projection_budget_report.json`：
  - `lineage_id`, `query_id`, `lease_state`, `heartbeat_ts`
  - `resume_terms[]`, `code_block_fidelity`, `reroute_to_batch_execute`
- 新增门禁：
  - `context_projection_budget_guard_pass`
  - `retrieval_matchlayer_audit_pass`
  - `progressive_search_throttle_pass`

### 新增失败条件

- `context_projection_budget_guard_pass`
  - 失败条件：`savings_ratio` 超预算且缺失 `intent_query/match_layer` 任一字段。
- `retrieval_matchlayer_audit_pass`
  - 失败条件：连续 fallback 到 `trigram/levenshtein` 且未触发 reindex 或 drift freeze。
- `progressive_search_throttle_pass`
  - 失败条件：`throttle_tier=t3_blocked` 但未记录 `reroute_to_batch_execute=true`。

## Cycle 143 同化增量（Intent Threshold + Fallback Chain Integrity）

### 空白判定

cycle 142 已补齐 projection budget/matchLayer/throttle 的基础审计字段，
但仍缺“触发阈值、fallback 链路、截断完整性、代码块保真”四类强约束。
这会留下“字段存在但行为不可复验”的灰区。

### 核心补丁

- `augment_recall_eval.json` 新增：
  - `input_bytes`
  - `intent_filter_threshold_bytes`（固定 `5120`）
  - `intent_filter_applied`
  - `original_query`, `rewritten_query`
  - `fallback_hops[]`（含 `from_layer/to_layer/reason`）
  - `truncation_line_boundary_ok`, `utf8_integrity_ok`, `tail_error_snippet_preserved`
  - `code_block_exact_hash`, `code_block_hash_match`
  - `throttle_transition_path[]`（`t1->t2->t3` 可审计迁移路径）
- `context_projection_budget_report.json` 新增：
  - `intent_filter_reason`
  - `throttle_transition_reason`
  - `fallback_chain_digest`
  - `projection_repro_fixture_id`
- 新增门禁：
  - `intent_filter_activation_guard_pass`
  - `retrieval_fallback_chain_integrity_pass`
  - `truncation_integrity_guard_pass`
  - `code_block_exactness_guard_pass`
  - `progressive_throttle_state_machine_pass`

### 新增失败条件

- `intent_filter_activation_guard_pass`
  - 失败条件：`input_bytes > 5120` 且 `intent_query` 存在，但 `intent_filter_applied=false`。
- `retrieval_fallback_chain_integrity_pass`
  - 失败条件：触发 fallback 但缺 `original_query/rewritten_query/fallback_hops` 任一字段。
- `truncation_integrity_guard_pass`
  - 失败条件：`truncation_policy=head60_tail40` 时任一完整性字段为 `false`。
- `code_block_exactness_guard_pass`
  - 失败条件：`code_block_exact_hash` 缺失或 `code_block_hash_match=false`。
- `progressive_throttle_state_machine_pass`
  - 失败条件：`query_count` 跨过 `1-3/4-8/9+` 阈值时，`throttle_transition_path` 缺失或与 `throttle_tier` 不一致。

## Cycle 144 同化增量（Tool-Path Decision + Projection Fixture Repro）

### 空白判定

cycle 143 已补齐 intent/fallback/truncation/code-block 的行为链路，但仍缺三类可复验字段：
tool 路径选择矩阵、节流分段调用号/结果上限、projection fixture 的落盘路径与摘要。
缺这些字段会导致“门禁定义存在，但无法复跑复核”。

### 核心补丁

- `augment_recall_eval.json` 新增：
  - `intent_vocab_terms[]`
  - `search_call_ordinal`
  - `per_query_result_cap`
  - `throttle_warning_emitted`
  - `data_type_class`
  - `tool_decision_matrix_version`
- `context_projection_budget_report.json` 新增：
  - `projection_fixture_path`
  - `projection_fixture_sha256`
- 新增门禁：
  - `tool_path_decision_integrity_pass`
  - `throttle_cap_consistency_pass`
  - `projection_fixture_reproducibility_pass`

### 新增失败条件

- `tool_path_decision_integrity_pass`
  - 失败条件：`data_type_class in {docs, api_ref, skill_prompt, mcp_signature}` 时，未走 `index+search` 或缺 `tool_decision_matrix_version`。
- `throttle_cap_consistency_pass`
  - 失败条件：`search_call_ordinal` 与 `throttle_tier` 不一致，或 `per_query_result_cap` 不满足 `t1=2/t2=1/t3=0`。
- `projection_fixture_reproducibility_pass`
  - 失败条件：存在 `projection_repro_fixture_id` 但缺 `projection_fixture_path/projection_fixture_sha256`，或摘要不可复算。

## Cycle 145 同化增量（Benchmark Trade-off + Deterministic Safe Mode）

### 空白判定

cycle 144 已补齐 tool-path/cap/fixture 的结构化字段，但仍缺“模式切换收益是否真实可复验”的基准对账层。
缺少 strict/fallback/safe-baseline 的模式语义与质量/成本/时延对账字段时，会出现“节省率看起来很好但质量回退不可审计”的假阳性。

### 核心补丁

- `augment_recall_eval.json` 新增：
  - `retrieval_mode`（`strict/fallback/safe_baseline`）
  - `benchmark_suite_id`
  - `baseline_tokens`, `filtered_tokens`, `context_reduction_pct`
  - `quality_score`, `latency_delta_pct`, `cost_delta_pct`
  - `retrieval_skipped_due_to_intent`
  - `citation_from_retrieval_only`
- `context_projection_budget_report.json` 新增：
  - `benchmark_sample_size`
  - `benchmark_mode_split`（`strict_queries/fallback_queries`）
  - `quality_floor_config`
- 新增门禁：
  - `retrieval_mode_traceability_pass`
  - `benchmark_tradeoff_consistency_pass`
  - `deterministic_safe_mode_citation_integrity_pass`

### 新增失败条件

- `retrieval_mode_traceability_pass`
  - 失败条件：命中 `intent_query` 但缺 `retrieval_mode`，或 `retrieval_mode` 不在允许集合内。
- `benchmark_tradeoff_consistency_pass`
  - 失败条件：`baseline_tokens/filtered_tokens/context_reduction_pct` 任一缺失，或 `context_reduction_pct` 与 token 差值不可对账。
  - 失败条件：`quality_score` 低于 `quality_floor_config` 且未记录降级到 `fallback` 的原因。
- `deterministic_safe_mode_citation_integrity_pass`
  - 失败条件：`retrieval_skipped_due_to_intent=true` 但输出仍声明检索引用。
  - 失败条件：`citation_from_retrieval_only=false` 且未标注为 `safe_baseline` 输出。

## Cycle 146 同化增量（Retrieval Trace Linkage + Benchmark Fixture Lineage）

### 空白判定

cycle 145 已补齐 strict/fallback/safe-baseline 的成本/质量对账字段，
但仍缺“单次检索命中 -> 片段选择 -> 最终上下文注入”的链路级可追溯凭据，
以及 benchmark 样本集与复跑命令的可验 lineage。
缺少这两层会出现“指标看起来可对账，但无法复跑复核”的假阳性。

### 核心补丁

- `augment_recall_eval.json` 新增：
  - `retrieval_trace_id`
  - `selected_snippet_ids[]`
  - `snippet_selection_policy`
  - `benchmark_case_id`
  - `benchmark_fixture_sha256`
  - `benchmark_replay_cmd`
- `context_projection_budget_report.json` 新增：
  - `benchmark_manifest_sha256`
  - `scenario_coverage_ratio`
  - `tool_coverage_ratio`
  - `quality_regression_reason`
- 新增门禁：
  - `retrieval_trace_linkage_pass`
  - `benchmark_fixture_lineage_pass`
  - `benchmark_coverage_disclosure_pass`

### 新增失败条件

- `retrieval_trace_linkage_pass`
  - 失败条件：`retrieval_trace_id` 缺失，或与 projection 报告中的 trace id 不一致。
  - 失败条件：`context_bytes>0` 但 `selected_snippet_ids[]` 为空。
- `benchmark_fixture_lineage_pass`
  - 失败条件：存在 `benchmark_suite_id`/`benchmark_case_id`，但缺 `benchmark_fixture_sha256` 或 `benchmark_replay_cmd`。
  - 失败条件：`benchmark_manifest_sha256` 缺失，无法将样本清单绑定到本次对账。
- `benchmark_coverage_disclosure_pass`
  - 失败条件：输出 trade-off 字段（token/cost/latency/quality）但缺 `scenario_coverage_ratio` 或 `tool_coverage_ratio`。
  - 失败条件：`quality_score` 下降且 `quality_regression_reason` 缺失。

## 合并来源

- Augment Context Engine 公开材料
- Augment issue #924（old/new hash mix）
- Augment MCP overview（context-services）
- Augment workspace indexing / .augmentignore 覆盖规则
- claude-context-mode README / BENCHMARK（intent filtering + matchLayer + progressive throttling）
- claude-context-mode BENCHMARK（strict/fallback token-cost-latency-quality trade-off 对账样本）
- claude-context-mode repository
- long context recall/rollback 基线 pattern
- cycle 131 空白补齐（runtime-governance）
- cycle 133 同化更新（hashset + MCP surface parity）
- cycle 143 同化更新（intent threshold + fallback chain + truncation/code block integrity）
- cycle 144 同化更新（tool-path decision + throttle cap + projection fixture reproducibility）
- cycle 145 同化更新（benchmark trade-off 对账 + deterministic safe mode citation integrity）
- cycle 146 同化更新（retrieval trace linkage + benchmark fixture lineage/disclosure）
