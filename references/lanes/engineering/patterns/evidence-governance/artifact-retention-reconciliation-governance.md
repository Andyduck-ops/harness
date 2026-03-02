---
name: artifact-retention-reconciliation-governance
topic: evidence-governance
evidence_band: medium
verified_count: 41
sources:
  - artifact-governance cluster (cycles 50-85)
  - backlog-governance cluster (cycles 60-85)
  - recovery-governance cluster (cycles 60-85)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - prd-epic-contract-replay-closure-gate (cycle 127 cross-check)
  - contract-replay-verification-gate (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 129)
  - GitHub Docs: troubleshooting required status checks
  - Scout/Analyst/Cartographer team synthesis (cycle 134)
  - GitHub Docs: re-running workflows and jobs
  - Analyst/Cartographer L2/L5 verdict (cycle 138)
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
  - GitHub Docs: matrix jobs and rerun semantics
  - GitHub Docs: store and share data with workflow artifacts
  - GitHub CLI Manual: gh attestation verify
  - Scout/Analyst/Cartographer team synthesis (cycle 149)
  - Scout/Analyst/Cartographer team synthesis (cycle 150)
  - Analyst L2/L5 verdict (cycle 150)
  - GitHub REST API: workflow runs/jobs replay identifiers (cycle 151)
  - in-toto Statement v1 digest envelope fields (cycle 151)
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

工件、候选项、恢复动作分散在不同轨道，导致“做过但对不上账”。

## 核心解法

做 retention-attestation reconciliation ledger：
- 工件保留策略分层；
- 候选晋级与工件清单绑定；
- 恢复动作写回同一对账账本。

## Cycle 127 同化增量（Artifact Lineage Digest Lock）

### 空白判定

现状已经有：
- required checks 是否通过；
- PRD→Issue→PR 血缘字段是否完整；
- contract replay 是否通过。

但仍缺少一个阻断层：**这些证据工件是否来自同一条变更链且未被替换**。

### 核心补丁

引入 `Artifact Lineage Digest Lock Gate (ALDLG)`，把关键工件绑定到同一组 `lineage_id + head_sha + digest_set_id`：

- `artifact_lineage_manifest.json`
  - `lineage_id`, `issue_id`, `pr_number`, `head_sha`, `contract_epoch`, `digest_set_id`, `generated_at_utc`
- `artifact_digest_set.json`
  - `digest_set_id`, `head_sha`, `artifacts[]`
  - `artifacts[]` 每项：`artifact_name`, `sha256`, `bytes`, `producer_check`, `produced_at_utc`
- `artifact_promotion_attestation.json`
  - `lineage_id`, `head_sha`, `digest_set_id`, `digest_verification_pass`, `freshness_pass`, `decision`, `attested_by`, `attested_at_utc`

### 阻断门禁

`artifact_lineage_lock_pass=true` 必须同时满足：
1. 必需 artifact 全部存在且可解析；
2. digest set 中每个 `sha256` 与实际文件一致；
3. 全部 artifact 的 `head_sha` 与当前 PR HEAD 一致；
4. 全部 artifact 的 `lineage_id` 一致；
5. `produced_at_utc` 在有效窗口内（默认 24h）。

任一失败：阻断 `promote/merge`。

### 检索测试（L5）

- 查询：`cross artifact digest mismatch same lineage gate`
  - 命中：本 pattern
  - 动作：执行 `artifact_lineage_lock_pass`，阻断跨工件错链晋级
- 查询：`required_checks pass but artifact source not same head`
  - 命中：本 pattern + `required-checks-snapshot-closure-gate`
  - 动作：执行 `head_sha parity` 校验
- 查询：`contract replay report from stale run accepted`
  - 命中：本 pattern + `prd-epic-contract-replay-closure-gate`
  - 动作：执行 `freshness window + digest_set attestation`

## Cycle 129 同化增量（Cross-Gate Decision Snapshot Lock）

### 空白判定

现状已具备工件同源与 digest 校验，但仍存在“拼接绿灯”风险：
- 不同时间窗口产出的门禁结果可被混合引用；
- 不同 `head_sha` 的通过证据被拼成一次晋级决策；
- 决策令牌缺失统一快照绑定，导致事后追责困难。

### 核心补丁

引入 `Cross-Gate Decision Snapshot Lock (CGDSL)`，把晋级决策绑定到同一组
`lineage_id + head_sha + decision_epoch + gate_digest_set_id`：

