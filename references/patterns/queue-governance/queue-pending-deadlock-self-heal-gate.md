---
name: queue-pending-deadlock-self-heal-gate
topic: queue-governance
confidence: 0.78
verified_count: 8
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (last active Feb 28, 2026)
  - HN top lane sample: https://news.ycombinator.com/item?id=47196582 (from topstories, sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (from showstories, sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47179611 (from newstories, sampled 2026-03-01)
  - Hacker News API: topstories/showstories/newstories endpoints (https://github.com/HackerNews/API)
  - GitHub Docs: managing merge queue (jump/rebuild, status check timeout and removal reasons) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (skipped workflow keeps Pending and blocks merge) (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: re-running workflows and jobs (`GITHUB_SHA` / `GITHUB_REF` from original event) (https://docs.github.com/en/actions/how-tos/manage-workflow-runs-and-deployments/manage-workflow-runs/re-run-workflows-and-jobs)
merge_upgrade_of:
  - references/patterns/ci-governance/required-check-pending-deadlock-gate.md
  - references/patterns/queue-governance/queue-fallback-recovery-threshold-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

夜间无人推进里，很多团队已经能检测到 required checks 的 Pending 僵局，但仍然卡死在“恢复动作”：

- 盲目 `re-run` 只会复用原始 `GITHUB_SHA/GITHUB_REF`，无法修复触发契约缺失；
- merge queue 重排/重建后，旧 Pending 与新 `merge_group` 检查混在一起；
- 自动化系统反复重试却不隔离，最终把短时故障放大成长期吞吐黑洞。

本质问题不是“是否发现僵局”，而是**缺少可审计的僵局自愈闭环合同**。

## 核心解法

建立 **Queue Pending Deadlock Self-Heal Gate（QPDSG）**，把“检测”升级为“分类恢复 + 失败隔离”：

1. 僵局分类器
   - `trigger_missing`：required check 未触发（常见于 `paths` 过滤、未监听 `merge_group`）。
   - `transient_failure`：runner/网络抖动导致短时 Pending。
   - `queue_rebuild_overlap`：queue 重建后旧 run 与新 run 并存。
2. 恢复动作白名单
   - `trigger_missing`：禁止重试，直接 `quarantine + contract_fix_required`。
   - `transient_failure`：允许有上限的重试（如最多 1 次）。
   - `queue_rebuild_overlap`：丢弃旧 Pending，只接受最新 `merge_group` run。
3. 时效与预算门禁
   - `pending_minutes > timeout_minutes` 必须转入 `deadlock=true`，禁止继续排队。
   - 重试次数超预算触发 `self_heal_exhausted=true`，进入人工仲裁。
4. required checks 一体化
   - `pending_deadlock_pass`
   - `self_heal_policy_pass`
   - `merge_group_parity_pass`
   - 任一失败即阻断晋级。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `pending_deadlock_audit.json` | `pr_number`, `check_name`, `pending_since_utc`, `pending_minutes`, `deadlock` | `deadlock=true` 仍继续晋级 |
| `deadlock_classification.json` | `class`(`trigger_missing/transient_failure/queue_rebuild_overlap`), `evidence`, `decision` | 分类缺失或与证据不一致 |
| `self_heal_action_log.json` | `action`, `attempt`, `max_attempts`, `result`, `actor` | 超预算重试或动作不在白名单 |
| `queue_rebuild_alignment.json` | `current_merge_group_sha`, `accepted_run_id`, `stale_run_ids[]` | 接受了 stale run 结果 |
| `promotion_decision.json` | `pending_deadlock_pass`, `self_heal_policy_pass`, `merge_group_parity_pass`, `decision` | 任一 gate fail 仍 `decision=promote` |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到 OPML Gist，且 Gist 有修订历史，说明输入面高时变，僵局恢复必须可追溯而非“无限重试”。
2. HN API 三车道（`topstories/showstories/newstories`）当前样本 `47196582 / 47195123 / 47179611`，证明夜间窗口内信号持续刷新，排队系统需要具备自动收敛能力。
3. GitHub required checks 文档明确：workflow 被跳过会导致 check 长期 Pending 并阻塞 merge，验证了 `trigger_missing` 必须走“修契约”而不是“盲重试”。
4. GitHub `merge_group` 是独立触发事件；若检查未覆盖该事件，queue 路径会出现结构性 Pending。
5. GitHub re-run 文档明确重跑继承原始事件的 `GITHUB_SHA/GITHUB_REF`，说明重试不是“新判定面”，不能代替触发契约修复。
6. GitHub merge queue 文档给出 `jump` 引发全量重建、status check timeout 与移出原因，支持“重建对齐 + 超时隔离”的自愈闭环设计。

## 反模式

- 把所有 Pending 都当成瞬时抖动，统一无限重试。
- 检测到 `trigger_missing` 后仍执行 `re-run`，不修 workflow 触发契约。
- `pull_request` 与 `merge_group` 使用不同 check 名，导致自愈策略判定失真。
- queue 重建后继续消费 stale run 结果，造成“旧绿灯复活”。
- 不落盘 `deadlock_classification` 与 `self_heal_action_log`，次日无法审计恢复链路。
