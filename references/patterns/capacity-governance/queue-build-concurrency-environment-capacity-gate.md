---
name: queue-build-concurrency-environment-capacity-gate
topic: capacity-governance
confidence: 0.78
verified_count: 7
sources:
  - t.co redirect snapshot: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML gist (checked 2026-02-28)
  - Hacker News news lane snapshot (2026-02-28): https://news.ycombinator.com/news
  - Hacker News show lane snapshot (2026-02-28): https://news.ycombinator.com/show
  - Hacker News newest lane snapshot (2026-02-28): https://news.ycombinator.com/newest
  - GitHub merge queue settings (build concurrency, status check timeout, minimum PRs): https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
  - GitHub Actions merge_group event for required checks: https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
  - GitHub deployments/environments (required reviewers, wait timer): https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
  - GitHub review deployments (prevent self-reviews, bypass behavior): https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
merge_upgrade_of:
  - references/patterns/release-governance/queue-deploy-continuity-dual-gate.md
  - references/patterns/queue-governance/queue-jump-throughput-loss-budget-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

merge queue 的 `Build concurrency` 可以提升并行验证吞吐，但发布端（environment reviewers + wait timer）处理能力往往是慢变量。
如果只优化“入队吞吐”，不约束“出队审批容量”，会出现：

- `merge_group` 触发洪峰，deploy 审批队列滞后；
- required checks 在排队与等待中跨窗过期；
- 系统被迫进入 fallback 或人工 bypass，审计链断裂。

本质是：**队列提速与发布容量是同一系统的耦合变量，必须用统一容量门禁治理，而不是分别调参。**

## 核心解法

建立 **Queue Build-Concurrency Environment-Capacity Gate（QBCECG）**，把 queue 与 deploy 放在同一压力预算里判定：

1. 构建并发上限与审批容量绑定
   - `safe_build_concurrency = floor(approval_throughput_per_hour * review_sla_hours * alpha)`
   - merge queue `build_concurrency` 不得超过 `safe_build_concurrency`。
2. 队列-部署压差预算
   - 计算 `pressure_ratio = merge_group_dispatch_rate / deploy_approval_rate`。
   - `pressure_ratio > max_pressure_ratio` 时禁止继续提速，必要时自动降到保守并发档位。
3. 等待窗口时效重验
   - 任何经过 environment wait timer 的候选，必须在 deploy 前重跑 `merge_group` 关键检查。
   - 重验失败或过期即冻结晋级。
4. 审批身份与旁路约束
   - 强制 `prevent_self_review=true`。
   - bypass 仅允许 incident 路径，且必须生成结构化审计卡。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_capacity_budget.json` | `build_concurrency`, `safe_build_concurrency`, `dispatch_rate`, `max_pressure_ratio` | `build_concurrency > safe_build_concurrency` |
| `deploy_capacity_snapshot.json` | `required_reviewers`, `approval_throughput_per_hour`, `wait_timer_minutes`, `prevent_self_review` | reviewer 容量未知或允许自审 |
| `queue_deploy_pressure_report.json` | `pressure_ratio`, `queue_wait_minutes_p95`, `reverify_required`, `pressure_pass` | `pressure_pass=false` 仍允许提速 |
| `promotion_decision.json` | `queue_capacity_pass`, `deploy_capacity_pass`, `freshness_reverify_pass`, `decision` | 任一 gate 失败仍 promote |

## 证据链

1. `t.co/dwAiIjlXet` 重定向到 OPML gist，说明外部输入面持续变化，不能把“旧窗口通过”长期继承到发布判定。
2. HN `news/show/newest` 同窗头部主题明显异构，表明发现流高波动，压力峰值会频繁触发 queue/deploy 不对称。
3. GitHub merge queue 文档给出 `build concurrency`、`status check timeout`、`minimum pull requests to merge`，证明队列吞吐可调且存在等待窗口。
4. GitHub Actions 文档要求 required checks 监听 `merge_group`，否则队列上下文验证不完整。
5. GitHub environments 文档给出 required reviewers 与 wait timer（1 分钟到 30 天）能力边界，证明发布端是可配置但有限容量系统。
6. GitHub review deployments 文档说明可阻止自审并定义 bypass 行为，支持将“旁路”纳入容量超载审计闭环。

## 反模式

- 单独提高 `build_concurrency`，不评估审批吞吐与 wait timer 压力。
- 把 queue 通过当作 deploy 永久绿灯，不做等待后重验。
- 发布审批允许自审，容量告急时靠 bypass 常态化穿透。
- 只看平均排队时长，不跟踪 `pressure_ratio` 与 `p95` 等高压信号。
