---
name: anti-fake-test-property-mutation-stateful-gate
topic: fullstack-engineering
evidence_band: medium
verified_count: 23
sources:
  - ai-generated-code-prodlike-e2e-closure-gate (cycle 128 baseline)
  - ai-code-fault-injection-fuzz-replay-prebug-gate (cycle 130 baseline)
  - requirement-assertion-semantic-conformance-score-gate (cycle 129 baseline)
  - requirement-assertion-execution-ledger-closure-gate (cycle 130 baseline)
  - Stryker Docs: mutation score thresholds and break behavior
  - engineering lane gap radar (cycle 131)
  - Scout/Analyst/Cartographer team synthesis (cycle 132)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
  - Infection Docs: max-timeouts and timeout handling
  - fast-check Docs: model-based testing
  - Scout/Analyst/Cartographer team synthesis (cycle 134)
  - Argo Rollouts Docs: analysis run failure/abort semantics
  - Evidently Docs: drift methods and threshold customization (PSI/KL/JSD/Wasserstein)
  - Scout findings synthesis (cycle 135)
  - Analyst L2/L5 verdict (cycle 135)
  - Analyst L2/L5 verdict (cycle 136)
  - Stryker Docs: incremental mutation testing
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Analyst/Cartographer L2/L5 verdict (cycle 138)
  - fast-check Docs: model-based state transitions
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
last_verified: 2026-03-02
rank: 3
---

## 元问题

仅靠示例化单测会出现“测试全绿但行为不可泛化”的虚假安全：属性不守恒、变异体未被杀死、状态序列回放不稳定。

## 核心解法

建立 `Anti-Fake-Test Property/Mutation/Stateful Gate (AF-PMS)`：

1. **Property 不变量门禁**
   - 对关键业务不变量做属性检验，失败必须可缩减复现。
2. **Mutation 杀伤门禁**
   - 对关键模块执行变异测试，强制最低 kill-rate 与关键变异体清零。
3. **Stateful 序列回放门禁**
   - 对跨步骤状态机执行序列回放，拦截顺序依赖和隐式共享状态。
4. **三角闭环晋级**
   - 三类门禁任一失败，阻断 `promote/merge`。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `property_suite_report.json` | `lineage_id`, `property_count`, `critical_property_count`, `falsification_count`, `shrink_repro_paths[]` | 关键属性被反例击穿 |
| `mutation_score_report.json` | `lineage_id`, `mutant_total`, `killed`, `survived`, `kill_rate`, `threshold_high`, `threshold_low`, `threshold_break`, `threshold_registry_sha256`, `critical_survivors[]`, `incremental_baseline_sha`, `incremental_cache_key`, `cache_hit_ratio`, `reused_mutants` | `kill_rate` 低于阈值、关键幸存变异体非空，或 incremental 复用链不可审计 |
| `stateful_sequence_replay_report.json` | `lineage_id`, `scenario_id`, `sequence_count`, `link_source`, `state_model_digest`, `command_sequence_digest`, `replay_pass`, `flaky_rate` | 回放失败、抖动率超阈或状态模型摘要缺失 |
| `secret_holdout_delta_report.json` | `lineage_id`, `public_score`, `secret_score`, `delta`, `delta_threshold`, `holdout_pass` | 公共集与隐藏集分差超阈，疑似过拟合测试集 |
| `anti_fake_test_closure.json` | `lineage_id`, `property_pass`, `mutation_pass`, `stateful_pass`, `holdout_pass`, `build_break_triggered`, `closure_pass` | 任一 pass=false 仍晋级或 break 未触发 |

## 阻断门禁

- `property_invariant_pass`
  - 失败条件：`falsification_count > 0` 或关键属性覆盖不足。
- `mutation_killrate_pass`
  - 失败条件：`kill_rate < threshold_low` 或 `critical_survivors` 非空。
- `mutation_break_threshold_pass`
  - 失败条件：`kill_rate < threshold_break` 且未触发构建失败。
