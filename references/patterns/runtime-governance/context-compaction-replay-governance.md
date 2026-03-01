---
name: context-compaction-replay-governance
topic: runtime-governance
confidence: 0.78
verified_count: 8
sources:
  - context-governance cluster (cycles 45-80)
  - comprehension-governance cluster (cycles 45-80)
  - OpenAI context-window practices
last_verified: 2026-03-01
rank: 3
---

## 元问题

上下文压缩后如果没有回放合同，Agent 会“看起来继续跑，实际丢关键语义”。

## 核心解法

压缩必须绑定 replay continuity：
1. compaction 前后关键状态校验；
2. 理解债务超阈值触发 freeze；
3. 恢复时必须重放最小证据集。

## 合并来源

- compaction recovery contract
- context burn replay-freeze
- comprehension budget / debt ratchet freeze
