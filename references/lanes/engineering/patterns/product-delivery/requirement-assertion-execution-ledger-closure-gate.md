---
name: requirement-assertion-execution-ledger-closure-gate
topic: product-delivery
evidence_band: medium
verified_count: 12
sources:
  - requirement-assertion-semantic-conformance-score-gate (cycle 129 baseline)
  - ai-generated-code-prodlike-e2e-closure-gate (cycle 129 baseline)
  - artifact-retention-reconciliation-governance (cycle 129 baseline)
  - Scout/Analyst/Cartographer team synthesis (cycle 130)
  - Cucumber Docs: Gherkin executable requirement syntax
  - OPA Docs: policy testing and fail-on-empty guard
  - Scout/Analyst/Cartographer team synthesis (cycle 134)
  - arXiv: PROMPTEVALS (2025)
  - arXiv: Spec2Assertion (2025)
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
  - GitHub Docs: syntax for issue forms
last_verified: 2026-03-02
rank: 3
---

## 元问题

需求与断言映射存在时，仍可能出现“断言执行记录存在，但无法证明需求已被结果满足”的假闭环，导致未满足需求仍可晋级。

## 核心解法

建立 `Requirement-Assertion-Execution Ledger Closure Gate (RAELCG)`：

1. **需求账本标准化**
   - 每条需求固定 `requirement_id`、`semantic_intent`、`lineage_id`。
2. **断言执行强关联**
   - 每个 `assertion_id` 必须回写 `run_id + head_sha + result + requirement_ids[]`。
3. **三向对账闭环**
   - 生成 `requirement -> assertion -> execution_result` 对账报告，显式列出未覆盖需求。
4. **晋级阻断**
   - 对账失败、执行陈旧、来源漂移时直接阻断 `promote/merge`。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `requirement_assertion_map.json` | `lineage_id`, `requirement_id`, `assertion_ids[]`, `mapping_version` | 需求缺少断言映射 |
| `assertion_execution_ledger.json` | `lineage_id`, `assertion_id`, `requirement_ids[]`, `run_id`, `head_sha`, `result`, `executed_at_utc` | 断言未执行或 HEAD 不匹配 |
| `requirement_execution_closure_report.json` | `lineage_id`, `coverage_ratio`, `uncovered_requirements[]`, `failed_assertions[]`, `benchmark_name`, `sample_size`, `pass_at_k`, `closure_pass` | 存在未覆盖需求、失败断言仍晋级，或 benchmark 证据不足 |
| `assertion_generation_quality_report.json` | `lineage_id`, `formalization_pass_rate`, `assertion_validity_score`, `quality_pass` | 自动生成断言不可执行或质量不足 |

## 阻断门禁

- `assertion_execution_coverage_pass`
  - 失败条件：任一 `requirement_id` 无可验证执行记录。
- `execution_lineage_integrity_pass`
  - 失败条件：执行记录 `lineage_id/head_sha` 与当前变更链不一致。
- `requirement_execution_closure_pass`
  - 失败条件：`uncovered_requirements` 或 `failed_assertions` 非空。
- `requirement_assertion_generation_quality_pass`
  - 失败条件：`formalization_pass_rate` 或 `assertion_validity_score` 低于阈值且仍进入晋级流程。

## Cycle 134 同化增量（Requirement->Gate Runner Binding Closure）

### 空白判定

已有 `requirement -> assertion -> execution_result` 闭环仍存在缺口：
需求虽然映射到断言，但断言未必绑定到“阻断晋级”的 required gates。

### 核心补丁

补充 gate 绑定层，把 requirement 闭环升级为 requirement->assertion->required_gate->runner evidence：

- `requirement_assertion_map.json` 新增 `required_gates[]`
- 新增 `requirement_gate_binding_closure_report.json`
  - `lineage_id`, `requirement_id`, `assertion_ids[]`, `required_gates[]`, `bound_gates[]`, `missing_gates[]`, `closure_pass`
- `assertion_execution_ledger.json` 新增 `gate_id`, `registry_version`, `registry_sha256`

### 新增阻断门禁

- `requirement_gate_binding_closure_pass`
  - 失败条件：任一 requirement 缺少 `required_gates[]`，或 `missing_gates` 非空。
