# Provenance: first-screen-tri-signal-router-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/first-screen-tri-signal-router-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/backpressure 的运行态判定独立留在 runtime 通道，避免首屏混写。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义符合性保留 gate 通道，不被指标叙述替代。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/digest 对账保留 evidence 通道，避免与 commit blocker 串写。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 闭环保留独立证据束，不被首屏摘要压缩掉边界。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 连续性约束保留 runtime+evidence 双边界，防止恢复路径误裁决。

## Compression Decisions
- removed_repetition:
  - 删除跨轮重复背景全文，改为 `history_pointer` + 本轮 `delta_packet`。
  - 删除把指标解释与门禁结论混排的长段文本。
- preserved_boundaries:
  - 首屏只允许 `gate_verdict + blocker_channel + next_action`。
  - 指标仅观测（`observation_only=true`），不参与三门合同裁决。
  - 四通道 `gate/evidence/runtime/commit` 强制隔离。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
