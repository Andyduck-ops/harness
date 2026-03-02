---
name: openapi-link-stateful-sequence-closure-gate
topic: fullstack-engineering
evidence_band: medium
verified_count: 6
sources:
  - OpenAPI Specification 3.1.1: Link Object
  - Schemathesis Docs: stateful testing from OpenAPI links
  - Testcontainers Docs: ephemeral real dependencies
  - requirement-assertion-execution-ledger-closure-gate (cycle 130 baseline)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
last_verified: 2026-03-02
rank: 3
---

## 元问题

`requirement -> assertion` 在多步骤 API 流程中常停留在“单请求断言”，缺少跨请求状态转移语义。
没有显式 link graph 时，测试可能全绿但真实状态序列（create -> read -> update -> settle）并未被验证。

## 核心解法

建立 `OpenAPI Link Stateful Sequence Closure Gate (OLS-SCG)`：

1. **Link Graph 显式化**
   - 从 OpenAPI `operationId/operationRef` 与 runtime expressions 生成可执行 link graph。
2. **状态序列自动生成**
   - 使用 stateful 引擎按 link graph 生成调用序列并执行回放。
3. **表达式解析阻断**
   - link 参数表达式解析失败时，禁止降级为“默认通过”。
4. **真实依赖短生命周期验证**
   - 序列执行使用真实依赖（容器化）并保证测试后销毁，避免假阳性。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `openapi_link_graph.json` | `spec_version`, `operations[]`, `links[]`, `resolution_scope` | link graph 缺失或无法解析 `operationId/operationRef` |
| `link_resolution_report.json` | `lineage_id`, `expression_total`, `expression_failed`, `regex_extract_stats`, `resolution_pass` | 表达式解析失败或提取规则不稳定 |
| `stateful_link_plan.json` | `lineage_id`, `sequence_cases[]`, `manual_overrides[]`, `override_consistency_pass` | 手工覆盖与自动 graph 冲突 |
| `stateful_sequence_replay_report.json` | `lineage_id`, `scenario_id`, `link_source`, `sequence_count`, `replay_pass`, `flaky_rate` | 状态序列回放失败或抖动超阈 |
| `container_runtime_report.json` | `lineage_id`, `wait_strategy`, `startup_time_ms`, `lifecycle_events[]`, `isolation_pass` | 真实依赖未就绪或生命周期未隔离 |

## 阻断门禁

- `openapi_link_resolution_pass`
  - 失败条件：`operationId/operationRef` 无法唯一解析或表达式求值失败。
- `link_expression_evaluation_pass`
  - 失败条件：`expression_failed > 0`。
- `manual_link_override_consistency_pass`
  - 失败条件：手工 link 覆盖与自动 link graph 不一致。
- `stateful_link_sequence_pass`
  - 失败条件：`replay_pass=false` 或 `flaky_rate > threshold`。
- `ephemeral_dependency_isolation_pass`
  - 失败条件：真实依赖生命周期未完整闭合（未销毁/污染跨用例）。

## 最小验收矩阵

- 正常：link graph 可解析、状态序列稳定、真实依赖生命周期隔离通过。
- 边界：表达式解析有警告但可修复，允许一次性通过并要求补录覆盖。
- 异常：link 解析失败、序列回放不稳定或依赖未隔离，阻断晋级。

## 检索测试（L5）

- 查询：`openapi link stateful sequence gate`
  - 命中：本 pattern
  - 动作：执行 link graph 解析 + 状态序列门禁。
- 查询：`requirement assertion multi-step api closure`
  - 命中：本 pattern + `requirement-assertion-execution-ledger-closure-gate`
  - 动作：把 requirement 映射到 link-driven assertions。
- 查询：`stateful api test with real dependencies`
  - 命中：本 pattern + `ai-generated-code-prodlike-e2e-closure-gate`
  - 动作：执行 `stateful_link_sequence_pass` + `ephemeral_dependency_isolation_pass`。

## 合并来源

- OpenAPI 3.1 Link Object 规范
- Schemathesis stateful testing 文档
- Testcontainers 真实依赖生命周期实践
- cycle 133 Scout/Analyst 结论（OpenAPI link 空白补齐）
