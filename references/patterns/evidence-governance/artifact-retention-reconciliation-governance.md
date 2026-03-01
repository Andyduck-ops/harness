---
name: artifact-retention-reconciliation-governance
topic: evidence-governance
confidence: 0.78
verified_count: 8
sources:
  - artifact-governance cluster (cycles 50-85)
  - backlog-governance cluster (cycles 60-85)
  - recovery-governance cluster (cycles 60-85)
last_verified: 2026-03-01
rank: 3
---

## 元问题

工件、候选项、恢复动作分散在不同轨道，导致“做过但对不上账”。

## 核心解法

做 retention-attestation reconciliation ledger：
- 工件保留策略分层；
- 候选晋级与工件清单绑定；
- 恢复动作写回同一对账账本。

## 合并来源

- artifact retention verification window
- artifact digest mismatch escalation
- candidate to issue promotion contract
- workspace recovery envelope
