---
name: artifact-retention-reconciliation-governance
topic: evidence-governance
evidence_band: medium
verified_count: 11
sources:
  - artifact-governance cluster (cycles 50-85)
  - backlog-governance cluster (cycles 60-85)
  - recovery-governance cluster (cycles 60-85)
  - required-checks-snapshot-closure-gate (cycle 127 cross-check)
  - prd-epic-contract-replay-closure-gate (cycle 127 cross-check)
  - contract-replay-verification-gate (cycle 127 cross-check)
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

## Cycle 127 同化增量（Artifact Lineage Digest Lock）

### 空白判定

现状已经有：
- required checks 是否通过；
- PRD→Issue→PR 血缘字段是否完整；
- contract replay 是否通过。

但仍缺少一个阻断层：**这些证据工件是否来自同一条变更链且未被替换**。

### 核心补丁

引入 `Artifact Lineage Digest Lock Gate (ALDLG)`，把关键工件绑定到同一组 `lineage_id + head_sha + digest_set_id`：

- `artifact_lineage_manifest.json`
  - `lineage_id`, `issue_id`, `pr_number`, `head_sha`, `contract_epoch`, `digest_set_id`, `generated_at_utc`
- `artifact_digest_set.json`
  - `digest_set_id`, `head_sha`, `artifacts[]`
  - `artifacts[]` 每项：`artifact_name`, `sha256`, `bytes`, `producer_check`, `produced_at_utc`
- `artifact_promotion_attestation.json`
  - `lineage_id`, `head_sha`, `digest_set_id`, `digest_verification_pass`, `freshness_pass`, `decision`, `attested_by`, `attested_at_utc`

### 阻断门禁

`artifact_lineage_lock_pass=true` 必须同时满足：
1. 必需 artifact 全部存在且可解析；
2. digest set 中每个 `sha256` 与实际文件一致；
3. 全部 artifact 的 `head_sha` 与当前 PR HEAD 一致；
4. 全部 artifact 的 `lineage_id` 一致；
5. `produced_at_utc` 在有效窗口内（默认 24h）。

任一失败：阻断 `promote/merge`。

### 检索测试（L5）

- 查询：`cross artifact digest mismatch same lineage gate`
  - 命中：本 pattern
  - 动作：执行 `artifact_lineage_lock_pass`，阻断跨工件错链晋级
- 查询：`required_checks pass but artifact source not same head`
  - 命中：本 pattern + `required-checks-snapshot-closure-gate`
  - 动作：执行 `head_sha parity` 校验
- 查询：`contract replay report from stale run accepted`
  - 命中：本 pattern + `prd-epic-contract-replay-closure-gate`
  - 动作：执行 `freshness window + digest_set attestation`

## 合并来源

- artifact retention verification window
- artifact digest mismatch escalation
- candidate to issue promotion contract
- workspace recovery envelope
- artifact lineage digest lock gate (cycle 127 assimilation)
