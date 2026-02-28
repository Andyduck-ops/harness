---
name: shownew-promotion-latency-gate
topic: discovery-governance
confidence: 0.80
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML (redirect checked 2026-03-01)
  - HN top lane: https://news.ycombinator.com/news (checked 2026-03-01)
  - HN show lane: https://news.ycombinator.com/show (checked 2026-03-01)
  - HN newest lane: https://news.ycombinator.com/newest (checked 2026-03-01)
  - HN API docs: topstories/showstories/newstories semantics (https://github.com/HackerNews/API, checked 2026-03-01)
  - GitHub Docs: merge queue checks must pass (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: merge_group trigger for queued changes (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: required status checks on protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-03-01
rank: 3
---

## 元问题

`newest` 里的 Show 类条目是“最早出现”的信号，但不是“可执行成熟”的信号。

常见误判是：

- `newest` 首现后立即 candidate->issue；
- 把短时上升热度当作稳定价值；
- 未验证该条目在冷却后是否仍可复现/可晋级。

结果是夜间队列被“短命热度”污染，白天在 merge queue 或 required checks 阶段集中失败。

## 核心解法

建立 **Shownew Promotion Latency Gate（SPLG）**，把“首现”与“晋级”之间强制插入时滞预算：

1. `first_seen_capture`
   - 记录条目首次进入 `newest` 的时间戳 `t_newest_first_seen`。
2. `lag_budget_hold`
   - 设定最小时滞预算（例如 `lag_minutes >= 180`），预算不足禁止晋级。
3. `cross_lane_recheck`
   - 在预算窗口后复采样 `news/show/newest`，判断是否仍存活、是否出现跨车道稳定信号。
4. `promotion_contract`
   - 仅当 `lag_budget_pass + liveness_pass + recheck_pass` 全通过时才允许 candidate->issue。

## 最小执行协议

| Artifact | 必填字段 | Gate |
|---|---|---|
| `artifacts/shownew_first_seen.json` | `item_id`, `t_newest_first_seen`, `window_id`, `captured_at` | 没有首现锚点不得讨论时滞 |
| `artifacts/shownew_lag_budget.json` | `item_id`, `lag_minutes`, `threshold_minutes`, `lag_budget_pass`, `reason` | `lag_budget_pass=false` 阻断晋级 |
| `artifacts/shownew_cross_lane_recheck.json` | `item_id`, `rechecked_at`, `seen_in_news`, `seen_in_show`, `seen_in_newest`, `liveness_pass`, `digest` | 无复采样证据不得 promotion |
| `artifacts/shownew_promotion_decision.json` | `item_id`, `required_checks`, `decision`, `blocked_reason`, `evidence_refs` | required checks 不全不得入 issue |

建议 required checks：

- `shownew_first_seen_capture_pass`
- `shownew_lag_budget_pass`
- `shownew_cross_lane_recheck_pass`
- `shownew_promotion_contract_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 仍指向 HN Popular Blogs OPML，说明它适合作为“发现入口”，但不提供执行成熟度担保。
2. HN `news/show/newest` 同窗观察显示三车道职责不同：`newest` 偏首现，`show/news` 偏可见性扩散。
3. HN API 文档把三车道拆成独立 endpoint（`topstories/showstories/newstories`），支持“首现与晋级是两个阶段”的模型。
4. GitHub merge queue 与 `merge_group` 事件强调队列内仍需统一 checks，不能把早期热度直接映射为可合并状态。
5. Protected branches 的 required status checks 可将“时滞预算 + 复采样”转成硬门禁，避免人工主观放行。

## 反模式

- `newest` 首现后 30 分钟内直接建 issue。
- 只记录首次抓取，不做冷却后的二次采样。
- 将“进入 show/news”误当“可执行验证通过”。
- required checks 只在文档里描述，不接分支保护。
- 失败后继续沿用第一次快照，不刷新 evidence digest。
