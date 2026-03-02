# Provenance — audience-lens-delta-brief-contract-pack

timestamp_utc: 2026-03-02T04:47:12Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/audience-lens-delta-brief-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat/backpressure 决定 operator 视角可执行性
  - mapped_to: `operator_lens_brief.json`, `lens_self_contained_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement/assertion 语义闭环必须独立于执行叙述
  - mapped_to: `product_lens_brief.json`, `lens_boundary_separation_pass`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 对账同源锁
  - mapped_to: `shared_evidence_nucleus.json`, `shared_evidence_parity_pass`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: prod-like replay 可重放是发布前置条件
  - mapped_to: `replay_recall_release_pass`, `prodlike_e2e_manifest.json`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall 命中率与 rollback continuity 的联合放行
  - mapped_to: `delta_brief_dedup_pass`, `recall_manifest.json`, `rollback_attestation.json`

## Distillation Notes
- patterns 证据层仅读取，不主改。
- 本轮将“同文多受众混写”压缩为 `lens_query -> three_lens_brief -> delta_brief_pointer`，减少跨角色重复叙述。

## Fidelity Notes
- 保留边界条件：lease freshness、semantic conformance、artifact digest parity、prod-like replay、recall/rollback continuity。
- 保留反模式：三镜混写、证据多套并存、同窗口重复全量改写、回放未闭环先发布。
- 保留证据映射：5/5 pattern 均映射到硬门禁或最小证据工件。
