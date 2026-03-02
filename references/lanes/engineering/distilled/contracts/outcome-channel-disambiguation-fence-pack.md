# Outcome Channel Disambiguation Fence Pack

## Target Meta-Problem
在 sleep 长跑中，`runtime运行态`、`合同验收态`、`git提交态`、`发布可检索态` 经常被压成一句“本轮完成”。
结果是：
- 阅读负担：必须翻查 state/report/index/events 四个面板才能确认“到底完成了哪一层”；
- 元问题混杂：执行成功、验收通过、提交成功、索引可检索被错误等价；
- 重复叙述：每轮重复解释整段历史，而不是只写本轮 outcome delta。

## 60s Compression Path
1. 固化四通道卡：`runtime_outcome_card`、`contract_outcome_card`、`commit_outcome_card`、`publication_outcome_card`。
2. 因果顺序固定：`runtime -> contract -> commit -> publication`，禁止逆序宣称完成。
3. 合取围栏：仅当 `runtime_ok && contracts_pass && commit_ok && index_linked` 才允许 `round_state=closed`。
4. 通道失败不跨层吞并：任一通道失败仅写本通道 `blocked_reason`，不得篡改上游结果。
5. 恢复轮只写 delta：`outcome_channel_delta + blocked_reason_delta + retry_plan_delta`。

## Outcome Channel Contract
1. Runtime outcome card:
`runtime_outcome_card.json` 必含 `cycle_id,status,lease_freshness_pass,backpressure_guard_pass,stale_run`。
2. Contract outcome card:
`contract_outcome_card.json` 必含 `self_containment,fidelity,index_integrity,failed_gate,recheck_required`。
3. Commit outcome card:
`commit_outcome_card.json` 必含 `attempted,commit_ok,commit_sha,commit_blocked_reason,index_lock_observed`。
4. Publication outcome card:
`publication_outcome_card.json` 必含 `distilled_index_updated,provenance_linked,retrieval_shortcut_added,publish_state`。
5. Delta replay budget:
恢复轮最多读取 4 张 outcome card，超限标记 `narrative_replay_overflow=true`。

## Minimal Evidence Bundle
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `backpressure_report.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `prodlike_e2e_manifest.json`
- `index_shard_manifest.json`
- `recall_manifest.json`
- `runtime_outcome_card.json`
- `contract_outcome_card.json`
- `commit_outcome_card.json`
- `publication_outcome_card.json`

## Hard Gates
- `Self-Containment`: 单 fragment 可独立回答“这轮到底完成到哪一层、卡在哪一层、下一轮该补哪一层”。
- `Fidelity`: 保留 freshness/backpressure、semantic/assertion、digest 同源、prod-like parity、recall 连续性边界。
- `Index Integrity`: fragment/provenance/index/shortcut 四点命名一致且可回链。

任一 gate fail：`round_state=defer`，禁止输出“本轮完整完成”。

## Anti-Patterns
- 用“completed”覆盖 runtime/contract/commit/publication 多层差异。
- `commit_ok=false` 但报告写成“已完成并发布”。
- 三门合同未通过仍更新为可检索最终态。
- 恢复轮复制全量历史，不写 `blocked_reason_delta`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
