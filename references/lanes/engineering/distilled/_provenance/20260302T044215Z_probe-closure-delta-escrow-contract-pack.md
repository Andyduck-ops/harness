# Provenance — probe-closure-delta-escrow-contract-pack

timestamp_utc: 2026-03-02T04:42:15Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/probe-closure-delta-escrow-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat/backpressure 决定连续性探测是否可放行
  - mapped_to: `liveness_probe_card.json`, `probe_self_contained_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement/assertion 强绑定与 conformance 阈值
  - mapped_to: `semantic_probe_card.json`, `tri_axis_probe_separation_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 同源锁与对账约束
  - mapped_to: `lineage_probe_card.json`, `delta_pointer_dedup_pass`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: prod-like replay 可重放是发布前置条件
  - mapped_to: `closure_escrow_release_pass`, `prodlike_e2e_manifest.json`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall 命中率 + rollback continuity 的联合放行条件
  - mapped_to: `replay_recall_lineage_pass`, `recall_manifest.json`, `rollback_attestation.json`

## Distillation Notes
- patterns 证据层仅读取，不主改。
- 本轮将“探测/闭环/发布”压缩为 `probe -> escrow -> delta pointer` 三段合同，降低读路径膨胀。

## Fidelity Notes
- 保留边界条件：lease freshness、semantic conformance、artifact digest parity、prod-like replay、recall/rollback continuity。
- 保留反模式：混写三轴、probe 未闭环直接发布、同窗口重复正文、低命中仍释放 escrow。
- 保留证据映射：5/5 pattern 均映射到硬门禁或最小证据工件。
