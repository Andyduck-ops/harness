# Closure Receipt Delta Ordering Contract Pack

## Target Meta-Problem
恢复轮常把“完成声明、提交收据、增量证据”混成一个结论段落，导致读者先看到结论再反查事实，阅读负担上升，元问题边界被冲掉，并触发跨轮重复叙述。

## 60s Compression Path
1. 固定发布顺序：`delta_evidence -> commit_receipt -> index_receipt -> closure_claim`。
2. 将提交结果收敛为单卡：`commit_receipt_card.json`，禁止在 narrative 中二次口述。
3. 将索引状态收敛为单卡：`index_receipt_card.json`，显式声明 `index_row_added` 与 `shortcut_added`。
4. 若 `commit_receipt` 缺失，closure 自动降级为 `deferred`，只发布恢复指针。

## Receipt-First Closure Contract
1. Ordering barrier:
`closure_claim_card.json.step_order` 必须严格等于 `["delta_evidence","commit_receipt","index_receipt","closure_claim"]`。
2. Commit receipt hard bind:
`commit_receipt_card.json` 必含 `head_before`, `head_after`, `files_changed`, `commit_status`。
3. Index receipt hard bind:
`index_receipt_card.json` 必含 `fragment_slug`, `provenance_ref`, `index_row_added`, `shortcut_added`。
4. Deferred fallback:
当 `commit_status != success` 时，`closure_claim_card.decision` 必须为 `deferred`，且给出 `retry_after_cycle`。

## Minimal Evidence Bundle
- `delta_evidence_capsule.json`
- `commit_receipt_card.json`
- `index_receipt_card.json`
- `closure_claim_card.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `heartbeat_status.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭四张 receipt/delta 卡可回答“本轮是否闭环、阻塞在哪、下一轮怎么恢复”。
- `Fidelity`: 保留 lease/freshness、语义符合、证据血缘、索引可检索四类边界，不把失败态伪装为完成态。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 四点回链一致。

任一失败：禁止发布 `closed`，仅允许发布 `deferred`。

## Anti-Patterns
- 先写“已完成”再补提交或索引细节。
- 用长段叙述替代可验证 receipt 卡。
- commit 失败但继续输出 closure 语义。
- 仅更新 fragment 不更新 provenance/index shortcut。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
