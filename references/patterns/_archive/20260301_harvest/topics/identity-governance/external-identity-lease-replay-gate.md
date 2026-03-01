---
name: external-identity-lease-replay-gate
topic: identity-governance
confidence: 0.77
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T22:03:20Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Obsidian Sync now has a headless client")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Now I Get It - Translate scientific papers into interactive webpages")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, signal titles include: "Show HN: AgentMailr, an MCP server that can read and write emails" and "Be Careful with LLM Agents")
  - OpenAI Docs: Responses API background mode (https://developers.openai.com/topics/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: Controlling permissions for GITHUB_TOKEN (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/permission-governance/agent-scope-manifest-escalation-gate.md
  - references/patterns/permission-governance/agent-memory-partition-least-privilege-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

无人值守链路里，Agent 往往会持有“可调用外部系统”的身份租约（邮箱、仓库、第三方 API）。
即使单次任务结束，这些身份凭证和会话链也可能被后续 run 继续复用，形成一种隐性越权：

1. 任务 A 在高权限下创建了外部会话；任务 B 降权运行却复用了 A 的身份上下文；
2. `completed` 被误当作“可安全晋级”，但没有证明外部身份已经解绑或过期；
3. 晋级门禁只看代码与测试，不看“身份租约是否仍有效”。

本质问题：**缺少“身份租约时效 + 会话回放绑定 + required checks”三位一体治理。**

## 核心解法

建立 **External Identity Lease Replay Gate（EILRG）**：

1. **身份租约清单化**
   - 每次外部系统访问都生成 `identity_lease_id`，并绑定 `issuer`, `scope`, `expires_at_utc`。
   - 没有租约 ID 的外部调用一律拒绝晋级。
2. **会话链绑定**
   - 在 `promotion_packet` 中记录 `conversation_id`/`previous_response_id` 与 `identity_lease_id` 的映射。
   - 回放时若发现“会话链连续但租约已过期或 scope 变化”，立即 quarantine。
3. **并列 required checks**
   - `scope_manifest_pass`
   - `memory_partition_replay_pass`
   - `identity_lease_replay_pass`
   任一失败，冻结 candidate -> issue -> PR 晋级。
4. **过期即失效，不允许隐式续租**
   - 租约续期必须产生新 ID，并重新执行全量 replay 检查。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `identity_lease_manifest.json` | `identity_lease_id`, `issuer`, `scope`, `expires_at_utc`, `run_id` | 缺 `expires_at_utc` 或 scope 空集直接 fail |
| `identity_replay_binding.json` | `identity_lease_id`, `conversation_ref`, `previous_response_id`, `replay_window_minutes` | 绑定链断裂或超窗直接 quarantine |
| `promotion_packet.json` | `identity_lease_replay_pass`, `lease_expired`, `scope_changed`, `blocked_reason` | `identity_lease_replay_pass=false` 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续指向 HN Popular Blogs OPML，说明外部信号入口稳定但内容持续漂移，适合做租约时效治理。
2. HN `newest` 出现 AgentMailr（可读写邮箱）与 `Be Careful with LLM Agents`，直接暴露“外部身份能力 + 代理自动化”的风险面。
3. OpenAI Background mode 文档体现任务可能异步跨时段运行，任务结束状态不能替代身份租约校验。
4. OpenAI Conversation state 文档提供会话链路标识，可作为回放绑定键。
5. GitHub `GITHUB_TOKEN` 文档强调显式权限最小化，支持“scope 变化必须重新验收”的门禁原则。
6. GitHub protected branches 的 required checks 能承载 `identity_lease_replay_pass` 作为硬门禁。
7. HN API 的 `topstories/showstories/newstories` 提供跨车道证据回放输入，支持追踪租约风险随时间的变化。

## 反模式

- 把外部账号凭证当作普通环境变量，不做租约生命周期管理。
- 只在任务启动时校验权限，不在晋级时重放身份绑定。
- 允许过期租约在重试流程里隐式续用。
- `promotion_packet` 不记录 `lease_expired` / `scope_changed`，导致审计不可追责。
