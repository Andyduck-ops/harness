---
name: compaction-recovery-contract
topic: context-governance
confidence: 0.77
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-03-01)
  - Hacker News top/show/new snapshots (https://news.ycombinator.com/news, https://news.ycombinator.com/show, https://news.ycombinator.com/newest)
  - HN Top: Stop Burning Your Context Window (https://news.ycombinator.com/item?id=45218039)
  - HN Show: Claude-File-Recovery (https://news.ycombinator.com/item?id=45217278)
  - HN Show: Unfucked (https://news.ycombinator.com/item?id=45211872)
  - OpenAI Docs: Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - OpenAI Docs: Background mode (https://platform.openai.com/docs/guides/background)
  - GitHub Docs: Store and share data with workflow artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - Git Docs: git-reflog (https://git-scm.com/docs/git-reflog)
last_verified: 2026-03-01
rank: 3
---

## 元问题

长时自治流程里，大家把“上下文压缩”当成纯成本优化，但真正故障点是：
**压缩后无法恢复执行语义**。

结果是 token 省下来了，但次晨接管者拿不到“还剩哪些步骤、从哪个检查点继续、对应哪份证据包”。

## 核心解法

引入 **Compaction Recovery Contract（CRC）**，把压缩动作改为可恢复交接动作：

1. **触发门槛**
   - 触发条件不是“窗口快满”本身，而是“窗口快满且本轮还有未完成动作”。
   - 一旦触发，禁止只写自然语言摘要，必须产出结构化压缩快照。
2. **结构化压缩快照**
   - 统一写出 `compaction-manifest.json`，至少包含 `goal/decisions/completed_steps/pending_steps/checkpoint_id/reflog_ref/artifact_index/resume_cmd`。
3. **双落盘**
   - 快照写入仓库（可审计）+ CI artifacts（可交接），保证会话中断后仍可取回。
4. **恢复前校验**
   - 恢复执行前校验 `checkpoint_id + reflog_ref + commit_sha` 一致性，不一致先回滚到最近可验证点。

这把“压缩”从 token 技术细节，提升为自治系统的运行时契约。

## 最小合约字段

| 字段 | 作用 |
|------|------|
| `lineage_id` | 全链路唯一主键 |
| `goal` | 当前轮次目标 |
| `decisions` | 已确认决策 |
| `completed_steps` | 已完成步骤 |
| `pending_steps` | 待续步骤 |
| `checkpoint_id` | 恢复锚点 |
| `reflog_ref` | 本地历史指针 |
| `artifact_index` | 证据包索引 |
| `resume_cmd` | 接管后建议执行命令 |
| `commit_sha` | 状态写入时的代码指纹 |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML，说明可持续信号池可稳定维护。
2. HN top 出现“上下文窗口压缩”高热讨论（MCP 输出降幅案例），证明该痛点已从个体技巧转向工程议题。
3. HN show/new 同步出现恢复类工具（Claude-File-Recovery、Unfucked），侧面证明“压缩后可恢复”是现实生产问题。
4. OpenAI Conversation state 文档明确存在 conversation compaction 机制；Background mode 进一步放大跨会话执行需求。
5. GitHub artifacts 与 `git reflog` 提供“跨会话恢复 + 本地回滚”两条证据链落点。

## 反模式

- 把 compaction 当作“自动摘要”而非“可恢复交接”。
- 只记录“做了什么”，不记录 `pending_steps` 和恢复指针。
- 仅保留 CI 日志，不保留结构化 manifest。
- 恢复时直接继续执行，不校验 checkpoint 与代码指纹一致性。