- `gate_decision_snapshot.json`
  - `lineage_id`, `head_sha`, `decision_epoch`, `gate_digest_set_id`, `gate_vector`
- `gate_digest_set.json`
  - `gate_digest_set_id`, `head_sha`, `gates[]`
  - `gates[]` 每项：`gate_id`, `artifact_sha256`, `pass`, `produced_at_utc`
- `promotion_token_attestation.json`
  - `lineage_id`, `head_sha`, `gate_digest_set_id`, `token_id`, `issued_at_utc`, `expires_at_utc`

### 阻断门禁

- `decision_snapshot_consistency_pass`
  - 失败条件：`gate_vector` 与 `gate_digest_set` 不一致，或包含跨 `decision_epoch` 混合结果。
- `gate_digest_integrity_pass`
  - 失败条件：任一门禁 artifact 的摘要复算不一致。
- `promotion_token_freshness_pass`
  - 失败条件：`token` 过期、`head_sha` 漂移、或 `gate_digest_set_id` 未绑定当前快照。

### 检索测试（L5）

- 查询：`cross gate pass but different head sha promotion`
  - 命中：本 pattern
  - 动作：执行 `decision_snapshot_consistency_pass` 阻断跨 HEAD 拼接晋级
- 查询：`required checks green mixed evidence epoch block`
  - 命中：本 pattern + `required-checks-snapshot-closure-gate`
  - 动作：执行 `decision_epoch` 一致性校验并冻结晋级

## Cycle 134 同化增量（Threshold-Decision Snapshot Coherence）

### 空白判定

现有 `gate_decision_snapshot` 已可防跨 epoch 拼接，但还不能证明“门禁决策与阈值版本/runner 实例同源”。
这会导致同一 `head_sha` 下出现“换阈值后复用旧决策”的隐性风险。

### 核心补丁

扩展快照字段并绑定阈值版本：

- `gate_decision_snapshot.json` 新增
  - `threshold_registry_version`, `threshold_registry_sha256`, `runner_id`
- `gate_digest_set.json` 每个 gate 新增
  - `threshold_registry_sha256`, `runner_id`
- `promotion_token_attestation.json` 新增
  - `threshold_registry_sha256`, `runner_id`

### 新增阻断门禁

- `threshold_snapshot_coherence_pass`
  - 失败条件：`gate_vector` 的任一 gate 与快照中的 `threshold_registry_sha256` 不一致。
- `runner_binding_consistency_pass`
  - 失败条件：同一 `decision_epoch` 混入多个未经授权 `runner_id`。

## Cycle 138 同化增量（Required Checks Snapshot Binding）

### 空白判定

现有 `decision_snapshot_consistency_pass` 可阻断跨 epoch 拼接，
但仍缺少“晋级决策使用的是哪一份 required checks 快照”的摘要锚点，
导致同 `head_sha` 下仍可能误复用过期或错源的绿灯结果。

### 核心补丁

- `promotion_token_attestation.json` 新增：
  - `required_checks_snapshot_sha256`
  - `rerun_same_sha_pass`
  - `rerun_actor`
- `gate_decision_snapshot.json` 新增：
  - `required_checks_snapshot_sha256`

### 新增阻断门禁

- `required_checks_snapshot_binding_pass`
  - 失败条件：`required_checks_snapshot_sha256` 缺失、与快照不一致，或来自超过 7 天 freshness 窗口的 checks。
- `rerun_identity_consistency_pass`
  - 失败条件：`rerun_same_sha_pass=false`，或 rerun actor/attempt 与实际审计记录不一致。

## Cycle 139 同化增量（Gate Digest Set Replay Lock）

### 空白判定

cycle 138 已绑定 required checks 快照，但 `gate_digest_set` 内各 gate 工件仍缺 replay 身份字段，
导致“快照一致但 gate 子项来源不一致”的隐性风险。

### 核心补丁

- `gate_digest_set.json` 的 `gates[]` 增补：
  - `threshold_registry_sha256`
  - `runner_id`
  - `produced_at_utc`
- `promotion_token_attestation.json` 增补：
  - `gate_digest_set_id`
  - `threshold_registry_sha256`
  - `runner_id`
  - `rerun_same_sha_pass`
- 新增阻断门禁 `gate_digest_replay_identity_pass`：
  - 失败条件：`gates[]` 任一条目缺少 `runner_id`，或与 attestation 的 `gate_digest_set_id` 不一致。

## Cycle 148 同化增量（Artifact Rehydration Replay Contract）

### 空白判定

