# Cross-Lane Links

> 跨 lane 只保留摘要级桥接，不直接互写对方 patterns。

## Format

- source_lane:
- target_lane:
- topic:
- summary:
- evidence:
- created_at:

## Entries

- source_lane: engineering
- target_lane: shared (product-delivery / runtime-governance / autonomous-ops)
- topic: artifact-lineage-digest-lock
- summary: 工程 lane 在 cycle 127 新增“跨工件同源 digest 锁”门禁，补齐 required checks 与 replay 报告之间的同源性阻断层，可复用于其他 lane 的交付验收链路。
- evidence: references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md
- created_at: 2026-03-01

- source_lane: engineering
- target_lane: shared (runtime-governance / autonomous-ops / product-delivery / fullstack-engineering)
- topic: p0-gap-closure-four-gates
- summary: 工程 lane 在 cycle 128 一次性补齐 4 个 P0 空白：long-context 索引回滚合同、background runplane 编排合同、requirement→assertion 语义符合性门禁、AI 代码 prod-like E2E 闭环门禁；可作为跨 lane 的晋级总闸基础件。
- evidence: references/lanes/engineering/patterns/_master_index.md
- created_at: 2026-03-01

- source_lane: engineering
- target_lane: shared (release-gates / evidence-governance / runtime-governance)
- topic: cross-gate-decision-snapshot-lock
- summary: cycle 129 在 evidence-governance 同化 CGDSL，总结为“同一 lineage/head/epoch 的跨门禁快照锁”，阻断不同时间或不同 HEAD 证据被拼接晋级。
- evidence: references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md
- created_at: 2026-03-01

- source_lane: engineering
- target_lane: shared (runtime-governance / product-delivery / fullstack-engineering / evidence-governance)
- topic: threshold-registry-gate-runner-binding-contract
- summary: cycle 134 将“阈值注册表与 gate runner 强绑定”同化到四个 topic：门禁阈值必须来自统一 registry，执行结果必须携带 registry_sha + runner_id + head_sha，同步进入决策快照对账。
- evidence: references/lanes/engineering/patterns/runtime-governance/map-integrity-filegraph-attestation-gate.md
- created_at: 2026-03-02

- source_lane: engineering
- target_lane: shared (evidence-governance / autonomous-ops / fullstack-engineering)
- topic: evidence-high-promotion-cross-runner-round1
- summary: cycle 136 将 evidence 升档条件从“合同定义”推进到“cross-runner round-1 可审计复现实绩”，并补齐 attestation/head_sha/decision_epoch 与 shadow/holdout 连续窗口字段，供其他 lane 复用为升档前置闸。
- evidence: references/lanes/engineering/patterns/evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md
- created_at: 2026-03-02

- source_lane: engineering
- target_lane: shared (evidence-governance / release-gates / runtime-governance)
- topic: round2-execution-evidence-hardening
- summary: cycle 140 将 round-2 升档门槛从“矩阵字段存在”推进到“执行证据可审计”：要求同 SHA rerun 身份、BASE...HEAD 偏差审计、attestation 离线验签三者同时成立，才允许进入 evidence uplift 判定。
- evidence: references/lanes/engineering/patterns/evidence-governance/sources-distilled-ingestion-lineage-freshness-governance.md
- created_at: 2026-03-02
