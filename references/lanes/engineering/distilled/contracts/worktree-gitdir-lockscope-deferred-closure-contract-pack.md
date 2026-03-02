# Worktree Gitdir Lockscope Deferred Closure Contract Pack

## Target Meta-Problem
在 worktree 执行 Sleep 轮次时，工作目录可写并不等于 Git 元数据可写：
`gitdir` 指向主仓库 `.git/worktrees/...`，当该路径不可写时，`index.lock` 创建失败会让本轮卡在“有产物但无提交收据”的悬空态。
- 阅读负担：需要在 report、state、git stderr 三处来回对账才能判断是否闭环；
- 元问题混杂：环境写边界失败被误路由为语义门禁失败；
- 重复叙述：后续轮次反复解释同一提交失败原因，增量信息极少。

## 60s Compression Path
1. 固化三卡：`lockscope_probe_card -> commit_attempt_card -> closure_decision_card`。
2. 先判写边界，再判合同闭环；`gitdir_writable=false` 时禁止发布 closed。
3. 将提交失败压缩为指纹字段：`stderr_fingerprint`，禁止跨轮复制长错误叙述。
4. 当失败指纹命中 `index.lock permission denied`，统一裁决 `decision=deferred`。
5. 下一轮仅发布 `probe_delta + attempt_delta + recovery_action`。

## Lockscope-Aware Closure Contract
1. Lockscope probe hard bind:
`lockscope_probe_card.json` 必含 `worktree_path`, `git_dir_path`, `index_lock_path`, `gitdir_writable`, `probe_at_utc`。
2. Commit attempt hard bind:
`commit_attempt_card.json` 必含 `staged_paths`, `commit_exit_code`, `stderr_fingerprint`, `attempt_at_utc`。
3. Decision fence:
当 `commit_exit_code!=0` 且 `stderr_fingerprint` 命中 `permission denied` + `index.lock` 时，`closure_decision_card.decision` 必须为 `deferred`。
4. Publication barrier:
仅在 `contracts_pass=true && commit_exit_code=0 && index_row_added=true && shortcut_added=true` 时允许 `decision=closed`。

## Minimal Evidence Bundle
- `lockscope_probe_card.json`
- `commit_attempt_card.json`
- `closure_decision_card.json`
- `commit_receipt_card.json`
- `index_receipt_card.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭 lockscope/commit/decision 三卡可回答“为何未闭环、是否可宣告完成、下一轮最小恢复动作”。
- `Fidelity`: 保留 runtime、semantic、evidence、index 边界，不把写边界故障伪装成合同通过。
- `Index Integrity`: fragment/provenance/index row/retrieval shortcut 回链一致。

任一 gate fail：禁止发布 `closed`，仅允许 `deferred`。

## Anti-Patterns
- 把 `git commit` 失败写成“合同失败”，不区分环境边界通道。
- 明知 `index.lock permission denied` 仍发布“本轮闭环完成”。
- 在恢复轮重复整段历史错误日志，而不输出本轮 delta。
- 先改索引再补提交收据，导致回链断裂。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
