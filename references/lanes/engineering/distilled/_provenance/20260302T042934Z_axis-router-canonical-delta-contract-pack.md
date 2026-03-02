# Provenance — axis-router-canonical-delta-contract-pack

timestamp_utc: 2026-03-02T04:29:34Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/axis-router-canonical-delta-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat/backpressure 的运行态新鲜度与冻结条件
  - mapped_to: `single_axis_query_pass`, `freeze_on_axis_drift_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement/assertion 语义闭环与 conformance 阈值
  - mapped_to: `gate_scoped_readset_pass`, `semantic_conformance_report`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 对账锁
  - mapped_to: `pointer_lineage_parity_pass`, `artifact_digest_set`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: prod-like replay 与运行时边界闭环
  - mapped_to: `canonical_delta_only_pass`, `prodlike_e2e_manifest`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall 命中率与 rollback 连续性门禁
  - mapped_to: `freeze_on_axis_drift_pass`, `recall_manifest`

## Distillation Notes
- patterns 证据层未主改，仅抽取可执行门禁和字段合同。
- 本轮压缩骨架：`axis_lock + gate_scoped_readset + delta_ledger + pointer_publish + drift_freeze`。

## Fidelity Notes
- 保留边界条件：单轴路由、读集上限、lineage parity、recall/freshness 阈值。
- 保留反模式：跨轴混写、跨层复写正文、超预算扩读。
- 保留证据映射：5/5 pattern 均映射到字段合同与硬门禁。
