# Single Writer Thread Delta Contract Pack

## Target Meta-Problem
阅读负担、元问题混杂、重复叙述叠加时，最常见退化是同一 incident window 被多个角色重复改写，导致读路径拉长、meta scope 漂移、结论无法稳定复用。

## 60s Compression Path
1. 先锚定 `thread_key = incident_window_id + lineage_id + meta_problem_tag`，没有 `thread_key` 不允许写结论。
2. `thread_key` 由单写者持有 `writer_lease`，其他角色只能追加证据 delta，不能改写 verdict。
3. verdict 永远以 `canonical_thread_pointer` 交付，文本正文只在 canonical thread 内维护一份。
4. 命中重复叙述时仅更新 `evidence_delta` 与 `freshness_bucket`，并递增 `thread_revision`。

## Single-Writer Thread Contract
1. Thread key lock:
每条记录必须声明唯一 `thread_key`，跨 tag 直接拆线程，不允许多标签混写。
2. Writer lease gate:
同一 `thread_key` 同时仅允许一个 `writer_lease_owner`，租约失效后才能切换写者。
3. Canonical pointer delivery:
外部卡片只能输出 `canonical_thread_pointer`，不得复制完整 verdict 段落。
4. Delta append only:
证据更新采用 append-only `evidence_delta_log`，禁止重写历史证据映射。

## Minimal Evidence Bundle
- `thread_key_registry.json`
- `writer_lease_registry.json`
- `canonical_thread_pointer.json`
- `thread_revision_manifest.json`
- `evidence_delta_log.jsonl`
- `meta_problem_tag_map.json`

## Hard Gates
- `thread_key_uniqueness_pass`
- `single_writer_lease_pass`
- `canonical_pointer_only_pass`
- `delta_append_only_pass`

任一失败：冻结 `promote/merge`，并回退到上一个 `thread_revision`。

## Anti-Patterns
- 同一 incident window 在多个文档同时改写 verdict 正文。
- 一个线程同时挂载多个 `meta_problem_tag` 导致归因混线。
- 非 lease owner 直接重写结论文本。
- 以“改词重发”替代 evidence delta，制造同义多版本叙述。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