cycle 139 已补齐 gate digest replay identity，但 lane 仍缺“升档样本在决策窗口内可重取、可回放”的执行合同。
若只校验摘要而不校验可重取，会出现“摘要正确但工件已失效”的假可复验。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `gate_decision_snapshot.json` | `lineage_id`, `head_sha`, `decision_epoch`, `round2_artifact_set_id`, `round2_run_ids[]`, `retention_deadline_utc`, `gate_digest_set_id` | round-2 升档样本未绑定 `round2_artifact_set_id` 或缺失 retention 截止时间 |
| `gate_digest_set.json` | `gate_digest_set_id`, `head_sha`, `gates[] {gate_id, artifact_uri, artifact_sha256, attestation_verify_report_sha256, retention_expires_at_utc, produced_at_utc}` | 任一 gate 缺 `artifact_uri` 或 `retention_expires_at_utc` |
| `promotion_token_attestation.json` | `lineage_id`, `head_sha`, `gate_digest_set_id`, `artifact_fetch_receipt_sha256`, `rehydration_verified_at_utc`, `required_checks_snapshot_sha256` | 升档 attestation 无重取回执或重取时间超出 retention 窗口 |

### 新增阻断门禁

- `round2_artifact_retention_window_pass`
  - 失败条件：参与升档的 round-2 工件超出 `retention_deadline_utc` 或无法下载。
- `decision_to_artifact_bidirectional_trace_pass`
  - 失败条件：决策快照无法反查完整工件集合，或工件无法反查到唯一 `decision_epoch`。
- `artifact_rehydration_replay_pass`
  - 失败条件：重取工件 `sha256` 与 `gate_digest_set` 不一致。
- `attestation_verify_json_digest_pass`
  - 失败条件：`gh attestation verify --format=json` 的摘要未写入并对齐 `attestation_verify_report_sha256`。

## Cycle 149 同化增量（Rehydration Receipt Coverage Contract）

### 空白判定

cycle 148 已要求“可重取回放”，但还缺少“重取过程本身可审计”的最小回执集合：
若没有逐 run 的 receipt 字段，仍会出现“声明可重取，但缺下载证据”的灰区。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `gate_digest_set.json` | `gate_digest_set_id`, `head_sha`, `gates[] {gate_id, artifact_uri, artifact_sha256, retention_expires_at_utc, rehydration_receipts[] {run_id, fetched_at_utc, fetch_status, fetched_bytes, fetched_sha256, sha256_match}}` | 任一 gate 缺失 `rehydration_receipts`，或 receipt 无法证明下载成功与摘要一致 |
| `promotion_token_attestation.json` | `lineage_id`, `head_sha`, `gate_digest_set_id`, `rehydration_coverage_ratio`, `rehydration_verified_run_ids[]`, `required_checks_snapshot_sha256`, `decision` | coverage 低于 100% 或验证 run 列表与决策样本不一致 |

### 新增阻断门禁

- `round2_rehydration_coverage_pass`
  - 失败条件：`rehydration_coverage_ratio < 1.0`，或 `rehydration_verified_run_ids[]` 未覆盖决策快照全部 `round2_run_ids[]`。
- `artifact_fetch_receipt_integrity_pass`
  - 失败条件：任一 receipt `fetch_status != 200`、`fetched_bytes <= 0`、或 `sha256_match = false`。

## Cycle 150 同化增量（Rehydration-Promotion Epoch Reconciliation Contract）

### 空白判定

