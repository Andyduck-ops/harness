---
name: sources-distilled-ingestion-lineage-freshness-governance
topic: evidence-governance
evidence_band: medium
verified_count: 58
sources:
  - artifact-retention-reconciliation-governance (cycle 129 baseline)
  - background-agent-dag-checkpoint-resume-idempotency-gate (cycle 131 baseline)
  - engineering lane gap radar (cycle 131)
  - pattern master gap radar (cycle 131)
  - augmentcode changelog remote-agent update (2025-02-06 cross-check)
  - Augment Docs: context-services MCP overview
  - Scout/Analyst/Cartographer team synthesis (cycle 132)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
  - Augment Docs: context engine and context services overview
  - OpenAI Docs: background mode status lifecycle
  - LangGraph Docs: durable execution and thread-level resume
  - Scout findings synthesis (cycle 135)
  - Analyst L2/L5 verdict (cycle 135)
  - GitHub Docs: using matrix for jobs in workflows
  - Scout findings synthesis (cycle 136)
  - Analyst L2/L5 verdict (cycle 136)
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - GitHub Docs: re-running workflows and jobs
  - Analyst/Cartographer L2/L5 verdict (cycle 138)
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
  - GitHub Docs: matrix strategy for multi-runner reproducibility
  - Scout/Analyst/Cartographer team synthesis (cycle 140)
  - GitHub Docs: re-run identity and variables semantics
  - GitHub Docs: compare two commits BASE...HEAD
  - GitHub Docs: workflow matrix coverage and limits
  - GitHub Docs: artifact attestation offline verification
  - OpenAI Docs: background stream cursor and webhook retry semantics
  - Analyst L2/L5 verdict (cycle 141)
  - Scout/Analyst/Cartographer team synthesis (cycle 147)
  - GitHub REST API: list jobs for workflow run attempt
  - GitHub REST API: list workflow runs for a workflow
  - GitHub Docs: github-hosted runners reference
  - GitHub Docs: self-hosted runners reference
  - GitHub Docs: available rules for rulesets
  - SLSA v1.0 requirements
  - Scout/Analyst/Cartographer team synthesis (cycle 149)
  - Scout/Analyst/Cartographer team synthesis (cycle 150)
  - Analyst L2/L5 verdict (cycle 150)
  - GitHub REST API: workflow runs replay-chain fields (cycle 151)
  - GitHub REST API: workflow jobs runner-chain fields (cycle 151)
  - Scout/Analyst/Cartographer team synthesis (cycle 152)
  - Analyst L2/L5 verdict (cycle 152)
  - Scout/Analyst/Cartographer team synthesis (cycle 153)
  - Analyst L2/L5 verdict (cycle 153)
  - Scout/Analyst/Cartographer team synthesis (cycle 154)
  - Analyst L2/L5 verdict (cycle 154)
  - Scout/Analyst/Cartographer team synthesis (cycle 155)
  - Analyst L2/L5 verdict (cycle 155)
  - Scout/Analyst/Cartographer team synthesis (cycle 156)
  - Analyst L2/L5 verdict (cycle 156)
  - Scout/Analyst/Cartographer team synthesis (cycle 157)
  - Analyst L2/L5 verdict (cycle 157)
  - Scout/Analyst/Cartographer team synthesis (cycle 158)
  - Analyst L2/L5 verdict (cycle 158)
  - Scout/Analyst/Cartographer team synthesis (cycle 159)
  - Analyst L2/L5 verdict (cycle 159)
last_verified: 2026-03-02
rank: 3
---

## 元问题

`sources/` 与 `distilled/` 长期为空或断续更新时，门禁会退化为“有规则但无新证据”的假治理，导致旧证据被重复复用。

## 核心解法

建立 `Sources→Distilled Ingestion Lineage Freshness Governance (SDILFG)`：

1. **摄取连续性合同**
   - 以日为粒度记录 `sources` 摄取，断档即标红。
2. **血缘绑定合同**
   - 每条 `distilled` 记录必须绑定 `source_digest + lineage_id + head_sha`。
3. **新鲜度窗口合同**
   - 证据超过窗口不允许晋级复用。
4. **后台恢复一致性**
   - 长任务恢复后必须补齐遗漏摄取窗口，禁止“恢复成功但证据断层”。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `sources_ingestion_log.json` | `date_utc`, `ingest_count`, `max_ingest_lag_hours`, `lineage_id` | 最近 7 天存在 `ingest_count=0` 或 `max_ingest_lag_hours>48` |
| `distilled_manifest.json` | `distilled_id`, `source_digest`, `lineage_id`, `head_sha`, `distilled_at_utc` | 任一 distilled 无来源 digest 或 lineage 漂移 |
| `lineage_freshness_snapshot.json` | `lineage_id`, `head_sha`, `window_hours`, `retrieval_surface`, `stale_artifacts[]` | `stale_artifacts` 非空或 retrieval surface 未声明 |
| `ingest_continuity_report.json` | `daily_counts[]`, `continuity_pass`, `lineage_pass`, `freshness_pass` | 任一 pass 为 false 仍晋级 |

## 阻断门禁

- `source_ingest_continuity_pass`
  - 失败条件：最近 7 天任一日 `ingest_count < 1`。
- `source_distilled_lineage_pass`
  - 失败条件：`distilled_manifest` 中任一记录无法追溯到 `source_digest + lineage_id + head_sha`。
- `evidence_freshness_window_pass`
  - 失败条件：任一证据 `now - distilled_at_utc > window_hours`。
- `ingest_recovery_backfill_pass`
  - 失败条件：存在恢复窗口但无 backfill 记录。
- `evidence_high_promotion_pass`
  - 失败条件：独立高信任来源不足 3 条，或跨 runner 复现轮次不足 2 轮，或过期证据占比超过 5%。

## 最小验收矩阵

- 正常：7 天连续摄取、distilled 血缘完整、无过期证据。
- 边界：摄取连续但 lag 接近阈值，允许通过并强制下一轮加严。
- 异常：断档、血缘断裂或过期证据复用，阻断并输出 backfill 清单。

## 检索测试（L5）

- 查询：`sources distilled ingestion continuity gate`
  - 命中：本 pattern
  - 动作：执行连续性与血缘双门禁。
