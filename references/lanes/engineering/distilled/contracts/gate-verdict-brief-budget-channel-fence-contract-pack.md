# Gate Verdict Brief Budget Channel Fence Contract Pack

## Target Meta-Problem
恢复轮在一个输出里同时承载 gate 裁决、环境阻塞与排障叙述，导致三类信号持续放大：
- 阅读负担：读者需要扫描整段文本才能定位“合同是否通过”。
- 元问题混杂：内容层 verdict 与 git lockscope 错误混为同一结论通道。
- 重复叙述：相同错误签名跨轮重复写入，新增信息被淹没。

## 60s Compression Path
1. 先产出 `verdict_brief_card`，只回答三门合同 pass/fail 与理由。
2. `git_channel` 单独写 `blocked/error_signature/next_action`，不得覆盖合同结论。
3. `narrative_channel` 改为 pointer-only：只保留 provenance 跳转，不写排障长文。
4. 相同 `error_signature` 命中时走 `dedup_receipt`，禁止重复扩写。
5. 发布索引前校验 `brief_budget_guard=true`，超预算则回退到卡片化摘要。

## Channel Fence Contract
1. Verdict card hard bind:
`verdict_brief_card.json` 必含 `round_id`, `self_containment`, `fidelity`, `index_integrity`, `verdict_reason`.
2. Git channel hard bind:
`git_channel_receipt.json` 必含 `round_id`, `commit_status`, `error_signature`, `lock_path`, `next_action`.
3. Narrative pointer hard bind:
`narrative_pointer.json` 必含 `round_id`, `provenance_ref`, `fragment_ref`, `delta_scope`.
4. Dedup hard bind:
`error_signature_dedup_receipt.json` 必含 `error_signature`, `last_seen_round`, `dedup_mode`.
5. Budget barrier:
`brief_budget_guard=true` 且 `channel_fence_pass=true` 才允许 `index_publish=closed`。

## Minimal Evidence Bundle
- `verdict_brief_card.json`
- `git_channel_receipt.json`
- `narrative_pointer.json`
- `error_signature_dedup_receipt.json`
- `runplane_lease_registry.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 brief card 可独立回答三门合同结论与下一步动作。
- `Fidelity`: 保留“内容合同”与“环境阻塞”边界，不将 lockscope 错误误归因为合同失败。
- `Index Integrity`: fragment/provenance/index/query shortcut 四点命名一致、回链可用。

任一 gate fail：仅允许 `deferred-brief-reconcile`，禁止 `index_publish=closed`。

## Anti-Patterns
- 在同一段文本混写 gate 结论与 git 错误。
- 用“提交失败”覆盖合同门 PASS 结论。
- 重复写同一 `error_signature` 长文而不生成 dedup receipt。
- 先发索引再补 provenance。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
