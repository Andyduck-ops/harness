# Owner Handoff Integrity Contract Pack

## Target Meta-Problem
当 continuity 与 semantic 同时触发时，若缺失可验证交接条件，会造成并行修复、证据污染与重复叙述。

## 60s Handoff Decision Path
1. 先判 continuity 是否仍异常：`stale_run`、`cursor_lag_seconds`、`lease_expire_at`。
2. 若 continuity 未恢复，禁止交接，owner 固定为 `continuity`。
3. 若 continuity 恢复，再判 semantic：`unmapped_requirements[]`、`conformance_score`。
4. 仅在交接卡通过时，允许 owner 从 `continuity` 切到 `semantic`。

## Handoff Eligibility Matrix
| 当前 owner | 目标 owner | 允许条件（全部满足） | 阻断条件 |
|---|---|---|---|
| `continuity` | `semantic` | `background_freshness_pass=true`; `index_recall_fidelity_pass=true`; `handoff_allowed=true` | freshness/replay 任一失败仍尝试交接 |
| `semantic` | `lineage` | `requirement_conformance_pass=true`; `unmapped_requirements=[]`; `handoff_allowed=true` | 语义缺口未闭合即切 lineage |
| `lineage` | `runtime-boundary` | `artifact_lineage_lock_pass=true`; `head_sha` 一致; `handoff_allowed=true` | 跨 head_sha 仍交接 |

## Required Handoff Artifacts
- `owner_gate_decision_card.json`
- `handoff_attestation.json`
- `recall_manifest.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`

## Handoff Attestation (Single Format)
`handoff_attestation.json` 必填：
- `incident_id`, `from_gate`, `to_gate`, `handoff_allowed`
- `preconditions[]`, `failed_preconditions[]`, `evidence_bundle[]`
- `lineage_id`, `head_sha`, `decided_at_utc`, `decided_by`

## Blocking Gates (Hard)
- `owner_handoff_integrity_pass`
- `background_freshness_pass`
- `requirement_conformance_pass`
- `artifact_lineage_lock_pass`

任一失败，禁止交接与晋级。

## Anti-Patterns
- 用“并行修复”代替 owner 交接判定。
- 未完成上游门禁恢复就切换 owner。
- 只变更 owner，不补 `handoff_attestation`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
