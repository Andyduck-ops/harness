# Read Budget Epoch Owner Dedup Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述叠加时，常见退化是同一窗口被多 owner 重复写结论，事实/推理/裁决混写，读集扩张后仍无法稳定复用。

## 60s Compression Path
1. 先收敛窗口：每次回答先生成 `epoch_brief_card`，锁定单一 `incident_window_id`。
2. 再锁定 owner：只有当前 `owner_gate` 持有写 lease 时可发布结论。
3. 证据只保留指纹：正文不复制证据长叙述，只写 `evidence_fingerprint_map`。
4. 语义强绑定断言：每条结论必须绑定 `requirement_id -> assertion_id` 映射。
5. 召回/回滚失败即冻结：命中率不足或回滚断链，停止发布新版本。

## Read Budget Epoch Contract
1. Epoch brief card:
`epoch_brief_card` 必含 `incident_window_id,lineage_id,owner_gate,problem_axis,epoch_id`。
2. Owner write lease:
`owner_write_lease.json` 必含 `lease_owner,lease_expire_at,lease_version`，过期 lease 不得写入。
3. Evidence fingerprint dedup:
`evidence_fingerprint_map.json` 必含 `digest_set_id,artifact_name,sha256,head_sha`，正文只允许 pointer 引用。
4. Semantic bind parity:
`requirement_assertion_bind.json` 必含 `requirement_id,assertion_id,conformance_score`，不得出现 unmapped requirement。
5. Recall rollback freeze:
`recall_rollback_gate.json` 必含 `actual_hit_ratio,min_hit_ratio,rollback_target_epoch,continuity_replay_pass`。

## Minimal Evidence Bundle
- `epoch_brief_card.json`
- `owner_write_lease.json`
- `evidence_fingerprint_map.json`
- `requirement_assertion_bind.json`
- `semantic_conformance_report.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `recall_rollback_gate.json`

## Hard Gates
- `epoch_brief_self_contained_pass`
- `owner_single_writer_pass`
- `evidence_fingerprint_dedup_pass`
- `semantic_bind_parity_pass`
- `recall_rollback_integrity_pass`

任一失败：阻断 `promote/merge/write`，并将 `incident_window_id` 置为 `freeze_pending`。

## Anti-Patterns
- 同一窗口由多个 owner 重复发布完整结论。
- 在 verdict 正文重复抄写 artifact 内容而非指纹指针。
- requirement/assertion 映射缺失仍发布通过结论。
- recall 低命中或 rollback replay 失败仍继续写新 epoch。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