- 查询：`background agent resumed but evidence stale`
  - 命中：本 pattern + `background-agent-dag-checkpoint-resume-idempotency-gate`
  - 动作：执行 `ingest_recovery_backfill_pass`，补齐恢复窗口。
- 查询：`augment context memory fresh index evidence cadence`
  - 命中：本 pattern + `augment-context-memory-index-parity-recall-freshness-gate`
  - 动作：执行 freshness window 校验并冻结过期晋级。
- 查询：`evidence high promotion pass cross runner two cycles`
  - 命中：本 pattern
  - 动作：校验跨 runner 连续两轮复现实绩并决定是否可升档。
- 查询：`evidence band uplift attestation lineage head sha`
  - 命中：本 pattern
  - 动作：校验 `lineage_id/head_sha/decision_epoch` 一致性，防止跨快照拼接升档。

## Cycle 135 同化增量（Evidence High Uplift Contract）

### 空白判定

lane 当前 `evidence_band` 仍集中在 `medium`，说明“证据有输入”但“缺可复验晋级合同”。
需要把 `sources -> distilled` 的输入治理升级为“可审计升档”治理。

### 核心补丁

新增三类升档工件：

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `repro_matrix.json` | `lineage_id`, `runner_set[]`, `repro_cycles`, `pass_matrix` | 无跨 runner 复现或复现轮次不足 |
| `cross_source_consistency_report.json` | `lineage_id`, `independent_source_count`, `consistency_checks[]`, `consistency_pass` | 独立来源不足或一致性检查失败 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `target_pattern`, `from_band`, `to_band`, `decision`, `attested_at_utc` | 升档缺失证据链或结论与检查结果不一致 |

### 升档判定合同

`evidence_high_promotion_pass=true` 必须同时满足：
1. 独立高信任来源 `>= 3`；
2. 至少 `2` 轮跨 runner 复现通过；
3. 过期证据占比 `<= 5%`；
4. `evidence_band_uplift_attestation` 与 `lineage_id/head_sha` 一致。

## Cycle 136 同化增量（Cross-Runner Repro Round-1）

### 空白判定

cycle 135 已定义升档合同，但缺“跨 runner 连续两轮”中的首轮可审计复现实绩。
本轮仅补齐 round-1，并显式标注“暂不升档”，避免假阳性晋级。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `repro_matrix.json` | `lineage_id`, `runner_runs[] {runner_id, runner_class, cycle_id, replay_digest, pass}`, `repro_cycles`, `pass_matrix` | 跨 runner `<2` 或有效轮次 `<2`，或 runner 独立性不可审计 |
| `cross_source_consistency_report.json` | `lineage_id`, `independent_source_count`, `sources[] {source_id, source_class, source_digest, trust_tier, independence_class}`, `consistency_checks[]`, `consistency_pass` | 独立来源计数不可审计、独立性分级缺失或一致性失败 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `gate_digest_set_id`, `target_pattern`, `from_band`, `to_band`, `decision`, `attested_at_utc` | 与 `repro_matrix/cross_source_consistency` 证据不一致 |

### 本轮状态

- `evidence_high_promotion_pass`: `false`（仅完成 round-1，尚缺第二轮跨 runner 复现实绩）
- `evidence_band`: 维持 `medium`（未升至 `medium-high/high`）

## Cycle 137 同化增量（Round-2 Contract Enrichment）

### 空白判定

当前缺口从“是否有 round-2”转为“round-2 是否真正独立可审计”。
仅有第二轮次数不足以升档，仍需 runner 与来源独立性可机读判定。

### 核心补丁

- `repro_matrix.json` 增加 `runner_class`，区分执行面独立性。
- `cross_source_consistency_report.json` 增加 `independence_class`，防止同源镜像被误计为独立来源。
- `evidence_high_promotion_pass` 继续保持 `false`，直到 round-2 通过且独立性字段齐备。

## Cycle 138 同化增量（Round-2 Replay Identity Hardening）

### 空白判定

cycle 137 已补齐 `runner_class + independence_class`，但仍缺少两类可审计锚点：

1. 同一提交上的 rerun 身份与执行环境指纹（防“看起来是 round-2，实际环境不可比”）。
2. 升档决策绑定 required checks 快照摘要（防“拼接绿灯”）。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `repro_matrix.json` | `lineage_id`, `runner_runs[] {runner_id, runner_class, runner_env_fingerprint, cycle_id, rerun_attempt, rerun_actor, replay_digest, rerun_same_sha_pass, pass}` | `runner_env_fingerprint` 缺失，或 rerun 不是同一 `GITHUB_SHA/GITHUB_REF` |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `gate_digest_set_id`, `required_checks_snapshot_sha256`, `decision` | 升档决策未绑定 required checks 快照摘要 |

### 新增阻断门禁

- `cross_runner_env_fingerprint_pass`
  - 失败条件：跨 runner 复现记录缺少 `runner_env_fingerprint`，或同名 runner 指纹漂移未声明。
- `required_checks_snapshot_binding_pass`
  - 失败条件：`evidence_band_uplift_attestation` 缺 `required_checks_snapshot_sha256`，或与决策快照不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（本轮完成 replay identity 合同补齐，但仍缺连续 round-2 实际复现实绩工件）。
- `evidence_band`: 维持 `medium`（不做 premature 升档）。

## Cycle 139 同化增量（Round-2 Evidence Matrix Tightening）

### 空白判定

cycle 138 已补 replay identity 与 required checks 绑定字段，但 round-2 连续复现实绩仍缺少“矩阵级可读判定”。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `repro_matrix.json` | `lineage_id`, `runner_runs[] {runner_id, runner_class, runner_env_fingerprint, rerun_same_sha_pass, pass}`, `repro_cycles`, `pass_matrix` | `pass_matrix` 缺失或任一 runner 未显式声明 `rerun_same_sha_pass` |
| `cross_source_consistency_report.json` | `lineage_id`, `independent_source_count`, `sources[] {source_id, source_class, source_digest, independence_class}`, `consistency_pass` | 来源独立性字段缺失，或 `independent_source_count < 3` |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `gate_digest_set_id`, `required_checks_snapshot_sha256`, `decision` | 升档决策与 `pass_matrix/consistency_pass` 任一不一致 |

