# Gate First Delta Packetization Contract Pack

## Target Meta-Problem
同一轮压缩把门禁裁决、证据对账、运行态恢复和提交边界写在同一叙述流里，会同时触发三类信号恶化：
- 阅读负担：必须读完整段才能定位“本轮是否阻断”。
- 元问题混杂：合同裁决与执行异常（如 git lock）互相污染。
- 重复叙述：每轮重复完整背景，增量动作反而被淹没。

## 60s Compression Path
1. 先产出 `gate_first_verdict_packet`，只保留 gate 结论和阻断原因。
2. 把证据细节下沉到 `evidence_delta_packet`，仅写本轮新增与失配。
3. 运行态单独写 `runtime_recovery_packet`，不混写业务语义门禁。
4. 提交结果单独写 `commit_boundary_packet`，失败原因只在 commit 通道出现。
5. 发布前只看三门合同布尔结果，指标与日志仅作观测。

## Gate-First Delta Packetization Contract
1. Gate-first hard bind:
`gate_first_verdict_packet.json` 必含 `cycle_id,gate_id,verdict,blocking_reason,decision_channel,decided_at_utc`。
2. Evidence delta hard bind:
`evidence_delta_packet.json` 必含 `cycle_id,lineage_id,artifact_delta[],digest_check,stale_window_hit`。
3. Runtime recovery hard bind:
`runtime_recovery_packet.json` 必含 `cycle_id,lease_state,heartbeat_state,dlq_state,backpressure_state,recovery_action`。
4. Commit boundary hard bind:
`commit_boundary_packet.json` 必含 `cycle_id,commit_required,commit_status,failure_scope,reason_if_no_commit`。
5. Publish barrier:
`self_containment_pass && fidelity_pass && index_integrity_pass` 才允许发布；`metric_value/log_volume` 不得参与最终布尔裁决。

## Minimal Evidence Bundle
- `gate_first_verdict_packet.json`
- `evidence_delta_packet.json`
- `runtime_recovery_packet.json`
- `commit_boundary_packet.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看四个 packet 即可回答“是否阻断、阻断因果、恢复动作、提交边界状态”。
- `Fidelity`: 语义门禁失败、运行态异常、提交权限失败三条因果链保持隔离，不可互相替代。
- `Index Integrity`: fragment/provenance/index/shortcut 命名一致且可回链。

任一 gate fail：只允许 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 把 `permission denied creating index.lock` 写成语义门禁失败。
- 指标解释先于 gate 结论，导致阻断原因被埋。
- 每轮全量重述历史背景，不输出可执行增量 packet。
- 未分 channel 就直接给统一“all pass/all fail”结论。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