cycle 149 已补齐回执覆盖率与下载完整性，但还缺“重取回执与升档决策同 epoch 对账”的硬约束：
- 仅有 receipt 完整性不能证明其属于当前 `decision_epoch/window_ref_id`；
- `rehydration_verified_run_ids[]` 与 `round2_run_ids[]` 命名集合不统一时，coverage 可能通过但决策样本仍不可回放。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `gate_digest_set.json` | `gate_digest_set_id`, `head_sha`, `decision_epoch`, `window_ref_id`, `gates[] {gate_id, round2_run_ids[], rehydration_receipts[] {run_id, run_attempt, fetched_at_utc, fetch_status, fetched_bytes, fetched_sha256, sha256_match}}` | 任一 gate 缺 `decision_epoch/window_ref_id` 或 `run_id + run_attempt` 无法映射到决策样本 |
| `promotion_token_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `window_ref_id`, `gate_digest_set_id`, `round2_run_ids[]`, `rehydration_verified_run_ids[]`, `rehydration_coverage_ratio`, `decision` | attestation 的 epoch/window 与 `gate_digest_set` 不一致，或 run 集不能 canonical 对齐 |

### 新增阻断门禁

- `rehydration_promotion_epoch_alignment_pass`
  - 失败条件：rehydration receipt 所属 `decision_epoch/window_ref_id` 与 promotion attestation 不一致。
- `round2_run_id_alias_consistency_pass`
  - 失败条件：`rehydration_verified_run_ids[]` 未覆盖 canonical `round2_run_ids[]`，或存在无法回放的 alias run_id。

### 本轮状态

- `round2_rehydration_coverage_pass`: 继续要求 `1.0`，并新增 epoch/window 同步约束。
- `evidence_high_promotion_pass`: `false`（回执对账链已闭合到 epoch 级，但真实连续通过样本仍不足）。

## Cycle 151 同化增量（Promotion Evidence Sample Binding Contract）

### 空白判定

cycle 150 已将 rehydration 与 promotion 对齐到 epoch/window，但仍缺“升档证据样本级绑定 + 可执行反查查询”：
1. `promotion` 记录缺 `evidence_sample_ids[]`，难以直接回放到具体样本；
2. gate 快照可对账但不可检索复跑，L5 检索测试可执行性不足；
3. 反重复约束未进入 promotion 阻断链。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_token_attestation.json` | `lineage_id`, `head_sha`, `decision_epoch`, `window_ref_id`, `gate_digest_set_id`, `round2_run_ids[]`, `evidence_sample_ids[]`, `gate_snapshot`, `blocked_by[]`, `decision` | 缺样本级绑定，或 `blocked_by` 缺失导致阻断原因不可审计 |
| `gate_decision_snapshot.json` | `lineage_id`, `head_sha`, `decision_epoch`, `gate_vector`, `required_checks_snapshot_sha256`, `evidence_sample_digest_set_id` | 样本摘要集与 gate 快照不一致 |
| `promotion_replay_query.json` | `promotion_id`, `query_text`, `executable_query`, `expected_hits`, `actual_hits`, `replay_pass` | 查询结果不能覆盖 `evidence_sample_ids[]` |

### 新增阻断门禁

- `round2_evidence_sample_binding_pass`
  - 失败条件：`evidence_sample_ids[]` 不能完整映射到 canonical `round2_run_ids[]`。
- `promotion_replay_query_consistency_pass`
  - 失败条件：`promotion_replay_query` 复跑后 `actual_hits` 与 `expected_hits` 不一致。
- `gate_snapshot_single_epoch_pass`
  - 失败条件：单次 promotion 混入多个 `decision_epoch` 或多个 `gate_digest_set_id`。
- `duplicate_baseline_blocking_trace_pass`
  - 失败条件：`blocked_by` 中缺 `duplicate_cycle150` 追踪项，但样本哈希命中既有基线。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（升档证据回放路径补齐，但真实连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 152 同化增量（Promotion Replay Digest & Duplicate Blocking Evidence）

### 空白判定

