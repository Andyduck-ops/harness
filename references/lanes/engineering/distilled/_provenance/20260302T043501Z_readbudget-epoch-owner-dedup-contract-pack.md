# Provenance — readbudget-epoch-owner-dedup-contract-pack

timestamp_utc: 2026-03-02T04:35:01Z
lane: engineering
mode: dual-store
fragment: `references/lanes/engineering/distilled/contracts/readbudget-epoch-owner-dedup-contract-pack.md`

## Source Mapping (Evidence Layer Only)

- source: `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - extracted_signals: lease/heartbeat 新鲜度与 stale-run 阻断
  - mapped_to: `owner_single_writer_pass`, `recall_rollback_integrity_pass`

- source: `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - extracted_signals: requirement 到 assertion 的语义映射与 conformance 阈值
  - mapped_to: `semantic_bind_parity_pass`, `requirement_assertion_bind.json`

- source: `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - extracted_signals: lineage/head/digest 对账锁
  - mapped_to: `evidence_fingerprint_dedup_pass`, `artifact_digest_set.json`

- source: `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - extracted_signals: prod-like 场景闭环与 replay 可重现
  - mapped_to: `epoch_brief_self_contained_pass`, `prodlike_e2e_manifest.json`

- source: `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - extracted_signals: recall 命中率、rollback 连续性与漂移冻结
  - mapped_to: `recall_rollback_integrity_pass`, `recall_rollback_gate.json`

## Distillation Notes
- patterns 证据层未主改，仅抽取可执行字段合同与阻断门禁。
- 本轮压缩骨架：`epoch_brief + owner_lease + fingerprint_dedup + semantic_bind + rollback_freeze`。

## Fidelity Notes
- 保留边界条件：single owner 写入、digest parity、conformance 阈值、recall/rollback 连续性。
- 保留反模式：多 owner 复写、正文抄证据、映射缺失仍晋级、低命中继续发布。
- 保留证据映射：5/5 pattern 均映射到 hard gate 或最小证据工件。
