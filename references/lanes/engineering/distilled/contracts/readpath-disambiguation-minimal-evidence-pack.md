# Readpath Disambiguation Minimal Evidence Pack

## Target Meta-Problem
如何在连续性、语义闭环、证据血缘三类失败同时出现时，仍用最少读取成本做正确分流。

## 90s Read Path
1. 先判连续性：`stale_run` / `cursor_lag_seconds` / `lease_expire_at`。
2. 再判语义闭环：`unmapped_requirements[]` / `conformance_score`。
3. 再判证据血缘：`lineage_id + head_sha + digest_set_id` 一致性。
4. 最后判 prod-like：`prodlike_e2e_pass + runtime_boundary_parity_pass`。

## Minimal Evidence by Failure Family
| 失败族 | 主门禁 | 最小证据（仅 2-3 份） | 禁止动作 |
|---|---|---|---|
| 连续性失真 | `background_freshness_pass` | `runplane_lease_registry.json`, `heartbeat_status.json`, `recall_manifest.json` | 禁止 promote/write |
| 语义闭环缺口 | `requirement_conformance_pass` | `requirement_assertion_map.json`, `semantic_conformance_report.json` | 禁止 merge |
| 证据链错配 | `artifact_lineage_lock_pass` | `artifact_lineage_manifest.json`, `artifact_digest_set.json`, `artifact_promotion_attestation.json` | 禁止 promote |
| 运行时边界漂移 | `prodlike_e2e_pass` + `runtime_boundary_parity_pass` | `prodlike_e2e_manifest.json`, `replay_repro_bundle.json`, `promotion_closure.json` | 禁止 release |

## Conflict Resolver (Single-Owner Gate)
- 同一事件只允许一个“主门禁”拥有裁决权。
- 若触发多门禁，优先级固定：
`continuity > semantic > lineage > runtime-boundary`。
- 非主门禁仅提供补充证据，不得并行触发修复流。

## Anti-Patterns
- 在未分主门禁前并行修复，导致证据互相污染。
- 把 `required checks green` 当成闭环完成。
- 使用跨 `head_sha` 工件拼装通过态。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