cycle 151 已有样本级绑定与 replay 查询合同，但仍缺三项“可执行对账”锚点：
1. replay 结果集缺固定摘要，存在“查询相同、结果被替换”风险；
2. duplicate 拒收仅有原因码，缺样本级命中证据；
3. promotion 候选链未在快照层显式绑定，回放路径仍需人工拼接。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_replay_query.json` | `promotion_id`, `query_text`, `expected_hits`, `actual_hits`, `replay_result_sha256`, `replay_pass` | 缺 `replay_result_sha256`，或摘要与实际结果集不一致 |
| `promotion_token_attestation.json` | `lineage_id`, `decision_epoch`, `blocked_by[]`, `duplicate_blocking_evidence[] {sample_id, novelty_hash, matched_cycle_id, matched_baseline_id}` | duplicate 阻断缺样本级证据，无法自动复核 |
| `gate_decision_snapshot.json` | `lineage_id`, `decision_epoch`, `promotion_candidate_chain_ids[]`, `gate_digest_set_id`, `required_checks_snapshot_sha256` | 快照未绑定候选样本链，导致决策回放链断裂 |

### 新增阻断门禁

- `promotion_replay_result_digest_lock_pass`
  - 失败条件：`replay_result_sha256` 缺失，或与 `actual_hits` 结果集摘要不一致。
- `duplicate_blocking_evidence_trace_pass`
  - 失败条件：触发 duplicate 阻断时未提供 `duplicate_blocking_evidence[]` 样本级命中证据。
- `promotion_candidate_chain_binding_pass`
  - 失败条件：`promotion_candidate_chain_ids[]` 不能映射到 `evidence_sample_ids[] + round2_sample_chain`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（补齐 replay/dedup 决策锚点，但真实连续通过样本不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 153 同化增量（Promotion Candidate Bundle Epoch-Join Contract）

### 空白判定

cycle 152 已补 replay 结果摘要锁与 duplicate 样本级阻断证据，但“候选升档包”仍存在两处断点：
1. `promotion_candidate_chain_ids[]` 与 `rehydration_verified_run_ids[]` 缺统一 join 清单，回放仍需人工拼接；
2. replay 查询与候选包摘要缺同源对账，存在“查询通过但候选包替换”的风险。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `gate_decision_snapshot.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `promotion_candidate_chain_ids[]`, `evidence_sample_ids[]`, `round2_run_ids[]`, `rehydration_verified_run_ids[]`, `candidate_bundle_join_manifest_sha256` | 四集合缺失任一，或 `candidate_bundle_join_manifest_sha256` 与 join 报告不一致 |
| `promotion_token_attestation.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `promotion_candidate_chain_ids[]`, `rehydration_verified_run_ids[]`, `promotion_replay_result_sha256`, `candidate_bundle_digest_sha256`, `decision` | `promotion_replay_result_sha256` 与 `candidate_bundle_digest_sha256` 任一缺失或不一致 |
| `promotion_replay_query.json` | `promotion_id`, `query_text`, `expected_hits`, `actual_hits`, `replay_result_sha256`, `candidate_bundle_join_manifest_sha256`, `replay_pass` | replay 结果摘要与候选包 join 摘要不同步 |

### 新增阻断门禁

- `promotion_candidate_bundle_epoch_join_pass`
  - 失败条件：`promotion_candidate_chain_ids[] + evidence_sample_ids[] + round2_run_ids[] + rehydration_verified_run_ids[]` 无法在同一 `decision_epoch/window_ref_id` 闭合。
- `promotion_replay_bundle_digest_consistency_pass`
  - 失败条件：`promotion_replay_result_sha256`、`candidate_bundle_digest_sha256`、`candidate_bundle_join_manifest_sha256` 任一不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（候选包回放对账已补齐，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 154 同化增量（Promotion Candidate Bundle Receipt-Join Closure）

### 空白判定

cycle 153 已补齐候选包 epoch-join 与 replay/bundle digest 一致性，但仍有两处阻断空白：
1. 候选包摘要一致不等于可重取，缺 `bundle_uri + fetch_receipt` 闭环；
2. 阻断条件已存在，但 `decision` 与 `blocked_by[]` 仍可能出现“阻断存在却误升档”的执行偏差。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `promotion_candidate_chain_ids[]`, `candidate_bundle_join_manifest_sha256`, `candidate_bundle_uri`, `candidate_bundle_fetch_receipt_sha256` | 缺 `candidate_bundle_uri` 或回执摘要，导致候选包不可重取复验 |
| `promotion_token_attestation.json` | `lineage_id`, `decision_epoch`, `window_ref_id`, `promotion_replay_result_sha256`, `candidate_bundle_digest_sha256`, `candidate_bundle_uri`, `candidate_bundle_fetch_receipt_sha256`, `candidate_bundle_fetched_at_utc`, `blocked_by[]`, `decision` | `blocked_by[]` 非空仍 `decision=promote`，或候选包回执缺失/摘要不一致 |
| `promotion_replay_query.json` | `promotion_id`, `replay_result_sha256`, `candidate_bundle_join_manifest_sha256`, `candidate_bundle_fetch_receipt_sha256`, `replay_pass` | replay 摘要通过但候选包回执缺失或无法映射到同一 join manifest |

### 新增阻断门禁

- `promotion_candidate_bundle_rehydration_pass`
  - 失败条件：`candidate_bundle_uri` 不可重取，或 `candidate_bundle_fetch_receipt_sha256` 缺失/与实取回执不一致。
- `promotion_replay_bundle_receipt_join_pass`
  - 失败条件：`promotion_replay_result_sha256`、`candidate_bundle_digest_sha256`、`candidate_bundle_join_manifest_sha256`、`candidate_bundle_fetch_receipt_sha256` 不能形成单一闭环。
- `promotion_decision_blocker_enforcement_pass`
  - 失败条件：`evidence_high_promotion_pass=false` 或 `blocked_by[]` 非空时仍给出 `decision=promote`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（候选包从“摘要一致”推进到“可重取且决策阻断可执行”，仍待真实连续通过样本）。
- `evidence_band`: 维持 `medium`。

## Cycle 155 同化增量（Trusted Root & Retention Horizon Contract）

### 空白判定

cycle 154 已补齐 receipt-join 闭环，但仍有两处执行面空白：
1. 离线验签可执行，但 trusted root 新鲜度缺机读硬约束；
2. 候选包可重取不等于“覆盖升档窗口”，retention 与 promotion 窗口仍可能错位。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `attestation_verify_report.json` | `trusted_root_sha256`, `trusted_root_generated_at_utc`, `trusted_root_age_hours`, `verify_pass` | trusted root 缺失、过期或验签失败 |
| `promotion_token_attestation.json` | `artifact_retention_days_effective`, `promotion_window_days_required`, `retention_horizon_pass`, `candidate_bundle_uri`, `candidate_bundle_fetch_receipt_sha256`, `blocked_by[]`, `decision` | retention 覆盖不足，或候选包回执缺失/不一致，或 blocker 非空仍 promote |
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `candidate_bundle_join_manifest_sha256`, `candidate_bundle_fetch_receipt_sha256`, `retention_deadline_utc` | 决策快照缺 receipt 锚点或 retention 截止时间不可审计 |

### 新增阻断门禁

- `attestation_trusted_root_freshness_pass`
  - 失败条件：`trusted_root_age_hours` 超过允许窗口，或 trusted root 摘要与验签报告不一致。
- `promotion_retention_horizon_pass`
  - 失败条件：`artifact_retention_days_effective < promotion_window_days_required`。
- `candidate_bundle_live_receipt_integrity_pass`
  - 失败条件：`candidate_bundle_fetch_receipt_sha256` 缺失，或与实际重取回执不一致。
- `promotion_blocker_resolution_enforcement_pass`
  - 失败条件：`blocked_by[]` 非空或 `retention_horizon_pass=false` 时仍 `decision=promote`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（receipt-join 与 trusted-root/retention 合同已闭合，但真实 cross-runner 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`。

