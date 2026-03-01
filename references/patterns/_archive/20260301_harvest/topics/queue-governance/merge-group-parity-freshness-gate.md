---
name: merge-group-parity-freshness-gate
topic: queue-governance
confidence: 0.78
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:35:58Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Japan's Buddhist temples turn to AI chatbots amid monk shortage")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Open-Source Note Taking App with Spatial Keyboard Navigation")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "I made a stupidly simple app to stop my household from losing things")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules#troubleshooting-required-status-checks)
merge_upgrade_of:
  - references/patterns/evidence-governance/tombstone-replay-promotion-gate.md
  - references/patterns/product-delivery/merge-fence-required-checks-lineage.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间自治流水线里，PR 上通过的 required checks，进入 merge queue 后并不天然等价为“可合并”：

- queue 会构造新的 `merge_group` 上下文；
- 若工作流未监听 `merge_group`，校验会被跳过或失配；
- 状态检查还存在时效窗口，排队等待会让“之前通过”变成“现在过期”。

本质是：**“PR 通过”与“队列出队可合并”不是同一判定面，但很多系统把它们当作同一个绿灯。**

## 核心解法

建立 **Merge-Group Parity Freshness Gate（MGPFG）**，把“入队前通过”升级为“出队前同构且新鲜”：

1. 触发面同构
   - 所有晋级关键工作流必须同时监听 `pull_request` 与 `merge_group`。
   - 分支保护只认固定 check 名，禁止事件分裂后改名。
2. 双时点时效门禁
   - `queue_entry_fresh_pass`：入队前完成证据回放与校验。
   - `queue_exit_fresh_pass`：出队前在 merge_group 上重跑关键校验。
3. 排队时滞预算
   - 记录 `queued_at_utc`、`dequeue_started_at_utc`、`queue_wait_minutes`。
   - 超预算直接标记 `stale_in_queue`，禁止自动晋级。
4. 证据复验串联
   - merge_group 阶段必须复验 `promotion_replay_pass`（含 tombstone/可检索/时效）。
   - 任一失败进入 quarantine，不允许“旧绿灯继承”。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_parity_gate.json` | `pr_checks_pass`, `merge_group_checks_pass`, `check_name_set_equal` | 任一为 false |
| `queue_freshness_budget.json` | `queued_at_utc`, `dequeue_started_at_utc`, `queue_wait_minutes`, `max_wait_minutes` | `queue_wait_minutes > max_wait_minutes` |
| `merge_group_replay_report.json` | `claim_id`, `promotion_replay_pass`, `tombstone_freeze_pass`, `retrievable_pass` | 任一 gate fail |
| `promotion_decision.json` | `queue_entry_fresh_pass`, `queue_exit_fresh_pass`, `required_checks`, `decision` | 非双绿仍晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 仍重定向到 OPML 入口，说明夜间外部信号入口可持续演化，队列等待期间需要重检而非继承旧结论。
- HN `top/show/newest` 同时段头条不同，体现高时变输入；排队等待会放大“采样时正确、合并时失效”的窗口风险。
- GitHub merge queue 文档明确队列在合并前做合成验证，意味着需要单独的合并上下文校验面。
- GitHub Actions 事件文档明确 `merge_group` 是独立触发事件；如果 workflow 不监听，会直接丢失队列阶段验证。
- GitHub 规则文档要求 required checks 成功且超过 7 天需重新通过，支持把“出队前重检”设置为硬门禁。

## 反模式

- 只在 `pull_request` 事件跑验证，忽略 `merge_group`。
- 把 PR 阶段的绿灯直接继承到队列出队决策。
- required checks 名称在不同事件下不一致，导致分支保护无法稳定判定。
- 排队时长不入账，导致“证据过期晋级”无法追责。
