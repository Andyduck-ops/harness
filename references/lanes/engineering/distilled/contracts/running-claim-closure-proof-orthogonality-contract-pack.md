# Running Claim / Closure Proof Orthogonality Contract Pack

## Target Meta-Problem
当恢复轮把 `state.status=running`、run 闭环证据、三门合同裁决、commit 回执放在同一段叙述时，会同时触发三类信号：
- 阅读负担信号：首屏无法快速回答“系统在跑”是否等于“本轮闭环”。
- 元问题混杂信号：运行活性问题被误写成 Fidelity 或 Index Integrity 失败。
- 重复叙述信号：同一 `index.lock permission denied` 在每轮全文回放，增量事实被淹没。

## 60s Compression Path
1. 首屏先产出 `running_claim_card`，仅回答“是否仍在运行”。
2. 闭环判断独立输出 `closure_proof_card`，必须绑定 run pair 证据。
3. 三门合同裁决只读 `gate_verdict_card`，禁止读取 commit 回执字段。
4. `commit_receipt_card` 仅记录提交边界与错误域，不回写 gate 结论。
5. 同指纹失败只发布 `delta_fact_card`，历史通过 `history_pointer_card` 回链。

## Orthogonality Contract
1. Running claim fence（强约束）
`running_claim_card.json` 必含 `cycle_id,status_claim,pid_witness,heartbeat_freshness,claim_scope=runtime`。
2. Closure proof fence（强约束）
`closure_proof_card.json` 必含 `run_id,run_start_seen,run_end_seen,closure_verdict,proof_scope=runpair`。
3. Gate verdict purity（强约束）
`gate_verdict_card.json` 必含 `self_containment,fidelity,index_integrity,reason_scope=contracts`。
4. Receipt isolation（强约束）
`commit_receipt_card.json` 必含 `commit_attempted,receipt_status,error_class,lock_scope,cross_scope_write=false`。
5. Delta-only replay（强约束）
`delta_fact_card.json` 必含 `fingerprint,new_fact,unchanged_context`，禁止内联历史全文。

## Minimal Evidence Bundle
- `running_claim_card.json`
- `closure_proof_card.json`
- `gate_verdict_card.json`
- `commit_receipt_card.json`
- `delta_fact_card.json`
- `history_pointer_card.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单碎片可独立回答“在跑声明、闭环状态、阻塞域”三问。
- `Fidelity`: 保留 runtime claim / closure proof / contract verdict / commit receipt 四通道边界。
- `Index Integrity`: fragment、provenance、index 命名一致，且可回链 5 个 pattern 主证据。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 仅凭 `state.status=running` 推导 `closure=closed`。
- 用 `index.lock permission denied` 解释三门合同失败。
- 将 commit 回执状态作为 Self-Containment/Fidelity 直接证据。
- 对同指纹阻塞态重复全文叙述而不发布 delta。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
