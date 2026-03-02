# Signal Router Readset Capsule Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述三信号并发时，同一窗口常被迫同时回答连续性、语义闭环、证据一致性，导致读集超预算与结论复写。

## 60s Compression Path
1. 入口先原子化：每次只接受一个 `meta_problem_tag` 的 query atom。
2. 证据再胶囊化：每个窗口只保留最小主证据集合，超限立即回退重路由。
3. 闭环再拆分：`continuity_closure` 与 `semantic_closure` 分轨计算，最终只在 pointer 层汇合。
4. 叙述再去重：同窗口 verdict 只能引用 canonical pointer，不再发布新正文版本。
5. 运行再保鲜：lease/heartbeat/backpressure 与 recall/rollback 合同并行阻断失真写入。

## Signal Router Capsule Contract
1. Query atom schema lock:
`query_atom_card` 必含 `incident_window_id,lineage_id,meta_problem_tag,owner_gate,question_digest`。
2. Readset capsule budget:
`evidence_capsule_manifest.primary_evidence_count <= 3`，并显式记录 `budget_reason`。
3. Split closure invariant:
同窗口必须同时产出 `continuity_closure_card` 与 `semantic_closure_card`，禁止单卡混写。
4. Pointer-only publish:
`verdict_pointer_card` 必须绑定 `lineage_id + head_sha + digest_set_id + verdict_digest`。
5. Liveness + recall parity:
`stale_run=false` 且 `actual_hit_ratio >= min_hit_ratio` 才允许生成新 verdict pointer。

## Minimal Evidence Bundle
- `query_atom_card.json`
- `evidence_capsule_manifest.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`
- `verdict_pointer_card.json`

## Hard Gates
- `single_meta_problem_tag_pass`
- `evidence_capsule_budget_pass`
- `split_closure_integrity_pass`
- `continuity_liveness_recall_pass`
- `pointer_lineage_dedup_pass`

任一失败：阻断 `promote/merge/write`，并冻结该 `incident_window_id` 的新叙述发布。

## Anti-Patterns
- 同一窗口同时回答 continuity + semantic + rollback 细节并发布长文。
- 为“信息完整”无限扩容主证据读集。
- 在 evidence 与 verdict 同层重写同义结论。
- freshness 或 recall 不达标仍产出新 pointer。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
