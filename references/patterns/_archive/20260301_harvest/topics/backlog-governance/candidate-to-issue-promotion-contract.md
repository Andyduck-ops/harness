---
name: candidate-to-issue-promotion-contract
topic: backlog-governance
confidence: 0.74
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28)
  - GitHub Docs: About Projects (https://docs.github.com/en/issues/planning-and-tracking-with-projects/learning-about-projects/about-projects)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-cloud@latest/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
merge_upgrade_of:
  - references/patterns/signal-governance/exploit-explore-evidence-router.md
  - references/patterns/product-delivery/proof-bundle-issue-form-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间探索车道会持续发现新线索，但大多数团队把这些线索直接塞进 backlog，导致两个后果：
- Issue 池快速污染，无法区分“可执行任务”与“未验证灵感”。
- 次日接管时只能看链接和标题，缺少可审计的晋级依据。

本质问题是：**缺少从信号到 Issue 的结构化晋级合同**。

## 核心解法

建立 **Candidate-to-Issue Promotion Contract（CIPC）**，让“发现”先进入候选池，再晋级为执行任务：

1. **信号入池（Candidate）**
   - 输入强制来自 OPML + HN top/show/new。
   - 每条信号必须带 `source_url + novelty_note + meta_problem_guess`。
2. **表单晋级（Issue Form Gate）**
   - 只允许通过 Issue Form 创建执行任务。
   - 必填 `meta_problem`、`core_solution`、`evidence_chain`、`anti_patterns`。
3. **项目挂载（Project Intake）**
   - 晋级后的 Issue 自动进入 Projects，看板状态从 `candidate` 到 `promoted`。
4. **合并闸门（Promotion Fence）**
   - 分支 required checks 必须校验 `promotion_report`。
   - 未通过不得进入实现分支。
5. **证据留痕（Artifact）**
   - Workflow artifact 固化 `candidate_id -> issue_id -> pr_id -> pattern_id` 映射。

## 最小执行协议

| 组件 | 必填字段 | 通过条件 |
|------|----------|----------|
| `candidate_queue.json` | `candidate_id`, `source_url`, `meta_problem_guess`, `novelty_score` | 不允许缺字段入队 |
| `issue_form.yml` | `meta_problem`, `core_solution`, `evidence_chain`, `anti_patterns` | 四段全部必填 |
| `project_intake.csv` | `candidate_id`, `issue_id`, `stage`, `owner` | candidate/promoted 状态可追踪 |
| `promotion_report.json` | `checks_passed`, `artifact_ref`, `dedupe_result` | required checks 全绿 |

## 证据链

- `https://t.co/dwAiIjlXet` 指向 HN Popular Blogs OPML，提供稳定高信噪比信号池。
- HN `news/show/newest` 同时存在“趋势信号”和“新奇信号”，证明发现侧天然高吞吐且高噪声，需要晋级合同而非直接入库。
- GitHub Issue Form 语法支持 required 字段与结构化校验，适合作为发现到任务的硬门。
- GitHub Projects 提供单一项目视图与自动化流转，适合作为 candidate/promoted 阶段账本。
- GitHub protected branches 的 required checks 与 Actions artifacts 组合，可把“晋级是否有效”变为可审计事实。

## 反模式

- 把 HN/OPML 线索直接转成 Issue，不经过候选池。
- Issue 只保留链接，不写元问题与反模式。
- Project 看板只做展示，不维护 candidate/promoted 状态语义。
- 只看 PR 是否合并，不校验晋级证据 artifact。
