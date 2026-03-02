# Failure Ontology Routing Pack

## Target Meta-Problem
如何快速区分“连续性失败”与“闭环失败”，避免把不同失败类型混成同一类修复动作。

## One-Page Routing Matrix
| 触发症状 | 首要失败类型 | 阻断门禁 | 最小证据束 | 立即动作 |
|---|---|---|---|---|
| 进程在跑，但 `cursor_lag_seconds` 持续超预算 | Continuity/Liveness | `background_freshness_pass` | `runplane_lease_registry.json` + `heartbeat_status.json` | 冻结晋级，回收过期 lease，仅保留恢复路径 |
| required checks 全绿，但需求语义未满足 | Semantic Closure | `requirement_conformance_pass` | `requirement_assertion_map.json` + `semantic_conformance_report.json` | 回填缺失断言，阻断 promote/merge |
| 召回命中到了错误分片或旧版本 | Recall Fidelity | `index_recall_fidelity_pass` | `index_shard_manifest.json` + `recall_manifest.json` | 触发 drift freeze，禁止继续写新状态 |
| contract replay 通过，但工件来自不同 head | Evidence Lineage | `artifact_lineage_lock_pass` | `artifact_lineage_manifest.json` + `artifact_digest_set.json` + `artifact_promotion_attestation.json` | 校验 `lineage_id+head_sha+digest_set_id` 一致性后再晋级 |
| 单测通过但 prod-like 场景失败 | Runtime Closure | `prodlike_e2e_pass` + `runtime_boundary_parity_pass` | `prodlike_e2e_manifest.json` + `replay_repro_bundle.json` + `promotion_closure.json` | 固化 replay 输入并校准运行时边界 |
| 回滚完成但后续断言持续漂移 | Rollback Integrity | `rollback_integrity_pass` | `rollback_attestation.json` + `recall_manifest.json` | 回滚后强制 continuity replay，未通过不得恢复写入 |

## 60s Disambiguation Order
1. 先判定是“连续性失真”还是“语义闭环缺口”。
2. 再挑选唯一主门禁，避免并发修复导致证据污染。
3. 最后补齐同一 `lineage_id` 下的证据束，确认可重放。

## Anti-Patterns
- 把 freshness 问题当成语义问题，导致误修复。
- 同时开启多个门禁而不定义主失败类型。
- 使用跨 lineage 的工件拼出“看起来完整”的闭环。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
