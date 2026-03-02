# Shortcut Hotset Coldset Recall Rollback Contract Pack

## Target Meta-Problem
`_distilled_index.md` 的 retrieval shortcuts 在多轮叠加后出现热词与冷词混排：
- 阅读负担：读者必须扫完整个 shortcuts 列表，才能定位本轮高频入口；
- 元问题混杂：索引容量治理与语义/证据 gate 失败混写，导致恢复动作错路由；
- 重复叙述：每轮都补一条“近义长串”，但对命中率改进极小。

## 60s Compression Path
1. 固化 `hotset_card -> coldset_card -> rollback_receipt_card` 三卡。
2. hotset 只保留当前窗口高频 canonical query，冷词沉到 coldset 别名表。
3. 命中重复别名簇时仅写 `coldset_delta_only`，禁止写新长串正文。
4. index 发布前必须生成 `shortcut_tier_receipt`，记录 hot/cold 分层变更。
5. 当召回 fidelity 下降时执行 `shortcut_rollback_to_last_hotset`，先回滚再扩写。

## Tiered Shortcut Contract
1. Hotset hard bind:
`hotset_card.json` 必含 `fragment_slug`, `canonical_query`, `window_id`, `hit_count`, `owner_gate`。
2. Coldset hard bind:
`coldset_card.json` 必含 `alias_cluster_id`, `aliases[]`, `duplicate_signature`, `delta_only`。
3. Tier receipt hard bind:
`shortcut_tier_receipt.json` 必含 `index_rev`, `hotset_size`, `coldset_size`, `changed_clusters`, `updated_at_utc`。
4. Recall fence:
`index_recall_fidelity_pass=false` 时，动作必须是 `shortcut_rollback_to_last_hotset`。
5. Publish barrier:
仅在 `tier_receipt_written=true && provenance_linked=true && canonical_bound=true` 时允许 `index_publish=closed`。

## Minimal Evidence Bundle
- `hotset_card.json`
- `coldset_card.json`
- `shortcut_tier_receipt.json`
- `rollback_attestation.json`
- `recall_manifest.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `index_publish_card.json`

## Hard Gates
- `Self-Containment`: 单凭 hotset/coldset/receipt 三卡可回答“先查哪条 query、何时降级到 coldset、何时回滚”。
- `Fidelity`: 保留 shortcut 容量治理与语义/证据合同边界，不把容量噪声误判为语义失败。
- `Index Integrity`: fragment/provenance/index row/shortcut tier 命名一致且可双向回链。

任一 gate fail：仅允许 `deferred-shortcut-compaction`，禁止 `index_publish=closed`。

## Anti-Patterns
- 将 hotset 与 coldset 混写为单列表，导致检索入口漂移。
- 把 shortcut 容量问题直接归因为 semantic gate 失败。
- 只追加 query 长串，不更新 tier receipt 与 rollback attestation。
- 召回下降时继续扩写 alias，导致重复叙述累积。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
