---
name: control-plane-conflict-governance
topic: runtime-governance
confidence: 0.77
verified_count: 7
sources:
  - control-plane-governance cluster (cycles 70-87)
  - ci-governance cluster (cycles 70-87)
last_verified: 2026-03-01
rank: 3
---

## 元问题

冲突治理常见失败是：入口不完整、仲裁无时限、恢复后重复进入僵局。

## 核心解法

把冲突治理做成控制面合同：
- 冲突入口结构化必填；
- 冲突账本冻结 + SLA tombstone；
- 仲裁后走双相复验（reverify + reapprove）。

## 合并来源

- conflict intake required form
- contradiction ledger freeze / SLA tombstone
- conflict arbitration dual-phase contract
- required-check pending deadlock