## Cycle 156 同化增量（Band Transition Readiness Token Contract）

### 空白判定

cycle 155 已补齐 trusted-root 新鲜度与 retention horizon，
但 `medium-high/high` 仍为 0 时，promotion token 还缺“证据带迁移就绪”显式字段，
导致“为什么不能从 medium 升档”仍需人工解释，不能直接机读阻断。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_token_attestation.json` | `target_evidence_band`, `band_transition_ready_pass`, `band_transition_blockers[]`, `required_transition_gates[]`, `observed_transition_gates[]`, `decision` | 目标带位声明缺失，或 blocker 未结构化，或 gate 观测与结论不一致 |
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `current_evidence_band`, `target_evidence_band`, `transition_gate_set_id` | 缺失 current/target band，无法验证迁移上下文 |
| `attestation_verify_report.json` | `trusted_root_sha256`, `trusted_root_age_hours`, `verify_pass`, `transition_gate_set_id` | 验签通过但缺迁移 gate 集绑定 |

### 新增阻断门禁

- `band_transition_readiness_pass`
  - 失败条件：`band_transition_ready_pass=false` 或缺失，且仍给出 `decision=promote`。
- `band_transition_blocker_alignment_pass`
  - 失败条件：`band_transition_blockers[]` 与 `promotion_blocker_code/blocked_by[]` 不一致。
- `band_transition_decision_consistency_pass`
  - 失败条件：`target_evidence_band` 已声明，但 `required_transition_gates[]` 未完整覆盖 `observed_transition_gates[]`。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（阻断原因从“执行合同不足”收敛到“band 迁移就绪仍不满足”）。
- `evidence_band`: 维持 `medium`（`target_evidence_band=medium-high/high` 仍未达标）。

## Cycle 157 同化增量（Band Blocker Resolution Trace Contract）

### 空白判定

cycle 156 已补齐 `band_transition_ready_pass + band_transition_blockers[]`，
但 blocker 仍偏“列表态”，缺可执行回执链：
1. blocker 未绑定 pair/run 级缺口与动作引用，无法直接驱动补样任务；
2. transition gate 仅做集合对比，缺 gate 级证据锚点；
3. promotion token 与 uplift deficit 清单缺摘要绑定，存在跨工件松耦合风险。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_token_attestation.json` | `target_evidence_band`, `band_transition_ready_pass`, `band_transition_blockers[] {blocker_code, metric_key, missing, linked_missing_pair_keys[], linked_missing_run_ids[], resolution_gate, action_refs[]}`, `uplift_deficit_manifest_sha256`, `uplift_attestation_ref`, `decision` | blocker 未对象化到 pair/run/action，或 token 与 uplift 清单摘要不一致 |
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `transition_gate_set_id`, `required_transition_gates[]`, `observed_transition_gates[]`, `transition_gate_evidence[] {gate_id, pass, evidence_sha256, decision_epoch, window_ref_id}` | gate 通过结果缺证据锚点，或 gate 集与 evidence 不一致 |
| `blocker_resolution_report.json` | `decision_epoch`, `window_ref_id`, `blocker_code`, `metric_key`, `action_refs[]`, `receipt_refs[]`, `resolution_pass` | blocker 声明已解决但缺 action/receipt 回执 |

