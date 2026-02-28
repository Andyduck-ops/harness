---
name: triangulated-evidence-ratification-gate
topic: source-governance
confidence: 0.74
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
merge_upgrade_of:
  - references/patterns/autonomous-ops/opml-hn-priority-watchlist.md
  - references/patterns/backlog-governance/candidate-to-issue-promotion-contract.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间探索里，OPML/HN 信号是高吞吐输入，但它们本身只能回答“有人在讨论什么”，不能直接回答“这条结论能不能晋级为执行任务”。

如果没有统一的信源仲裁层，团队会在两种错误之间来回摆动：
- 只看 HN 热度，导致高噪声观点直接进入执行池；
- 只信 OPML 长文，导致新变化滞后，错过高价值窗口。

本质问题是：**缺少把社区信号与官方规范对齐的三角校验闸门**。

## 核心解法

建立 **Triangulated Evidence Ratification Gate（TERG）**，把“发现”升级为“可晋级证据”：

1. **信号拆层**
   - OPML + HN 仅生成 `claim`，默认是“待证实”而不是“可执行”。
2. **官方锚定**
   - 每条 claim 必须至少绑定 1 条官方文档证据（GitHub/OpenAI/规范文档）。
   - 无官方锚点只能留在 candidate，不得晋级 Issue/PR。
3. **三角一致性判定**
   - 需要同时给出：`社区信号`、`官方依据`、`执行映射`（落到具体 gate/check）。
   - 三角任一边缺失，promotion 直接 fail。
4. **结果落盘**
   - 输出结构化 `ratification_matrix` 和 `promotion_decision`，并上传 artifact，保证次日可复核。

## 最小执行协议

| 组件 | 必填字段 | 通过条件 |
|------|----------|----------|
| `signal_claims.json` | `claim_id`, `source_url`, `snapshot_time_utc`, `meta_problem` | OPML/HN 发现可追踪 |
| `ratification_matrix.json` | `claim_id`, `official_doc_url`, `mapping_rule`, `consistency` | `consistency=pass` 才可晋级 |
| `promotion_decision.json` | `claim_id`, `decision`, `blocked_reason`, `required_checks` | blocked 可解释、pass 可审计 |
| `ratification_artifact` | `cycle`, `commit_sha`, `digest` | 次日可回放与核验 |

## 证据链

- `https://t.co/dwAiIjlXet` 持续重定向到 HN Popular Blogs OPML，可作为稳定长周期作者池。
- HN `news/show/newest` 提供高时变实时信号，证明“热度”与“可执行性”不是同一维度，必须分层治理。
- HN API 提供稳定 ID 与时间字段，适合构建 claim 主键与回放索引。
- GitHub Issue Forms 支持 required 字段，能把“元问题/解法/证据链/反模式”前置为晋级硬门。
- GitHub protected branches + required checks 可把 ratification 判定变成不可绕过的合并门禁。
- GitHub Actions artifact 机制保证 ratification 矩阵可持久化和复核。

## 反模式

- 社区链接直接转 Issue，不做官方锚定。
- 只有“我认为可行”的结论，没有映射到 required checks。
- 只做口头评审，不落盘 `ratification_matrix`。
- 把“信息新颖”误当作“可直接执行”。
