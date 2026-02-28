---
name: agent-scope-manifest-escalation-gate
topic: permission-governance
confidence: 0.78
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:49:26Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Verified Spec-Driven Development with OpenAI and IaC (Sponsored)")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Augment Agent, coding assistant with autonomy")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, signal title: "Be Careful with LLM Agents")
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Authenticate with GITHUB_TOKEN (https://docs.github.com/en/actions/tutorials/authenticate-with-github_token)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/runtime-governance/browser-tool-scope-parity-gate.md
  - references/patterns/release-governance/bypass-reason-registry-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

在 24h 无人值守的 agent 链路里，最常见事故不是“任务失败”，而是**权限缓慢升级却未被显式审批**：

1. 早期步骤只需要只读权限，后续步骤临时获得写权限后继续复用旧结论；
2. 异步任务最终状态显示 `completed`，但权限轨迹没有被纳入晋级门禁；
3. 会话链连续（`previous_response_id` 可追踪）却没有 scope 漂移判定。

本质问题：**缺少“会话级最小权限清单 + 升级即冻结”的统一约束**。

## 核心解法

引入 **Agent Scope Manifest Escalation Gate（ASMEG）**，把权限漂移从“日志告警”升级为“不可绕过门禁”：

1. **会话起点白名单**
   - 每个 run 固化 `allowed_scopes` 与 `max_scope_level`。
   - 未声明 scope 默认拒绝，禁止隐式继承上轮权限。
2. **升级封套（Escalation Envelope）**
   - 任何 scope 扩大必须附带 `reason_code`、`requested_scope`、`ttl_minutes`、`approver`。
   - 缺任一字段则 `escalation_approved=false`。
3. **升级即冻结晋级**
   - 发生升级后，当前 run 只能继续探索，不能直接 candidate->issue 或 PR 晋级。
   - 必须在新 scope 下完成重放并生成新证明包。
4. **双校验并列 required checks**
   - `scope_manifest_pass`：会话级最小权限清单完整且一致。
   - `escalation_replay_pass`：升级后重放成功且证据链更新。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `agent_scope_manifest.json` | `run_id`, `allowed_scopes`, `max_scope_level`, `issued_at_utc` | 缺字段即 fail |
| `scope_escalation_envelope.json` | `reason_code`, `requested_scope`, `ttl_minutes`, `approver` | `approver` 为空即 quarantine |
| `promotion_packet.json` | `scope_manifest_pass`, `escalation_replay_pass`, `blocked_reason` | 任一 false 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML Gist，可作为每日入口锚点。
2. HN `news/show/newest` 同窗中，`Show HN: Augment Agent` 与 `Be Careful with LLM Agents` 同时出现，说明“自主性提升”和“风险暴露”并行上升。
3. OpenAI Background mode 文档强调异步任务状态机，证明 `completed` 不等于“权限安全完成”。
4. OpenAI Conversation state 文档支持 `previous_response_id` 链路，适合绑定 scope 漂移审计。
5. GitHub protected branches 文档要求 required status checks 通过后才能合并，适合作为权限门禁承载面。
6. GitHub `GITHUB_TOKEN` 文档强调用 `permissions` 显式收紧 token 权限，支撑最小权限清单策略。
7. HN API 文档给出 `topstories/showstories/newstories` 端点，支持多车道证据重放与异常归因。

## 反模式

- 只记录“谁请求了升级”，不记录“升级后是否完成重放”。
- 把 `completed` 当作晋级条件，忽略 scope 漂移。
- 升级后沿用升级前的审批与证明包。
- 把最小权限做成建议项，而不是 required check。
