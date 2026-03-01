---
name: merge-queue-failure-surface-budget
topic: pipeline-governance
confidence: 0.79
verified_count: 10
sources:
  - queue-governance cluster (cycles 60-87)
  - capacity-governance cluster (cycles 50-80)
  - GitHub merge queue docs
last_verified: 2026-03-01
rank: 3
---

## 元问题

Merge Queue 不是单点故障，而是“重排、回放、并发、吞吐”耦合系统。
单个门禁无法覆盖系统性风险。

## 核心解法

采用 failure-surface budget：
- 把 queue 重排失效、pending 僵局、重试黑洞、吞吐丢失统一计入预算；
- 超预算时自动降级并进入恢复窗口；
- 恢复后必须重建证据纪元，禁止复用旧绿灯。

## 合并来源

- queue-reorder-evidence-epoch / rerun-blackhole / pending-deadlock taxonomy
- queue-build-concurrency / reviewer throughput / approval shock absorber
