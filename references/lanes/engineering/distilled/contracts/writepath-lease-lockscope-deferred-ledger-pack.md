# Writepath Lease Lockscope Deferred Ledger Pack

## Target Meta-Problem
在守护式压缩循环中，写路径不可用（如 `index.lock` 无法获取）会触发三类退化：
- 阅读负担：每轮重复回放全量叙述，读路径持续增厚；
- 元问题混杂：distill 成果、commit 事务、恢复调度混写在同一文本；
- 重复叙述：同一锁冲突被不同轮次重复解释，缺少稳定增量锚点。

## 60s Compression Path
1. 固化 `writepath_scope_card`：声明 `repo_path + lock_scope + writer_owner + cycle_id`，禁止同轮语义漂移。
2. 分离 `distill_success_attest` 与 `commit_deferred_attest`：蒸馏成功与提交成功独立建模。
3. 锁冲突仅追加 `lockscope_delta_ledger`：记录 `lock_path + denied_capability + retry_after_cycle`。
4. 绑定 `lineage_digest_parity`：deferred 状态也必须携带 `lineage_id + head_sha + digest_set_id`。
5. 下一轮只消费 delta：恢复时禁止重放上一轮全量 narrative，只读取 `delta + parity + gate verdict`。

## Deferred Commit Contract
1. Writepath scope uniqueness:
`writepath_scope_card.json` 必含 `lane_id,cycle_id,run_id,repo_path,lock_scope,writer_owner`。
2. Distill/commit split:
`distill_success_attest.json` 与 `commit_deferred_attest.json` 必须分文件，禁止单卡双义。
3. Lockscope delta-only:
`lockscope_delta_ledger.json` 仅记录失败增量：`lock_path,denied_capability,first_seen_cycle,last_seen_cycle,retry_after_cycle`。
4. Parity freeze:
若 `lineage_digest_parity=false`，禁止发布任何 commit 语义，状态冻结为 `deferred-blocked`。
5. Replay budget:
恢复轮次只允许读取 `N=3` 张卡（scope,delta,parity），超预算视为重复叙述退化。

## Minimal Evidence Bundle
- `writepath_scope_card.json`
- `distill_success_attest.json`
- `commit_deferred_attest.json`
- `lockscope_delta_ledger.json`
- `lineage_digest_parity.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭 scope + delta + deferred attestation 可回答“本轮为何未提交、下一轮如何恢复”。
- `Fidelity`: 保留 lease/heartbeat、lineage digest、semantic conformance、prod-like/replay、recall continuity 边界。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 四点可回链。

任一 gate fail：阻断 `promote/merge`，仅允许发布 `commit_deferred` 增量。

## Anti-Patterns
- 锁冲突后再次输出完整长文而不写 `lockscope_delta_ledger`。
- 用“持续运行中”替代可追溯的 `commit_deferred_attest`。
- 在同一段文本混写 distill 结果、commit 事务和恢复策略。
- 未声明 writer_owner 就尝试写入 git 索引。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
