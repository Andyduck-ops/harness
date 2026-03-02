# Index Shortcut Entropy Alias Collapse Contract Pack

## Target Meta-Problem
随着 cycle 持续追加，`_distilled_index.md` 的 retrieval shortcuts 出现“同义别名膨胀”：
- 阅读负担：同一检索意图被多条近义 query 覆盖，读者先筛别名再读证据；
- 元问题混杂：index 维护问题与合同裁决问题混写，修复路径被误导；
- 重复叙述：每轮新增一条近义 shortcut，重复描述同一检索通道。

## 60s Compression Path
1. 固化 `alias_probe_card -> canonical_query_card -> index_publish_card` 三卡。
2. 每个 fragment 仅允许一个 `canonical_query`，别名只保留可追溯映射，不直接扩写正文。
3. 命中同义簇重复时，只发布 `alias_delta`，禁止追加新叙述段。
4. index 发布必须绑定 `fragment_slug + provenance_ref + canonical_query` 三元组。
5. 本轮只写 delta：新增或删减 alias 必须落到 `shortcut_registry_card`。

## Alias Collapse Contract
1. Alias probe hard bind:
`alias_probe_card.json` 必含 `fragment_slug`, `query_tokens`, `alias_cluster_id`, `duplicate_signature`, `probe_at_utc`。
2. Canonical query hard bind:
`canonical_query_card.json` 必含 `fragment_slug`, `canonical_query`, `alias_count`, `owner_gate`, `query_digest`。
3. Registry hard bind:
`shortcut_registry_card.json` 必含 `index_rev`, `total_shortcuts`, `duplicate_clusters`, `changed_fragments`, `updated_at_utc`。
4. Decision fence:
命中 `duplicate_signature=true` 时，发布动作必须为 `alias_delta_only`，禁止新增同义 shortcut 正文。
5. Publication barrier:
仅在 `index_row_added=true && provenance_linked=true && canonical_query_bound=true` 时允许 `index_publish=closed`。

## Minimal Evidence Bundle
- `alias_probe_card.json`
- `canonical_query_card.json`
- `shortcut_registry_card.json`
- `index_publish_card.json`
- `index_receipt_card.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单凭 alias/canonical/publish 三卡可回答“该用哪条 query、为何不扩写别名、索引是否可发布”。
- `Fidelity`: 保留 index 管理问题与语义/证据合同边界，不把检索噪声误判为语义失败。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 命名一致且双向可回链。

任一 gate fail：仅允许 `deferred-index-prune`，禁止 `index_publish=closed`。

## Anti-Patterns
- 同一 fragment 跨轮不断追加同义 shortcut，不维护 canonical 查询。
- 把 shortcut 噪声误写为“合同不通过”，触发错误修复路径。
- 只改 index 文本，不更新 provenance 与 registry 映射。
- 在恢复轮复制历史查询串，而不是发布 alias delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
