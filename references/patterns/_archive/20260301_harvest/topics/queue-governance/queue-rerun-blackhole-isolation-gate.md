---
name: queue-rerun-blackhole-isolation-gate
topic: queue-governance
confidence: 0.79
verified_count: 9
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (last active Feb 28, 2026)
  - HN top lane sample: https://news.ycombinator.com/item?id=47343197 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47344731 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47349478 (sampled 2026-03-01)
  - Hacker News API: topstories/showstories/newstories endpoints (https://github.com/HackerNews/API)
  - GitHub Docs: managing merge queue (status check timeout/removal and queue rebuild behaviors) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (skipped workflow keeps Pending and blocks merge) (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: re-running workflows and jobs (`GITHUB_SHA` / `GITHUB_REF` from original event) (https://docs.github.com/en/actions/how-tos/manage-workflow-runs-and-deployments/manage-workflow-runs/re-run-workflows-and-jobs)
merge_upgrade_of:
  - references/patterns/ci-governance/required-check-pending-deadlock-gate.md
  - references/patterns/queue-governance/queue-pending-deadlock-self-heal-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

夜间无人推进中，Pending 僵局经常被“机械 re-run”伪装为在恢复，实际却进入黑洞：

- `trigger_missing`（触发契约缺失）场景下，re-run 继承原事件上下文，无法补出缺失的 check；
- merge queue 重建后，旧 run 与新 `merge_group` run 并存，系统误把旧结果当作“恢复”；
- 自动化只记录“重试次数”，不记录“重试是否改变证据面”，导致无限重试吞吐塌陷。

本质不是“有没有重试”，而是**是否阻断无效重试并强制隔离不可修复 Pending**。

## 核心解法

建立 **Queue Rerun Blackhole Isolation Gate（QRBIG）**：

1. 有效重试判定
   - 只有“能改变证据面”的动作才算恢复动作（例如修复 workflow 触发器并产生新 run）。
   - 仅“重复执行同一上下文 run”记为 `ineffective_retry`。
2. 分类隔离策略
   - `trigger_missing`：禁止 re-run，直接 `quarantine + contract_fix_required`。
   - `queue_rebuild_overlap`：只接受最新 `merge_group` run，旧 run 一律 tombstone。
   - `transient_failure`：允许受预算约束的有限重试。
3. 双账本
   - `retry_effect_log.json`：记录每次重试是否改变事件上下文/证据面。
   - `quarantine_decision.json`：记录隔离理由、解除条件与人工接管 SLA。
4. 并联门禁
   - `rerun_effective_pass`
   - `pending_deadlock_pass`
   - `merge_group_parity_pass`
   - 任一失败即禁止晋级。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `retry_effect_log.json` | `run_id`, `event_name`, `sha`, `ref`, `effective_retry`, `reason` | 连续 `effective_retry=false` 且仍自动重试 |
| `pending_deadlock_audit.json` | `check_name`, `pending_minutes`, `class`, `deadlock` | `deadlock=true` 仍进入 queue |
| `queue_rebuild_alignment.json` | `merge_group_sha`, `accepted_run_id`, `rejected_stale_runs[]` | 接受 stale run 作为最终判定 |
| `quarantine_decision.json` | `quarantined`, `cause`, `exit_criteria`, `owner` | `trigger_missing` 未隔离或无退出条件 |
| `promotion_decision.json` | `rerun_effective_pass`, `pending_deadlock_pass`, `merge_group_parity_pass`, `decision` | gate fail 但 `decision=promote` |

## 证据链

1. `https://t.co/dwAiIjlXet` 稳定重定向到 OPML Gist（且有修订历史），说明输入流会漂移，恢复动作必须可审计而非盲重试。
2. HN 三车道样本（top/show/newest：`47343197/47344731/47349478`）显示信号持续刷新，夜间系统必须优先“收敛”而不是“堆重试”。
3. GitHub 文档明确：workflow 被跳过会让 required checks 保持 Pending 并阻塞 merge，证明 `trigger_missing` 不可用 re-run 解决。
4. GitHub 文档明确 `merge_group` 是独立触发事件，若未同构监听，queue 路径天然出现 Pending 盲区。
5. GitHub 文档明确 re-run 使用原始事件的 `GITHUB_SHA/GITHUB_REF`，证明“上下文不变的重跑”不是新证据。
6. GitHub merge queue 文档提供 timeout/removal 与重建行为，支持“无效重试隔离 + stale run tombstone”的治理闭环。

## 反模式

- 以“已重试”代替“已修复”，不验证重试有效性。
- 在 `trigger_missing` 场景持续 re-run，既不修触发契约也不隔离。
- 不区分 `pull_request` 与 `merge_group` 检查面，导致 queue 隐性僵局。
- queue 重建后仍消费旧 run 结果。
- 不落盘 `retry_effect_log` / `quarantine_decision`，次日无法审计黑洞来源。
