---
name: queue-reorder-rebuild-attestation-gate
topic: queue-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:27:10Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "747s and Coding Agents")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Obsidian Garden for running local llm agents")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Open Source and self host your own private Telegram using Telegram API")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: GraphQL Objects (`EnqueuePullRequestInput.jump` / `MergeQueueParametersInput.groupingStrategy`) (https://docs.github.com/en/enterprise-server@3.16/graphql/reference/input-objects)
merge_upgrade_of:
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
  - references/patterns/queue-governance/merge-queue-tail-green-risk-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

merge queue 在运行中允许“重排”和“重建”：

- 官方文档说明 jump to top 会触发 queue 重建；
- queue 会生成新的 merge group 临时分支与新的 head SHA；
- 如果系统继续复用重排前证据（旧 replay / 旧 gate / 旧 decision），就会出现“看似仍绿，实则已换判定面”。

本质是：**队列重排改变了验证对象，但很多流水线没有把“重排事件”当作强制失效信号。**

## 核心解法

建立 **Queue Reorder Rebuild Attestation Gate（QRRAG）**，把重排事件升级为硬门禁：

1. 队列纪元（queue epoch）建模
   - 每次入队生成 `queue_epoch_id`。
   - 一旦出现 `jump=true` 或 merge group 重建，切换到新 epoch，旧 epoch 证据自动失效。
2. 重建后强制重放
   - 对新 `merge_group_head_sha` 重新执行 required checks 与 replay 校验。
   - `promotion_decision.json` 必须绑定当前 epoch 与当前 head SHA，禁止跨 epoch 复用。
3. 分组策略显式验签
   - 固化 `groupingStrategy`（`ALLGREEN` / `HEADGREEN`）到 gate 产物。
   - 策略变化时强制 quarantine，等待人工确认。
4. 失败可见性最小集
   - 记录 `reorder_trigger_actor`、`rebuild_reason`、`previous_epoch_invalidated=true`。
   - 缺少任一字段，默认判定为不可审计晋级。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_epoch_manifest.json` | `queue_epoch_id`, `merge_group_head_sha`, `grouping_strategy`, `captured_at_utc` | 字段缺失或与当前队列不一致 |
| `queue_reorder_event.json` | `jump_requested`, `rebuild_triggered`, `reorder_trigger_actor`, `previous_epoch_id` | 发生重排但无事件记录 |
| `queue_rebuild_replay_report.json` | `queue_epoch_id`, `replay_pass`, `required_checks_pass`, `head_sha_bound` | 任一为 false |
| `promotion_decision.json` | `queue_epoch_id`, `previous_epoch_invalidated`, `rebuild_replay_pass`, `decision` | 跨 epoch 晋级或失效标记缺失 |

## 证据链

- `https://t.co/dwAiIjlXet` 仍指向 OPML 信号入口，说明外部输入持续变化，队列中的“重排后复用旧证据”风险真实存在。
- HN `top/show/newest` 同时段头条异构，进一步证明夜间高波动环境下重排是常态而不是异常。
- GitHub merge queue 文档明确说明 jump 到队首会导致 in-progress PR 全部重建。
- GitHub Actions 文档明确 `merge_group` 是独立事件，重建后必须在新上下文再次触发关键检查。
- GitHub GraphQL 输入对象给出 `jump` 与 `groupingStrategy`，可直接作为“重排发生 + 策略变化”的机器可判定信号。

## 反模式

- 只记录“是否通过”，不记录 queue epoch 和 head SHA 绑定关系。
- jump 到队首后，继续沿用旧 `promotion_decision.json`。
- `groupingStrategy` 变更没有触发重验与隔离。
- 仅在 `pull_request` 事件保留证据，不在 `merge_group` 重建后补跑 gate。
