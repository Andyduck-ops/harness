---
name: ruleset-bypass-list-drift-gate
topic: release-governance
confidence: 0.78
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:15:38Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Modern-day Oracles or Bullshit Machines?")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Decided to play god and create my own agent civilisation")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Show HN: AIQuotaBar – Menubar app for OpenAI API usage tracking")
  - GitHub Docs: About rulesets (https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
  - GitHub Docs: Managing ruleset history (https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets#managing-ruleset-history)
  - GitHub REST API: Rules (https://docs.github.com/en/rest/repos/rules)
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
merge_upgrade_of:
  - references/patterns/release-governance/bypass-reason-registry-gate.md
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

ruleset 的 bypass list 是“谁可绕过规则”的硬权限面，但在高频自动化发布里它有两个常见盲点：

- 配置导出不总是包含 bypass actor 细节，导致“有变更但导出看不见”；
- merge queue 的校验上下文独立于 PR，上游旧绿灯无法覆盖“队列期间名单漂移”。

结果是：**旁路主体边界在变，但晋级闸门感知不到，形成静默放行窗口。**

## 核心解法

建立 **Ruleset Bypass List Drift Gate（RBLDG）**，把“名单漂移”提升为晋级阻断条件：

1. 双通道快照
   - 用有权限的 token 调用 Rules API 拉取 `bypass_actors` 与 `bypass_mode`。
   - 同时抓 ruleset history 导出作为变更时间线，但不把它当完整身份源。
2. 漂移判定
   - 计算 `actor_set_hash` 与 `mode_hash`；任一变化即标记 `ruleset_drift_detected=true`。
   - 变更必须绑定 `drift_approval_ticket` 和 `reason_code`，否则阻断。
3. 队列耦合重验
   - 若 PR 已入 merge queue 且检测到名单漂移，强制触发 `merge_group` 复验并重算门禁。
   - 漂移期间禁止继承旧 PR 绿灯。
4. 审计封账
   - 产出 `ruleset_bypass_drift_report.json`，并把 `drift_window` 写入 `promotion_decision.json`。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `ruleset_bypass_snapshot.json` | `ruleset_id`, `bypass_actors`, `bypass_mode`, `captured_at_utc`, `actor_set_hash` | 无 `bypass_actors` 仍当作“无漂移” |
| `ruleset_bypass_diff.json` | `baseline_hash`, `current_hash`, `actors_added`, `actors_removed`, `mode_changed` | 有差异但无阻断标记 |
| `ruleset_bypass_drift_report.json` | `drift_detected`, `drift_approval_ticket`, `reason_code`, `queue_impact` | `drift_detected=true` 且 ticket 缺失 |
| `promotion_decision.json` | `ruleset_bypass_drift_pass`, `merge_group_reverify_pass`, `decision` | 任一为 false 仍 `decision=promote` |

## 证据链

- `https://t.co/dwAiIjlXet` 持续指向同一 OPML 入口，说明“入口稳定不代表内容不漂移”，名单治理也需要持续比对而非一次性确认。
- HN `news/show/newest` 同时出现“AI agents 可靠性争议 + agent 工具发布 + 新实验”，表明自动化执行密度升高，权限边界漂移风险随之放大。
- GitHub `about rulesets` 明确 ruleset 包含 bypass list；`managing ruleset history` 指出导出 JSON 不含 bypass actor 细节，证明“只看导出”存在观测盲区。
- GitHub Rules API 提供可编程读取规则数据，是实现 actor 集合差异检测的必要接口。
- GitHub merge queue 与 `merge_group` 事件定义了独立校验面，支持“队列期间策略漂移必须重验”的门禁设计。

## 反模式

- 只依赖 ruleset history 导出做名单审计，不抓 API 快照。
- 用低权限 token 拉取规则并把空 `bypass_actors` 误判为“无变更”。
- 名单漂移后继续复用 PR 阶段绿灯，不触发 `merge_group` 重验。
- `promotion_decision.json` 不记录 `ruleset_bypass_drift_pass`，导致复盘无法追责。
