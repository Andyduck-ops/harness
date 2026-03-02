# State Runtime Parity Deferred Commit Pack

## Target Meta-Problem
在守护式 sleep 压缩循环中，若 runtime 状态与 workflow 状态未分离，且 commit 被延迟或阻断：
- 阅读负担：同一轮需要重复解释“是否成功、成功到哪一层”；
- 元问题混杂：distill 成功、commit 成功、可恢复性三件事被混写；
- 重复叙述：跨轮反复输出全量状态而不是增量账本。

## 60s Compression Path
1. 固化双平面状态：`runtime_status_card` 与 `workflow_status_card` 分离记录。
2. 固化提交意图：每轮写 `commit_intent_ledger`，明确 `attempted/deferred/blocked`。
3. 绑定三元校验：`lease_freshness + lineage_digest + recall_epoch`。
4. 延迟提交冻结语义：`commit_state=deferred` 时禁止宣称“完成提交”。
5. 恢复只读增量：下一轮仅消费 `status_delta + intent_delta + parity_delta`。

## Deferred Commit Contract
1. Dual-plane status split:
`runtime_status_card.json` 与 `workflow_status_card.json` 必须同时存在，字段不可互推。
2. Commit intent ledger:
`commit_intent_ledger.json` 必含 `cycle_id,attempt_id,commit_state,blocked_reason,retry_after_cycle`。
3. Parity triplet:
`lease_freshness_pass && lineage_digest_pass && recall_epoch_pass` 三者缺一不可。
4. Deferred semantic freeze:
当 `commit_state` 为 `deferred|blocked`，输出必须使用 deferred 语义，不得写入 completed 结论。
5. Delta-only replay budget:
恢复轮次只允许读取三张增量卡，超出预算视为重复叙述退化。

## Minimal Evidence Bundle
- `runtime_status_card.json`
- `workflow_status_card.json`
- `commit_intent_ledger.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Hard Gates
- `Self-Containment`: 仅凭状态双平面 + commit_intent + parity triplet，可回答“当前是否可提交、为何延迟、下一轮如何恢复”。
- `Fidelity`: 保留 lease/heartbeat、semantic conformance、lineage digest、prod-like 边界、recall/rollback 连续性。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 四点可互相回链。

任一 gate fail：禁止发布 `commit completed` 结论，仅允许发布 `deferred delta`。

## Anti-Patterns
- 用单段叙述同时表达 runtime/workflow/commit 三类状态。
- `commit_state=deferred` 却输出“本轮提交完成”。
- 恢复轮次重复回放全量 narrative，不写增量意图账本。
- 缺少 `blocked_reason` 却要求下一轮自动恢复。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
