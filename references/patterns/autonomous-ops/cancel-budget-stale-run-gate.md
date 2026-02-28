---
name: cancel-budget-stale-run-gate
topic: autonomous-ops
confidence: 0.78
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot: Show HN: Vibe Kanban (https://news.ycombinator.com/item?id=45809110)
  - Hacker News show snapshot: Prompt Armor (https://news.ycombinator.com/item?id=45807945)
  - Hacker News newest snapshot: Open-Source AI Learning Platform (https://news.ycombinator.com/item?id=45809835)
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI API Reference: Responses cancel endpoint (https://platform.openai.com/docs/api-reference/responses/cancel)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: Control workflow concurrency (https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/control-workflow-concurrency)
  - GitHub Docs: Store and share data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
merge_upgrade_of:
  - references/patterns/autonomous-ops/audit-gated-autonomy.md
  - references/patterns/recovery-governance/workspace-recovery-envelope.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间自治最容易出现的隐性事故不是“任务失败”，而是**任务已经过期却还在产出结论**。

当 HN 信号在数小时内快速换代（`top/show/newest` 同时抖动）时，后台任务若没有取消预算，会出现：

- 旧 run 在新 run 之后完成并覆盖结论；
- 审核者看到的是“最后完成”的结果，而不是“最新有效”的结果；
- 发现车道和晋级车道出现时间错配，导致错误晋级。

本质矛盾：**系统管理了吞吐，却没有管理“过期执行”**。

## 核心解法

引入 **Cancel Budget + Stale-Run Gate（CBSG）**，把“异步执行能力”升级为“可取消、可抑制、可回放”。

1. **取消预算（Cancel Budget）**
   - 每个方向定义 `cancel_sla_minutes`，超过时延或检测到更新 run 即触发取消。
   - 取消动作必须记录 `cancel_reason` 与 `superseded_by_run_id`。
2. **并发互斥（Concurrency Group）**
   - 对同一方向使用固定 `concurrency.group`，启用 `cancel-in-progress`，保证只保留最新 run。
3. **过期结论抑制（Stale-Run Gate）**
   - 结果晋级前校验 `run_started_at < latest_anchor_at` 时直接标记 `stale=true`，禁止 candidate->issue 晋级。
4. **回放信封（Replay Envelope）**
   - 每轮保存 `run_manifest.json`（含 `run_id/anchor_snapshot/lineage_id/cancel_trace/stale_decision`）并上传 artifact。
5. **防抖晋级（Debounce Promote）**
   - 晋级前增加 `promote_debounce_window`（如 20 分钟），窗口内若出现新锚点则重新评估，不直接晋级。

## 最小执行字段

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `run_manifest.json` | `run_id`, `direction`, `run_started_at`, `anchor_snapshot` | 缺任一字段即不允许晋级 |
| `cancel_trace.json` | `cancelled`, `cancel_reason`, `superseded_by_run_id` | `cancelled=true` 时禁止产出晋级建议 |
| `stale_gate_report.json` | `latest_anchor_at`, `is_stale`, `decision` | `is_stale=true` 必须 `decision=hold` |
| `promotion_packet.json` | `lineage_id`, `evidence_refs`, `debounce_until` | 未过防抖窗口不得进入 issue/pr |

## 证据链

- `https://t.co/dwAiIjlXet` 当前重定向至 HN Popular Blogs OPML，可作为稳定长周期锚点池；
- HN 2026-02-28 快照中 `top/show/newest` 同时活跃，且条目热度/时效显著分层，说明“旧 run 完成时已过期”是高概率事件；
- OpenAI Background mode 明确支持异步执行；Responses cancel 提供显式取消语义，适合落地 cancel SLA；
- OpenAI conversation state 文档支持会话续接，但不替代“过期判定账本”，两者需分层；
- GitHub concurrency 能对同组 run 启用 `cancel-in-progress`，Artifacts 可保存取消与抑制证据包，保证次日可审计回放。

## 反模式

- 只做异步，不做取消预算，导致旧 run 抢写新结论。
- 把“最后完成”误当“最新有效”，不做 `latest_anchor_at` 校验。
- 取消了 run 但不记录 `superseded_by_run_id`，导致审计链断裂。
- 无防抖窗口，HN 高频波动时持续误晋级。
