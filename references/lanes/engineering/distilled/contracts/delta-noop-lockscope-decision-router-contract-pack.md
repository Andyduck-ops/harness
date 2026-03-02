# Delta Noop Lockscope Decision Router Contract Pack

## Target Meta-Problem
恢复轮里经常把三种结局写成一段“完成/失败”叙述：
- 阅读负担：必须通读整段才能判断本轮到底是 `有增量`、`无增量` 还是 `提交阻塞`；
- 元问题混杂：内容增量状态和 git lockscope 环境问题混在同一通道，修复动作会串线；
- 重复叙述：每轮都重复“commit failed: index.lock permission denied”长句，检索增量信息反而更难。

## 60s Compression Path
1. 固化 `delta_card -> noop_receipt -> commit_blocked_receipt` 三分流。
2. 先判定本轮是否有内容增量；无增量直接走 `noop_receipt`，禁止附加长叙述。
3. 有增量时独立判断提交通道；若 lockscope 阻塞，只写 `commit_blocked_receipt`。
4. `sleep-report` 仅汇总分流结果，不承载排障长文；长证据留在 provenance。
5. `_distilled_index.md` 发布前必须写 `decision_router_receipt`，保证检索入口稳定。

## Decision Router Contract
1. Delta hard bind:
`delta_card.json` 必含 `round_id`, `changed_files[]`, `fragment_slug`, `provenance_slug`, `delta_status`。
2. No-op hard bind:
`noop_receipt.json` 必含 `round_id`, `reason`, `scanned_patterns`, `contract_gates`。
3. Commit-blocked hard bind:
`commit_blocked_receipt.json` 必含 `round_id`, `git_action`, `lock_path`, `error_signature`, `impact_scope`。
4. Channel fence:
`content_channel` 与 `git_channel` 必须分离；git 阻塞不得改写 contract gate 结论。
5. Publish barrier:
仅在 `decision_router_receipt_written=true && provenance_linked=true` 时允许 `index_publish=closed`。

## Minimal Evidence Bundle
- `delta_card.json`
- `noop_receipt.json`
- `commit_blocked_receipt.json`
- `decision_router_receipt.json`
- `runplane_lease_registry.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单凭三分流卡可独立回答“本轮有无增量、为何未提交、下一步应走哪个通道”。
- `Fidelity`: 保留内容闭环与 git 环境阻塞的边界，不把 lockscope 错判为语义/证据失败。
- `Index Integrity`: fragment/provenance/index row/query shortcut 命名一致且可双向回链。

任一 gate fail：仅允许 `deferred-router-reconciliation`，禁止 `index_publish=closed`。

## Anti-Patterns
- 把 delta/no-op/commit-blocked 合并成单一“失败描述”。
- 用 git lock 错误覆盖内容层合同结论。
- no-op 轮仍追加长段重复叙述。
- 只记录错误字符串，不写结构化 blocked receipt。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