### 新增阻断门禁

- `cross_runner_round2_matrix_pass`
  - 失败条件：`repro_cycles < 2` 或 `pass_matrix` 未覆盖声明的 runner 集合。
- `independent_source_count_pass`
  - 失败条件：`independent_source_count < 3`，或来源独立性不可审计。

## Cycle 140 同化增量（Round-2 Execution Evidence Hardening）

### 空白判定

cycle 139 已补齐 round-2 的矩阵字段与 replay lock，但仍缺“连续复现实绩可审计执行件”：

1. rerun 身份语义是否同一 `SHA/REF` 且可机读判定；
2. 与默认分支偏差是否在执行时被显式审计；
3. 升档证据包是否可离线验签与回放。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `head_sha`, `run_id`, `run_attempt`, `rerun_same_sha_pass`, `branch_divergence_commits`, `pass_matrix`, `generated_at_utc` | `run_attempt < 2`，或 `rerun_same_sha_pass=false`，或 `branch_divergence_commits` 未声明 |
| `attestation_verify_report.json` | `lineage_id`, `gate_digest_set_id`, `required_checks_snapshot_sha256`, `attestation_bundle_sha256`, `trusted_root_sha256`, `verify_pass` | `verify_pass=false`，或 trusted root 缺失 |
| `source_freshness_audit.json` | `lineage_id`, `independent_source_count`, `source_urls[]`, `last_checked_utc`, `stale_ratio` | `independent_source_count < 3`，或 `stale_ratio > 0.05` |

### 新增阻断门禁

- `rerun_identity_consistency_pass`
  - 失败条件：rerun 非同一 `GITHUB_SHA/GITHUB_REF`，或 `run_attempt` 不连续可审计。
- `branch_divergence_audit_pass`
  - 失败条件：未生成 `BASE...HEAD` 偏差对账结果，或偏差结果未入 `round2_execution_report`。
- `attestation_offline_verify_pass`
  - 失败条件：缺失离线验签报告，或证据包摘要与决策快照不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（新增 round-2 执行证据合同，但仍缺连续两轮实测通过工件）
- `evidence_band`: 维持 `medium`

## Cycle 141 同化增量（Round-2 Consecutive Window Contract）

### 空白判定

cycle 140 已补齐 rerun identity / branch divergence / offline verify 三件套，但仍缺“连续两轮 round-2 实测通过”的可机读计数与阻断原因追踪字段。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `head_sha`, `run_id`, `run_attempt_chain[]`, `run_attempt_contiguous_pass`, `matrix_declared`, `matrix_covered`, `consecutive_round2_pass_count`, `generated_at_utc` | `run_attempt_contiguous_pass=false`，或 `matrix_covered=false`，或 `consecutive_round2_pass_count < 2` |
| `repro_matrix.json` | `lineage_id`, `runner_runs[] {runner_id, run_id, run_attempt, pass}`, `repro_cycles`, `pass_matrix` | runner 维度缺 `run_id/run_attempt`，或 `pass_matrix` 无法映射到完整 runner 集合 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `required_checks_snapshot_sha256`, `promotion_blocker_code`, `decision` | `promotion_blocker_code` 缺失导致“未升档原因”不可审计 |

### 新增阻断门禁

- `round2_consecutive_window_pass`
  - 失败条件：`consecutive_round2_pass_count < 2`，或任一 round-2 记录未通过连续性校验。
- `round2_promotion_blocker_trace_pass`
  - 失败条件：`evidence_high_promotion_pass=false` 但缺失 `promotion_blocker_code`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（缺口缩小，但尚未闭合）
- `evidence_band`: 维持 `medium`

## Cycle 147 同化增量（Round-2 Live Sample Sufficiency Contract）

### 空白判定

cycle 141 已有“连续窗口可判定”合同，但 lane 仍缺“样本充足度”机读约束：
即使 `consecutive_round2_pass_count` 可审计，也可能因窗口太窄或 runner 覆盖不足导致升档结论不稳。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `window_start_utc`, `window_end_utc`, `successful_round2_runs`, `runner_diversity_index`, `sample_sufficiency_pass` | `sample_sufficiency_pass=false`，或 `successful_round2_runs < 2` |
| `repro_matrix.json` | `lineage_id`, `runner_set[]`, `pass_matrix`, `window_ref_id`, `round2_runs_in_window` | `runner_set` 与 `pass_matrix` 不一致，或窗口内 round-2 覆盖不足 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `required_checks_snapshot_sha256`, `required_checks_policy_snapshot_sha256`, `window_ref_id`, `decision` | 升档决策未绑定样本窗口与策略快照，或与执行报告不一致 |

### 新增阻断门禁

- `round2_live_sample_sufficiency_pass`
  - 失败条件：窗口内 round-2 成功样本不足 2 次，或 `runner_diversity_index` 未达声明阈值。
- `evidence_uplift_epoch_alignment_pass`
  - 失败条件：`round2_execution_report`、`repro_matrix`、`evidence_band_uplift_attestation` 的 `window_ref_id/decision_epoch` 不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（合同继续收紧，但仍缺可复验的跨 runner 连续实测通过工件）。
- `evidence_band`: 维持 `medium`（不做提前升档）。

## Cycle 148 同化增量（Round-2 Provenance Integrity Contract）

### 空白判定

cycle 147 已补齐 `sample_sufficiency_pass + window_ref_id/decision_epoch`，
但还缺两类“可复验 provenance”约束：
1. round-2 连续样本的 `run_attempt -> workflow_job -> runner` 链路摘要；
2. 升档 attestation 与活体样本清单 bundle 的同源锁定。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `run_provenance_chain[] {run_id, run_attempt, workflow_job_id, runner_id, runner_class, artifact_sha256, attestation_sha256, completed_at_utc}`, `consecutive_round2_run_chain`, `round2_attempt_job_matrix_sha256` | 任一 round-2 记录缺 `workflow_job_id/runner_class/artifact_sha256`，或 `run_attempt` 链路不连续 |
| `repro_matrix.json` | `lineage_id`, `consecutive_pair_ids[]`, `runner_fingerprint_set[]`, `cross_runner_independence_pass`, `window_ref_id`, `pass_matrix` | `consecutive_pair_ids` 中任一 pair 无法映射到独立 runner 指纹集合 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `required_checks_snapshot_sha256`, `required_checks_expected_source_snapshot`, `promotion_evidence_bundle_sha256`, `live_artifact_manifest_sha256`, `promotion_basis`, `decision` | 升档声明无法回放到同一 live artifact bundle，或 expected source 快照缺失 |

