# Incident Capsule Delta-Fanout Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述三信号并发时，多个 gate 往往各写一版长叙述：
同一 incident 被重复解释、重复裁决、重复回传，导致检索路径膨胀且版本漂移。

## 60s Compression Path
1. 先构建 `incident_capsule`：把窗口、血缘、症状摘要压成单一 canonical capsule。
2. 各 gate 只允许写 `gate_delta_card`，禁止重写完整叙述。
3. 生成 `narrative_fingerprint_set`，同窗口重复叙述直接阻断。
4. 最终只保留一个 `canonical_brief_card`，其余输出必须 pointer 化。
5. 响应层仅返回 `response_pointer_card` 指向 capsule + brief，不复制正文。

## Capsule Delta-Fanout Contract
1. Capsule schema lock:
`incident_capsule` 必含 `incident_window_id,lineage_id,symptom_signature,meta_problem_tag,owner_gate,head_sha`。
2. Delta-only fanout discipline:
每个 gate 只能写一条 `gate_delta_card`，字段限定 `gate_name,delta_type,evidence_pointer,decision_delta`。
3. Single-tag invariant:
`incident_capsule.meta_problem_tag` 只能有一个，出现混合标签即失败。
4. Narrative dedup guard:
同一窗口内 `narrative_fingerprint` 不得重复写入不同正文版本。
5. Pointerized delivery:
所有对外响应必须引用 `canonical_brief_card_id`，禁止复制 verdict 正文。

## Minimal Evidence Bundle
- `incident_capsule.json`
- `gate_delta_cards.jsonl`
- `narrative_fingerprint_set.json`
- `canonical_brief_card.json`
- `response_pointer_card.json`
- `artifact_lineage_manifest.json`

## Hard Gates
- `capsule_self_contained_pass`
- `gate_delta_single_scope_pass`
- `meta_problem_single_tag_pass`
- `narrative_dedup_zero_rewrite_pass`
- `canonical_brief_singleton_pass`
- `pointer_lineage_parity_pass`

任一失败：阻断 `promote/merge`，并冻结该 `incident_window_id` 的新 verdict 发布。

## Anti-Patterns
- 每个 gate 各自输出“全量背景+全量结论”。
- 同一 incident 同时打 `continuity + semantic + lineage` 多标签。
- 使用改写长文替代 delta 卡片，造成多版本叙述并存。
- response 直接复制 verdict 正文而不返回 pointer。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
