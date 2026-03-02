# Incident Window Canonical Ledger Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述同时出现时，同一 incident 往往被拆到不同窗口和门禁里各写一版结论，最终出现“证据还在，裁决不可复用”的碎裂状态。

## 60s Ledger Path
1. 先绑定窗口：`incident_window_id = incident_id + window_bucket + head_sha`。
2. 再锁唯一 owner：`continuity > semantic > lineage > runtime-boundary`，窗口内只允许一次 owner 迁移。
3. 所有结论只写入 `incident_window_ledger.json`，叙述层只引用 `ledger_entry_id`。
4. 非 owner 门禁禁止生成并行裁决，只能补 `evidence_pointer_map`。

## Window-Scoped Canonical Contract
1. Ledger uniqueness:
同一 `incident_window_id` 只能存在一个 `canonical_verdict_id`。
2. Owner transition discipline:
owner 切换必须附带 `transition_reason + guard_pass_set`，缺任一字段即阻断。
3. Narrative dedup discipline:
同义结论必须映射同一 `canonical_verdict_id`，禁止跨文档重复改写。
4. Evidence closure discipline:
每条 ledger entry 必须绑定 `lineage_id + head_sha + freshness_bucket`。

## Minimal Evidence Bundle
- `incident_window_ledger.json`
- `owner_transition_attestation.json`
- `canonical_narrative_registry.json`
- `evidence_pointer_map.json`
- `recall_manifest.json`
- `artifact_promotion_attestation.json`

## Hard Gates
- `window_owner_consistency_pass`
- `canonical_registry_dedup_pass`
- `ledger_evidence_closure_pass`
- `window_freshness_replay_pass`

任一失败，禁止继续晋级与跨窗口复用历史裁决。

## Anti-Patterns
- 一个 incident 在同一窗口内出现多个 canonical verdict。
- 先复制旧叙述再补 attestation 字段。
- 以“解释补充”替代 `evidence_pointer_map` 绑定。
- owner 未锁定就并行触发 continuity/semantic/lineage 三门禁。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
