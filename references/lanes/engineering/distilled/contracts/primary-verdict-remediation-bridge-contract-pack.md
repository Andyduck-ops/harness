# Primary Verdict Remediation Bridge Contract Pack

## Target Meta-Problem
同一轮把 `gate verdict`、`remediation playbook`、`历史背景解释` 写在同一首屏，会让执行结论后置，触发阅读负担上升；同时 remediation 细节会反向污染裁决通道，造成元问题混杂与重复叙述回放。

## 60s Compression Path
1. 首屏固定 `primary_verdict_card`：仅给 `primary_gate + verdict + blocker_channel + immediate_action`。
2. 修复策略写入 `remediation_bridge_card`，只允许引用主裁决，不得改写主裁决。
3. 历史背景下沉到 `history_pointer`，正文只留 `delta_packet`。
4. 元问题统一写 `meta_problem_ledger`，禁止写 gate 结论。
5. 指标只进 `observation_ledger`，声明 `observation_only=true`。

## Verdict-Remediation Bridge Contract
1. Primary verdict lane（强约束）
`primary_verdict_card.json` 必含 `primary_gate, verdict, blocker_channel, immediate_action, decision_epoch`。
2. Remediation bridge lane（强约束）
`remediation_bridge_card.json` 必含 `remediation_owner, remediation_steps[], acceptance_signal, depends_on_primary_gate`。
3. Boundary replay lane（强约束）
`boundary_replay_card.json` 必含 `runtime_boundary_profile, replay_seed, replay_pass`；replay 失败不得标记 closed。
4. Evidence parity lane（强约束）
`evidence_parity_card.json` 必含 `lineage_id, head_sha, digest_set_id, digest_verification_pass`；parity 失败直接阻断。
5. Recall continuity lane（强约束）
`recall_continuity_card.json` 必含 `query_id, shard_epoch, actual_hit_ratio, rollback_checkpoint_digest`；命中率不足触发 freeze。

## Minimal Evidence Bundle
- `primary_verdict_card.json`
- `remediation_bridge_card.json`
- `boundary_replay_card.json`
- `evidence_parity_card.json`
- `recall_continuity_card.json`
- `meta_problem_ledger.json`
- `delta_packet.json`
- `history_pointer_map.json`
- `observation_ledger.json`
- `contract_gate_receipt.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 即可回答主裁决、阻断通道与立即动作。
- `Fidelity`: lease/heartbeat、requirement-assertion、artifact lineage digest、recall/rollback 边界保持完整且不互相覆盖。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `closed`。

## Anti-Patterns
- 把 remediation 说明写进主裁决字段。
- 用 observation 指标替代 gate 布尔裁决。
- 历史背景全量重写，不输出本轮 delta。
- secondary lane 解释反向改写 primary verdict。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
