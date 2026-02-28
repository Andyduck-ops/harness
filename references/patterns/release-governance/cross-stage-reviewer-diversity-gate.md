---
name: cross-stage-reviewer-diversity-gate
topic: release-governance
confidence: 0.78
verified_count: 4
sources:
  - t.co redirect snapshot: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML gist (checked 2026-02-28)
  - Hacker News news lane snapshot (2026-02-28, item 47213443): https://news.ycombinator.com/news and https://news.ycombinator.com/item?id=47213443
  - Hacker News show lane snapshot (2026-02-28, item 47197088): https://news.ycombinator.com/show and https://news.ycombinator.com/item?id=47197088
  - Hacker News newest lane snapshot (2026-02-28, Show HN: A2A Coder, item 47200919): https://news.ycombinator.com/newest and https://news.ycombinator.com/item?id=47200919
  - GitHub review deployments (required reviewers, prevent self-reviews, start all waiting jobs): https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments
  - GitHub rulesets (required approvals / stale approvals / approval from someone other than last pusher): https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets
  - GitHub merge queue (build concurrency, jump behavior): https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
  - GitHub Actions merge_group event (required checks): https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
last_verified: 2026-02-28
rank: 3
---

## 元问题

在 24h 无人推进链路里，系统常把“代码评审通过”与“部署审批通过”视为两段独立绿灯。
但 GitHub 环境审批默认只需 1 个 required reviewer，且支持 `Start all waiting jobs` 批量批准；如果同一批 reviewer 同时覆盖 PR 与 deploy，两段绿灯会变成同质化判断，出现盲区共振：

- 代码评审与发布审批看似双重把关，实则是同一身份重复放行；
- merge queue 并发提高后，单一审批人更容易批量放行 waiting jobs；
- 旁路和“应急批量批准”被长期化，审计链虽然完整但独立性不足。

本质是：**缺少“跨阶段评审身份多样性”这一硬门禁。**

## 核心解法

建立 **Cross-Stage Reviewer Diversity Gate（CSRDG）**，把“谁在审”纳入晋级预算：

1. 身份重叠预算门禁
   - 统计 `PR_reviewers ∩ deploy_reviewers`，计算 `overlap_ratio`。
   - 设定阈值 `max_overlap_ratio`（例如 0.5）；超阈值时禁止晋级。
2. 批量审批独立性门禁
   - 一旦触发 `Start all waiting jobs`，必须满足 `distinct_deploy_reviewers >= 2`。
   - 批量审批不允许由最后 push 人执行（与 rulesets 的“approval from someone other than last pusher”一致）。
3. 跨阶段重验锚点
   - 身份门禁通过后，仍需在 `merge_group` required checks 上重验，防止“身份合规但证据过窗”。
4. 旁路隔离与回写
   - bypass 必须绑定 `incident_id` 与 `owner_ack`；
   - 当 bypass 与高 overlap 同时出现时，自动进入 quarantine，仅允许最小波次放行。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `reviewer_diversity_policy.json` | `max_overlap_ratio`, `min_distinct_deploy_reviewers`, `block_last_pusher_on_batch_approve` | 阈值缺失或 `max_overlap_ratio` 超出 `(0,1]` |
| `promotion_identity_report.json` | `pr_reviewers`, `deploy_reviewers`, `overlap_ratio`, `last_pusher_in_approvers` | overlap 超阈值仍晋级 |
| `deploy_wave_review_report.json` | `used_start_all_waiting_jobs`, `batch_size`, `distinct_reviewer_count` | 批量审批但 reviewer 不达标 |
| `promotion_audit_card.json` | `merge_group_reverify_pass`, `bypass_count`, `incident_id` | 无重验或 bypass 无 incident 绑定 |

## 证据链

1. `t.co/dwAiIjlXet` 指向 OPML 订阅体，外部输入源持续变化，意味着“同一批审批人长期处理同质流量”的假设不成立。
2. HN `news/show/newest` 同窗头部条目类型明显异构（示例 item：`47213443`, `47197088`, `47200919`），证明夜间候选风险面不是单一分布。
3. GitHub review deployments 明确：required reviewers 里仅 1 人批准即可放行，并支持 `Start all waiting jobs`；同时支持 `prevent self-reviews`，说明身份约束是可配置但默认不足的。
4. GitHub rulesets 提供“required approvals”“dismiss stale approvals”“approval from someone other than last pusher”，为跨阶段身份独立性提供可复用约束基元。
5. GitHub merge queue 的 `build concurrency` 与 `jump` 机制会放大波次；`merge_group` 是 required checks 的统一重验锚点。

## 反模式

- 把 PR 审批和 deploy 审批当作天然独立，不做 reviewer 身份重叠审计。
- 批量 `Start all waiting jobs` 时仍允许单一审批人连续放行。
- 只看审批动作数量，不看审批身份多样性。
- 高重叠 + bypass 同时出现仍按常规波次晋级。
