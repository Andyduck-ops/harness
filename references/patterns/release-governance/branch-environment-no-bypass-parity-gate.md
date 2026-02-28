---
name: branch-environment-no-bypass-parity-gate
topic: release-governance
confidence: 0.78
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:04:41Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Open source and self host your own private Telegram using Telegram API")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Aider Polyglot - One command install and launch all your coding agents")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Making software for all is hard. Here's why")
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Deployments and environments (https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
merge_upgrade_of:
  - references/patterns/release-governance/environment-bypass-audit-quarantine-gate.md
  - references/patterns/release-governance/approval-freshness-budget-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

同一条发布链上，分支保护和环境保护对“可否绕过”给出不同语义：

- 分支保护可设置 `Do not allow bypassing the above settings`；
- 环境保护存在 bypass deployment protection rules 的操作入口；
- merge queue / `merge_group` 又在独立上下文执行检查。

结果是：**策略表面全绿，但绕过语义在不同控制面互相打架，出现“规则写了禁绕，流程仍可旁路”的隐式反转。**

## 核心解法

建立 **Branch-Environment No-Bypass Parity Gate（BENPG）**，把“禁绕策略同一”作为晋级前置条件：

1. 双面策略快照
   - 每次晋级前同时生成 `branch_protection_snapshot` 与 `environment_protection_snapshot`。
   - 显式记录 `do_not_allow_bypass`、`allow_admin_bypass`、`required_reviewers`、`wait_timer_minutes`。
2. 策略同一性判定
   - 计算 `policy_parity_state`：`aligned` / `mismatch` / `unknown`。
   - 若分支为禁绕而环境允许旁路，直接标记 `mismatch` 并阻断晋级。
3. 旁路后再同一
   - 一旦发生 bypass，必须重新计算同一性并触发 `post_bypass_reverify`。
   - 只有 `policy_parity_state=aligned` 且重验通过，才允许 `promotion_decision=promote`。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `branch_bypass_policy_snapshot.json` | `lineage_id`, `branch`, `do_not_allow_bypass`, `required_checks`, `captured_at_utc` | 未读取分支禁绕配置就进入晋级 |
| `environment_bypass_policy_snapshot.json` | `lineage_id`, `environment`, `allow_admin_bypass`, `required_reviewers`, `wait_timer_minutes`, `captured_at_utc` | 环境 bypass 策略缺失或未绑定同一 lineage |
| `bypass_policy_parity_report.json` | `lineage_id`, `branch_sha`, `merge_group_sha`, `policy_parity_state`, `mismatch_reasons` | `mismatch` 仍允许发布 |
| `promotion_decision.json` | `parity_gate_pass`, `post_bypass_reverify_pass`, `decision` | `parity_gate_pass=false` 时仍 `decision=promote` |

## 证据链

- `https://t.co/dwAiIjlXet` 仍重定向到 OPML Gist，说明入口源会变，发布策略判断必须可回放。
- HN `news/show/newest` 同时反映生产经验、工具演示和早期噪声，证明高吞吐场景下“口头禁绕”会快速失效。
- GitHub `about protected branches` 给出“禁止绕过”策略位，说明分支侧存在硬约束控制面。
- GitHub `deployments and environments` + `review deployments` 明确存在环境审批、等待和 bypass 入口，说明环境侧存在可旁路控制面。
- GitHub merge queue 与 `merge_group` 文档说明检查运行在独立触发上下文；因此禁绕策略必须跨分支/队列/环境统一校验，而不是只看单点配置。

## 反模式

- 只检查分支禁绕，不检查环境是否允许 bypass。
- 发生 bypass 后不重算策略同一性，沿用旧 `parity_state`。
- `promotion_decision.json` 不记录 `parity_gate_pass`，导致“谁放行了策略冲突”无法追责。
- 把 `merge_group` 校验结果当成环境审批的默认通行证，不做跨控制面一致性审计。