### 新增阻断门禁

- `band_transition_blocker_resolution_trace_pass`
  - 失败条件：`band_transition_blockers[]` 任一项缺 `action_refs[]` 或 `receipt_refs[]`。
- `transition_gate_evidence_integrity_pass`
  - 失败条件：`transition_gate_evidence[]` 缺 `evidence_sha256`，或 `gate_id/pass` 与快照不一致。
- `uplift_manifest_token_binding_pass`
  - 失败条件：`uplift_deficit_manifest_sha256` 与 `uplift_attestation_ref` 指向内容不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（band blocker 已进入“动作-回执”可执行态，但真实 cross-runner round-2 连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`（`band_transition_ready_pass` 仍未满足）。

## Cycle 158 同化增量（Band Transition Sample-Floor Alignment Contract）

### 空白判定

cycle 157 已把 blocker 推进到对象化 `action_refs[]/receipt_refs[]`，
但 `band_transition_ready_pass` 仍缺“样本下限是否达标”的机读硬约束：
1. blocker 有动作与回执，但缺 `target_evidence_band` 的最小样本门槛锚点；
2. blocker 与 deficit 动作虽在字段上相关，仍缺同 `decision_epoch/window_ref_id` 的一致性判定；
3. 存在“有回执但未满足样本地板”时误触发迁移就绪的风险。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_token_attestation.json` | `target_evidence_band`, `band_transition_ready_pass`, `band_transition_sample_floor {min_live_round2_samples, min_independent_runners, min_consecutive_rounds}`, `observed_sample_floor {live_round2_samples, independent_runners, consecutive_rounds}`, `band_transition_blockers[]` | 未声明目标带位样本地板，或观测值与 blocker 结论不一致 |
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `required_transition_gates[]`, `observed_transition_gates[]`, `sample_floor_snapshot_sha256` | 样本地板快照缺失，或 gate 集与样本地板快照不一致 |
| `blocker_resolution_report.json` | `decision_epoch`, `window_ref_id`, `blocker_code`, `action_refs[]`, `receipt_refs[]`, `sample_floor_delta`, `resolution_pass` | 声称 blocker 已解决但 `sample_floor_delta` 未闭合或与回执不一致 |

### 新增阻断门禁

- `band_transition_sample_floor_attested_pass`
  - 失败条件：`target_evidence_band` 声明存在，但 `band_transition_sample_floor` 任一阈值缺失或未满足。
- `blocker_action_epoch_alignment_pass`
  - 失败条件：`band_transition_blockers[]`、`uplift_deficit_actions[]`、`blocker_resolution_report` 不能在同一 `decision_epoch/window_ref_id` 对齐。
- `blocker_receipt_closure_integrity_pass`
  - 失败条件：`action_refs[]` 与 `receipt_refs[]` 缺一对一闭环，或 `sample_floor_delta` 不可复算。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（已补齐样本地板对齐判定与 blocker 同 epoch 闭环，但真实连续通过样本仍不足）。
- `evidence_band`: 维持 `medium`（`band_transition_ready_pass` 仍未满足）。

## Cycle 159 同化增量（Band Transition Blocker-Zero Readiness Contract）

### 空白判定