### 新增阻断门禁

- `cross_runner_round2_live_artifact_pass`
  - 失败条件：连续两次 round-2 通过记录未绑定可验签工件，或 `runner_class` 不满足独立性要求。
- `round2_consecutive_pair_integrity_pass`
  - 失败条件：`consecutive_pair_ids` 与 `run_provenance_chain`、`runner_fingerprint_set` 任一不一致。
- `promotion_evidence_bundle_integrity_pass`
  - 失败条件：`promotion_evidence_bundle_sha256` 无法唯一还原 `live_artifact_manifest_sha256 + window_ref_id + decision_epoch`。
- `evidence_band_uplift_slsa_requirements_pass`
  - 失败条件：升档证据不满足 SLSA provenance 必需约束（完整来源、可验证构建身份、不可拼接）。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（已补 provenance 可追根合同，但仍缺真实 cross-runner 连续实测通过工件）。
- `evidence_band`: 维持 `medium`（继续阻断提前升档）。

## Cycle 149 同化增量（Round-2 Live Sample Authenticity Lock）

### 空白判定

cycle 148 已补齐 provenance/replay/rehydration 合同，但 P1 仍未关闭：
当前能证明“证据链可追根”，仍不能证明“用于升档的是 live 非合成样本且绑定同一 workflow 语义”。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `run_provenance_chain[] {run_id, run_attempt, execution_mode, workflow_ref_sha256, source_event, runner_id, artifact_sha256, completed_at_utc}`, `consecutive_round2_run_chain`, `pass_matrix` | 任一用于升档的 round-2 记录 `execution_mode != live`，或缺失 `workflow_ref_sha256/source_event` |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `round2_live_run_ids[]`, `non_synthetic_sample_count`, `promotion_evidence_bundle_sha256`, `decision` | live 样本数量不可审计，或 `round2_live_run_ids[]` 无法映射到 `run_provenance_chain` |

### 新增阻断门禁

- `round2_non_synthetic_evidence_pass`
  - 失败条件：任一用于升档的 round-2 样本 `execution_mode != live`，或被标记为 replay/simulated。
- `round2_workflow_ref_lock_pass`
  - 失败条件：`round2_live_run_ids[]` 对应样本的 `workflow_ref_sha256` 缺失或不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（阻断理由从“样本不足”收敛为“样本真实性与 workflow 锁定未闭环”）。
- `evidence_band`: 维持 `medium`（继续阻断提前升档）。

## Cycle 150 同化增量（Round-2 Execution Ledger Canonical Join Contract）

### 空白判定

cycle 149 已锁定 live 样本真实性与 workflow 语义，但执行账本仍有两个阻断空白：
1. `round2_live_run_ids[]`、`round2_run_ids[]`、`rehydration_verified_run_ids[]` 命名不统一，跨工件自动 join 不稳定；
2. attestation 字段在增量同化中存在“只增不保”歧义，可能回退 cycle 148 已约束字段，导致 P2 升档判定不可复验。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `lineage_id`, `window_ref_id`, `round2_run_ids[]`, `round2_live_run_ids[]`, `run_id_alias_map[] {canonical_run_id, live_run_id, run_attempt, workflow_job_id}`, `pass_matrix`, `promotion_blocker_code` | 缺 canonical `round2_run_ids[]`，或 alias 映射无法回放到唯一 `run_attempt/workflow_job_id` |
| `repro_matrix.json` | `lineage_id`, `window_ref_id`, `round2_run_ids[]`, `runner_set[]`, `pass_matrix`, `consecutive_round2_pass_count` | `round2_run_ids[]` 与执行报告不一致，或 pass 矩阵无法覆盖 canonical run 集 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `round2_run_ids[]`, `round2_live_run_ids[]`, `required_checks_snapshot_sha256`, `required_checks_expected_source_snapshot`, `promotion_evidence_bundle_sha256`, `schema_inherits_cycle148_fields`, `decision` | 缺 `schema_inherits_cycle148_fields=true`，或 attestation run 集无法与 execution/repro 两侧对账 |

### 新增阻断门禁

- `round2_run_id_canonical_join_pass`
  - 失败条件：`round2_live_run_ids[]`、`round2_run_ids[]`、`rehydration_verified_run_ids[]` 不能一一映射到同一 canonical run 集。
- `attestation_schema_regression_guard_pass`
  - 失败条件：`evidence_band_uplift_attestation` 丢失 cycle 148 已要求字段（如 `required_checks_expected_source_snapshot`）。
- `round2_execution_ledger_traceability_pass`
  - 失败条件：`promotion_blocker_code` 与 `pass_matrix` 无法回放到具体 `run_id + runner_class`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（执行账本已可审计，但仍缺真实 cross-runner 连续通过样本）。
- `evidence_band`: 维持 `medium`（继续阻断提前升档）。

## Cycle 151 同化增量（Round-2 Sample Chain Replay Contract）

### 空白判定

