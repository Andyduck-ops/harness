---
name: ai-code-fault-injection-fuzz-replay-prebug-gate
topic: fullstack-engineering
evidence_band: medium
verified_count: 4
sources:
  - ai-generated-code-prodlike-e2e-closure-gate (cycle 129 baseline)
  - long-context-index-sharding-recall-rollback-contract (cycle 129 baseline)
  - background-agent-runplane-lease-heartbeat-dlq-backpressure (cycle 129 baseline)
  - Scout/Analyst/Cartographer team synthesis (cycle 130)
last_verified: 2026-03-01
rank: 3
---

## 元问题

AI 代码在“正常路径”通过后，仍可能在故障注入、边界扰动和恢复回放场景暴露潜在缺陷；这些缺陷若在合并后才暴露，修复成本显著上升。

## 核心解法

建立 `Fault Injection + Fuzz + Replay Pre-bug Gate (FFR-PG)`：

1. **Fault Injection 覆盖关键依赖**
   - 对关键依赖注入超时、抖动、部分失败和顺序漂移。
2. **Fuzz 扰动输入协议**
   - 针对结构、边界、组合输入生成 fuzz 样本并记录 crash/violation。
3. **Replay 可复现闭环**
   - 对失败样本输出 `replay_path`，要求重复运行可重现。
4. **预算化阻断**
   - 关键失败数超过预算或不可重放时，阻断 `promote/merge`。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `fault_injection_matrix.json` | `lineage_id`, `campaign_id`, `fault_profiles[]`, `target_services[]`, `head_sha` | 关键依赖未覆盖故障注入 |
| `fuzz_campaign_report.json` | `lineage_id`, `seed`, `case_count`, `new_failures`, `critical_failures` | 关键失败超预算 |
| `replay_triage_bundle.json` | `lineage_id`, `case_id`, `crash_signature`, `replay_path`, `replay_pass` | 崩溃不可重放 |

## 阻断门禁

- `fault_injection_coverage_pass`
  - 失败条件：关键依赖覆盖不足或故障剖面缺失。
- `fuzz_crash_repro_pass`
  - 失败条件：发现 crash 但 `replay_pass=false`。
- `failure_surface_budget_pass`
  - 失败条件：`critical_failures` 超过预算阈值。

## 最小验收矩阵

- 正常：关键依赖覆盖达标，fuzz 无关键新增失败，replay 全通过。
- 边界：失败面接近预算阈值但未超标，允许通过并加严下一轮阈值。
- 异常：关键失败超预算或不可重放，阻断并输出 triage 清单。

## 检索测试（L5）

- 查询：`ai code fault injection fuzz replay gate`
  - 命中：本 pattern
  - 动作：执行 FFR 三联门禁。
- 查询：`green tests but hidden edge failure`
  - 命中：本 pattern + `ai-generated-code-prodlike-e2e-closure-gate`
  - 动作：补跑故障注入与 fuzz 并按预算阻断。
- 查询：`fuzz crash cannot replay`
  - 命中：本 pattern
  - 动作：执行 `fuzz_crash_repro_pass` 阻断。

## 合并来源

- ai-generated-code prod-like e2e closure gate
- long-context index sharding recall rollback contract
- background-agent runplane lease heartbeat dlq backpressure
- cycle 130 空白补齐（fullstack-engineering）
