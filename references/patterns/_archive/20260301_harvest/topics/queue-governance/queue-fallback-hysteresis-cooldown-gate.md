---
name: queue-fallback-hysteresis-cooldown-gate
topic: queue-governance
confidence: 0.79
verified_count: 5
sources:
  - t.co redirect snapshot: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML gist (checked 2026-02-28)
  - Hacker News news lane snapshot (2026-02-28): https://news.ycombinator.com/news
  - Hacker News show lane snapshot (2026-02-28): https://news.ycombinator.com/show
  - Hacker News new lane snapshot (2026-02-28): https://news.ycombinator.com/newest
  - Hacker News API lanes: topstories/showstories/newstories and item schema (dead/deleted): https://github.com/HackerNews/API
  - GitHub merge queue settings (only merge non-failing PRs, status check timeout, minimum pull requests to merge): https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
  - GitHub Actions merge_group event for required checks: https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
  - OPML 2.0 structure contract (outline/text/xmlUrl): https://2005.opml.org/spec2.html
merge_upgrade_of:
  - references/patterns/queue-governance/queue-fallback-recovery-threshold-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

`fallback_mode` 常见失败不是“切不回 strict”，而是“能切回，但马上又掉回去”。
系统在 strict/fallback 之间高频抖动，会把 merge queue 变成不可审计的随机开关：

- 降级触发存在，但恢复后缺少冷却期；
- 恢复判定只看单次通过，不看连续清洁窗口；
- 外部证据在窗口内漂移（HN lane 头部持续变化，OPML 入口可变），导致恢复依据跨窗口失效。

本质是：**我们有阈值，没有滞回（hysteresis）与冷却（cooldown）。**

## 核心解法

建立 **Queue Fallback Hysteresis Cooldown Gate（QFHCG）**，把模式切换从单阈值改为双阈值滞回状态机：

1. 双阈值滞回
   - `enter_fallback_threshold`：故障密度超过该值才降级。
   - `exit_fallback_threshold`：故障密度低于该值且连续 `K` 个 merge_group 清洁周期才允许恢复。
   - 要求 `exit < enter`，避免同阈值来回震荡。
2. 恢复冷却窗口
   - `recovery_cooldown_minutes` 内禁止再次切回 strict。
   - 冷却期只采样，不切换；若故障回升，直接续留 fallback。
3. 恢复前强制重验
   - 切回 strict 前必须在 `merge_group` 上完成 required checks。
   - 绑定 `queue_epoch_id + evidence_epoch_id`，防止沿用降级期旧证据。
4. 外部信号稳定门禁
   - HN item 需通过 `deleted/dead=false` 复检。
   - OPML outline 需满足 `text/type/xmlUrl` 契约校验。
   - 不稳定外部信号不得作为恢复证据输入。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_mode_hysteresis.json` | `enter_threshold`, `exit_threshold`, `k_clean_windows`, `recovery_cooldown_minutes` | `exit_threshold >= enter_threshold` |
| `queue_mode_state.json` | `mode`, `entered_at_utc`, `last_switch_at_utc`, `cooldown_until_utc` | 无切换时间戳或冷却结束时间 |
| `queue_mode_recovery_report.json` | `clean_window_streak`, `failure_density`, `merge_group_reverify_pass`, `recovery_pass` | 未完成 merge_group 重验即恢复 |
| `external_signal_stability.json` | `hn_item_id`, `deleted`, `dead`, `opml_contract_pass`, `stable` | `stable=false` 仍参与恢复判定 |

## 证据链

1. `t.co/dwAiIjlXet` 指向 OPML gist，说明入口可重定向且会修订，恢复判定需要证据稳定性约束。
2. HN `news/show/new` 三车道同窗头部不一致，证明外部信号在短窗口内天然漂移。
3. HN API 定义 `dead/deleted`，支持“恢复前存活复检”这一硬门禁。
4. GitHub merge queue 原生支持 fallback 相关设置（non-failing merge、timeout、minimum PRs），说明可以实现可配置的滞回门禁。
5. GitHub `merge_group` required checks 是恢复前统一重验锚点；OPML 2.0 提供外部订阅结构最小契约。

## 反模式

- 使用单阈值同时做进入/退出 fallback，导致阈值附近频繁抖动。
- 恢复只看一次绿灯，不看连续清洁窗口。
- 没有冷却期，恢复后立刻再次切换，形成 oscillation。
- 恢复不重跑 `merge_group` required checks。
- 外部信号未做 `dead/deleted` 与 OPML 契约复检即参与恢复决策。
