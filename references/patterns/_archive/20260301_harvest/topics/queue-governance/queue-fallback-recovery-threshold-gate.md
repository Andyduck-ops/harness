---
name: queue-fallback-recovery-threshold-gate
topic: queue-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28)
  - Hacker News topstories API snapshot (2026-02-28, item 47203487: "What happened when I built a daily coding challenge platform with AI") (https://hacker-news.firebaseio.com/v0/topstories.json)
  - Hacker News showstories API snapshot (2026-02-28, item 47205198: "Show HN: Now I Get It – Translate scientific papers into interactive webpages") (https://hacker-news.firebaseio.com/v0/showstories.json)
  - Hacker News newstories API snapshot (2026-02-28, item 47205652: "Show HN: Free, open-source native macOS client for di.fm") (https://hacker-news.firebaseio.com/v0/newstories.json)
  - GitHub Docs: merge queue supports "Only merge non-failing pull requests", "Status check timeout", and minimum merge limits (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: required checks for merge queue must run on merge_group (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - Hacker News API reference (item fields include deleted/dead) (https://github.com/HackerNews/API)
  - OPML 2.0 Spec: outline contracts for feed identity (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/queue-governance/queue-jump-throughput-loss-budget-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

很多团队引入 merge queue 后，会在压力时开启 `Only merge non-failing pull requests` 以提升吞吐；
但事故结束后，系统常常没有明确的“恢复阈值”，导致容错模式长期滞留：

- 触发降级有规则，恢复严格模式却靠人工记忆；
- 队列表面吞吐上升，但失败成员被持续旁路，质量债务被延后爆发；
- 外部信号（HN/OPML）仍在快速漂移，旧证据被带入新的 queue 决策窗口。

本质问题：**我们治理了“何时降级”，但没有治理“何时且如何恢复”。**

## 核心解法

建立 **Queue Fallback Recovery Threshold Gate（QFRTG）**，把降级与恢复做成对称门禁：

1. 双阈值状态机
   - `strict_mode`：默认，全量 required checks 必须通过。
   - `fallback_mode`：仅允许 non-failing 成员合并。
   - `recovery_candidate`：进入恢复观察窗，满足阈值后回到 `strict_mode`。
2. 恢复阈值显式化
   - 连续 `K` 个 merge_group 周期无新失败成员。
   - `fallback_failure_density` 低于 `recovery_density_threshold`。
   - `queue_wait_p95_minutes` 低于 `recovery_wait_threshold`。
3. 证据纪元重绑定
   - 从 `fallback_mode -> strict_mode` 的切换，必须重跑 `merge_group` required checks。
   - 绑定 `queue_epoch_id + evidence_epoch_id`，避免恢复后继承旧证据。
4. 外部信号最小稳定门禁
   - HN item 必须通过 `deleted/dead` 复检。
   - OPML outline 必须通过 `text/type/xmlUrl` 契约校验。
   - 避免把不稳定外部信号引入恢复判定窗口。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_fallback_state.json` | `mode`, `entered_at_utc`, `exit_candidate_at_utc`, `reason` | 状态切换无时间戳/无理由 |
| `fallback_recovery_thresholds.json` | `k_clean_merge_groups`, `recovery_density_threshold`, `recovery_wait_threshold` | 阈值缺失或全为默认零值 |
| `fallback_recovery_report.json` | `clean_merge_group_streak`, `failure_density`, `queue_wait_p95_minutes`, `recovery_pass` | 未达阈值仍切回 strict |
| `merge_group_reverify_report.json` | `merge_group_sha`, `required_checks_pass`, `queue_epoch_id`, `evidence_epoch_id` | 恢复切换未完成 merge_group 重验 |
| `signal_stability_report.json` | `hn_item_id`, `deleted`, `dead`, `opml_contract_pass`, `stable` | 信号不稳定仍用于恢复判定 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前重定向到 HN Popular Blogs OPML Gist，说明外部入口是动态资产，恢复窗口必须考虑证据漂移。
2. HN `topstories/showstories/newstories` 同窗采样头条异构，证明外部信号在窗口内持续变化。
3. GitHub merge queue 文档提供 `Only merge non-failing pull requests`、`Status check timeout` 与 merge limits，证明容错模式存在且可配置。
4. GitHub Actions 文档要求 merge queue 所需检查运行在 `merge_group`，支持“恢复切换前必须重验”这一硬门禁。
5. HN API 提供 `deleted/dead` 字段；OPML 2.0 规范给出 outline 结构契约，可作为外部信号合法性最低基线。

## 反模式

- 把 fallback 当“临时开关”，但不记录进入/退出阈值与时戳。
- 仅统计降级触发次数，不统计恢复成功率与恢复耗时。
- 从 fallback 回 strict 时不重跑 merge_group required checks。
- 在 `deleted/dead=true` 或 OPML 契约漂移时仍放行恢复。
- 恢复失败后继续手工反复切换，缺少自动冷却与节流策略。
