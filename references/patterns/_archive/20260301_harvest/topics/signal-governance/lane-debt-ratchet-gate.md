---
name: lane-debt-ratchet-gate
topic: signal-governance
confidence: 0.78
verified_count: 9
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
  - references/patterns/signal-governance/exploit-explore-evidence-router.md
  - references/patterns/source-governance/triangulated-evidence-ratification-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

即使已经有 exploit/explore 双车道，夜间自治仍会在高波动窗口失控：
- HN `show/new` 突发增量时，固定配额会把新信号压成积压债务；
- HN `top` 稳态期仍持续吃配额，导致真正需要仲裁的 claim 没有 ratification 预算；
- 次日接管只能看到“抓了哪些链接”，看不到“哪条车道欠了多少证据债”。

本质问题是：**信号路由有配额，但没有“证据债务账本 + 动态棘轮”**。

## 核心解法

建立 **Lane Debt Ratchet Gate（LDRG）**，把车道治理从“固定配额”升级为“债务驱动配额”：

1. **三车道分工**
   - `anchor lane`：OPML + HN top，负责稳定增量。
   - `discovery lane`：HN show/new，负责早期新信号。
   - `ratification lane`：官方文档映射与晋级裁决。
2. **债务账本**
   - 每车道记录 `due_items`, `oldest_age_hours`, `carry_over_debt`。
   - 任一车道债务超阈值时，下一 cycle 自动提高该车道预算。
3. **动态棘轮**
   - 使用 `debt_ratio` 触发配额变更，不靠人工拍脑袋调参。
   - ratification lane 设最低保底配额，防止“只发现不裁决”。
4. **晋级联动**
   - 候选 claim 只有在 ratification lane 判定 `consistency=pass` 后，才允许进入 Issue/PR。
5. **可审计落盘**
   - 每轮输出 `lane_ledger`、`ratchet_decision`、`promotion_decision` 三件套并归档 artifact。

## 最小执行协议

| 组件 | 必填字段 | 通过条件 |
|------|----------|----------|
| `lane_ledger.json` | `cycle`, `lane`, `due_items`, `oldest_age_hours`, `carry_over_debt` | 三车道债务可追踪 |
| `ratchet_decision.json` | `from_quota`, `to_quota`, `trigger_lane`, `debt_ratio`, `reason` | 配额调整有依据 |
| `ratification_matrix.json` | `claim_id`, `official_doc_url`, `mapping_rule`, `consistency` | consistency=pass 才可晋级 |
| `promotion_decision.json` | `claim_id`, `decision`, `blocked_reason`, `required_checks` | block/pass 均可审计 |

## 证据链

- `https://t.co/dwAiIjlXet` 指向 HN Popular Blogs OPML，可长期提供稳定作者池信号。
- HN `news` 页面在同一时段出现高分热点（例如 326 分量级），而 `show/newest` 同时存在大量低分早信号，说明车道必须分工且要动态配额。
- HN API 提供 `topstories/showstories/newstories` 与 item 主键，适合构建可回放债务账本。
- GitHub Issue Forms 的 required 字段可把“元问题/证据链/反模式”做成晋级硬门。
- GitHub protected branches + required checks 可确保 ratification 未通过时无法绕过合并。
- GitHub Actions artifacts 可持久化账本与决策，支撑次日审计。

## 反模式

- 固定 exploit/explore 配额长期不调，导致某车道债务持续累积。
- 只统计发现数量，不统计 `oldest_age_hours`，最后演化成隐性积压。
- ratification lane 无保底预算，形成“发现很多、晋级很少”的假繁荣。
- 只落盘链接列表，不落盘配额变更依据与 blocked_reason。
