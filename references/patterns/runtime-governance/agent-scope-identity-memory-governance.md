---
name: agent-scope-identity-memory-governance
topic: runtime-governance
confidence: 0.79
verified_count: 9
sources:
  - permission-governance cluster (cycles 45-80)
  - identity-governance cluster (cycles 45-80)
  - state-governance cluster (cycles 45-80)
  - OpenAI background mode docs
last_verified: 2026-03-01
rank: 3
---

## 元问题

长时自治里最危险的不是报错，而是“权限、身份、记忆”悄然漂移。

## 核心解法

统一为 scope-identity-memory 三联门禁：
- scope drift 分级预算；
- identity lease 过期复验；
- memory partition 与 state replay 同步校验。

## 合并来源

- agent scope drift severity budget
- external identity lease replay
- agent state cell replay envelope
- agent memory partition least-privilege
