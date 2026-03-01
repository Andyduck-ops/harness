---
name: requirement-assertion-semantic-conformance-score-gate
topic: product-delivery
evidence_band: medium
verified_count: 4
sources:
  - prd-epic-contract-replay-closure-gate (cycle 127 cross-check)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - artifact-retention-reconciliation-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
last_verified: 2026-03-01
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
| `semantic_conformance_report.json` | `lineage_id`, `coverage_score`, `precision_score`, `freshness_score`, `conformance_score` | 分数低于阈值 |
| `requirement_closure_attestation.json` | `lineage_id`, `unmapped_requirements[]`, `stale_assertions[]`, `decision` | 仍有未映射/过期断言 |

## 阻断门禁

- `requirement_conformance_pass`
  - 失败条件：任一需求无断言映射、`conformance_score` 低于阈值。
- `lineage_semantic_parity_pass`
  - 失败条件：`requirement_id` 与 `lineage_id` 不一致、映射版本漂移。
- `assertion_freshness_pass`
  - 失败条件：关键断言超过 freshness 窗口仍用于晋级。

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

## 合并来源

- PRD-Epic Contract Replay Closure Gate
- Required Checks Snapshot Closure Gate
- Artifact Retention Reconciliation Governance
- cycle 128 空白补齐（product-delivery）
