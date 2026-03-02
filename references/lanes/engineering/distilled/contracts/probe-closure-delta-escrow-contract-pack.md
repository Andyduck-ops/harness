# Probe Closure Delta Escrow Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述并发时，最常见退化不是“缺少证据”，而是把信号探测、闭环判定、发布裁决写在同一长文里，导致读集超预算且同窗口反复重写。

## 60s Compression Path
1. 入口先探测化：每次请求先落到 `probe_query_card`，只声明窗口、问题轴、owner。
2. 判定再分轨：连续性、语义闭环、证据同源分别产出独立 `probe` 结论卡。
3. 发布先托管：任一 probe 未闭环时写入 `closure_escrow`，禁止正文扩写。
4. 输出只做 delta：外部只发布 `delta_verdict_pointer`，正文不重复抄写。
5. 放行需双回放：通过 `prodlike_replay + recall_rollback` 后才释放 escrow。

## Probe Closure Escrow Contract
1. Probe query lock:
`probe_query_card` 必含 `incident_window_id,lineage_id,owner_gate,problem_axis,query_digest`。
2. Tri-axis probe separation:
同窗口必须独立产出 `liveness_probe_card`,`semantic_probe_card`,`lineage_probe_card`，禁止单卡混写。
3. Closure escrow invariant:
任一 probe 失败时只允许写 `closure_escrow.json`，禁止生成新 verdict 正文。
4. Delta pointer only:
`delta_verdict_pointer` 必须绑定 `lineage_id + head_sha + digest_set_id + delta_id`。
5. Release replay parity:
释放 escrow 前必须满足 `prodlike_replay_pass=true` 且 `actual_hit_ratio >= min_hit_ratio` 且 `continuity_replay_pass=true`。

## Minimal Evidence Bundle
- `probe_query_card.json`
- `liveness_probe_card.json`
- `semantic_probe_card.json`
- `lineage_probe_card.json`
- `closure_escrow.json`
- `artifact_digest_set.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`
- `delta_verdict_pointer.json`

## Hard Gates
- `probe_self_contained_pass`
- `tri_axis_probe_separation_pass`
- `closure_escrow_release_pass`
- `delta_pointer_dedup_pass`
- `replay_recall_lineage_pass`

任一失败：阻断 `promote/merge/write`，并将 `incident_window_id` 标记为 `escrow_frozen`。

## Anti-Patterns
- 一次响应混写连续性、语义闭环、证据同源并直接发最终裁决。
- probe 未通过却追加长正文“解释版”结论。
- 重复发布同窗口全量叙述，而不是 pointer delta。
- replay/recall 未闭环仍释放 escrow 并晋级。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
