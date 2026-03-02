# Multi-Gate Verdict Collapse Channel Isolation Pack

## Target Meta-Problem
同一轮输出把 liveness、semantic、evidence、recall、rollback 结果压成单一 `all_green` 结论，三类信号被同时放大：
- 阅读负担：必须通读长文才能判断哪一门失败。
- 元问题混杂：内容门失败、环境门阻塞、索引门漂移被混成同一因果链。
- 重复叙述：同一失败签名在不同门重复解释，新增信息密度持续下降。

## 60s Compression Path
1. 先写 `gate_surface_matrix`：逐门输出 pass/fail 与阻断理由。
2. 再写 `cause_router_card`：只允许一个 `primary_cause`，其余写为 `secondary_effects`。
3. `environment_block` 独立通道，仅描述 lock/permission/backpressure，不覆盖内容门 verdict。
4. 同签名命中时仅更新 `signature_delta_receipt`，正文只写 pointer。
5. 发布前执行 `matrix_integrity_guard`，矩阵缺门或混门直接阻断发布。

## Channel Isolation Contract
1. Matrix hard bind:
`gate_surface_matrix.json` 必含 `round_id`, `gate_id`, `verdict`, `blocking_reason`, `evidence_ref`。
2. Cause router hard bind:
`cause_router_card.json` 必含 `round_id`, `primary_cause`, `secondary_effects[]`, `routing_decision`。
3. Environment channel hard bind:
`environment_block_receipt.json` 必含 `round_id`, `lock_scope`, `error_signature`, `recovery_action`。
4. Signature delta hard bind:
`signature_delta_receipt.json` 必含 `error_signature`, `delta_fields[]`, `last_round`, `dedup_mode`。
5. Publish barrier:
`matrix_integrity_guard=true` 且 `channel_isolation_pass=true` 才允许 `index_publish=closed`。

## Minimal Evidence Bundle
- `gate_surface_matrix.json`
- `cause_router_card.json`
- `environment_block_receipt.json`
- `signature_delta_receipt.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 matrix 与 cause router 就能回答“哪一门失败、主因是什么、下一步去哪条恢复路径”。
- `Fidelity`: 保留内容层失败与环境阻塞边界，不把 lockscope/权限错误误判为语义失败。
- `Index Integrity`: fragment/provenance/index/query shortcut 四点命名一致，检索入口与证据回链可打开。

任一 gate fail：仅允许 `deferred-matrix-reconcile`，禁止 `index_publish=closed`。

## Anti-Patterns
- 用单个 `all_green` 覆盖多门状态差异。
- 在同一句里混写 `semantic_fail` 与 `index.lock permission denied`。
- 同签名跨门重复解释且不产出 delta receipt。
- 先改索引再补 provenance。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
