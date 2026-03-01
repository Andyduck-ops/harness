---
name: multi-lane-discovery-arbitration
topic: discovery-governance
confidence: 0.78
verified_count: 9
sources:
  - discovery-governance cluster (cycles 65-87)
  - feed-governance cluster (cycles 40-80)
  - HN top/show/newest snapshots
last_verified: 2026-03-01
rank: 3
---

## 元问题

HN top/show/newest 与 OPML 长信号的时间尺度不同，直接拼接会导致误判。

## 核心解法

构建 multi-lane arbitration：
- top 作为热度锚点；
- show/newest 作为新颖性探针；
- OPML 作为稳定基座；
- 三车道冲突时走仲裁合同而非直接晋级。

## 合并来源

- show-top resonance cooldown
- shownew lag / maturity arbitration
- hn lane identity parity / window skew budget
