---
name: browser-tool-scope-parity-gate
topic: runtime-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:47:01Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Obsidian Sync now has a headless client")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Now I Get It – Translate scientific papers into interactive webpages")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, signal title: "Be Careful with LLM Agents")
  - OpenAI Docs: Background mode guide (https://developers.openai.com/api/docs/guides/background)
  - OpenAI Docs: Conversation state guide (https://developers.openai.com/api/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Authenticate with GITHUB_TOKEN (https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/runtime-governance/browser-runtime-boundary-manifest-gate.md
  - references/patterns/release-governance/ruleset-bypass-visibility-attestation-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

当 Agent 在 `cli` 与 `browser-contained` runtime 间切换时，常见失效不是“任务失败”，而是**权限快照失配仍被当成成功结果晋级**：

1. 运行时切换后，工具可用范围发生变化，但任务只回报 `completed`；
2. 会话链可连续（`previous_response_id` 正常），但执行权限已不同；
3. 旧审批快照与新 runtime scope 混用，导致候选结果绕过真实门禁。

本质问题：**缺少可计算的 tool scope 同构证明（scope parity proof）**。

## 核心解法

引入 **Browser Tool Scope Parity Gate（BTSPG）**，把“权限一致性”从日志描述提升为 required check：

1. **作用域摘要（Scope Digest）**
   - 在每次执行开始时固化 `tool_scope_digest`（允许工具、权限级别、来源 runtime）。
   - 产出时再次计算 `observed_scope_digest`，比较是否一致。
2. **链路绑定（Scope-to-Conversation Binding）**
   - 将 `tool_scope_digest` 与 `response_id`、`previous_response_id`、`conversation_id` 同步入档。
   - 任何“链路连续但 scope 变化”都标记为 `scope_parity_pass=false`。
3. **晋级硬门禁（Required Checks）**
   - 将 `scope_parity_pass` 与 `runtime_boundary_pass` 设为并列 required checks。
   - 任何一项失败时只能保留为探索结论，禁止 candidate->issue 或 PR 晋级。
4. **最小权限对齐（Least-Privilege Alignment）**
   - 参考 GitHub `GITHUB_TOKEN` 最小权限原则，要求 scope 白名单显式声明。
   - 未声明工具默认视为越权，不进入晋级包。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `tool_scope_manifest.json` | `runtime_type`, `tool_scope_digest`, `approved_scope_digest`, `captured_at_utc` | 缺字段即 fail |
| `scope_parity_report.json` | `response_id`, `previous_response_id`, `scope_parity_pass`, `diff_keys` | `scope_parity_pass=false` 即 quarantine |
| `promotion_packet.json` | `runtime_boundary_pass`, `scope_parity_pass`, `blocked_reason` | 任一 false 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML Gist（含更新时间与 revision），可作为方向入口锚点。
2. HN `news/show/newest` 本轮同窗中同时出现 headless client、Show HN 交互产品与 “Be Careful with LLM Agents”，说明“可运行”与“可控”正在分离。
3. OpenAI Background 文档明确异步状态与轮询/取消语义（`queued`、`in_progress`、cancel idempotent），证明“完成状态”不足以表达权限一致性。
4. OpenAI Conversation state 文档提供 `previous_response_id` 与 `conversation` 持久链路，适合做 scope 绑定键。
5. GitHub protected branches 文档要求 required status checks 通过后才可合并，适合作为 parity gate 承载面。
6. GitHub `GITHUB_TOKEN` 文档强调最小权限与 `permissions` 显式配置，支撑 scope 白名单策略。
7. HN API 文档给出 `/v0/topstories`、`/v0/newstories`、`/v0/showstories`，支持跨车道证据重放与去重。

## 反模式

- 把 `completed` 当作唯一成功条件，不检查 scope 摘要一致性。
- 只校验会话链，不校验权限链，导致“链路真、权限假”。
- runtime 切换后继续复用旧审批 digest。
- `scope_parity_pass` 不是 required check，仅做告警日志。
