# Verdict Surface / History Pointer Fence Contract Pack

## Target Meta-Problem
恢复轮若把 `history` 全量背景、`gate` 裁决和 `remediation` 动作同屏混写，会同时放大三类信号：
- 阅读负担信号：操作者需要穿透长背景才能找到本轮可执行结论。
- 元问题混杂信号：历史解释、当前事实与门禁裁决边界被打穿。
- 重复叙述信号：同一阻断签名跨轮复制整段历史，增量事实被淹没。

## 60s Compression Path
1. 首屏固定 `gate_verdict_triplet`，只写三门合同结论与下一步动作。
2. 同签名仅发布 `delta_fact_capsule`，禁止历史段落重放到首屏。
3. 历史背景统一下沉到 `history_pointer_card`，只保留可回链指针。
4. `meta_scope_router` 强制区分 `runtime/evidence/policy` 三种问题面。
5. commit 边界异常只写 `commit_receipt`，不反向污染 gate verdict。

## Fence Contract
1. Verdict surface first（强约束）
`gate_verdict_triplet.json` 必含 `self_containment,fidelity,index_integrity,next_action`。
2. Delta-only current state（强约束）
`delta_fact_capsule.json` 必含 `fingerprint,cycle_window,new_fact,unchanged_context`。
3. History pointer isolation（强约束）
`history_pointer_card.json` 必含 `pointer_id,last_stable_cycle,lookup_path,replay_policy`。
4. Meta-scope router（强约束）
`meta_scope_router.json` 必含 `runtime_scope,evidence_scope,policy_scope,cross_scope_write=false`。
5. Commit boundary decouple（强约束）
`commit_receipt.json` 必含 `commit_attempted,error_class,lock_scope,gate_verdict_unchanged=true`。

## Minimal Evidence Bundle
- `gate_verdict_triplet.json`
- `delta_fact_capsule.json`
- `history_pointer_card.json`
- `meta_scope_router.json`
- `commit_receipt.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 只读本碎片即可回答“本轮结论是什么、下一步做什么、历史去哪里查”。
- `Fidelity`: 保留边界条件与反模式映射；不以观测指标替代合同裁决。
- `Index Integrity`: fragment/provenance/index 命名一致，且能回链到 5 个 pattern 主证据路径。

任一 gate fail：进入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 首屏写“历史回顾 + 多轮背景 + 本轮结论”三段长文。
- 把 `history_pointer` 当成当前轮事实写回 `delta_fact_capsule`。
- 将 runtime 漂移说明直接当作 Fidelity 通过证据。
- 用“指标改善”替代 Self-Containment/Fidelity/Index Integrity 裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
