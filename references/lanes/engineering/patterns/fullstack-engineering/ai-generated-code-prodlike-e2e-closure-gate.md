---
name: ai-generated-code-prodlike-e2e-closure-gate
topic: fullstack-engineering
evidence_band: medium
verified_count: 13
sources:
  - contract-replay-verification-gate (cycle 127 cross-check)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - agent-scope-identity-memory-governance (cycle 127 cross-check)
  - Testcontainers Docs: ephemeral real dependencies
  - Scout/Analyst/Cartographer team synthesis (cycle 128)
  - Scout findings synthesis (cycle 133)
  - Analyst L2/L5 verdict (cycle 133)
  - Istio Docs: traffic mirroring
  - Playwright Docs: trace viewer
  - Scout findings synthesis (cycle 137)
  - Analyst L2/L5 verdict (cycle 137)
  - Analyst/Cartographer L2/L5 verdict (cycle 138)
  - Scout/Analyst/Cartographer team synthesis (cycle 139)
last_verified: 2026-03-02
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
| `prodlike_e2e_manifest.json` | `lineage_id`, `e2e_scenario_id`, `runtime_boundary_profile`, `dependency_runtime_profile`, `head_sha` | 场景、依赖画像或边界档案缺失 |
| `replay_repro_bundle.json` | `lineage_id`, `seed`, `path`, `replay_path`, `replay_pass` | 失败不可重放 |
| `e2e_invariant_report.json` | `lineage_id`, `invariants[]`, `violations[]`, `invariant_pass` | 关键不变量违反 |
| `container_runtime_report.json` | `lineage_id`, `wait_strategy`, `startup_time_ms`, `lifecycle_events[]`, `isolation_pass` | 容器就绪失败或生命周期隔离失败 |
| `shadow_traffic_manifest.json` | `lineage_id`, `route_id`, `mirror_percent`, `divergence_budget`, `shadow_pass` | 未声明镜像路由预算或影子链路越界 |
| `trace_artifact_manifest.json` | `lineage_id`, `trace_id`, `trace_path`, `trace_bundle_sha256`, `scenario_id`, `retention_hours`, `trace_pass` | 失败场景缺 trace 证据、摘要不可复算或保留期不足 |
| `promotion_closure.json` | `contract_replay_pass`, `prodlike_e2e_pass`, `mutation_threshold_pass`, `runtime_boundary_parity_pass` | 任一 false 仍晋级 |

## 阻断门禁

- `prodlike_e2e_pass`
  - 失败条件：关键场景失败或 replay 不可重现。
- `runtime_boundary_parity_pass`
  - 失败条件：prod-like 环境与目标生产边界不一致。
- `container_readiness_pass`
  - 失败条件：真实依赖容器未按 `wait_strategy` 就绪或启动超预算。
- `ephemeral_dependency_isolation_pass`
  - 失败条件：测试结束后依赖未销毁、状态污染跨测试泄漏。
- `mutation_threshold_pass`
  - 失败条件：变异分数低于阈值或未执行全量校准窗口。
- `shadow_traffic_safety_pass`
  - 失败条件：`mirror_percent` 超预算或 `shadow_pass=false`。
- `trace_artifact_retention_pass`
  - 失败条件：关键失败场景无 trace，或 `retention_hours` 低于审计窗口。
- `trace_bundle_integrity_pass`
  - 失败条件：`trace_bundle_sha256` 缺失或复算不一致，导致取证包不可验证。

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

## Cycle 137 同化增量（Shadow Traffic + Trace Forensics）

### 空白判定

prod-like E2E 已覆盖容器就绪与 replay，但仍缺流量影子验证预算与失败取证工件保留合同。

### 核心补丁

- 新增 `shadow_traffic_manifest.json` 与门禁 `shadow_traffic_safety_pass`。
- 新增 `trace_artifact_manifest.json` 与门禁 `trace_artifact_retention_pass`。
- 将 prod-like “可跑”升级为“可审计回放 + 可取证追责”。

## Cycle 138 同化增量（Trace Bundle Integrity）

### 空白判定

cycle 137 已要求 trace 存在与保留期，但未要求 trace 包摘要可复算，
仍可能出现“路径存在但内容被替换”而无法审计追责。

### 核心补丁

- `trace_artifact_manifest.json` 新增 `trace_bundle_sha256`。
- 新增阻断门禁 `trace_bundle_integrity_pass`。
- 失败时强制输出 `trace_digest_recalc_report.json`（含 recompute_result）。

## Cycle 139 同化增量（Trace Mode + Mirror Route Isolation）

### 空白判定

cycle 138 已要求 trace 摘要可复算，但仍缺“trace 采集模式”和“shadow 路由隔离策略”的可审计字段，
导致失败后难以确认取证覆盖面与镜像流量安全边界。

### 核心补丁

- `trace_artifact_manifest.json` 新增：
  - `trace_mode`（例如 `on-first-retry`）
  - `trace_source_run_id`
- `shadow_traffic_manifest.json` 新增：
  - `shadow_route_isolated`
  - `host_rewrite_policy`
- 新增阻断门禁：
  - `trace_collection_mode_pass`
    - 失败条件：关键失败场景未声明 `trace_mode` 或 `trace_source_run_id`。
  - `shadow_route_isolation_pass`
    - 失败条件：`shadow_route_isolated=false` 或未声明 `host_rewrite_policy`。

## 合并来源

- contract replay verification gate
- required checks snapshot closure gate
- agent scope identity memory governance
- cycle 128 空白补齐（fullstack-engineering）
- cycle 133 同化更新（Testcontainers 实依赖短生命周期门禁）
- Playwright Trace Viewer 文档（trace.zip 打开与可重放语义）
- cycle 138 Analyst/Cartographer 同化裁决（trace 摘要完整性）
- Istio traffic mirroring 文档（shadow route isolation 约束）