cycle 150 已补齐 run-id canonical join 与 epoch 对账，但仍缺少“样本级连续链可回放 + 升档证据反查 + 去重拒收”三项硬约束：
1. 当前 round-2 记录更偏结果点，缺 `chain_id/prev_sample_id` 连续链语义；
2. 升档决策缺 `evidence_sample_ids[]` 级别的回溯绑定；
3. 缺少“命中 cycle 150 既有样本即拒收”的反重复门禁。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_sample_chain.json` | `cycle_id`, `round_id`, `chain_id`, `prev_sample_id`, `continuity_score`, `novelty_hash` | 任一样本缺 `chain_id/prev_sample_id`，或 `continuity_score` 不可审计 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `round2_run_ids[]`, `evidence_sample_ids[]`, `gate_snapshot`, `blocked_by[]`, `decision` | 升档结论缺样本级回溯链，或 `blocked_by` 未显式声明阻断原因 |
| `retrieval_replay_report.json` | `query_text`, `executable_query`, `expected_hits`, `actual_hits`, `replay_cmd`, `retrieval_pass` | 检索复跑结果无法覆盖 `evidence_sample_ids[]` |

### 新增阻断门禁

- `round2_sample_chain_continuity_pass`
  - 失败条件：同一 `chain_id` 的样本链断裂，或 `prev_sample_id` 不能回放到连续 round-2 通过链。
- `promotion_evidence_backtrace_pass`
  - 失败条件：`evidence_sample_ids[]` 无法一一映射到 `round2_sample_chain` + `round2_run_ids[]`。
- `l5_retrieval_replay_pass`
  - 失败条件：`executable_query` 复跑后 `actual_hits` 与 `expected_hits` 不一致，或未覆盖全部升档样本。
- `duplicate_cycle150_baseline_guard_pass`
  - 失败条件：`novelty_hash` 命中 cycle 150 基线集合且仍被纳入升档候选。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（规则缺口继续收敛，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 152 同化增量（Round-2 Live Chain Readiness Contract）

### 空白判定

cycle 151 已补齐样本链回放与升档证据反查，但仍缺“样本链是否具备真实连续实测就绪性”的机读字段：
1. `sample_id -> run_id/run_attempt/workflow_job_id` 缺不可篡改绑定摘要；
2. 连续样本缺时间间隔约束，可能将密集重跑误判为连续实测；
3. runner 独立性虽有属性字段，但缺证据引用锚点。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_sample_chain.json` | `chain_id`, `sample_id`, `sample_run_binding_digest`, `chain_time_gap_seconds`, `novelty_hash` | 缺 `sample_run_binding_digest`，或 `chain_time_gap_seconds` 不可审计 |
| `round2_execution_report.json` | `lineage_id`, `round2_run_ids[]`, `runner_independence_proof_ref`, `runner_independence_pass` | 缺 `runner_independence_proof_ref`，或独立性校验失败 |
| `evidence_band_uplift_attestation.json` | `lineage_id`, `decision_epoch`, `promotion_candidate_chain_ids[]`, `round2_chain_readiness_pass`, `promotion_blocker_code` | 升档决策未绑定候选样本链，或 readiness 结论不可回放 |

### 新增阻断门禁

- `round2_sample_run_binding_integrity_pass`
  - 失败条件：`sample_run_binding_digest` 无法反查到唯一 `run_id/run_attempt/workflow_job_id`。
- `round2_chain_temporal_spacing_pass`
  - 失败条件：连续样本的 `chain_time_gap_seconds` 未达声明阈值，或字段缺失。
- `runner_independence_proof_trace_pass`
  - 失败条件：`runner_independence_proof_ref` 缺失，或引用证据与 `runner_class/runner_id` 不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（补齐“就绪可审计”字段，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 153 同化增量（Cross-Runner Live Pair Qualification Contract）

### 空白判定

cycle 152 已补齐样本链绑定摘要与 replay 结果摘要锁，但 `evidence_high_promotion_pass` 仍未关闭：
1. `successful_round2_runs` 可能由同执行面样本叠加，缺少 pair 级跨 runner 资格约束；
2. `promotion_candidate_chain_ids[]`、`evidence_sample_ids[]`、`round2_run_ids[]`、`rehydration_verified_run_ids[]` 缺少单门禁四向闭合；
3. duplicate 拒收已有样本级证据，但缺滚动窗口前置拒收，仍可能抬高连续通过计数。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `qualified_cross_runner_pairs[] {pair_id, run_id_a, run_id_b, runner_id_a, runner_id_b, runner_class_a, runner_class_b, execution_mode_a, execution_mode_b, pair_time_gap_seconds, pair_pass}`, `qualified_pair_count`, `evidence_ready_for_uplift` | `qualified_pair_count < 2`，或任一 pair 不是 `live`/独立 runner class |
| `round2_epoch_join_report.json` | `decision_epoch`, `window_ref_id`, `promotion_candidate_chain_ids[]`, `evidence_sample_ids[]`, `round2_run_ids[]`, `rehydration_verified_run_ids[]`, `join_coverage_ratio`, `missing_links[]`, `join_manifest_sha256` | `join_coverage_ratio < 1.0`，或 `missing_links[]` 非空 |
| `round2_sample_chain.json` | `baseline_window_cycles[]`, `duplicate_hit_refs[] {sample_id, matched_cycle_id, matched_sample_id, novelty_hash}`, `rolling_novelty_guard_pass` | 命中 duplicate 但仍进入 `promotion_candidate_chain_ids[]` |

### 新增阻断门禁

- `cross_runner_live_pair_qualification_pass`
  - 失败条件：`qualified_pair_count < 2`，或任一 pair 的 `runner_id/runner_class/execution_mode` 不满足独立 live 条件。
- `promotion_epoch_four_way_join_pass`
  - 失败条件：`promotion_candidate_chain_ids[] + evidence_sample_ids[] + round2_run_ids[] + rehydration_verified_run_ids[]` 不能在同一 `decision_epoch/window_ref_id` 四向闭合。
- `rolling_duplicate_sample_guard_pass`
  - 失败条件：`duplicate_hit_refs[]` 非空且 `rolling_novelty_guard_pass=false`，或命中样本仍被纳入升档候选链。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（升档门禁已收紧到 pair 级资格 + 四向 join，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 154 同化增量（Cross-Runner Live Streak Deficit Trace Contract）

### 空白判定

