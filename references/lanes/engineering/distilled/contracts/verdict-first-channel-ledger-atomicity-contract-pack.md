# Verdict First Channel Ledger Atomicity Contract Pack

## Target Meta-Problem
当一轮压缩把“门禁结论、证据增量、运行态恢复、提交边界”串成一段叙述时，会稳定触发三类退化：
- 阅读负担：读者无法在首屏判断本轮是否阻断。
- 元问题混杂：语义门禁失败与运行/提交异常互相污染。
- 重复叙述：每轮重复背景，新增 delta 被淹没。

## 60s Compression Path
1. 先发 `verdict_first_card`：只说 gate verdict 与 block cause。
2. 再发 `channel_ledger_delta`：按 `gate/evidence/runtime/commit` 四通道写增量。
3. 冲突信息只写在所属通道，不跨通道复述。
4. 历史背景只保留 pointer，正文只写本轮变化。
5. 发布前仅看三门合同布尔值，指标只做观测。

## Verdict-First Channel-Ledger Atomicity Contract
1. Verdict first card（强约束）  
`verdict_first_card.json` 必含 `cycle_id,gate_vector,primary_blocking_cause,decision,decided_at_utc`。
2. Channel ledger delta（强约束）  
`channel_ledger_delta.json` 必含 `cycle_id,channel,delta_items[],fingerprint,owner`，且 channel 仅允许 `gate/evidence/runtime/commit`。
3. Cross-channel fence（强约束）  
`commit` 通道错误（如 `index.lock`）不得写入 `gate` 判定字段。
4. Repetition fence（强约束）  
`delta_items[]` 禁止复制上轮 full narrative；历史仅允许 `pointer_ref`。
5. Publish barrier（强约束）  
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass` 为 `true` 才允许发布。

## Minimal Evidence Bundle
- `verdict_first_card.json`
- `channel_ledger_delta.json`
- `requirement_closure_attestation.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 verdict card + channel ledger 即可回答“是否阻断、阻断因果、恢复动作、提交边界”。
- `Fidelity`: requirement/assertion、artifact lineage、prod-like e2e、recall/rollback 边界未被混道改写。
- `Index Integrity`: fragment/provenance/index 行与 shortcut 命名一致并可回链。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 用 `commit` 边界失败替代语义门禁失败。
- 把指标数值写成合同裁决依据。
- 在本轮报告重复整段历史背景而无 delta。
- 四通道未分离就输出统一“all pass/all fail”。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
