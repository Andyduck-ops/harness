---
name: requirement-assertion-semantic-conformance-score-gate
topic: product-delivery
evidence_band: medium
verified_count: 9
sources:
  - prd-epic-contract-replay-closure-gate (cycle 127 cross-check)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - artifact-retention-reconciliation-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
  - arXiv: PROMPTEVALS (2025)
  - arXiv: Spec2Assertion (2025)
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - W3C QA Framework: Test Assertions metadata requirements
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
last_verified: 2026-03-02
rank: 3
---

## 元问题

`PRD -> Epic -> Issue -> PR` 字段闭环完成后，仍可能出现“需求文本在，验证断言缺位”：
最终通过的是检查项，不一定是需求语义本身。

## 核心解法

建立 `Requirement->Assertion Semantic Conformance Score Gate (RASSCG)`：

1. **需求切片结构化**
   - 每条需求生成 `requirement_id` 与 `semantic_intent`。
2. **断言映射强制化**
   - 每条 `requirement_id` 必须至少映射一个可执行断言 `assertion_id`。
3. **语义符合性评分**
   - 计算 `conformance_score`：
   - `coverage_score`（需求覆盖）
   - `precision_score`（断言与语义一致）
   - `freshness_score`（证据时效）
4. **晋级阻断**
   - `conformance_score` 低于阈值时，禁止 `promote/merge`。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `requirement_assertion_map.json` | `lineage_id`, `requirement_id`, `assertion_ids[]`, `mapping_version` | 需求无映射断言 |
| `semantic_conformance_report.json` | `lineage_id`, `coverage_score`, `precision_score`, `freshness_score`, `conformance_score`, `benchmark_name`, `sample_size`, `pass_at_k` | 分数低于阈值或 benchmark 样本不足 |
| `requirement_closure_attestation.json` | `lineage_id`, `unmapped_requirements[]`, `stale_assertions[]`, `decision` | 仍有未映射/过期断言 |
| `assertion_generation_quality_report.json` | `lineage_id`, `formalization_pass_rate`, `assertion_validity_score`, `quality_pass` | 断言生成质量低于阈值 |

## 阻断门禁

- `requirement_conformance_pass`
  - 失败条件：任一需求无断言映射、`conformance_score` 低于阈值。
- `lineage_semantic_parity_pass`
  - 失败条件：`requirement_id` 与 `lineage_id` 不一致、映射版本漂移。
- `assertion_freshness_pass`
  - 失败条件：关键断言超过 freshness 窗口仍用于晋级。
- `requirement_assertion_generation_quality_pass`
  - 失败条件：`formalization_pass_rate` 或 `assertion_validity_score` 低于阈值。

## 检索测试（L5）

- 查询：`requirement to assertion mapping conformance score gate`
  - 命中：本 pattern
  - 动作：生成 `requirement_assertion_map + conformance_report`
- 查询：`prd closure but semantic mismatch`
  - 命中：本 pattern + `prd-epic-contract-replay-closure-gate`
  - 动作：阻断晋级并回填缺失断言
- 查询：`required checks pass but requirement unmet`
  - 命中：本 pattern + `required-checks-snapshot-closure-gate`
  - 动作：执行 `requirement_conformance_pass` 复核

## Cycle 137 同化增量（Benchmark-Backed Req->Assertion）

### 空白判定

现有门禁覆盖映射与符合性评分，但缺“生成质量”与“基准对照”字段，导致 requirement->assertion 自动化难以横向比较。

### 核心补丁

- `semantic_conformance_report.json` 新增 `benchmark_name/sample_size/pass_at_k`。
- 新增 `assertion_generation_quality_report.json`。
- 新增门禁 `requirement_assertion_generation_quality_pass`，先作为 warning 观测，再逐步升级阻断。

## Cycle 139 同化增量（Assertion Metadata Completeness）

### 空白判定

cycle 137 已补 benchmark 字段，但 requirement->assertion 仍缺 assertion 元数据完整性合同，
无法证明断言具备规范定位、强度等级和版本适用范围。

### 核心补丁

- `requirement_assertion_map.json` 新增：
  - `normative_source_ref`
  - `requirement_strength`
  - `spec_version_applicability`
  - `conformance_degree`
- `assertion_generation_quality_report.json` 新增：
  - `domain_shift_score`
  - `human_audit_sample_n`
  - `executable_assertion_rate`
- 新增门禁 `assertion_metadata_completeness_pass`：
  - 失败条件：关键 requirement 的 assertion 缺少规范定位或适用版本字段。

## 合并来源

- PRD-Epic Contract Replay Closure Gate
- Required Checks Snapshot Closure Gate
- Artifact Retention Reconciliation Governance
- cycle 128 空白补齐（product-delivery）
- W3C QA Framework（assertion 元数据最小集合）
