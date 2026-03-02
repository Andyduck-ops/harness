# Publication-State Commit-Boundary Separation Contract Pack

## Target Meta-Problem
恢复轮若把 `runtime/gate/index` 的通过结论与 `commit boundary blocked` 混写成一个“完成态”，会同时触发三类信号劣化：
- 阅读负担：执行者无法在首屏判断“内容完成”与“提交完成”是否同义。
- 元问题混杂：质量门 verdict 被 commit 通道失败覆写，修复路径错配。
- 重复叙述：同一 `index.lock permission denied` 指纹跨轮重复全量解释，增量线索被淹没。

## 60s Compression Path
1. 首屏强制发布 `publication_state_card`，拆分 `content_ready` 与 `commit_settled`。
2. `commit_settled=false` 时只发布 `deferred_commit_receipt` 与 `retry_condition`，不重讲历史。
3. `runtime/gate/index/commit` 四通道 verdict 固化，禁止跨通道覆写。
4. 同指纹复发仅追加 `delta_pointer_receipt.new_information`，历史统一走 `history_pointer`。
5. 仅当三门合同通过且 `commit_settled=true` 才允许 `publish_decision=closed`。

## Publication-Boundary Separation Contract
1. Publication card hard bind（强约束）
`publication_state_card.json` 必含 `cycle_id,content_ready,commit_settled,primary_blocker_channel,failure_fingerprint,observed_at_utc`。
2. Deferred receipt hard bind（强约束）
`deferred_commit_receipt.json` 必含 `content_delta_present,commit_required,commit_attempted,commit_status,reason_if_no_commit,retry_condition`。
3. Verdict partition hard bind（强约束）
`verdict_partition_card.json` 必含 `runtime_verdict,gate_verdict,index_verdict,commit_verdict,cross_lane_override=false`。
4. Repetition delta hard bind（强约束）
`delta_pointer_receipt.json` 必含 `failure_fingerprint,new_information,unchanged_sections,history_pointer,next_retry_condition`。
5. Publish barrier（强约束）
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass && commit_settled=true` 时允许 `publish_decision=closed`。

## Minimal Evidence Bundle
- `publication_state_card.json`
- `deferred_commit_receipt.json`
- `verdict_partition_card.json`
- `delta_pointer_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 即可回答“当前是否只卡在 commit 边界、恢复条件是什么”。
- `Fidelity`: commit 通道失败不改写 runtime/gate/index 的既有 verdict。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 用“已完成”同时表示内容完成与提交完成。
- 把 commit 边界失败覆写为 gate/evidence/runtime 失败。
- 同签名无新增信息仍重复全量叙述。
- 用伪精度分数替代合同布尔裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
