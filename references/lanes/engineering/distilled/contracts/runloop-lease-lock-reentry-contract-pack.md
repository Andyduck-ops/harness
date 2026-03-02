# Runloop Lease Lock Reentry Contract Pack

## Target Meta-Problem
守护式压缩在长跑场景下容易出现同一 cycle 的重复重入：
- 阅读负担：同一轮反复重放检查与上下文采样，读路径持续变长；
- 元问题混杂：distill、审计、提交、watchdog 恢复混写在同一叙述；
- 重复叙述：锁失败后重复输出完整 narrative，而不是增量失败证据。

## 60s Compression Path
1. 先写 `cycle_intent_card`：固定 `lane_id + cycle_id + owner + target_action`，避免同轮多解释。
2. 写 `single_writer_lease`：提交链路在同一时刻只允许一个 writer 持有 git 变更 lease。
3. 分离 `distill_payload` 与 `commit_transaction`：蒸馏成功不等于提交成功，禁止语义混并。
4. 锁失败只发布 `lock_failure_delta`：记录 `lock_path + lock_owner + retry_window`，不重发全量 narrative。
5. 仅在 `lease_valid && lock_cleared && lineage_parity_pass` 时执行 commit；否则冻结为 `commit_deferred`。

## Reentry Contract
1. Cycle uniqueness:
`cycle_intent_card` 必含 `lane_id,cycle_id,run_id,owner,target_action,query_digest`。
2. Single-writer lease:
`git_mutation_lease.json` 必含 `lease_owner,lease_expire_at,lease_epoch,lock_scope`，同 scope 禁止多 writer。
3. Distill/commit separation:
`distill_result_card` 与 `commit_result_card` 分文件落盘，禁止“distill=success”推导“commit=success”。
4. Lock-failure delta only:
锁冲突仅允许更新 `lock_failure_delta.json`，不得重复回放全量 phase 叙述。
5. Deferred-commit attestation:
当 `index.lock` 冲突未消解时，必须写 `commit_deferred_attestation.json`，并绑定下一轮 `retry_after_cycle`。

## Minimal Evidence Bundle
- `cycle_intent_card.json`
- `git_mutation_lease.json`
- `distill_result_card.json`
- `commit_result_card.json`
- `lock_failure_delta.json`
- `commit_deferred_attestation.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `recall_manifest.json`
- `rollback_attestation.json`

## Hard Gates
- `Self-Containment`: `cycle_intent_card` + `distill_result_card` + `commit_result_card` 可独立回答“本轮做了什么、卡在哪里”。
- `Fidelity`: 保留 lease/heartbeat、lineage digest、requirement conformance、recall/rollback 边界，不改 patterns 主证据。
- `Index Integrity`: fragment/provenance/index 三者可回链，且 shortcut 命中本包。

任一 gate fail：阻断 `promote/merge`，仅允许发布 `commit_deferred` 增量说明。

## Anti-Patterns
- 在同一段文本中混写蒸馏结果、提交结果、watchdog 重启策略。
- 锁失败后再次输出完整长文而不提供 `lock_failure_delta`。
- 未持有 single-writer lease 即尝试写 git 索引。
- 用“运行中”替代可追溯的 `commit_deferred_attestation`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
