# Cycle-Advance Content-Commit Decoupling Contract Pack

## Target Meta-Problem
恢复轮把 `cycle_advance` 绑定到 `commit_success`，会把“内容已蒸馏”与“提交已落库”耦合成单一状态：
- 阅读负担：执行者无法在首屏判断本轮是否已有有效新知识。
- 元问题混杂：commit 边界失败覆写 runtime/gate/index verdict。
- 重复叙述：同一 `index.lock permission denied` 指纹被迫跨轮全量复述。

## 60s Compression Path
1. 首屏固定拆分 `content_cycle` 与 `commit_cycle`，禁止单一 completed 结论。
2. 三门合同通过后允许 `content_cycle=cycle+1`，即使 `commit_cycle` 仍停留。
3. commit 不可达时发布 `pending_commit_receipt`，只给重试条件与 delta 指针。
4. `_distilled_index.md` 更新后写 `index_snapshot_attestation`，声明检索层已可用。
5. 同指纹复发仅追加 `attempt_window_delta`，历史解释统一下沉 `history_pointer`。

## Cycle-Decoupling Contract
1. Cycle state hard bind（强约束）
`cycle_state_card.json` 必含 `cycle_id,content_cycle,commit_cycle,content_ready,commit_settled,failure_fingerprint`。
2. Decoupling receipt hard bind（强约束）
`content_commit_decoupling_receipt.json` 必含 `contracts_pass,content_published,commit_required,commit_attempted,commit_status,retry_condition`。
3. Pending queue hard bind（强约束）
`pending_commit_queue.json` 必含 `queue_id,pending_cycle_ids,last_attempt_at_utc,next_retry_at_utc,lock_scope`。
4. Index attestation hard bind（强约束）
`index_snapshot_attestation.json` 必含 `distilled_fragment_path,provenance_path,index_entry_hash,index_updated_at_utc`。
5. Repetition fence hard bind（强约束）
`attempt_window_delta.json` 必含 `failure_fingerprint,attempt_window_id,new_information,unchanged_sections,history_pointer`。

## Minimal Evidence Bundle
- `cycle_state_card.json`
- `content_commit_decoupling_receipt.json`
- `pending_commit_queue.json`
- `index_snapshot_attestation.json`
- `attempt_window_delta.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看本 fragment 可回答“本轮知识是否已发布、提交为何延后、下次重试条件是什么”。
- `Fidelity`: commit 失败只影响 commit 通道，不覆写 runtime/gate/index 的已通过结论。
- `Index Integrity`: fragment/provenance/index 三者命名一致，且都可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止宣告 `publish_decision=closed`。

## Anti-Patterns
- 把 `content_cycle` 与 `commit_cycle` 合并成同一 completed 字段。
- 因 commit 失败回滚或覆写已通过的三门合同 verdict。
- 同签名无新增信息仍重复粘贴全量历史。
- 用伪精度分数裁决是否允许 cycle 前进。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