cycle 153 已补齐 pair 资格与四向 join，但仍存在三处“可审计不足”：
1. `qualified_pair_count` 可能被重复 pair key 抬高，缺唯一性锁；
2. `evidence_high_promotion_pass=false` 仍偏结论态，缺量化缺口清单；
3. 连续 live 通过样本的 quorum 约束尚未与同一 `decision_epoch/window_ref_id` 强绑定。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `qualified_cross_runner_pairs[] {pair_id, pair_key, run_id_a, run_id_b, cycle_id_a, cycle_id_b, runner_id_a, runner_id_b, pair_pass}`, `qualified_pair_count`, `qualified_pair_unique_count`, `qualified_pair_key_set_sha256` | `qualified_pair_unique_count < 2`，或 `pair_key` 非唯一导致计数虚高 |
| `evidence_band_uplift_attestation.json` | `decision_epoch`, `window_ref_id`, `evidence_high_promotion_pass`, `uplift_requirements {min_qualified_pairs, min_successful_round2_runs, min_independent_sources}`, `uplift_observed {qualified_pair_unique_count, successful_round2_runs, independent_source_count}`, `uplift_deficit[]`, `promotion_blocker_code` | `evidence_high_promotion_pass=false` 但缺 `uplift_deficit[]`，或缺口与 `promotion_blocker_code` 不一致 |
| `round2_epoch_join_report.json` | `decision_epoch`, `window_ref_id`, `qualified_pair_run_ids[]`, `successful_round2_run_ids[]`, `join_coverage_ratio`, `missing_links[]` | `qualified_pair_run_ids[]` 与 `successful_round2_run_ids[]` 不能在同一 epoch/window 闭合 |

### 新增阻断门禁

- `cross_runner_live_pair_uniqueness_pass`
  - 失败条件：`qualified_pair_unique_count < 2`，或 `qualified_pair_key_set_sha256` 与 pair 集合摘要不一致。
- `round2_live_run_quorum_pass`
  - 失败条件：未同时满足 `qualified_pair_unique_count>=2` 且 `successful_round2_runs>=2`，或两者不在同一 `decision_epoch/window_ref_id`。
- `evidence_high_promotion_deficit_trace_pass`
  - 失败条件：`evidence_high_promotion_pass=false` 但 `uplift_deficit[]` 缺失、不可机读，或与 `promotion_blocker_code` 不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（已从“结论式阻断”推进为“缺口可量化阻断”，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 155 同化增量（Attempt-Scoped Quorum Closure Contract）

### 空白判定

cycle 154 已补齐 pair 唯一性与缺口量化，但仍有三处可机读断点：
1. `successful_round2_runs` 仍可能基于 run 级汇总，缺 attempt 级 job 链约束；
2. merge queue 场景下 `merge_group` 触发源与 head sha 缺强绑定，存在错源绿灯风险；
3. rerun 触发者与原 actor 权限语义缺统一锚点，影响“连续通过样本”可信度。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `decision_epoch`, `window_ref_id`, `attempt_number`, `attempt_scoped_job_ids[]`, `attempt_job_chain_sha256`, `qualified_pair_unique_count`, `successful_round2_runs` | `attempt_scoped_job_ids[]` 缺失，或 `attempt_job_chain_sha256` 无法复算，或 quorum 计数不可回放 |
| `evidence_band_uplift_attestation.json` | `decision_epoch`, `window_ref_id`, `trigger_event`, `merge_group_head_sha`, `merge_group_ref`, `required_check_source`, `github_actor`, `github_triggering_actor`, `rerun_privilege_anchor`, `uplift_deficit[]`, `promotion_blocker_code` | `merge_group_head_sha` 缺失/不一致，或 rerun 权限语义不可审计，或缺口清单与 blocker 不一致 |
| `round2_epoch_join_report.json` | `decision_epoch`, `window_ref_id`, `qualified_pair_run_ids[]`, `successful_round2_run_ids[]`, `join_coverage_ratio`, `missing_links[]` | `join_coverage_ratio < 1.0`，或 `missing_links[]` 非空 |

### 新增阻断门禁

- `round2_attempt_scoped_job_chain_pass`
  - 失败条件：round-2 判定未绑定 attempt 级 job 集合，或 job 链摘要不可复算。
- `merge_group_head_sha_binding_pass`
  - 失败条件：`trigger_event=merge_group` 时，`merge_group_head_sha` 与 required checks 快照不一致。
- `rerun_privilege_semantics_pass`
  - 失败条件：`github_actor/github_triggering_actor` 权限语义与 `rerun_privilege_anchor` 不一致。
- `round2_live_quorum_closure_pass`
  - 失败条件：`qualified_pair_unique_count>=2` 与 `successful_round2_runs>=2` 不能在同一 epoch/window 闭合。
- `uplift_deficit_resolution_trace_pass`
  - 失败条件：`evidence_high_promotion_pass=false` 但 `uplift_deficit[]` 不可机读或与 `promotion_blocker_code` 不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（合同已收紧到 attempt-scope + merge-group/source-pin + rerun 权限语义，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 156 同化增量（Structured Uplift Deficit Trace Contract）

### 空白判定

cycle 155 已把阻断条件推进到 attempt-scope/quorum + trusted-root/retention，
但 `evidence_high_promotion_pass=false` 仍主要停留在“结论态”：
缺少可直接驱动采样执行的结构化缺口清单（缺哪些 pair、缺哪些 run、还差多少）。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `evidence_band_uplift_attestation.json` | `decision_epoch`, `window_ref_id`, `uplift_requirements`, `uplift_observed`, `uplift_deficit[] {metric_key, required, observed, missing, missing_pair_keys[], missing_run_ids[]}`, `promotion_blocker_code` | `uplift_deficit[]` 缺结构化字段，或缺口与 blocker 不一致 |
| `round2_epoch_join_report.json` | `decision_epoch`, `window_ref_id`, `qualified_pair_run_ids[]`, `successful_round2_run_ids[]`, `missing_pair_keys[]`, `missing_run_ids[]`, `join_coverage_ratio` | `join_coverage_ratio < 1.0` 且缺失 pair/run 级缺口清单 |
| `round2_execution_report.json` | `decision_epoch`, `window_ref_id`, `round2_run_ids[]`, `qualified_pair_unique_count`, `successful_round2_runs`, `sample_gap_summary` | 计数可见但无法反查到缺失 run 集合 |

### 新增阻断门禁

- `uplift_deficit_structured_trace_pass`
  - 失败条件：`evidence_high_promotion_pass=false` 时，`uplift_deficit[]` 缺 `metric_key/required/observed/missing` 任一字段。
- `round2_epoch_missing_pair_trace_pass`
  - 失败条件：`join_coverage_ratio < 1.0` 但 `missing_pair_keys[]` 或 `missing_run_ids[]` 为空。
