---
name: browser-runtime-boundary-manifest-gate
topic: runtime-governance
confidence: 0.77
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:40:03Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Now I get it, this is what all the fuss over LLMs is about")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "The Self-Driving Codebase: Introducing GitHub Spark and Spark CLI")
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/autonomous-ops/audit-gated-autonomy.md
  - references/patterns/state-governance/background-cursor-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

Agent 从本地 CLI 进入浏览器容器后，执行速度会提高，但可审计边界会变模糊：

1. 同一个任务可在 CLI / Browser 两种 runtime 间切换；
2. 会话状态链（`previous_response_id`）与运行环境边界没有强绑定；
3. 晚到结果可能来自旧 runtime 或旧权限快照；
4. 如果晋级门禁仅看“任务完成”，就会把边界不明的结果推进到 issue/PR。

本质问题是：**跨 runtime 的执行结果缺少统一“边界声明 + 时效验证 + 晋级门禁”。**

## 核心解法

引入 **Browser Runtime Boundary Manifest Gate（BRBMG）**，把“在哪运行、用什么权限、绑定哪个会话链”变成 required check：

1. **边界声明（Runtime Boundary Manifest）**
   - 每次产出必须写入 `runtime_type`, `runtime_session_id`, `tool_scope_digest`, `anchor_window_id`。
   - `runtime_type` 只允许 `cli` 或 `browser-contained`，否则直接拒绝晋级。
2. **会话链同构校验（Conversation Continuity Parity）**
   - 校验 `response_id -> previous_response_id -> conversation_id` 连续。
   - 若 runtime 切换后链路断裂，`boundary_pass=false`。
3. **权限镜像校验（Scope Parity）**
   - 比对 `tool_scope_digest` 与最新审批快照。
   - digest 不一致时，自动进入 `quarantine`，禁止候选晋级。
4. **晋级硬门禁（Required Checks）**
   - 将 `runtime_boundary_pass`、`conversation_chain_pass` 设为 required checks。
   - 任一失败时仅允许继续探索，不允许落入交付分支。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `runtime_boundary_manifest.json` | `runtime_type`, `runtime_session_id`, `tool_scope_digest`, `anchor_window_id` | 缺字段直接 fail |
| `conversation_chain_report.json` | `response_id`, `previous_response_id`, `conversation_id`, `chain_pass` | 链路断裂即 fail |
| `scope_parity_report.json` | `tool_scope_digest`, `approved_scope_digest`, `scope_parity_pass` | digest 不同即 quarantine |
| `promotion_packet.json` | `runtime_boundary_pass`, `conversation_chain_pass`, `blocked_reason` | 任一 false 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到 OPML 锚点池，说明长期方向源稳定可复用。
2. HN `news/show/newest` 同时出现上下文成本、体验反馈、自驱代码库话题，表明 runtime 形态和执行速度正在快速变化。
3. OpenAI Background 文档明确异步运行状态机（如 `queued` / `in_progress` / `completed`），证明“晚到完成”是常态，需要额外边界门禁。
4. OpenAI Conversation state 文档提供 `previous_response_id` 与 `conversation` 链能力，可直接用于会话链一致性验证。
5. GitHub protected branches 文档提供 required status checks 作为不可绕过的晋级入口，适合承载 `runtime_boundary_pass`。
6. HN API 文档给出统一 API 前缀与 item 查询方式，支持把 news/show/newest 快照固化为可重放证据。

## 反模式

- 把 runtime 仅当执行细节，不写边界声明字段。
- 只看 `completed`，不校验会话链和权限摘要。
- runtime 切换后沿用旧审批快照，未做 scope parity。
- `runtime_boundary_pass` 不是 required check，导致夜间结果可绕过晋级。