cycle 158 已补齐 sample-floor 与 blocker 的同 epoch 对齐，
但 `band_transition_ready_pass` 仍缺“blocker 已归零”的执行态证明：
1. blocker 有动作与回执，但缺全量 blocker 是否已清零的快照锁；
2. promotion 判定缺 `blocker_zero_state` 与 `decision` 的强一致约束；
3. 若 P1 在窗口内闭合，P2 仍可能因 blocker 清零语义不明确而无法稳定升档。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `promotion_token_attestation.json` | `band_transition_readiness_snapshot_sha256`, `remaining_transition_blockers[]`, `blocker_zero_state_pass`, `p2_transition_ready_pass`, `decision` | blocker 非空或 zero-state 不通过却仍给出可升档判定 |
| `gate_decision_snapshot.json` | `decision_epoch`, `window_ref_id`, `sample_floor_snapshot_sha256`, `blocker_zero_snapshot_sha256`, `transition_readiness_snapshot_sha256` | readiness 快照无法同时反查 sample-floor 与 blocker-zero 证据 |
| `blocker_resolution_report.json` | `resolved_blocker_codes[]`, `open_blocker_codes[]`, `zero_state_checked_at_utc`, `resolution_pass` | blocker 列表不可复算，或 open/resolved 集合与 attestation 不一致 |

### 新增阻断门禁

- `band_transition_blocker_zero_pass`
  - 失败条件：`remaining_transition_blockers[]` 非空，或 `blocker_zero_state_pass=false`。
- `transition_readiness_snapshot_consistency_pass`
  - 失败条件：`band_transition_readiness_snapshot_sha256` 与 `sample_floor/blocker_zero` 快照摘要不一致。
- `promotion_decision_ready_state_enforcement_pass`
  - 失败条件：`p2_transition_ready_pass=false` 时仍输出 `decision=promote`，或 `blocked_by[]` 与 `remaining_transition_blockers[]` 不一致。

### 本轮状态

- `evidence_high_promotion_pass`: `false`（P2 已推进到 blocker-zero 可判定，但仍待真实连续 through 样本闭合）。
- `evidence_band`: 维持 `medium`（`medium-high/high` 仍为 0，继续阻断 premature 升档）。

## 合并来源

- artifact retention verification window
- artifact digest mismatch escalation
- candidate to issue promotion contract
- workspace recovery envelope
- artifact lineage digest lock gate (cycle 127 assimilation)
- cross-gate decision snapshot lock (cycle 129 assimilation)
- cycle 134 同化更新（threshold registry + runner snapshot coherence）
- GitHub Docs: troubleshooting required status checks（7 天 freshness + 指定来源约束）
- GitHub Docs: re-running workflows and jobs（rerun 同 SHA/REF + actor 语义）
- cycle 138 Analyst/Cartographer 同化裁决（快照绑定优先）
- cycle 139 同化更新（gate digest set replay identity 收紧）
- GitHub Docs: store and share data with workflow artifacts（retention-days 与跨 run 工件获取路径）
- GitHub CLI Manual: gh attestation verify（JSON 验签结果摘要对账）
- cycle 150 同化更新（rehydration/promotion epoch 对账 + run-id alias 一致性）
- cycle 151 同化更新（promotion evidence sample binding + replay query consistency）
- cycle 152 同化更新（replay result digest lock + duplicate blocking evidence trace + candidate chain binding）
- cycle 153 同化更新（promotion candidate bundle epoch-join + replay/bundle digest consistency）
- cycle 154 Scout/Analyst/Cartographer team synthesis（candidate bundle receipt-join closure）
- cycle 154 Analyst L2/L5 verdict（阻断决策执行一致性收敛）
- cycle 155 Scout/Analyst/Cartographer team synthesis（trusted root freshness + retention horizon + live receipt integrity）
- cycle 155 Analyst L2/L5 verdict（同化优先，继续收敛 P1/P2）
- cycle 156 Scout/Analyst/Cartographer team synthesis（band transition readiness token 字段化）
- cycle 156 Analyst L2/L5 verdict（同化优先，保持 evidence-governance 内部收敛）
- cycle 157 Scout/Analyst/Cartographer team synthesis（blocker 对象化到 pair/run/action + transition gate 证据锚点）
- cycle 157 Analyst L2/L5 verdict（同化优先，不新增 pattern，推进 band transition 可执行闭环）
- cycle 158 Scout/Analyst/Cartographer team synthesis（band transition sample-floor 判定 + blocker/deficit 同 epoch 对齐）
- cycle 158 Analyst L2/L5 verdict（同化优先，不新增 pattern，推进 `band_transition_ready_pass` 可复算阻断）
- cycle 159 Scout/Analyst/Cartographer team synthesis（blocker-zero readiness snapshot + decision enforcement）
- cycle 159 Analyst L2/L5 verdict（同化优先，不新增 pattern，落地 `band_transition_blocker_zero_pass`）