- `promotion_blocker_structural_consistency_pass`
  - 失败条件：`promotion_blocker_code` 与 `uplift_deficit[]` 的主缺口维度不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（由“结论阻断”提升为“缺口结构化阻断”，仍待真实跨 runner 连续通过样本补齐）。
- `evidence_band`: 维持 `medium`（不做 premature 升档）。

## Cycle 157 同化增量（Deficit-to-Action Closure Contract）

### 空白判定

cycle 156 已把 `evidence_high_promotion_pass=false` 推进到 pair/run 级结构化缺口，
但缺口仍主要停留在“可读”而非“可执行”：
1. `missing_pair_keys[]/missing_run_ids[]` 未绑定动作引用，补样任务不可直接下发；
2. `missing_*` 缺 `expected_*` 锚点，无法复算“缺口是否真实收敛”；
3. 缺口收敛速度缺统一指标，难以判断是否在向升档阈值单调逼近。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `evidence_band_uplift_attestation.json` | `decision_epoch`, `window_ref_id`, `uplift_deficit[]`, `uplift_deficit_actions[] {metric_key, missing_pair_keys[], missing_run_ids[], action_type, owner, due_epoch, action_refs[]}` | `evidence_high_promotion_pass=false` 但任一 deficit 缺动作映射 |
| `round2_epoch_join_report.json` | `decision_epoch`, `window_ref_id`, `expected_pair_keys[]`, `expected_run_ids[]`, `expected_set_sha256`, `missing_pair_keys[]`, `missing_run_ids[]`, `missing_pair_action_refs[]`, `missing_run_action_refs[]`, `deficit_burn_down_ratio` | 缺 `expected_*` 锚点，或缺口与动作引用不一致，或 burn-down 不可判定 |
| `round2_execution_report.json` | `decision_epoch`, `window_ref_id`, `sample_gap_summary {missing_pair_keys[], missing_run_ids[], required_runner_classes[], next_sampling_window_ref_id}`, `newly_closed_pair_keys[]`, `newly_closed_run_ids[]`, `remaining_deficit_count` | 仅有计数无缺口/收敛明细，无法回放 deficit 收敛过程 |

### 新增阻断门禁

- `uplift_deficit_actionability_pass`
  - 失败条件：`uplift_deficit[]` 任一项缺 `uplift_deficit_actions[]` 映射。
- `deficit_burndown_monotonicity_pass`
  - 失败条件：连续 cycle 的 `remaining_deficit_count` 反向扩大且未声明例外原因。
- `missing_set_recomputable_pass`
  - 失败条件：缺 `expected_pair_keys[]/expected_run_ids[]/expected_set_sha256`，无法复算 `missing_*`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（阻断已推进为“缺口-动作-回执”链路，但真实跨 runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`（继续阻断 premature 升档）。

## Cycle 158 同化增量（Live Round-2 Action-Run Receipt Closure Contract）

### 空白判定

cycle 157 已把缺口推进到 `deficit -> action -> receipt` 可执行闭环，
但仍缺少“动作确实落在 canonical run 且可被摘要复算”的强绑定：
1. `uplift_deficit_actions[]` 有动作引用，但缺 action 到 `canonical_run_id/run_attempt` 的执行回执锚点；
2. 缺少窗口级 `canonical_run_set` 摘要，无法保证补样窗口内 run 集不被静默替换；
3. `evidence_high_promotion_pass=false` 仍难直接反查“缺口关闭由哪些 run 完成、是否为非重复 live 增量”。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `action_execution_receipts[] {action_ref, canonical_run_id, run_attempt, runner_id, runner_class, execution_mode, completed_at_utc, receipt_sha256}`, `window_canonical_run_set_sha256`, `new_live_samples[] {sample_id, canonical_run_id, novelty_hash}` | 有动作无执行回执，或窗口 run 集不可摘要复算，或新增样本不可证明为非重复 live 增量 |
| `round2_epoch_join_report.json` | `deficit_closure_bindings[] {metric_key, missing_key, action_ref, canonical_run_id, closure_receipt_sha256}`, `window_ref_id`, `decision_epoch` | `missing_*` 关闭结论不能绑定到 action/run/receipt 三元组 |
| `evidence_band_uplift_attestation.json` | `readiness_snapshot_sha256`, `decision_epoch`, `window_ref_id`, `uplift_deficit[]`, `uplift_deficit_actions[]` | 升档就绪判定未绑定 execution/join 双侧摘要，或快照不可回放 |

### 新增阻断门禁

- `deficit_action_execution_trace_pass`
  - 失败条件：`uplift_deficit_actions[]` 任一 `action_ref` 无 `action_execution_receipts[]` 映射。
- `window_runset_digest_lock_pass`
  - 失败条件：缺 `window_canonical_run_set_sha256`，或与 `round2_execution_report` 的 run 集复算摘要不一致。
- `missing_to_run_closure_pass`
  - 失败条件：`deficit_closure_bindings[]` 缺失，或 `missing_key` 无法反查到唯一 `canonical_run_id + closure_receipt_sha256`。
- `non_duplicate_live_increment_pass`
  - 失败条件：`new_live_samples[]` 缺 `novelty_hash`，或命中 rolling duplicate 仍计入关闭缺口。
- `promotion_readiness_snapshot_binding_pass`
  - 失败条件：`readiness_snapshot_sha256` 与 execution/join 侧摘要不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（已补齐 action->canonical run->receipt 摘要闭环，但真实 cross-runner round-2 连续通过样本仍未达升档阈值）。
- `evidence_band`: 维持 `medium`（继续阻断 premature 升档）。

## Cycle 159 同化增量（Live Round-2 Window Closure Contract）

### 空白判定

cycle 158 已将 `deficit -> action -> canonical run -> receipt` 推进到可复算闭环，
但仍缺少“补样动作是否真正闭合升档窗口”的执行判定：
1. `action_execution_receipts[]` 可追溯，但缺少与 `missing_key` 的窗口内强绑定闭合证明；
2. `qualified_pair_unique_count>=2` 与 `successful_round2_runs>=2` 仍可能跨窗口拼接；
3. `band_transition_sample_floor` 已定义，但未与同一窗口 live 闭合结论做单门禁联判。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `round2_execution_report.json` | `live_round2_closure_proof[] {metric_key, missing_key, action_ref, canonical_run_id, run_attempt, runner_pair_key, novelty_hash, closure_receipt_sha256}`, `qualified_pair_closure_set_sha256`, `consecutive_round2_live_pass_count` | 缺口关闭不能落到唯一 run/receipt，或连续 live 通过计数不可复算 |
| `round2_epoch_join_report.json` | `sampling_plan_sha256`, `missing_key_plan_bindings[] {missing_key, required_runner_pair, min_pair_time_gap_seconds, required_execution_mode, bound_run_id, binding_pass}`, `window_ref_id`, `decision_epoch` | 存在补样动作但无法证明满足窗口计划约束（runner pair/间隔/live 语义） |
| `evidence_band_uplift_attestation.json` | `live_round2_window_closure_pass`, `p1_closure_ready_pass`, `remaining_transition_blockers[]`, `readiness_snapshot_sha256` | 升档就绪结论未绑定 live 闭合门禁，或 blocker 列表与执行证据不一致 |

### 新增阻断门禁

- `live_round2_window_closure_pass`
  - 失败条件：同一 `decision_epoch/window_ref_id` 下未同时满足 `qualified_pair_unique_count>=2` 与 `successful_round2_runs>=2`。
- `sampling_plan_lock_pass`
  - 失败条件：`missing_key_plan_bindings[]` 任一项 `binding_pass=false`，或缺 `sampling_plan_sha256`。
- `qualified_pair_run_binding_pass`
  - 失败条件：`uplift_deficit_actions[].action_ref` 不能唯一映射到 `canonical_run_id + closure_receipt_sha256`。
- `consecutive_live_round2_attested_pass`
  - 失败条件：`consecutive_round2_live_pass_count < 2`，或存在 duplicate sample 仍计入 closure proof。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（已把 P1 从“可复算缺口”推进到“窗口闭合可判定”，但真实连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`（待 P1/P2 同窗口同时闭合后再评估升档）。

