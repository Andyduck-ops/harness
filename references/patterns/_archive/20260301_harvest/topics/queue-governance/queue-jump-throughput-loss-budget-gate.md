---
name: queue-jump-throughput-loss-budget-gate
topic: queue-governance
confidence: 0.79
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28)
  - Hacker News news snapshot (2026-02-28): "MinIO Is Dead, Long Live MinIO" (https://news.ycombinator.com/news)
  - Hacker News show snapshot (2026-02-28): "Show HN: Now I Get It – Translate scientific papers into interactive webpages" (https://news.ycombinator.com/show)
  - Hacker News newest snapshot (2026-02-28): "Show HN: Free, open-source native macOS client for di.fm" (https://news.ycombinator.com/newest)
  - GitHub Docs: jump to top causes full rebuild of in-progress PRs and can slow merge velocity (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: required checks for merge queue must include merge_group trigger (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - HN API docs: top/new/show endpoints and item fields deleted/dead (https://github.com/HackerNews/API)
  - OPML 2.0 Spec: outline text required; rss outlines require type/text/xmlUrl (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/queue-governance/queue-reorder-rebuild-attestation-gate.md
  - references/patterns/queue-governance/queue-reorder-evidence-epoch-invalidation-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

merge queue 的 `jump to top` 既是应急手段，也是吞吐风险放大器：

- 官方文档明确：jump 会触发所有 in-progress PR 全量重建，并降低目标分支合并速度；
- 在夜间高噪声输入（HN news/show/newest 持续变动）下，团队会频繁尝试“抢位”；
- 如果没有 jump 成本预算，系统会把“紧急”当常态，形成重建风暴和队列抖动。

本质问题：**我们治理了“重建后要重验”，但没有治理“是否值得发起重建”。**

## 核心解法

建立 **Queue Jump Throughput-Loss Budget Gate（QJTLBG）**：

1. jump 成本可计量化
   - 定义 `rebuild_cost_units = in_progress_pr_count * avg_required_check_minutes`。
   - 每次 jump 必须记录 `expected_throughput_loss_minutes`。
2. 预算门禁前置
   - 设 `daily_jump_budget_units` 与 `hourly_jump_budget_units`。
   - 超预算默认拒绝 jump，除非进入显式应急路径（incident class + owner）。
3. 应急与常规双路径
   - `normal_path`: 必须满足预算内 + 证据完备。
   - `incident_path`: 允许超预算，但必须附 `incident_id`、`blast_radius`、`rollback_plan`。
4. 与 merge_group 绑定 required checks
   - `queue_jump_budget_pass`
   - `queue_rebuild_attested_pass`
   - `evidence_epoch_rebound_pass`
   - 未触发 `merge_group` 的重建一律视为不可审计。
5. 外部证据最小约束
   - HN item 必须通过 `deleted/dead` 复检；
   - OPML outline 必须通过 `text/type/xmlUrl` 契约校验；
   - 防止“为不稳定信号付出重建成本”。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_jump_budget.json` | `window_utc`, `daily_budget_units`, `hourly_budget_units`, `used_units`, `remaining_units` | 预算字段缺失或 remaining < 0 未触发隔离 |
| `jump_request_ticket.json` | `request_id`, `queue_epoch_id`, `reason`, `expected_throughput_loss_minutes`, `path_type` | jump 请求无成本评估 |
| `jump_admission_decision.json` | `budget_pass`, `incident_override`, `approver`, `decision` | 超预算但无 incident override 仍放行 |
| `merge_group_rebuild_report.json` | `merge_group_sha`, `required_checks_pass`, `rebuild_complete` | 重建未完成或 checks 未回报 |
| `signal_stability_report.json` | `hn_item_id`, `deleted`, `dead`, `opml_contract_pass`, `stable` | 信号不稳定仍触发 jump |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前仍重定向到 HN Popular Blogs OPML Gist，说明入口是动态修订资产，不应被当静态证据。
2. HN 三车道同窗样本持续变化（news/show/newest 头条异构），意味着“抢位 jump”的冲动会长期存在。
3. GitHub merge queue 文档明确：jump 到队首会导致 in-progress PR 全量重建，并可能降低合并速度。
4. GitHub Actions 文档明确：merge queue 场景必须配置 `merge_group` 触发，否则 required checks 不会被报告。
5. HN API 给出 `topstories/newstories/showstories` 与 item `deleted/dead` 字段，支持把“信号稳定性”转成可执行门禁。
6. OPML 2.0 规范要求 `outline.text`，rss 订阅要求 `type/text/xmlUrl`，可作为入口结构合法性校验基线。

## 反模式

- 把 jump 当成“高优先级按钮”，不计吞吐成本。
- 只看业务紧急性，不看重建波及面（in-progress PR 数量）。
- 超预算 jump 只口头审批，无 incident 编号和回滚方案。
- merge queue 只监听 `pull_request`，忽略 `merge_group` required checks。
- 为 `deleted/dead` 条目或 OPML 契约漂移信号触发 jump。
