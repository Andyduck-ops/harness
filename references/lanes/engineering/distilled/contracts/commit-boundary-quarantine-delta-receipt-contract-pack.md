# Commit Boundary Quarantine Delta Receipt Contract Pack

## Target Meta-Problem
恢复轮里若把 `git index.lock` 写失败、合同门禁裁决和历史解释混写在同一段，会稳定触发三类信号恶化：
- 阅读负担：必须先通读长段才能定位“真正阻断在哪个通道”。
- 元问题混杂：commit 通道异常被误判为 semantic/evidence/runtime 失败。
- 重复叙述：同一失败签名被跨轮全文重复，缺少可执行增量。

## 60s Compression Path
1. 首屏只发布 `commit_boundary_card`：`cycle_id + boundary_state + failure_fingerprint + immediate_action`。
2. 用 `verdict_quarantine_card` 固化四通道 verdict：`runtime/gate/commit/index`，禁止跨通道覆写。
3. 对同签名错误只发布 `repetition_delta_receipt`，历史说明下沉到 `history_pointer`。
4. 若 commit 失败或无内容增量，必须写 `deferred_or_nochange_receipt`，并说明下一轮恢复条件。
5. 仅在三门合同通过且 `commit_boundary_state=clear` 时允许发布 `closed`。

## Commit-Boundary Quarantine Contract
1. Commit boundary hard bind（强约束）
`commit_boundary_card.json` 必含 `cycle_id,git_dir,index_lock_path,boundary_state,failure_fingerprint,immediate_action,observed_at_utc`。
2. Verdict quarantine hard bind（强约束）
`verdict_quarantine_card.json` 必含 `runtime_verdict,gate_verdict,commit_verdict,index_verdict,cross_channel_override=false`。
3. Repetition delta hard bind（强约束）
`repetition_delta_receipt.json` 必含 `failure_fingerprint,window_cycles,first_seen_cycle,last_seen_cycle,new_information,history_pointer`。
4. Deferred/no-change receipt hard bind（强约束）
`deferred_or_nochange_receipt.json` 必含 `content_delta_present,commit_required,commit_status,reason_if_no_commit,retry_condition`。
5. Publish barrier（强约束）
`self_containment_pass && fidelity_pass && index_integrity_pass && commit_boundary_state=clear` 才允许 `publish_decision=closed`。

## Minimal Evidence Bundle
- `commit_boundary_card.json`
- `verdict_quarantine_card.json`
- `repetition_delta_receipt.json`
- `deferred_or_nochange_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 即可回答“主阻断是否在 commit 通道、当前是否可闭环、下一步是什么”。
- `Fidelity`: runtime/gate/commit/index 四通道边界保持不变，commit 写失败不得覆盖语义与证据 verdict。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 把 `index.lock permission denied` 直接写成语义门禁失败。
- 同签名故障每轮重贴全量历史，不输出 delta receipt。
- 未生成 no-change/deferred 收据却给出“本轮已闭环”结论。
- 用观测指标值替代合同布尔裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
