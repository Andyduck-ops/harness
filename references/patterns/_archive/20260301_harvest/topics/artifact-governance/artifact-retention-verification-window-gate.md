---
name: artifact-retention-verification-window-gate
topic: artifact-governance
confidence: 0.78
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:06:46Z)
  - Hacker News news snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "The Relationship Crisis Facing Gen Z")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Briefly, explain and understand codebases with AI")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "The Making of MinCaml Compiler Series")
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: Store and share data with workflow artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - GitHub Docs: Use artifact attestations (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)
  - GitHub Docs: Verify attestations offline (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline)
merge_upgrade_of:
  - references/patterns/artifact-governance/artifact-digest-mismatch-escalation-gate.md
  - references/patterns/evidence-governance/attested-evidence-provenance-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间无人流程常见的隐藏失败不是“没有 attestation”，而是：
**到次日需要复验时，artifact 已过保留期，导致证明链可引用但不可重验。**

这会制造一种伪稳定状态：流水线当下通过、后续审计失真，最终让自动晋级缺少可持续证据。

## 核心解法

建立 **Artifact Retention Verification Window Gate（ARVW-G）**，把“构建时可验签”升级为“晋级窗口内持续可验签”：

1. **双窗口绑定**
   - 定义 `artifact_retention_window` 与 `attestation_verification_window`。
   - 强制 `retention_window >= verification_window + replay_buffer`。
2. **分支分层保留策略**
   - `main/release/hotfix` 使用不同 retention 阈值，并在规则文件显式声明。
   - 禁止所有分支使用统一短 retention。
3. **根信任新鲜度闸门**
   - 离线验签除 `bundle` 外必须记录 `trusted_root_fetched_at`。
   - 超过新鲜度阈值则要求重新拉取 trusted root 后再验签。
4. **晋级前对账**
   - 在 promotion 前生成 `retention_attestation_reconcile.json`。
   - 仅当 `artifact_present && attestation_verify_pass && root_fresh_pass` 才允许晋级。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `retention_policy.json` | `branch_tier`, `retention_days`, `replay_buffer_hours` | 缺字段即失败 |
| `attestation_verify_report.json` | `subject_digest`, `verified`, `trusted_root_fetched_at` | `verified=false` 即阻断 |
| `retention_attestation_reconcile.json` | `artifact_present`, `retention_window_pass`, `root_fresh_pass` | 任一 false 即 hold |
| `promotion_decision.json` | `required_checks`, `reconcile_pass`, `decision` | 非全绿不得晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 继续稳定重定向到 OPML Gist，适合作为外部输入锚点，但本身不提供可持续验签窗口。
- HN `news/show/newest` 在同日呈现不同节奏，说明夜间发现与次日复验天然存在时差，必须把“可验签时段”显式预算化。
- HN API 明确 `topstories/showstories/newstories` 为独立车道，进一步强化了“采样时刻与复验时刻分离”的工程现实。
- GitHub artifacts 文档提供 retention 配置能力，验证窗口必须与保留期联动，否则复验可能落空。
- GitHub artifact attestations 与离线验签文档提供可机审证明路径，但仍依赖 artifacts 与 trusted root 的时效管理。

## 反模式

- 只校验构建当下可验签，不约束次日复验窗口。
- 所有分支共用短 retention，导致 release/hotfix 证据先于审批过期。
- 离线验签不记录 trusted root 拉取时间，长期复用旧根信任。
- promotion 不做保留期-验签对账，出现“流程全绿但证据不可重验”。
