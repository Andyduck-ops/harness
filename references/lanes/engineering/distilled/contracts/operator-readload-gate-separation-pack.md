# Operator Readload and Gate Separation Pack

## Target Meta-Problem
在多门禁体系里，阅读路径过长、问题归属混杂、模板叙述重复，导致同一事件被反复解释与重复修复。

## 60s Decision Path
1. 先归类事件：`readload` / `gate-owner-conflict` / `dup-narrative`。
2. 只选一个主门禁：`continuity > semantic > lineage > runtime-boundary`。
3. 读取对应最小证据束（2-3 份），禁止跨门禁拼接。
4. 输出单一裁决卡：`owner_gate_decision_card.json`，再进入修复。

## Signal-to-Gate Matrix
| 信号 | 主门禁 | 最小证据束 | 阻断条件 |
|---|---|---|---|
| 阅读负担信号：同一事件需跨多文档拼装 | `continuity` 或 `semantic`（按事件归属二选一） | `heartbeat_status.json` + `requirement_assertion_map.json` + `semantic_conformance_report.json` | 未定义主门禁就并行修复 |
| 元问题混杂信号：连续性与语义门禁同时 claim owner | `continuity` 优先；若连续性无异常才转 `semantic` | `runplane_lease_registry.json` + `recall_manifest.json` + `owner_gate_decision_card.json` | 多主门禁并发裁决 |
| 重复叙述信号：freshness/lineage/replay 在多文档重复解释 | `lineage` 或 `runtime-boundary`（按失配类型） | `artifact_lineage_manifest.json` + `artifact_digest_set.json` + `replay_repro_bundle.json` | 重复解释替代证据校验 |

## Owner Gate Decision Card (Single Format)
必须生成 `owner_gate_decision_card.json`：
- `incident_id`, `signal_family`, `owner_gate`
- `blocked_by`, `evidence_bundle[]`, `window_bucket`
- `handoff_allowed`, `handoff_reason`, `decided_at_utc`

## Anti-Patterns
- 用“看起来相关”的多门禁并发处理代替单一 owner 裁决。
- 先改再补证据，导致修复链与证据链错位。
- 把重复解释当成“更充分”，而不是做最小证据闭环。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
