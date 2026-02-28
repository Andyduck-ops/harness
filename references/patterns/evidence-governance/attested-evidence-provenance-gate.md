---
name: attested-evidence-provenance-gate
topic: evidence-governance
confidence: 0.76
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: About artifact attestations (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/about-artifact-attestations)
  - GitHub Docs: Establish provenance for builds (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds)
  - GitHub Docs: Verify attestations offline (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/verifying-attestations-offline)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/evidence-governance/temporal-evidence-freshness-gate.md
  - references/patterns/product-delivery/issue-pr-artifact-lineage-manifest.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间自治流程即使已经做了“时效闸门 + 回放信封”，仍然有一个未解决的断点：
次日可以重放证据，但无法证明“这份证据在采样后到合并前没有被篡改”。

本质问题是：**可回放不等于可验真，证据链缺少可机审的溯源签名层**。

## 核心解法

建立 **Attested Evidence Provenance Gate（AEPG）**，把“证据存在”升级为“证据可验签且可追责”：

1. **证据束标准化**
   - 每轮把 OPML/HN 采样归档为 `evidence_bundle.json`。
   - 固定字段：`sampled_at_utc`, `source_url`, `content_digest`, `collector_commit_sha`。
2. **构建溯源证明**
   - 在 CI 中对证据束生成 artifact attestation。
   - 证明里至少绑定 `subject_digest + workflow_identity + run_id`。
3. **离线验签闸门**
   - 合并前执行 `gh attestation verify` 或等价校验。
   - 校验失败直接阻断 candidate 晋级与主分支合并。
4. **血缘对齐**
   - 把 `candidate_id -> issue_id -> pr_id -> pattern_id` 与 attestation digest 绑定在同一 manifest。
   - 防止“证据包 A + 报告 B”交叉串线。

## 最小执行协议

| 组件 | 必填字段 | 通过条件 |
|------|----------|----------|
| `evidence_bundle.json` | `cycle`, `sampled_at_utc`, `source_url`, `content_digest` | 每条外部证据可重算摘要 |
| `attestation_ref.json` | `subject_digest`, `workflow_ref`, `run_id` | 可定位唯一溯源证明 |
| `verify_report.json` | `verified`, `verifier`, `policy_ref` | `verified=true` 才能晋级 |
| `promotion_report.json` | `freshness_passed`, `attestation_passed`, `required_checks` | 时效与验签双绿 |

## 证据链

- `https://t.co/dwAiIjlXet` 指向 HN Popular Blogs OPML，可做稳定来源，但仍需对采样结果验签，避免“同链接不同内容”导致审计漂移。
- HN `news/show/newest` 是高时变流，结合 HN API 的故事 ID/时间字段可形成稳定主键，但主键本身仍需签名链保护。
- GitHub artifact attestations 官方文档给出生成与验证路径，可把“谁在何时产出了哪份证据摘要”变成机审事实。
- GitHub protected branches 的 required checks 可把 attestation verify 变成不可绕过的合并硬门。

## 反模式

- 有快照无验签：只能回放，不能证明未被替换。
- attestation 已生成但不做 verify：把“证明文件”当“证明过程”。
- digest 不进 lineage manifest：导致 issue/pr/pattern 与证据指纹脱钩。
- 证据更新只改 JSON 不更新 attestation：形成“新证据 + 旧签名”的伪一致状态。
