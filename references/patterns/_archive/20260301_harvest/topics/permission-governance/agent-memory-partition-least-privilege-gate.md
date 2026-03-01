---
name: agent-memory-partition-least-privilege-gate
topic: permission-governance
confidence: 0.78
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:59:14Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Obsidian Sync now has a headless client")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: AgentMailr, an MCP server that can read and write emails")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Be Careful with LLM Agents")
  - OpenAI Docs: Background mode guide (https://developers.openai.com/topics/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: Controlling permissions for GITHUB_TOKEN (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/permission-governance/agent-scope-drift-severity-budget-gate.md
  - references/patterns/state-governance/agent-state-cell-replay-envelope.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

Agent 一旦引入持久化记忆（本地 DB、远端同步、跨会话复用），会出现一个新失效面：**运行时权限是最小的，但“历史记忆”仍携带高权限痕迹并在后续低权限会话被重放利用**。

典型表现：

1. 会话 A 允许外部写入，会话 B 仅允许只读，但 B 可读取 A 写入的敏感记忆；
2. `completed` 状态被误当“安全完成”，忽略了跨会话记忆分区差异；
3. 记忆层没有独立 required checks，导致晋级只看执行结果不看记忆边界。

本质问题：**缺少“记忆分区 + 最小权限 + 晋级门禁”的一体化协议**。

## 核心解法

引入 **Agent Memory Partition Least-Privilege Gate（AMPLG）**：

1. **记忆分区分级**
   - `M0`：会话内临时记忆（不可跨会话）
   - `M1`：本地持久记忆（可跨会话、不可外部同步）
   - `M2`：外部同步记忆（可跨系统传播）
2. **权限-分区矩阵**
   - 每条 capability 显式声明允许访问的最大分区（`max_memory_tier`）。
   - 默认 deny：未声明则只允许 `M0`。
3. **重放前校验**
   - 当会话切换或权限降级时，必须执行 `memory_partition_replay_pass`；
   - 若历史条目所属分区高于当前权限矩阵，直接 quarantine，不得晋级。
4. **并列 required checks**
   - `scope_manifest_pass`
   - `scope_drift_budget_pass`
   - `memory_partition_replay_pass`
   任一失败即冻结 candidate->issue/PR 晋级链路。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `memory_partition_manifest.json` | `run_id`, `memory_tier`, `namespace`, `retention_ttl` | 缺 tier 或 namespace 即 fail |
| `memory_scope_matrix.yaml` | `capability`, `max_memory_tier`, `allowed_namespaces` | 未配置 capability 默认只读 `M0` |
| `promotion_packet.json` | `memory_partition_replay_pass`, `blocked_reason`, `evidence_refs` | `memory_partition_replay_pass=false` 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML Gist，说明“入口稳定、内容动态”适合持续采样与分区门禁。
2. HN `show` 出现 AgentMailr（可读写邮箱），提示 Agent 正在接触高敏感外部系统，需要把“外部同步记忆”单独治理。
3. HN `newest` 的 `Be Careful with LLM Agents` 与 `top` 的 headless client 信号共同指向：长链路自动化正在扩大记忆复用面。
4. OpenAI Background mode 文档显示异步状态机，`completed` 不等于“可安全晋级”。
5. OpenAI Conversation state 文档给出会话链标识，可作为记忆重放校验绑定键。
6. GitHub `GITHUB_TOKEN` 文档强调最小权限，证明 capability 必须显式声明而非隐式继承。
7. GitHub protected branches 的 required checks 可承载 `memory_partition_replay_pass` 为硬门禁。
8. HN API 的 `topstories/showstories/newstories` 可提供分车道证据回放输入。

## 反模式

- 把持久化记忆当作“上下文缓存”，不纳入权限模型。
- 只按会话权限做 gate，不校验历史记忆所属分区。
- 权限降级后继续读取高分区历史记忆并直接晋级。
- 仅记录记忆来源 URL，不记录分区 tier 与 namespace。
