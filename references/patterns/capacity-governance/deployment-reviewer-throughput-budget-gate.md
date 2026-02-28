---
name: deployment-reviewer-throughput-budget-gate
topic: capacity-governance
confidence: 0.77
verified_count: 6
sources:
  - t.co redirect snapshot: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML gist (checked 2026-02-28)
  - Hacker News news lane snapshot (2026-02-28): https://news.ycombinator.com/news
  - Hacker News show lane snapshot (2026-02-28): https://news.ycombinator.com/show
  - Hacker News newest lane snapshot (2026-02-28): https://news.ycombinator.com/newest
  - GitHub deployments/environments (required reviewers, wait timer): https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments
  - GitHub review deployments (approve all waiting jobs, prevent self-reviews, bypass behavior): https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
  - GitHub merge queue + merge_group required checks: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue , https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
merge_upgrade_of:
  - references/patterns/capacity-governance/queue-build-concurrency-environment-capacity-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

在 merge queue 提速后，瓶颈常从 CI 转移到 deployment 审批。  
当 `required reviewers` 容量不足时，队列会出现“验证已通过但发布长期等待”的隐性拥塞，随后诱发：

- 等待窗口内证据过期；
- 审批批量处理导致旁路冲动上升；
- 夜间无人值守流程从可审计降级为经验驱动。

本质是：**审批吞吐是独立的慢变量，必须单独建预算 gate，而不是被 merge queue 吞吐假设掩盖。**

## 核心解法

建立 **Deployment Reviewer Throughput Budget Gate（DRTBG）**：

1. 审批容量建模
   - `approval_rate_per_hour`：单位时间可处理的有效审批数。
   - `review_backlog_minutes_p95`：审批等待时长尾部指标。
2. 队列提速前置约束
   - 若 `incoming_promotions_per_hour > approval_rate_per_hour * beta`，禁止提升 `build_concurrency`。
   - 仅在审批容量稳定窗口内允许恢复高并发。
3. 批处理防失真
   - 启用“批次上限 + 冷却期”，避免一次性批准过多 waiting jobs 造成证据同窗失真。
4. 身份与旁路约束
   - 强制 `prevent_self_review=true`。
   - bypass 必须绑定 incident 编号与追责字段，不能作为吞吐扩容手段。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `deploy_reviewer_capacity.json` | `required_reviewers`, `approval_rate_per_hour`, `batch_limit`, `cooldown_minutes` | 审批吞吐未知或 `batch_limit` 未设 |
| `deploy_wait_pressure.json` | `review_backlog_minutes_p95`, `queue_wait_minutes_p95`, `pressure_ratio` | `pressure_ratio` 超阈值仍允许提速 |
| `promotion_review_audit.json` | `prevent_self_review`, `bypass_count`, `incident_linked` | 允许自审或 bypass 无 incident 绑定 |

## 证据链

1. `https://t.co/dwAiIjlXet` 指向 OPML 订阅体，说明输入流持续变化，等待中的审批证据会快速老化。
2. HN `news/show/newest` 同窗异构，证明夜间信号流波动高，审批端更容易形成突发积压。
3. GitHub environments 文档提供 `required reviewers` 与 `wait timer`，表明发布端存在明确的容量和等待边界。
4. GitHub review deployments 文档支持“批准全部等待作业”、阻止自审与受控 bypass，说明审批吞吐必须与审计约束联动治理。
5. GitHub merge queue 与 `merge_group` required checks 共同说明：队列验证面可提速，但发布审批面若无预算 gate 会形成系统性压差。

## 反模式

- 把 deploy 审批看作“人工步骤”，不纳入容量预算。
- 用临时 bypass 解决审批积压，把旁路当常规扩容。
- 批量批准 waiting jobs 但不做冷却和重验，放大同窗误判。
- 只看平均等待，不跟踪 `p95` 尾部与审批吞吐下降趋势。
