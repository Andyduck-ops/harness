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
