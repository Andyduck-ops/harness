---
name: promotion-cooldown-latency-governance
topic: discovery-governance
confidence: 0.77
verified_count: 8
sources:
  - discovery-governance cluster (cycles 65-87)
  - signal-governance cluster (cycles 55-80)
  - source-governance cluster (cycles 55-80)
last_verified: 2026-03-01
rank: 3
---

## 元问题

发现到晋级之间缺少时滞控制时，系统会被短时噪声驱动。

## 核心解法

建立 promotion latency + cooldown 合同：
1. 最小观察窗口；
2. 复采样与复现证明；
3. 冷却后才允许晋级；
4. 证据不足则 tombstone 而非强推。

## 合并来源

- shownew promotion latency / lag reverify
- exploit-explore router / lane debt ratchet
- triangulated evidence ratification
