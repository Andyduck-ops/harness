# Closure Claim Commit Attestation Contract Pack

## Target Meta-Problem
恢复轮常见失败不是“修复没做”，而是“先宣告完成、后补提交证明”：
- 阅读负担：读者必须在长叙述中反查 commit/index 是否真实落地；
- 元问题混杂：runtime/contract/git/publication 四个通道被写成同一个“已闭环”；
- 重复叙述：后续轮次重复解释“为什么上轮说完成但未真正完成”。

## 60s Compression Path
1. 拆分 closure 通道：`runtime_state`、`contract_state`、`commit_state`、`publication_state`。
2. 先写 delta 再写结论：无 `commit_attestation` 与 `index_attestation` 禁止写 `round_closed`。
3. 固化证明链：`git_commit_sha -> staged_paths -> index_link_parity` 一条链闭合。
4. 发布后置：仅在 `contracts_pass && commit_ok && index_linked` 时允许 `decision=closed`。
5. 恢复最小读集：下一轮只读 `上一轮 decision_card + 本轮三段 delta + provenance`。

## Closure Attestation Contract
1. Closure intent card:
`closure_intent_card.json` 必含 `cycle_id,declared_outcome,blocked_channel,required_attestations`。
2. Commit attestation card:
`commit_attestation_card.json` 必含 `cycle_id,git_commit_sha,staged_paths,commit_ok,commit_error`。
3. Index attestation card:
`index_attestation_card.json` 必含 `cycle_id,index_updated,index_entry_id,shortcut_synced,index_linked`。
4. Publication decision card:
`publication_decision_card.json` 必含 `cycle_id,contracts_pass,commit_ok,index_linked,decision,publishable`。
5. Narrative ordering barrier:
若 `declared_outcome` 早于 `commit_attestation_card` 时间戳，标记 `ordering_regression=true`。

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
- `closure_intent_card.json`
- `commit_attestation_card.json`
- `index_attestation_card.json`
- `publication_decision_card.json`

## Hard Gates
- `Self-Containment`: fragment 可独立回答“本轮是否可宣告完成、缺哪个证明、下一轮最小读集”。
- `Fidelity`: 保留 runtime/semantic/evidence/index 四层边界，不把 commit 失败伪装为 contract 成功。
- `Index Integrity`: fragment、provenance、index row、shortcut 命名与回链一致。

任一 gate fail：`decision=defer`，禁止写“闭环完成”。

## Anti-Patterns
- 在 `commit_ok=false` 时写 `decision=closed`。
- 只写“合同通过”但不写 `git_commit_sha` 与 `staged_paths`。
- 更新了 `_distilled_index.md` 却不更新 retrieval shortcut。
- 为解释一次提交失败重复复制整段历史 narrative。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
