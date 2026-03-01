---
name: queue-deploy-continuity-dual-gate
topic: release-governance
confidence: 0.79
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:45:37Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Signal says it’s pulling feature users exploited to protect privacy")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Wavpilot - Voice to Cursor in Your Browser")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Introducing Claude 4.5")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: Deployments and environments (https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules#troubleshooting-required-status-checks)
merge_upgrade_of:
  - references/patterns/release-governance/staged-promotion-gate.md
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间无人执行里，很多团队把“merge queue 通过”和“部署审批通过”当成同一绿灯，
但 GitHub 实际把它们放在两个独立闸门：

- queue 在 `merge_group` 上下文决定是否可合并；
- deployment job 在 environment 保护规则（required reviewers / wait timer）通过前不会继续；
- required checks 还有最新 SHA 与时效窗口约束。

本质是：**如果不把 queue 证据与 deployment 审批做同一条 lineage 绑定，会出现“可合并但不可安全发布”的断层晋级。**

## 核心解法

建立 **Queue-Deploy Continuity Dual Gate（QDCDG）**，把晋级拆成“同构可合并 + 可审批可发布”双门禁：

1. Queue 同构门禁（Merge Context Gate）
   - 关键 workflow 同时监听 `pull_request` 与 `merge_group`。
   - 记录 `merge_group_sha`、`required_checks[]`、`queue_exit_fresh_pass`。
2. Deployment 连续性门禁（Environment Continuity Gate）
   - 对目标 environment 强制 required reviewers，开启 `prevent self-reviews`。
   - 每次审批必须绑定 `lineage_id + merge_group_sha + deploy_sha`。
3. 时效与一致性门禁（Freshness Gate）
   - required checks 必须对应最新 commit SHA，且不复用超时结果。
   - 若 queue 到审批间隔超预算，触发 `reverify_before_deploy=true` 重跑。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_promotion_card.json` | `lineage_id`, `merge_group_sha`, `queue_exit_fresh_pass`, `required_checks` | queue_exit_fresh_pass=false |
| `deployment_approval_card.json` | `lineage_id`, `environment`, `required_reviewers`, `self_review_blocked`, `approved_by` | 审批不匹配 lineage 或允许自审 |
| `queue_deploy_continuity.json` | `lineage_id`, `merge_group_sha`, `deploy_sha`, `freshness_within_budget`, `reverify_before_deploy` | SHA 断链或 freshness 超预算未重验 |
| `promotion_decision.json` | `queue_gate_pass`, `deploy_gate_pass`, `decision` | 任一 gate 失败仍 promote |

## 证据链

- `https://t.co/dwAiIjlXet` 当前重定向到 OPML 入口，夜间输入持续变化，不能把单次采样结果直接继承到发布决策。
- HN `top/show/newest` 同时段头条差异明显，说明夜间信号时变快，queue 与 deploy 之间需要时效重检。
- GitHub merge queue 文档明确队列使用独立合并上下文；GitHub Actions 文档明确 `merge_group` 是单独事件，验证面必须同构。
- GitHub deployments 文档说明 job 引用 environment 时需等待保护规则通过；Review deployments 文档要求 required reviewers 并支持阻止自审。
- GitHub required checks 文档强调检查需对应最新 SHA 且存在有效窗口，支持“queue 通过后到 deploy 前”的 freshness 重验。

## 反模式

- 只在 `pull_request` 跑检查，不在 `merge_group` 复验。
- queue 通过后直接触发部署，不绑定 `lineage_id` 与 `merge_group_sha`。
- 配了 required reviewers 但允许提交者自审发布。
- required checks 用旧 SHA 或过期结果直接复用到 deploy 决策。
