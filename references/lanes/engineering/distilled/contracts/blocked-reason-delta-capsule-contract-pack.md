# Blocked Reason Delta Capsule Contract Pack

## Target Meta-Problem
当 sleep 恢复轮反复出现阻塞时，常见写法会把 `阻塞原因`、`修复动作`、`证据有效性`、`晋级结论` 混写在同一叙述里：
- 阅读负担：排障者必须通读整段历史才能找到“这一轮新增了什么”；
- 元问题混杂：运行时阻塞与语义验收失败被误判成同类问题；
- 重复叙述：每轮重写全量背景，真实变化被淹没。

## 60s Compression Path
1. 固化三段 delta：`blocked_reason_delta`、`repair_action_delta`、`evidence_impact_delta`。
2. 分层路由：运行时阻塞先走 `runtime_block_queue`，语义缺口走 `contract_repair_queue`，禁止互相覆盖。
3. 证据冻结：`evidence_impact_delta` 未闭合前，`decision` 仅允许 `defer|block`。
4. 恢复最小读集：下一轮只读上一轮 capsule + 本轮三段 delta + 对应 provenance。
5. 发布后置：仅在 `contracts_pass && commit_ok && index_linked` 后允许写 `round_state=closed`。

## Delta Capsule Contract
1. Blocked reason card:
`blocked_reason_card.json` 必含 `cycle_id,channel,blocked_reason,first_observed_at,retry_window`。
2. Repair action card:
`repair_action_card.json` 必含 `cycle_id,owner,action_type,action_status,next_probe_at`。
3. Evidence impact card:
`evidence_impact_card.json` 必含 `cycle_id,lineage_id,digest_set_id,impact_scope,impact_closed`。
4. Decision card:
`decision_card.json` 必含 `cycle_id,contracts_pass,commit_ok,index_linked,decision,blocked_channel`。
5. Delta replay barrier:
恢复轮禁止复制上一轮全文叙述；若 `delta_bytes / full_narrative_bytes > 1.0`，标记 `repetition_regression=true`。

## Minimal Evidence Bundle
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `dlq_manifest.json`
- `backpressure_report.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `blocked_reason_card.json`
- `repair_action_card.json`
- `evidence_impact_card.json`
- `decision_card.json`

## Hard Gates
- `Self-Containment`: 单个 fragment 可独立回答“当前阻塞通道、最小修复动作、下一轮最小读集”。
- `Fidelity`: 保留 lease/heartbeat/backpressure、semantic conformance、lineage digest、recall continuity 的边界约束。
- `Index Integrity`: fragment、provenance、index、shortcut 命名一致并可双向回链。

任一 gate fail：`round_state=defer`，禁止声明“本轮闭环完成”。

## Anti-Patterns
- 在一段文本里同时写阻塞诊断、修复计划、发布结论且无通道字段。
- `impact_closed=false` 时输出 `decision=closed`。
- 为了追求完整叙述复制历史全文而不写 delta。
- commit 阻塞却将 `index_linked=true` 作为完成证据。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
