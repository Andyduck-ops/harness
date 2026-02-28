---
name: artifact-digest-mismatch-escalation-gate
topic: artifact-governance
confidence: 0.79
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T19:57:00Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, item 47196582)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, item 47195123)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, item 47199259)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: Generate artifact attestation for builds (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)
  - GitHub Docs: Verify attestations offline (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline)
  - GitHub Docs: Troubleshoot required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules)
  - GitHub Docs: Store and share data with workflow artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
merge_upgrade_of:
  - references/patterns/evidence-governance/attested-evidence-provenance-gate.md
  - references/patterns/product-delivery/issue-pr-artifact-lineage-manifest.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间无人推进里，最危险的“伪通过”不是测试失败，而是：
**required checks 全绿，但晋级包指纹与 attestation subject digest 不同**。

这通常发生在以下时序：

1. CI 先对 `artifact-A` 生成 attestation；
2. 后续步骤又重打包为 `artifact-B`（或下载重传）；
3. promotion 读取的是 `artifact-B`，但仍引用 `artifact-A` 的证明。

结果是可回放链路看起来完整，但“被晋级的到底是不是被证明的那个工件”无法机审回答。

## 核心解法

建立 **Artifact Digest Mismatch Escalation Gate（ADM-EG）**，把“有证明”升级为“证明对象同一且可追责”：

1. **单主体绑定（single subject binding）**
   - 每次晋级只能绑定一个 `subject_digest`（attestation）和一个 `artifact_digest`（promotion packet）。
   - 不允许 `N:1` 或 `1:N` 模糊关联。
2. **失配即隔离（mismatch -> quarantine）**
   - 定义 `digest_parity_pass = (subject_digest == artifact_digest)`。
   - 任一失配立即 `quarantine`，禁止 issue/PR 晋级，必须重新产出并验签。
3. **保留期-验签窗口协同**
   - 把 `artifact_retention_days` 与 `verification_window` 放进同一预算字段。
   - 过期工件不得参与“事后补验签”。
4. **并联硬门禁**
   - 仅当 `identity_parity_pass && digest_parity_pass && required_checks_pass` 才允许 promotion。
   - 把 `digest_parity_report` 上传 artifact，纳入次日审计回放。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `attestation_subject.json` | `subject_name`, `subject_digest`, `workflow_ref`, `run_id` | 缺字段即 `fail` |
| `promotion_packet.json` | `artifact_name`, `artifact_digest`, `lineage_id`, `commit_sha` | digest 缺失即 `fail` |
| `digest_parity_report.json` | `subject_digest`, `artifact_digest`, `digest_parity_pass`, `mismatch_reason` | `false` 即 `quarantine` |
| `promotion_decision.json` | `required_checks`, `identity_parity_pass`, `digest_parity_pass`, `decision` | 非全绿即 `hold` |

## 证据链

- `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML，适合作为长期信号入口，但不提供 artifact 同一性保障。
- HN `top/show/newest` 仍呈高频波动（示例 `47196582/47195123/47199259`），夜间流程必须确保“可追踪对象不漂移”。
- HN API 明确三车道列表是独立端点，说明采样与产物绑定必须结构化，不可隐式假设。
- GitHub artifact attestation 文档提供生成与验证链路，可把“谁证明了哪个 digest”落成机审事实。
- GitHub required checks/rules 文档支持把 `digest_parity_pass` 设为不可绕过门禁。
- GitHub artifacts 文档定义 retention 行为；因此 retention 与验签窗口必须同源配置，否则会出现“证据在、工件亡”或“工件在、证明失效”。

## 反模式

- 只验证 attestation 存在，不核对 subject 与晋级包 digest 同一性。
- 允许重打包后沿用旧 attestation。
- required checks 仅覆盖测试，不覆盖 `digest_parity_pass`。
- artifact 过期后再补验签，并继续晋级。
