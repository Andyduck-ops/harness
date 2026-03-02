# Audience Lens Delta Brief Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂与重复叙述同时出现时，根因常是同一段文本同时服务 operator、auditor、product 三类读者，导致单文档过载、问题边界漂移和同窗口反复改写。

## 60s Compression Path
1. 先写 `lens_query_card`：只声明窗口、任务目标、目标读者视角。
2. 再做三镜拆分：`operator_lens_brief`、`auditor_lens_brief`、`product_lens_brief` 独立生成。
3. 证据单核复用：三镜都引用同一 `shared_evidence_nucleus`，禁止各写一套证据。
4. 发布增量简报：同一窗口同一 lens 仅允许 `delta_brief_pointer`。
5. 放行前做回放闭环：必须通过 continuity replay 与 semantic/lineage parity。

## Audience Lens Contract
1. Lens query normalization:
`lens_query_card` 必含 `incident_window_id,lineage_id,lens_type,primary_task,owner_gate,query_digest`。
2. Lens boundary separation:
同窗口必须有且仅有三类 lens brief；任一 brief 不得混入其他 lens 的目标字段。
3. Shared evidence parity:
三类 brief 必须绑定同一 `head_sha + digest_set_id + evidence_epoch`。
4. Delta brief dedup:
同一 `incident_window_id + lens_type` 每轮只允许一条 `delta_brief_pointer`。
5. Replay before release:
释放 brief 前必须满足 `continuity_replay_pass=true`、`semantic_conformance_pass=true`、`lineage_digest_parity_pass=true`。

## Minimal Evidence Bundle
- `lens_query_card.json`
- `operator_lens_brief.json`
- `auditor_lens_brief.json`
- `product_lens_brief.json`
- `shared_evidence_nucleus.json`
- `artifact_digest_set.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`
- `delta_brief_pointer.json`

## Hard Gates
- `lens_self_contained_pass`
- `lens_boundary_separation_pass`
- `shared_evidence_parity_pass`
- `delta_brief_dedup_pass`
- `replay_recall_release_pass`

任一失败：阻断 `promote/merge/write`，并将该 `incident_window_id` 标记为 `lens_release_frozen`。

## Anti-Patterns
- 一份长文同时解释执行步骤、审计证据与需求语义，导致读者需要反复定位。
- 三个 lens 使用不同 `digest_set_id`，造成证据看似完整但不可对账。
- 同窗口重复发布“完整版说明”，不走 `delta_brief_pointer`。
- continuity 或 recall 未通过仍发布新的 brief。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