- `incremental_mutation_validity_pass`
  - 失败条件：incremental 模式缺少 `incremental_baseline_sha` 或 `reused_mutants` 证据不可追溯。
- `incremental_mutation_cache_scope_pass`
  - 失败条件：`incremental_cache_key` 未绑定 `runner_class + head_sha`，导致跨 runner 污染复用。
- `stateful_replay_stability_pass`
  - 失败条件：`replay_pass=false` 或 `flaky_rate > threshold`。
- `anti_fake_test_closure_pass`
  - 失败条件：三角门禁任一失败仍尝试晋级。
- `threshold_registry_source_pin_pass`
  - 失败条件：mutation/stateful 门禁阈值未来自统一 `threshold_registry_sha256`。
- `secret_holdout_gap_pass`
  - 失败条件：`public_score - secret_score > delta_threshold`。

## 最小验收矩阵

- 正常：property/mutation/stateful 三类门禁全部通过。
- 边界：接近阈值但未越界，允许通过并收紧下一轮阈值。
- 异常：任一关键属性破坏、关键幸存变异体、状态回放不稳定，阻断并输出 triage。

## 检索测试（L5）

- 查询：`anti fake test property mutation stateful gate`
  - 命中：本 pattern
  - 动作：执行三角门禁与闭环阻断。
- 查询：`tests green but mutation survivors critical`
  - 命中：本 pattern + `ai-generated-code-prodlike-e2e-closure-gate`
  - 动作：执行 `mutation_killrate_pass` 并冻结晋级。
- 查询：`stateful replay flaky ai generated code`
  - 命中：本 pattern + `ai-code-fault-injection-fuzz-replay-prebug-gate`
  - 动作：执行 `stateful_replay_stability_pass` 并回写失败序列。
- 查询：`shadow holdout auto convergence drift resample rollback guard`
  - 命中：本 pattern
  - 动作：执行 shadow 收敛、holdout 漂移重采样与 promote 回滚三门禁。

## Cycle 135 同化增量（Shadow-Holdout Auto-Convergence）

### 空白判定

cycle 134 已补齐 `threshold_registry_source_pin_pass` 与 `secret_holdout_gap_pass`，
但仍缺少“阈值 shadow 观察 -> promote/hold/rollback 决策”的自动收敛链路。

### 核心补丁

新增三类工件，形成 shadow 与 holdout 的闭环证据：

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `shadow_threshold_run_report.json` | `lineage_id`, `window_id`, `shadow_threshold`, `prod_threshold`, `decision_divergence_rate`, `false_positive_rate`, `false_negative_rate`, `convergence_delta` | 连续窗口无收敛或分歧率超阈 |
| `holdout_drift_report.json` | `lineage_id`, `holdout_digest`, `drift_method`, `drift_score`, `drift_threshold`, `resample_required`, `resample_digest` | 漂移超阈但未重采样 |
| `threshold_promotion_decision.json` | `lineage_id`, `decision`, `reason_codes[]`, `threshold_registry_sha256`, `runner_id`, `decision_epoch`, `rollback_guard_window_hours` | 结论与上游证据不一致或缺失回滚约束 |

### 新增阻断门禁

- `shadow_convergence_pass`
  - 失败条件：连续 3 个窗口 `decision_divergence_rate` 超阈，或 `convergence_delta` 未收敛。
- `holdout_drift_guard_pass`
  - 失败条件：`drift_score > drift_threshold` 且 `resample_required=true` 时无 `resample_digest`。
- `threshold_promote_rollback_guard_pass`
  - 失败条件：`decision=promote` 但未声明 `rollback_guard_window_hours` 或回滚窗口内关键回归指标超预算。

## Cycle 136 同化增量（Convergence Fields Hardening）

### 空白判定

cycle 135 已定义 shadow/holdout 自动收敛门禁，但部分工件字段不足以计算“连续窗口”与“可追溯决策”。
本轮补齐可执行字段并将“未知”默认改为“阻断失败”。

