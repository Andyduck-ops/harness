---
name: shownew-top-lag-reverify-gate
topic: discovery-governance
confidence: 0.81
verified_count: 5
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML raw (redirect checked 2026-02-28)
  - HN top lane sample item 47200342 from https://news.ycombinator.com/news (checked 2026-02-28T23:43Z)
  - HN show lane sample item 47195123 from https://news.ycombinator.com/show (checked 2026-02-28T23:43Z)
  - HN newest/shownew sample item 47200770 from https://news.ycombinator.com/shownew (checked 2026-02-28T23:44Z)
  - HN API docs: topstories/showstories/newstories are independent feeds (https://github.com/HackerNews/API, checked 2026-02-28)
  - GitHub Docs: managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: merge_group workflow trigger (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: required status checks on protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-02-28
rank: 3
---

## 元问题

`shownew/newest` 给的是“最先出现”，`top/news` 给的是“更广传播”。

问题在于团队经常把这两者串成“自动晋级”，导致还没完成复采样和可执行证明就进入 `candidate -> issue`，把热度误当成熟度。

## 核心解法

建立 **Shownew-Top Lag Reverify Gate（STLRG）**，把跨车道晋级改成硬门禁：

1. `first_seen_anchor`
   - 锚定 `shownew/newest` 首现时刻 `t_first_seen`。
2. `lag_budget_hold`
   - 设 `lag_minutes >= threshold`（例如 180 分钟），不足则禁止晋级。
3. `top_lane_reverify`
   - 到预算窗口后复采样 `top/show/newest`，验证条目仍存活且跨车道信号一致。
4. `promotion_contract`
   - 仅当 `lag_budget_pass + reverify_pass + required_checks_pass` 全通过才允许 promotion。

## 最小执行协议

| Artifact | 必填字段 | Gate |
|---|---|---|
| `artifacts/shownew_first_seen_anchor.json` | `item_id`, `t_first_seen`, `lane`, `captured_at`, `digest` | 没有首现锚点不得进入时滞预算 |
| `artifacts/shownew_top_lag_budget.json` | `item_id`, `lag_minutes`, `threshold_minutes`, `lag_budget_pass`, `reason` | `lag_budget_pass=false` 直接阻断 |
| `artifacts/shownew_top_reverify.json` | `item_id`, `rechecked_at`, `seen_in_top`, `seen_in_show`, `seen_in_newest`, `liveness_pass`, `digest` | 无复采样证据不得晋级 |
| `artifacts/shownew_top_promotion_contract.json` | `item_id`, `required_checks`, `decision`, `blocked_reason`, `evidence_refs` | required checks 不全不得 promotion |

建议 required checks：

- `shownew_first_seen_anchor_pass`
- `shownew_top_lag_budget_pass`
- `shownew_top_reverify_pass`
- `shownew_top_promotion_contract_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 仍可重定向到 HN Popular Blogs OPML，说明它适合作为发现入口但不提供执行担保。
2. 同窗采样中，`top`（item `47200342`）、`show`（item `47195123`）、`shownew`（item `47200770`）出现在不同分发车道，证明“首现”与“扩散”是不同状态。
3. HN API 文档将 `topstories/showstories/newstories` 拆为独立端点，支持“跨车道需再验证”的工程模型。
4. GitHub merge queue 与 `merge_group` 文档共同约束“排队合并必须跑完整检查”，不能用早期热度替代 checks。
5. protected branches 的 required status checks 为该门禁提供了可执行落点。

## 反模式

- `shownew` 抓到就直接建 issue，不设 lag budget。
- 只采样一次，不做窗口后复采样。
- 将“进入 top”误判为“可执行已验证”。
- required checks 写在文档里但未接分支保护。
- lag budget 失败后仍人工强推晋级。

