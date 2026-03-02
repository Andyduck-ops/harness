# Freshness Window and Recovery Trace Pack

## Target Meta-Problem
多门禁体系都依赖 freshness，但窗口定义和恢复链记录分散，导致同一事件在不同门禁被反复解释、重复读取且裁决不一致。

## 60s Read Path
1. 先判时间窗口：本次事件属于 `24h / 48h / 7d` 哪一层。
2. 再判主门禁：`continuity > semantic > lineage > runtime-boundary`。
3. 只取对应窗口的最小证据束，不跨窗口拼接。
4. 若进入恢复流，必须补齐 `recovery_trace_card` 再允许重新裁决。

## Freshness Window Contract
| Window | 适用场景 | 必需证据 | 阻断条件 |
|---|---|---|---|
| `24h` | 晋级前阻断裁决 | `heartbeat_status.json`, `requirement_closure_attestation.json`, `artifact_promotion_attestation.json` | 任一证据超窗或 `head_sha` 不一致 |
| `48h` | 回滚后复核 | `rollback_attestation.json`, `recall_manifest.json`, `replay_repro_bundle.json` | 回滚后 replay 不可重现 |
| `7d` | 趋势复盘与门禁调参 | `backpressure_report.json`, `semantic_conformance_report.json`, `promotion_closure.json` | 使用过期数据直接放宽阈值 |

## Recovery Trace Card (Single Format)
必须生成 `recovery_trace_card.json`：
- `incident_id`, `owner_gate`, `window_bucket`
- `block_reason`, `rollback_target_epoch`, `checkpoint_digest`
- `replay_pass`, `reopen_decision`, `closed_at_utc`

## Anti-Patterns
- 在未声明窗口的情况下混用 24h 与 7d 证据裁决当前阻断。
- 修复完成后缺失 `recovery_trace_card` 就重开晋级。
- 多门禁各自记录恢复链，造成同一事件多版本真相。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
