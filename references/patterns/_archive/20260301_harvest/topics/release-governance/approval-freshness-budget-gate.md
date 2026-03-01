---
name: approval-freshness-budget-gate
topic: release-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:50:30Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Tell HN: Looking for data points where coding assistants caused incidents")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: WeatherMCP: Access weather data from your AI tool")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "How to stop overcomplicating your product")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: Deployments and environments (https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/release-governance/queue-deploy-continuity-dual-gate.md
  - references/patterns/evidence-governance/temporal-evidence-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

团队常把 merge queue 的“可合并”当成 deploy 的“可审批可发布”，但二者中间存在天然时滞：

- queue 通过发生在 `merge_group` 上下文；
- deployment 通过依赖 environment 保护规则与人工审批；
- required checks 还受最新 SHA 与时间窗口约束。

如果审批阶段不重新核对时效，系统会继承旧绿灯，出现 **“队列时可证，审批时失效”** 的晋级错判。

## 核心解法

建立 **Approval Freshness Budget Gate（AFBG）**，把“审批是否还能继承 queue 证据”变成硬门禁：

1. Queue 证据冻结
   - 出队时写入 `queue_gate_card.json`，固定 `lineage_id + merge_group_sha + checks_passed_at_utc`。
2. 审批时效预算
   - deploy 审批前计算 `approval_age_minutes`，与分支阈值 `max_approval_age_minutes` 对比。
   - 超预算必须触发 `reverify_before_approval=true`，重跑关键检查后才允许审批。
3. 审批身份与环境保护
   - environment 启用 required reviewers，并开启 `prevent self-reviews`。
   - 审批记录必须携带 `approved_by` 与 `deploy_sha`，并与 `lineage_id` 对齐。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_gate_card.json` | `lineage_id`, `merge_group_sha`, `checks_passed_at_utc`, `required_checks` | queue 信息缺失或 checks 非最新 SHA |
| `approval_freshness_budget.json` | `lineage_id`, `approval_age_minutes`, `max_approval_age_minutes`, `within_budget` | `within_budget=false` 且未重验 |
| `deployment_approval_card.json` | `lineage_id`, `environment`, `approved_by`, `self_review_blocked`, `deploy_sha` | 审批人自审或 lineage 断链 |
| `promotion_decision.json` | `queue_gate_pass`, `approval_freshness_pass`, `deploy_gate_pass`, `decision` | 任一门禁失败仍 promote |

## 证据链

- `https://t.co/dwAiIjlXet` 持续重定向到 OPML 入口，说明夜间输入池持续变化，审批不能无条件继承旧采样。
- HN `news/show/newest` 同时段头条明显不同，证明信号漂移速度高，审批前需要 freshness 复验。
- GitHub merge queue 与 `merge_group` 文档共同说明：队列阶段是独立验证面，不等于部署审批面。
- GitHub deployments/environment 文档说明：作业会等待保护规则（包括 wait timer/required reviewers）通过后才继续。
- GitHub protected branches 文档强调 required checks 要对应最新 SHA，且检查结果有有效窗口（7 天），支持审批前重验策略。

## 反模式

- queue 通过后直接沿用旧 checks 发起环境审批，不做时效核验。
- 审批卡片不记录 `checks_passed_at_utc`，导致无法判定“绿灯是否过期”。
- 配置了 required reviewers 但允许提交者自审 deploy。
- `lineage_id` 只在 queue 记录，deploy 审批不绑定，导致审计断链。