- `required_gate_runner_evidence_pass`
  - 失败条件：断言执行记录未回写 `gate_id + registry_sha256 + head_sha` 三元组。

## 最小验收矩阵

- 正常：需求全覆盖且关键断言通过 -> `closure_pass=true`。
- 边界：仅最小断言集覆盖阈值 -> 允许通过但标记 `risk_level=boundary`。
- 异常：存在未执行映射、陈旧记录或环境漂移 -> `closure_pass=false` 并阻断。

## 检索测试（L5）

- 查询：`requirement assertion execution ledger closure gate`
  - 命中：本 pattern
  - 动作：生成对账报告并执行闭环阻断。
- 查询：`checks pass but requirement unmet`
  - 命中：本 pattern + `requirement-assertion-semantic-conformance-score-gate`
  - 动作：定位未闭环需求并冻结晋级。
- 查询：`lineage mismatch in execution ledger`
  - 命中：本 pattern + `artifact-retention-reconciliation-governance`
  - 动作：执行 `execution_lineage_integrity_pass`。

## Cycle 137 同化增量（Req->Assertion Execution Quality）

### 空白判定

execution ledger 已能证明“执行发生过”，但缺少对自动生成断言的质量判定字段，难以支撑 requirement->assertion 自动化可信落地。

### 核心补丁

- `requirement_execution_closure_report.json` 新增 `benchmark_name/sample_size/pass_at_k`。
- 新增 `assertion_generation_quality_report.json`。
- 新增门禁 `requirement_assertion_generation_quality_pass`，对低质量自动断言执行实行阻断。

## Cycle 139 同化增量（Executable Assertion Coverage）

### 空白判定

当前可判定“是否执行过”，但仍缺少“执行的是可执行断言而非占位断言”的审计字段。

### 核心补丁

- `assertion_execution_ledger.json` 新增：
  - `assertion_schema_version`
  - `assertion_executable`
  - `execution_engine`
- `requirement_execution_closure_report.json` 新增：
  - `executable_assertion_ratio`
- 新增阻断门禁 `executable_assertion_coverage_pass`：
  - 失败条件：关键 requirement 映射的断言中 `assertion_executable=true` 占比低于阈值。

## Cycle 148 同化增量（Requirement->Runtime Traceability Contract）

### 空白判定

cycle 139 已能判定断言是否可执行，但仍缺“需求主键到 runtime 证据”的强绑定：
存在 `assertion_execution_ledger` 记录时，仍可能无法证明该 requirement 在生产样本窗口内被真实验证。

### 核心补丁

- `requirement_assertion_map.json` 新增：
  - `runtime_evidence_required`
  - `prd_requirement_id_capture_schema`
- `assertion_execution_ledger.json` 新增：
  - `window_ref_id`
  - `round2_run_ids[]`
  - `repro_matrix_sha256`
  - `assertion_trace_id`
  - `runtime_trace_id`
  - `regression_artifact_sha256`
- `requirement_execution_closure_report.json` 新增：
  - `requirement_runtime_fidelity_ratio`
  - `runtime_trace_coverage_ratio`
  - `missing_runtime_evidence_requirements[]`
  - `fidelity_window_ref_id`

### 新增阻断门禁

- `assertion_runtime_evidence_alignment_pass`
  - 失败条件：断言执行记录无法映射到同窗 `round2_run_ids + repro_matrix_sha256`。
- `requirement_runtime_traceability_pass`
  - 失败条件：关键 `requirement_id` 缺失 `runtime_trace_id` 或 `regression_artifact_sha256`。
- `requirement_runtime_fidelity_pass`
  - 失败条件：`runtime_trace_coverage_ratio` 低于阈值，或 `missing_runtime_evidence_requirements` 非空。
- `critical_requirement_live_evidence_pass`
  - 失败条件：`runtime_evidence_required=true` 的 requirement 未满足最小 live evidence 约束。

## 合并来源

- requirement assertion semantic conformance score gate
- ai-generated-code prod-like e2e closure gate
- artifact retention reconciliation governance
- cycle 130 空白补齐（product-delivery）
- GitHub Docs: syntax for issue forms（PRD/Issue 结构化 requirement_id 采集）
