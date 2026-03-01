---
name: comprehension-budget-gate
topic: comprehension-governance
confidence: 0.76
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-02-28)
  - Hacker News top/show/new snapshot (2026-02-28)
  - Cognitive Debt: When Velocity Exceeds Comprehension (https://minds.md/zakirullin/cognitive)
  - VSDD: Verified Spec-Driven Development (https://gist.github.com/mlubinsky/73212dd00ef02051a171f48d3f5c4f65)
  - 747s and coding agents (https://www.seangoedecke.com/747s-and-coding-agents/)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
last_verified: 2026-02-28
rank: 3
---

## 元问题

AI 工程流程的瓶颈不再是“产出速度”，而是“团队能否在次日理解并接管这些产出”。
当生成速度超过理解速度，系统会积累 **认知债务**：
代码和文档看似齐全，但无人能快速判断风险边界与变更意图。

## 核心解法

引入 **Comprehension Budget Gate（理解预算闸门）**，把“可读可接管”变成合并前置条件，而不是事后补文档。

1. **预算约束（Budget）**
   - 每个交付单元限制“可一次理解”的变更规模（文件数、关键决策数、跨模块数）。
   - 超预算时强制拆单，不允许继续堆叠。
2. **解释包（Explainability Bundle）**
   - 必交三件套：`spec_delta.md`、`invariant_checklist.md`、`replay_cmds.md`。
   - 解释包作为 CI artifact 持久化，和 `lineage_id` 绑定。
3. **受保护分支闸门（Gate）**
   - 将 `comprehension-gate` 设为 required status check。
   - 未提交解释包或预算超标，直接阻断合并。
4. **状态延续（State Carryover）**
   - 会话状态只做摘要，不承载完整工程上下文。
   - 完整可回放证据由 artifact 与 manifest 持有，避免跨会话丢语义。

## 最小执行协议

| 组件 | 最小字段 | 验收标准 |
|------|----------|----------|
| `spec_delta.md` | 变更目标、非目标、影响边界 | 可在 5 分钟内回答“改了什么、没改什么” |
| `invariant_checklist.md` | 不变量列表、验证结果、失败回退策略 | 每条不变量都有验证证据 |
| `replay_cmds.md` | 复现命令、输入样本、预期输出 | 新接手者可在本地复现关键路径 |
| `comprehension_report.json` | `lineage_id`、预算指标、artifact 链接 | CI 自动校验并给出 pass/fail |

## 证据链

- HN Top 同时出现 `Cognitive Debt`、`VSDD` 与 `747s and coding agents`，共同指向同一风险：执行速度提升后，理解与验证成为主瓶颈。
- OPML（`https://t.co/dwAiIjlXet`）持续汇聚高信号工程博客，提供“认知债务/规格驱动/审计验证”共振证据。
- GitHub protected branch 支持 required checks，可将理解闸门从“建议”升级为“不可绕过约束”。
- GitHub Actions artifacts 可持久化解释包，保证次日可接管。
- OpenAI conversation state 指出会话状态管理需要明确边界，支持“摘要状态”和“可回放证据”分层。

## 反模式

- 只追求吞吐，不限制单次交付理解成本。
- 只写“变更总结”但不提供可复现命令和不变量清单。
- 把理解责任推给 reviewer 的主观经验，不做强制闸门。
- 仅依赖会话记忆，不保存可审计 artifact。
