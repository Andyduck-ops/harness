---
name: map-integrity-filegraph-attestation-gate
topic: runtime-governance
evidence_band: medium
verified_count: 11
sources:
  - engineering-lane-master-index gap radar (cycle 130 baseline)
  - engineering-pattern-master-index consistency contract (cycle 130 baseline)
  - artifact-retention-reconciliation-governance (cycle 129 baseline)
  - Scout/Analyst/Cartographer team synthesis (cycle 131)
  - lane filegraph snapshot (cycle 131)
  - engineering validation command set (cycle 130 baseline)
  - GitHub Docs: about protected branches and required checks
  - GitHub Docs: troubleshooting required status checks
  - Scout/Analyst/Cartographer team synthesis (cycle 134)
  - Scout/Analyst/Cartographer team synthesis (cycle 143)
  - Scout/Analyst/Cartographer team synthesis (cycle 144)
last_verified: 2026-03-02
rank: 3
---

## 元问题

索引声明（pattern 总数、topic 计数、链接）与真实文件图一旦漂移，
后续所有“探索/压缩/晋级”决策都会建立在错误地基上，形成系统性假阳性。

## 核心解法

建立 `Map-Integrity Filegraph Attestation Contract`，把“索引正确”从人工感觉升级为机读阻断：

1. **声明快照固化**
   - 每轮生成 `index_claim_manifest`，固化声明总数、topic 计数、更新时间和 cycle。
2. **文件图实测**
   - 同步生成 `filegraph_snapshot`，统计真实 pattern 文件、topic 目录和可解析链接。
3. **差异对账**
   - 产出 `map_integrity_report`，列出声明-实测差异（数量、链接、topic）。
4. **晋级阻断**
   - 对账存在未豁免差异时阻断 `promote/merge`，强制先修索引再继续。

## 最小证据协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `index_claim_manifest.json` | `lane`, `cycle_id`, `declared_total_patterns`, `declared_topic_counts`, `generated_at_utc` | 声明字段缺失或版本陈旧 |
| `filegraph_snapshot.json` | `lane`, `actual_total_patterns`, `actual_topic_counts`, `pattern_files[]`, `broken_links[]` | 文件图采样失败或链接解析失败 |
| `map_integrity_report.json` | `lane`, `count_diff`, `topic_diff[]`, `broken_links[]`, `map_integrity_pass` | 差异非空仍标记通过 |

## 阻断门禁

- `map_integrity_pass`
  - 失败条件：`declared_total_patterns != actual_total_patterns` 或 `topic_diff` 非空。
- `index_link_resolve_pass`
  - 失败条件：存在不可解析链接（含 `_index.md` 与 `_master_index.md` 引用）。
- `topic_count_parity_pass`
  - 失败条件：任一 topic 的声明数量与真实文件数量不一致。

## Cycle 134 同化增量（Threshold Registry + Gate Runner Binding）

### 空白判定

原有 map-integrity 只保证“索引声明和文件图一致”，但没有覆盖“门禁阈值定义是否真实绑定到执行器”。
这会留下“索引正确但门禁失效”的假绿窗口。

### 核心补丁

在 map-integrity 合同里加入阈值注册表绑定层：

- `gate_threshold_registry.json`
  - `registry_version`, `registry_sha256`, `gates[]`
  - `gates[]` 每项：`gate_id`, `check_name`, `metric`, `op`, `target`, `source_app`, `freshness_ttl_hours`
- `gate_runner_binding_report.json`
  - `head_sha`, `runner_app`, `bound_checks[]`, `unbound_gates[]`, `binding_pass`
- `threshold_version_lock.json`
  - `registry_version`, `registry_sha256`, `change_ticket`, `approved_by[]`, `issued_at_utc`

### 新增阻断门禁

- `threshold_registry_complete_pass`
  - 失败条件：任一 required gate 缺失阈值定义，或 `gates[]` 字段不完整。
- `gate_runner_binding_pass`
  - 失败条件：`unbound_gates` 非空，或 required checks 未从注册表映射生成。
- `threshold_version_pin_pass`
  - 失败条件：`registry_sha256` 未被当前 run 固定，或变更缺失 `change_ticket`/审批记录。

## Cycle 143 同化增量（PreToolUse Route Binding for Context Retrieval）

### 空白判定

现有 map-integrity 只约束“声明与文件图一致 + 阈值与执行器绑定”，
未覆盖 context/indexing 场景下的 PreToolUse 路由升级有效性。
这会导致 Bash 子代理本该升级到 general-purpose 执行却仍走旧路径，形成检索能力降级且不可审计。

### 核心补丁

- 新增 `pretooluse_route_binding_report.json`：
  - `lineage_id`, `head_sha`, `source_agent_class`, `target_agent_class`
  - `intent_category`, `route_decision`, `route_reason`
  - `required_tools[]`, `routed_tools[]`, `missing_tools[]`
  - `binding_pass`
- 新增门禁：
  - `pretooluse_route_binding_pass`

### 新增失败条件

- `pretooluse_route_binding_pass`
  - 失败条件：`intent_category` 为 context retrieval，但 `required_tools` 中任一工具未出现在 `routed_tools`。
  - 失败条件：`source_agent_class=bash` 且 `route_decision=keep`，同时 `missing_tools` 非空。

## Cycle 144 同化增量（Hook Attestation Completeness）

### 空白判定

cycle 143 已定义 route binding 结果字段，但缺少“由哪个 hook 版本注入路由决策”的溯源凭据。
当 hook 代码升级后，若无摘要锚点，会出现 `binding_pass=true` 但不可追责的盲区。

### 核心补丁

- `pretooluse_route_binding_report.json` 新增：
  - `pretooluse_hook_sha256`
  - `route_instruction_injected`
  - `route_binding_audit_version`
- `pretooluse_route_binding_pass` 新增失败条件：
  - `intent_category=context retrieval` 且 `binding_pass=true`，但 `pretooluse_hook_sha256` 缺失。
  - `route_decision=upgrade` 且 `route_instruction_injected=false`。
  - `route_binding_audit_version` 缺失或低于当前 runner 要求版本。

## 最小验收矩阵

- 正常：数量一致、topic 一致、链接可解析 -> 允许晋级。
- 边界：仅存在非关键展示字段漂移 -> 警告并限时修复。
- 异常：计数或链接失配 -> 立即阻断。

## 检索测试（L5）

- 查询：`map integrity pass for lane index and filegraph`
  - 命中：本 pattern
  - 动作：执行声明/实测对账并输出 `map_integrity_report`。
- 查询：`master index count differs from real files`
  - 命中：本 pattern + `artifact-retention-reconciliation-governance`
  - 动作：阻断晋级并生成差异清单。
- 查询：`broken links in pattern index`
  - 命中：本 pattern
  - 动作：触发 `index_link_resolve_pass` 阻断。

## 合并来源

- lane 索引一致性缺口（cycle 130）
- artifact retention reconciliation governance
- cycle 131 空白补齐（runtime-governance）
- cycle 144 同化更新（pretooluse hook attestation completeness）