## 合并来源（截至 cycle 159）

- artifact retention reconciliation governance
- background-agent dag checkpoint resume idempotency gate
- cycle 131 gap radar（sources/distilled 空白）
- augment remote-agent update cross-check
- cycle 132 Scout/Analyst/Cartographer synthesis
- cycle 133 同化更新（MCP retrieval surface 血缘锚定）
- cycle 135 同化更新（evidence high uplift contract + repro/consistency attestation）
- cycle 136 同化更新（cross-runner repro round-1 + attestation 字段补齐）
- cycle 137 同化更新（round-2 独立性字段补齐：runner_class + independence_class）
- GitHub Docs: re-running workflows and jobs（同提交 rerun 身份语义）
- GitHub Docs: troubleshooting required status checks（required checks 7 天 freshness）
- cycle 138 Analyst/Cartographer 同化裁决（L2 同化优先）
- cycle 139 同化更新（round-2 matrix 可审计收紧，仍未升档）
- GitHub Docs: compare two commits（`BASE...HEAD` 偏差审计语义）
- GitHub Docs: workflow syntax matrix（runner matrix 覆盖与规模上限语义）
- GitHub Docs: variables（`GITHUB_RUN_ID/GITHUB_RUN_ATTEMPT` rerun 语义）
- GitHub Docs: verify attestations offline（离线验签与 trusted root 管理）
- OpenAI Docs: background/webhooks（`sequence_number` cursor + completion retry 语义）
- cycle 140 同化更新（round-2 执行证据硬化，仍未升档）
- cycle 141 Analyst L2/L5 verdict（连续窗口合同 + 升档阻断码可审计化）
- cycle 147 Scout/Analyst/Cartographer synthesis（样本充足度与 epoch 对账合同）
- GitHub REST API: list jobs for workflow run attempt（attempt/job/runner 链路）
- GitHub REST API: list workflow runs for a workflow（连续窗口 run 链）
- GitHub Docs: github-hosted/self-hosted runners reference（runner 独立性与路由等价类）
- GitHub Docs: available rules for rulesets（required checks expected source 快照）
- SLSA v1.0 requirements（升档 provenance 标准对齐）
- cycle 150 同化更新（round-2 run-id canonical join + attestation schema regression guard）
- cycle 151 同化更新（sample chain continuity + promotion evidence backtrace + duplicate cycle150 baseline guard）
- cycle 152 同化更新（sample-run binding digest + chain temporal spacing + runner independence proof trace）
- cycle 153 同化更新（cross-runner live pair qualification + promotion epoch four-way join + rolling duplicate sample guard）
- cycle 154 Scout/Analyst/Cartographer team synthesis（pair 唯一性 + quorum + 可量化缺口追踪）
- cycle 154 Analyst L2/L5 verdict（同化优先，无新建 pattern）
- cycle 155 Scout/Analyst/Cartographer team synthesis（attempt-scoped job chain + merge_group source pin + rerun privilege semantics）
- cycle 155 Analyst L2/L5 verdict（同化优先，继续收敛 P1/P2）
- cycle 156 Scout/Analyst/Cartographer team synthesis（uplift_deficit 结构化缺口追踪 + round2 epoch missing pair/run 清单）
- cycle 156 Analyst L2/L5 verdict（同化优先，保持 evidence-governance 双 pattern 收敛）
- cycle 157 Scout/Analyst/Cartographer team synthesis（deficit→action 闭环 + expected set 锚点 + deficit burn-down 可判定）
- cycle 157 Analyst L2/L5 verdict（同化优先，不新增 pattern，推进 `evidence_high_promotion_pass` 就绪度）
- cycle 158 Scout/Analyst/Cartographer team synthesis（action->canonical run->receipt 摘要闭环 + 窗口 run 集摘要锁）
- cycle 158 Analyst L2/L5 verdict（同化优先，不新增 pattern，推进 P1 从“可读阻断”到“可复算阻断”）
- cycle 159 Scout/Analyst/Cartographer team synthesis（live round-2 window closure + sampling-plan lock）
- cycle 159 Analyst L2/L5 verdict（同化优先，不新增 pattern，落地 `live_round2_window_closure_pass`）
