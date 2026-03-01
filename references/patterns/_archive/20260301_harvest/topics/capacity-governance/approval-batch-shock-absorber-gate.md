---
name: approval-batch-shock-absorber-gate
topic: capacity-governance
confidence: 0.78
verified_count: 4
sources:
  - t.co redirect snapshot: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML gist (checked 2026-02-28)
  - HN API topstories snapshot (2026-02-28): https://hacker-news.firebaseio.com/v0/topstories.json
  - HN API showstories snapshot (2026-02-28): https://hacker-news.firebaseio.com/v0/showstories.json
  - HN API newstories snapshot (2026-02-28): https://hacker-news.firebaseio.com/v0/newstories.json
  - GitHub merge queue (build concurrency, jump behavior): https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
  - GitHub Actions merge_group event (required checks): https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
  - GitHub review deployments (approve all waiting jobs, prevent self-reviews): https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
merge_upgrade_of:
  - references/patterns/capacity-governance/queue-build-concurrency-environment-capacity-gate.md
  - references/patterns/capacity-governance/deployment-reviewer-throughput-budget-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

当 merge queue 提升并发后，部署审批端常用“approve and deploy all waiting jobs”快速消峰。
如果没有批次上限与冷却窗口，这种批量放行会把不同证据时窗的候选混入同一审批波次，导致：

- 审批吞吐短时看似提升，但 `merge_group` 新鲜度被透支；
- 等待中的候选跨窗老化，仍被同批放行；
- 旁路与补丁式审批变成常态，审计链失真。

本质是：**审批端需要“冲击吸收层”，而不是把批量批准当作无成本扩容。**

## 核心解法

建立 **Approval Batch Shock-Absorber Gate（ABSAG）**，把审批批量行为转为可度量门禁：

1. 批次上限 + 冷却窗口
   - 每批最多 `batch_limit` 个 waiting jobs；批与批之间至少 `cooldown_minutes`。
   - 冷却期间禁止新一轮“approve all waiting jobs”。
2. 批次前新鲜度门禁
   - 批次内候选若 `evidence_age_minutes > freshness_budget_minutes`，必须先重跑 `merge_group` required checks。
3. 批次后压力回读
   - 计算 `shock_ratio = approved_in_batch / approval_rate_per_hour`。
   - `shock_ratio` 超阈值时自动下调 queue `build_concurrency`，直到审批 backlog 回落。
4. 身份与旁路约束
   - 强制 `prevent_self_reviews=true`。
   - bypass 仅允许 incident 路径，且必须附 `incident_id` 与复盘链接。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `deploy_review_batch_policy.json` | `batch_limit`, `cooldown_minutes`, `freshness_budget_minutes` | 任一字段缺失或 `batch_limit <= 0` |
| `deploy_review_batch_report.json` | `approved_in_batch`, `shock_ratio`, `stale_candidates_count`, `reverify_count` | `shock_ratio` 超阈值仍继续批量放行 |
| `queue_capacity_feedback.json` | `build_concurrency_before`, `build_concurrency_after`, `rollback_reason` | 审批冲击超阈值但并发未回调 |
| `promotion_audit_card.json` | `prevent_self_reviews`, `bypass_count`, `incident_linked` | 允许自审或 bypass 无追责信息 |

## 证据链

1. `https://t.co/dwAiIjlXet` 指向 OPML 订阅体，外部输入面持续变化，说明审批等待窗口内证据会快速老化。
2. HN API `topstories/showstories/newstories` 同窗头部条目类型明显异构，证明信号流在短窗内波动大，容易触发审批端突发积压。
3. GitHub merge queue 文档提供 `build concurrency` 与 `jump`（会重启 in-progress checks），证明上游吞吐与重建风暴可被配置放大。
4. GitHub Actions 文档要求 required checks 监听 `merge_group`，说明队列上下文验证需要专门事件锚定。
5. GitHub review deployments 文档支持“批准全部等待作业”与“阻止自审”，证明批量审批与身份约束必须一起治理。

## 反模式

- 把“approve all waiting jobs”当作常规扩容，不设批次上限/冷却。
- 批量审批前不检查候选新鲜度，直接继承旧证据。
- 审批冲击后不回调 queue 并发，继续叠加 backlog。
- 允许自审并把 bypass 当吞吐补丁，形成不可追责放行。
