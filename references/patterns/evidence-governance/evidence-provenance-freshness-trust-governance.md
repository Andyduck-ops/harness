---
name: evidence-provenance-freshness-trust-governance
topic: evidence-governance
confidence: 0.79
verified_count: 9
sources:
  - evidence-governance cluster (cycles 55-87)
  - trust-governance cluster (cycles 60-85)
  - source-governance cluster (cycles 50-80)
last_verified: 2026-03-01
rank: 3
---

## 元问题

证据链失效通常不是“没有证据”，而是来源、时效、信任根三者不一致。

## 核心解法

建立 provenance + freshness + trust-root 三元门禁：
1. 证据可追溯来源；
2. 证据有时效预算；
3. trust root 过期触发隔离与重签。

## 合并来源

- temporal evidence freshness
- attested evidence provenance
- trusted root freshness quarantine
- triangulated evidence ratification
