# Workspace Write Scope VCS Lock Fence Contract Pack

## Target Meta-Problem
当 lane 内文档已成功写入，但 Git 元数据锁路径不在可写域时，常见退化是把“提交边界失败”混写成“合同失败”。
这会稳定触发三类信号：
- 阅读负担：首屏无法判断是语义阻断还是提交阻断。
- 元问题混杂：gate/evidence/runtime/commit 通道被串写。
- 重复叙述：每轮重复同一失败背景，delta 难以检索。

## 60s Compression Path
1. 先发 `verdict_first_card`，只给三门合同结果与 primary cause。
2. 再发 `scope_and_lock_receipt`，声明 `workspace_write_scope` 与 `gitdir_lock_scope`。
3. 将 `index.lock permission denied` 严格约束在 commit 通道。
4. 历史失败只保留 pointer，正文只写本轮 delta。
5. 指标仅观测，裁决只看三门合同布尔值。

## Workspace/Lock Fence Contract
1. Scope probe（强约束）  
`scope_and_lock_receipt.json` 必含 `cycle_id,workspace_write_scope[],gitdir_path,gitdir_lock_scope,probe_at_utc`。
2. Dual receipt split（强约束）  
`deliverable_receipt.json` 与 `vcs_attestation_receipt.json` 必须分离，不得复用同一结论字段。
3. Commit fence（强约束）  
`index.lock`、`permission denied` 仅允许写入 `vcs_attestation_receipt.commit_blockers[]`。
4. Gate independence（强约束）  
`self_containment/fidelity/index_integrity` 的判定不得依赖 commit 成功与否。
5. Publish policy（强约束）  
合同三门通过且 commit 受阻时，发布状态为 `ready_with_commit_blocker`，禁止伪装为 `failed_gate`。

## Minimal Evidence Bundle
- `verdict_first_card.json`
- `scope_and_lock_receipt.json`
- `deliverable_receipt.json`
- `vcs_attestation_receipt.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 即可回答“本轮合同是否通过、阻断来源在哪个通道、下一步动作是什么”。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like e2e、recall/rollback 边界完整保留且不被 commit 错误污染。
- `Index Integrity`: fragment/provenance/index 命名、链接、来源映射一一对应。

任一 gate fail：进入 `deferred-reconcile`，禁止宣告闭环。

## Anti-Patterns
- 把 `git add/commit` 失败改写成 `semantic gate fail`。
- 把观测指标分数当作合同裁决。
- 在本轮继续复制历史失败全文而不写 delta。
- 将 `workspace 可写` 与 `gitdir 可写` 视为同义。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
