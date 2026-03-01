---
name: required-check-pending-deadlock-gate
topic: ci-governance
confidence: 0.77
verified_count: 7
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (revisions observed on page, last active Feb 28, 2026)
  - HN news lane sample: https://news.ycombinator.com/item?id=47161759 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201972 (sampled 2026-03-01)
  - GitHub Docs: events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (skipped workflows can stay Pending) (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: workflow syntax `paths` / `paths-ignore` filter (https://docs.github.com/actions/reference/workflows-and-actions/workflow-syntax)
merge_upgrade_of:
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
  - references/patterns/product-delivery/merge-fence-required-checks-lineage.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

24h 无人推进里，最容易被忽视的失败面不是“检查失败”，而是**required check 永久 Pending**：

- workflow 被 `paths` / `branches` 过滤后直接 skipped；
- 该 check 仍被分支保护设为 required；
- merge queue 走 `merge_group` 独立事件，未接入同构触发；
- 最终形成“无人值守无法自动收敛”的合并僵局。

这不是质量门禁缺失，而是**门禁触发契约缺失**。

## 核心解法

建立 **Required-Check Pending Deadlock Gate（RCPDG）**，把“必跑触发完整性”设为硬门禁：

1. 固定 required check 契约
   - 维护 `required_check_contract.json`，声明必须上报的 check 名与触发事件集合。
2. 必跑哨兵工作流
   - required check 不直接绑在重任务上；
   - 由轻量 sentinel job 在 `pull_request + merge_group` 必跑并汇总结果。
3. 过滤内聚而非触发缺席
   - 可对重任务做路径过滤，但 sentinel 本身不能被路径过滤跳过。
4. Pending 超时阻断
   - 增加 `pending_deadlock_pass`：任何 required check 超过阈值仍 Pending，直接阻断晋级并进入 quarantine。
5. 双路径同构
   - PR 与 queue 路径必须上报同一组 check 名，避免“PR 可判定，queue 不可判定”。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `required_check_contract.json` | `check_name`, `required_events[]`, `timeout_minutes` | required checks 未声明触发面 |
| `required_check_sentinel_report.json` | `event_name`, `required_checks[]`, `reported_checks[]`, `missing_checks[]` | `missing_checks` 非空 |
| `pending_deadlock_audit.json` | `check_name`, `pending_since_utc`, `pending_minutes`, `timeout_minutes`, `deadlock` | `deadlock=true` 仍继续晋级 |
| `promotion_decision.json` | `required_trigger_integrity_pass`, `pending_deadlock_pass`, `decision` | 任一失败仍 `decision=promote` |

建议 required checks：

- `required_trigger_integrity_pass`
- `pending_deadlock_pass`
- `queue_parity_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 稳定重定向到 OPML Gist，但 Gist 存在持续修订，说明夜间输入面长期变化，触发契约必须可审计。
2. HN `news/show/newest` 同窗样本（`47161759 / 47195123 / 47201972`）体现高时变信号流，自动化链路需要自收敛而非人工盯 Pending。
3. GitHub 明确 `merge_group` 是独立触发事件，未监听会导致 queue 路径不完整。
4. GitHub required checks 文档明确：workflow 因路径/分支过滤被跳过时，相关检查可能保持 Pending 并阻塞合并。
5. GitHub workflow syntax 文档确认 `paths`/`paths-ignore` 在触发层生效，支持“重任务可过滤、required sentinel 不可缺席”的分层设计。

## 反模式

- 直接把重任务设为 required check，同时给 workflow 加路径过滤。
- 只在 `pull_request` 上报 required checks，不在 `merge_group` 上报。
- 看到 Pending 仅人工重试，不记录 `pending_since` 与超时决策。
- required checks 名称在 PR 与 queue 路径不一致，导致策略面假绿灯。
