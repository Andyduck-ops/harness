# Gate Reason Purity / Receipt Attribution Contract Pack

## Target Meta-Problem
恢复轮若把三门合同失败理由与 `index.lock permission denied` 这类 commit 边界失败混写，会同时触发三类信号：
- 阅读负担信号：读者无法在首屏区分“合同失败”还是“提交流程失败”。
- 元问题混杂信号：Fidelity / Index Integrity 被外部写路径错误挟持。
- 重复叙述信号：同一 lock_scope 报错在每轮反复粘贴，合同语义逐轮漂移。

## 60s Compression Path
1. 首屏固定 `contract_gate_verdict_card`，只写 Self-Containment/Fidelity/Index Integrity 的语义结论。
2. commit 失败单独落入 `commit_receipt_card`，禁止进入 gate reason 字段。
3. 同签名 commit 阻塞只发布 `receipt_delta_card`，历史全文下沉 `receipt_history_pointer`。
4. `reason_attribution_router` 强制 gate_scope 与 receipt_scope 双通道分离。
5. gate fail 必须提供对应 gate 语义证据，不允许用工具错误替代。

## Fence Contract
1. Gate reason purity（强约束）
`contract_gate_verdict_card.json` 必含 `self_containment,fidelity,index_integrity,primary_blocker,evidence_refs[]`。
2. Receipt attribution isolation（强约束）
`commit_receipt_card.json` 必含 `commit_attempted,receipt_status,error_class,lock_scope,mutates_gate_reason=false`。
3. Delta-only receipt replay（强约束）
`receipt_delta_card.json` 必含 `fingerprint,new_receipt_fact,unchanged_context`，禁止内联历史全文。
4. Reason-attribution router（强约束）
`reason_attribution_router.json` 必含 `gate_scope,receipt_scope,cross_scope_write=false`。
5. Gate-evidence binding（强约束）
`gate_reason_binding.json` 必含 `gate_name,reason_class,boundary_evidence[]`，禁止 `reason_class=receipt_error`。

## Minimal Evidence Bundle
- `contract_gate_verdict_card.json`
- `commit_receipt_card.json`
- `receipt_delta_card.json`
- `receipt_history_pointer.json`
- `reason_attribution_router.json`
- `gate_reason_binding.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单碎片可独立回答“本轮三门合同为什么 pass/fail，以及 commit 是否只是旁路阻塞”。
- `Fidelity`: 保留 gate 语义与 receipt 语义边界，不以工具报错替代合同判定。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 主证据路径。

任一 gate fail：进入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 在 `Fidelity: FAIL` 后附加 “原因：index.lock permission denied”。
- 用 commit 回执错误直接判定 `Index Integrity: FAIL`。
- 同一 receipt 指纹每轮全量回放，缺少 delta。
- 用“指标提升”替代三门合同语义裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
