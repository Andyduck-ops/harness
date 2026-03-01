---
name: context-burn-replay-freeze-gate
topic: context-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01, gist last active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-03-01, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-03-01, top title: "Show HN: Syncari – AI-driven Infrastructure as Code Automation")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-03-01, top title: "A Proposal for Implementing Claude Code in the Browser")
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: Store and share data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/context-governance/compaction-recovery-contract.md
  - references/patterns/comprehension-governance/comprehension-debt-ratchet-freeze-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

长时无人运行时，最危险的点不是“上下文会变长”，而是：
**上下文被压缩后，系统还按“未压缩语义”继续晋级。**

典型事故路径是：

1. 工具输出暴涨，触发压缩；
2. 压缩只保留摘要，未保留结构化决策差分；
3. 后台 run 继续执行并产出晋级建议；
4. 次日审核只能看到结果，无法确认该结果是否仍绑定原证据。

本质矛盾：**token 成本优化与证据可回放性被割裂。**

## 核心解法

引入 **Context Burn Replay Freeze Gate（CBRFG）**，把“压缩”改成“可回放闸门事件”，不是静默优化：

1. **燃烧预算账本（Burn Ledger）**
   - 每轮记录 `prompt_tokens`, `tool_tokens`, `tool_output_ratio`, `burn_threshold`。
   - 当 `tool_output_ratio` 超阈值时强制进入压缩前快照流程。
2. **压缩前结构化快照（Pre-Compaction Snapshot）**
   - 必须落盘 `decision_deltas`, `pending_claims`, `lineage_id`, `artifact_digest`。
   - 缺任一字段，禁止进入后台续跑。
3. **回放冻结门（Replay Freeze）**
   - 续跑前验证 `previous_response_id` 链和 `conversation` 绑定是否连续。
   - 若上下文已压缩但 `artifact_digest` 不匹配，直接 `freeze=true`，禁止 `candidate -> issue/pr` 晋级。
4. **分支硬门禁（Required Checks）**
   - 受保护分支把 `context_burn_replay_pass` 设为 required。
   - 未解冻前只能继续采集，不可合并执行决策。

## 最小执行协议

| 文件 | 必填字段 | 闸门规则 |
|------|----------|----------|
| `context_burn_ledger.json` | `cycle`, `prompt_tokens`, `tool_tokens`, `tool_output_ratio`, `threshold` | 超阈值未触发快照 => fail |
| `pre_compaction_snapshot.json` | `lineage_id`, `decision_deltas`, `pending_claims`, `artifact_digest` | 缺字段 => freeze |
| `replay_integrity_report.json` | `previous_response_id_ok`, `conversation_chain_ok`, `artifact_digest_match`, `freeze` | 任一 false => `freeze=true` |
| `promotion_decision.json` | `context_burn_replay_pass`, `required_checks`, `decision`, `blocked_reason` | 未通过不得晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前仍重定向到 HN Popular Blogs OPML Gist，且 Gist 页面显示近期仍在维护，说明信号源活跃且会持续演化。
2. HN `news/show/newest` 在同日呈现不同类型高频信号（上下文窗口优化、IaC 自动化、浏览器内 Agent 执行），证明长时自治会持续承受工具输出抖动与语义切换。
3. OpenAI Background 文档给出后台状态机（`queued/in_progress/completed`）与取消语义，并强调 `store=true` 对后台模式必要；说明“可续跑”是官方支持能力，但不等于“可无损回放”。
4. OpenAI Conversation state 文档提供 `previous_response_id` 与 `conversation` 链接机制，并给出压缩相关端点，支持把“会话连续性”纳入结构化校验。
5. GitHub Artifacts 文档支持输出摘要与保留期配置，可将压缩前快照与回放报告持久化；Protected branches 的 required checks 可把该门禁变成不可绕过约束。

## 反模式

- 把上下文压缩当作透明优化，不产生结构化快照。
- 只记录最终摘要，不记录 `decision_deltas` 与 `pending_claims`。
- 后台续跑只看任务完成，不校验 `previous_response_id` 链。
- `context_burn_replay_pass` 不是 required check，导致夜间结果可绕过晋级。
