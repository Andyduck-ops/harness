# Provenance: gate-intent-trace-delta-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/gate-intent-trace-delta-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: observe/diagnose 阶段必须受 lease/heartbeat/backpressure 新鲜度约束
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: decide 阶段发布必须通过 requirement->assertion conformance
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 四阶段沿用同一 lineage/head_sha/digest_set 锚点
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: decide/recover 前要求 prod-like replay 可重放
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recover 阶段必须携带 recall/rollback continuity 证明

## Compression Decisions
- removed_repetition:
  - 删除同一 incident 在四阶段重复回放全量 narrative
  - 删除单阶段内事实/推理/裁决/恢复动作混写
- preserved_boundaries:
  - phase intent 单卡约束（observe/diagnose/decide/recover）
  - 阶段跃迁仅通过 `intent_delta_pointer`
  - 闭环失败即冻结 decide/recover 发布

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