### 核心补丁

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `shadow_threshold_run_report.json` | `lineage_id`, `window_id`, `window_start_utc`, `window_end_utc`, `prev_window_id`, `window_seq`, `decision_divergence_rate`, `convergence_delta` | 无法构成连续 3 窗口序列时 `shadow_convergence_pass=false` |
| `holdout_drift_report.json` | `lineage_id`, `baseline_digest`, `drift_method`, `drift_score`, `drift_threshold`, `resample_required`, `resample_digest`, `resampled_at_utc`, `resample_method` | `resample_required=true` 且缺重采样 digest/时间戳/方法 |
| `threshold_promotion_decision.json` | `lineage_id`, `decision`, `decision_epoch`, `evidence_snapshot_id`, `rollback_metric_budget_id`, `runner_id`, `threshold_registry_sha256` | `decision=promote` 但无快照锚点或回滚预算锚点 |

### 本轮状态

- `shadow_convergence_pass`: 已具备连续窗口可判定字段（round-1 通过）。
- `holdout_drift_guard_pass`: 已具备漂移重采样可审计字段（round-1 通过）。
- `threshold_promote_rollback_guard_pass`: 字段链路补齐，但仍需第二轮跨 runner 复验后再考虑升档。

## Cycle 137 同化增量（Model Digest + Incremental Mutation）

### 空白判定

cycle 136 已补齐收敛字段，但 stateful 序列仍缺“模型摘要锚点”，mutation 仍缺 incremental 复用链可审计字段。

### 核心补丁

- `stateful_sequence_replay_report.json` 新增 `state_model_digest/command_sequence_digest`。
- `mutation_score_report.json` 新增 `incremental_baseline_sha/cache_hit_ratio/reused_mutants`。
- 新增 `incremental_mutation_validity_pass`，防止“快跑但不可追溯”的假通过。

## Cycle 138 同化增量（Incremental Cache Scope）

### 空白判定

cycle 137 已有 incremental 可追溯字段，但缺少 cache 作用域锚点。
同一 baseline 在不同 runner/image/toolchain 复用缓存，会导致 mutation 分数虚高。

### 核心补丁

- `mutation_score_report.json` 新增 `incremental_cache_key`。
- `incremental_cache_key` 规则：必须显式包含 `runner_class + head_sha`。
- 新增阻断门禁 `incremental_mutation_cache_scope_pass`。

## Cycle 139 同化增量（Replay Seed + Incremental Drift Delta）

### 空白判定

cycle 138 已阻断跨 runner cache 污染，但 stateful 回放仍缺显式 seed/path，incremental mutation 仍缺“全量对比漂移”字段。

### 核心补丁

- `stateful_sequence_replay_report.json` 新增：
  - `replay_seed`
  - `replay_path`
  - `scheduled_run_used`
- `mutation_score_report.json` 新增：
  - `scope_digest`
  - `full_vs_incremental_drift`
- 新增阻断门禁：
  - `stateful_replay_seed_repro_pass`
    - 失败条件：`replay_pass=true` 但缺少 `replay_seed/replay_path`。
  - `incremental_mutation_drift_guard_pass`
    - 失败条件：`full_vs_incremental_drift` 超阈且未触发全量回归。

## 合并来源

- ai-generated-code prodlike e2e closure gate
- ai-code fault injection fuzz replay prebug gate
- requirement assertion semantic conformance score gate
- requirement assertion execution ledger closure gate
- cycle 131 gap radar（anti-fake-test 空白）
- cycle 132 Scout/Analyst/Cartographer synthesis
- cycle 133 同化更新（Stryker threshold/break + stateful link source）
- cycle 134 同化更新（threshold registry source pin + secret holdout delta）
- cycle 135 同化更新（shadow convergence + holdout drift resample + promote rollback guard）
- cycle 136 同化更新（convergence 字段硬化 + 未知即阻断）
- Stryker incremental 文档（本地缓存与 CI 差异语义）
- cycle 138 Analyst/Cartographer 同化裁决（cache scope hardening）
- fast-check model-based 文档（seed/replay 最小复现语义）
