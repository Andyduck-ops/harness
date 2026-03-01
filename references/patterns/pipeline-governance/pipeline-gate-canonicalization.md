---
name: pipeline-gate-canonicalization
topic: pipeline-governance
confidence: 0.80
verified_count: 12
sources:
  - queue-governance cluster (cycles 60-87)
  - release-governance cluster (cycles 50-87)
  - ci-governance cluster (cycles 70-87)
  - GitHub protected branches / required checks docs
last_verified: 2026-03-01
rank: 2
---

## 元问题

夜间自动化链路里，失败往往不是“没有检查”，而是检查集合与触发面不一致：
同名检查在 PR / merge_group / ruleset 的语义不一致，导致假绿灯。

## 核心解法

把 CI、Release、Queue 的门禁统一成一份 canonical gate profile：
1. required checks 名称、来源、事件面三元同一；
2. merge_group 与 PR 事件必须同时采样；
3. 规则漂移（新增/删除/改名）必须触发强制复验。

## 合并来源

- merge-group parity / required-check snapshot / expected-source pinning
- approval freshness / bypass registry / ruleset drift
- queue reorder / rerun blackhole / pending deadlock

## 反模式

- 只看 check 名称，不看来源与事件面
- 把 queue 与 release 分开治理，缺少闭环
