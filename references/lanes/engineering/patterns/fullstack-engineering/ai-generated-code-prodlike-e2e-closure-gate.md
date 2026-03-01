---
name: ai-generated-code-prodlike-e2e-closure-gate
topic: fullstack-engineering
evidence_band: medium
verified_count: 4
sources:
  - contract-replay-verification-gate (cycle 127 cross-check)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - agent-scope-identity-memory-governance (cycle 127 cross-check)
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
last_verified: 2026-03-01
rank: 3
---

## 元问题

AI 生成代码在单测和静态检查通过后，仍可能在 prod-like 场景失败：
失败点常在“真实时序、真实依赖边界、真实恢复路径”。

## 核心解法

建立 `AI Generated Code Prod-like E2E Closure Gate (AGC-PEG)`：

1. **场景合同化**
   - 每个高风险流程定义 `e2e_scenario_id`、输入约束和期望不变量。
2. **回放可重现**
   - 强制记录 `seed/path/replayPath`，保证失败可复现。
3. **运行时边界一致**
   - E2E 环境的权限、工具、配置必须与生产边界同构（prod-like parity）。
4. **晋级闭环**
   - 合并前必须同时通过 contract replay、stateful replay、mutation 阈值和边界一致性。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `prodlike_e2e_manifest.json` | `lineage_id`, `e2e_scenario_id`, `runtime_boundary_profile`, `head_sha` | 场景或边界档案缺失 |
| `replay_repro_bundle.json` | `lineage_id`, `seed`, `path`, `replay_path`, `replay_pass` | 失败不可重放 |
| `e2e_invariant_report.json` | `lineage_id`, `invariants[]`, `violations[]`, `invariant_pass` | 关键不变量违反 |
| `promotion_closure.json` | `contract_replay_pass`, `prodlike_e2e_pass`, `mutation_threshold_pass`, `runtime_boundary_parity_pass` | 任一 false 仍晋级 |

## 阻断门禁

- `prodlike_e2e_pass`
  - 失败条件：关键场景失败或 replay 不可重现。
- `runtime_boundary_parity_pass`
  - 失败条件：prod-like 环境与目标生产边界不一致。
- `mutation_threshold_pass`
  - 失败条件：变异分数低于阈值或未执行全量校准窗口。

## 检索测试（L5）

- 查询：`ai generated code prod-like e2e closure gate`
  - 命中：本 pattern
  - 动作：执行 `prodlike_e2e_manifest + replay_repro_bundle`
- 查询：`tests green but production sequence fails`
  - 命中：本 pattern + `contract-replay-verification-gate`
  - 动作：执行 stateful replay 与不变量校验
- 查询：`runtime boundary parity ai coding`
  - 命中：本 pattern + `agent-scope-identity-memory-governance`
  - 动作：核对运行时边界档案并阻断漂移晋级

## 合并来源

- contract replay verification gate
- required checks snapshot closure gate
- agent scope identity memory governance
- cycle 128 空白补齐（fullstack-engineering）
