---
name: background-cursor-freshness-gate
topic: state-governance
confidence: 0.76
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:35:53Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-03-01, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-03-01, top title: "Show HN: Syncari – AI-driven Infrastructure as Code Automation")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-03-01, top title: "A Proposal for Implementing Claude Code in the Browser")
  - Hacker News API (https://github.com/HackerNews/API, topstories/showstories/newstories)
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/autonomous-ops/cancel-budget-stale-run-gate.md
  - references/patterns/state-governance/agent-state-cell-replay-envelope.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

异步后台 run 能跑很久，但“能跑”不等于“仍有效”。

在 `top/show/new` 高频变化场景下，最常见的隐性事故是：

1. 旧 run 仍在 `in_progress`；
2. 新 run 已经基于新锚点启动；
3. 旧 run 晚到完成并写出结论；
4. 系统缺少游标新鲜度校验，误把旧结论晋级。

本质问题是：**后台状态机和会话游标链路分离后，没有统一时效门禁。**

## 核心解法

引入 **Background Cursor Freshness Gate（BCFG）**，在“后台状态 + 会话游标 + 证据锚点”三层同时验签：

1. **双游标账本（Run Cursor Ledger）**
   - 每次产出写入 `run_id`, `response_id`, `previous_response_id`, `conversation_id`, `anchor_window_id`。
   - 强制记录“此结论绑定的锚点窗口”。
2. **游标时效预算（Cursor Freshness Budget）**
   - 定义 `max_cursor_lag_seconds`。
   - 若 `run_completed_at - anchor_window_closed_at` 超预算，`freshness_pass=false`。
3. **晋级前双重一致性（Dual Integrity Gate）**
   - 校验 `previous_response_id` 链连续；
   - 校验 `anchor_window_id` 仍是当前最新窗口；
   - 任一失败，直接 `decision=hold`，禁止 candidate->issue/pr。
4. **受保护分支硬门禁（Required Checks）**
   - 将 `cursor_freshness_pass` 设为 required check；
   - 未通过仅允许继续探索，不允许晋级执行。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `run_cursor_ledger.json` | `run_id`, `response_id`, `previous_response_id`, `conversation_id`, `anchor_window_id` | 缺字段直接 fail |
| `cursor_freshness_report.json` | `anchor_window_closed_at`, `run_completed_at`, `cursor_lag_seconds`, `freshness_pass` | 超预算 `freshness_pass=false` |
| `cursor_integrity_report.json` | `response_chain_ok`, `anchor_is_latest`, `decision` | 任一 false => `decision=hold` |
| `promotion_packet.json` | `cursor_freshness_pass`, `required_checks`, `blocked_reason` | 门禁失败不得晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前仍重定向到 HN Popular Blogs OPML，说明长期锚点池稳定存在。
2. HN `news/show/newest` 同日头部主题差异明显（上下文优化、IaC 自动化、浏览器内 Agent），证明锚点窗口会快速变化。
3. HN API 给出 `topstories/showstories/newstories` 三条独立车道，天然需要窗口绑定与游标时效判定。
4. OpenAI Background 文档明确后台任务状态机（`queued/in_progress/completed`）与取消语义，说明“晚到完成”是要治理的常态而非异常。
5. OpenAI Conversation state 文档提供 `previous_response_id` 与 `conversation` 链路能力，可用于构建游标完整性校验。
6. GitHub protected branches 的 required checks 可把 `cursor_freshness_pass` 升级为不可绕过约束。

## 反模式

- 只看 run 是否完成，不看完成时是否仍绑定最新锚点窗口。
- 只保存自然语言摘要，不保存 `previous_response_id` 链路。
- 把 stale 判定放在人工复盘阶段，而不是晋级前硬门禁。
- `cursor_freshness_pass` 不是 required check，导致夜间结果可绕过晋级。
