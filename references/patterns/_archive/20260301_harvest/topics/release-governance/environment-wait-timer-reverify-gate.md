---
name: environment-wait-timer-reverify-gate
topic: release-governance
confidence: 0.77
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:55:06Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Open source and self host your own private Telegram using Telegram API")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "A framework to agentify your software and orchestrate dynamic LLMs")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "I got OpenAI Agent to make me 100k while I slept")
  - GitHub Docs: Deployments and environments (https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/release-governance/approval-freshness-budget-gate.md
  - references/patterns/release-governance/queue-deploy-continuity-dual-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

`merge_group` 阶段通过后，deployment 仍可能因为 environment `wait timer` 被延后。
如果系统只做“审批前一次 freshness 校验”，等待窗口内的额外漂移会把旧证据带入发布决策，形成：

- queue 绿灯有效，但 deploy 发生时已经跨窗；
- 审批人通过了，但通过依据不是“当前可验证状态”；
- 管理员 bypass 保护规则时，没有结构化审计信号。

本质是：**等待本身也是风险放大器，必须被建模成重验触发器，而不是被当作中性延迟。**

## 核心解法

建立 **Environment Wait-Timer Reverify Gate（EWTRG）**，把“审批”和“等待”都作为重验触发条件：

1. 双触发重验
   - 触发 A：`approval_age_minutes > max_approval_age_minutes`
   - 触发 B：`wait_timer_elapsed_minutes > max_wait_timer_minutes`
   - 任一触发都必须执行 `reverify_before_promotion=true`。
2. 等待窗口冻结上下文
   - 入等待窗口时写入 `wait_timer_gate_card.json`，固定 `lineage_id + merge_group_sha + wait_started_at_utc`。
   - 出等待窗口后刷新 `reverify_passed_at_utc`，禁止复用等待前结论。
3. 绕过审计强制留痕
   - 若发生 environment protection bypass，必须生成 `bypass_override_audit.json`，并把决策自动降级为 `quarantine_review`。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_gate_card.json` | `lineage_id`, `merge_group_sha`, `checks_passed_at_utc` | queue 证据缺失或 SHA 断链 |
| `wait_timer_gate_card.json` | `lineage_id`, `wait_started_at_utc`, `wait_timer_minutes`, `wait_timer_elapsed_minutes` | 等待窗口不可追溯 |
| `approval_reverify_card.json` | `lineage_id`, `reverify_trigger`, `reverify_passed`, `reverify_passed_at_utc` | 触发重验后未执行或失败仍放行 |
| `bypass_override_audit.json` | `lineage_id`, `bypass_actor`, `bypass_reason`, `forced_jobs` | 发生 bypass 但无审计记录 |
| `promotion_decision.json` | `queue_gate_pass`, `wait_timer_gate_pass`, `approval_gate_pass`, `decision` | 任一 gate 失败仍 promote |

## 证据链

- `https://t.co/dwAiIjlXet` 仍指向 OPML 聚合入口，说明外部信号面持续变化，旧采样不应无限期继承。
- HN `news/show/newest` 在同一采样时段出现显著异构主题，证明“等待期间漂移”是常态而非异常。
- GitHub deployments/environment 文档定义了 `wait timer` 与 required reviewers，这意味着部署前存在显式等待控制面。
- GitHub review deployments 文档提供审批/拒绝流程及 bypass 入口，说明“人工绕过”必须纳入审计闭环。
- GitHub merge queue + `merge_group` 文档确认 queue 校验是独立上下文；GitHub protected branches 要求 checks 对应最新 SHA，支持“等待后重验”策略。

## 反模式

- queue 通过后仅做一次审批校验，忽略 wait timer 造成的证据过窗。
- wait timer 到期即直接晋级，不重跑关键 required checks。
- bypass deployment protection rules 后只写日志，不产出结构化审计卡片。
- `promotion_decision.json` 不记录 `reverify_trigger`，导致无法追责“为何放行”。
