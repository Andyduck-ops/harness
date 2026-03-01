---
name: workspace-recovery-envelope
topic: recovery-governance
confidence: 0.78
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-03-01)
  - Hacker News top/show/newest snapshots (https://news.ycombinator.com/news, https://news.ycombinator.com/show, https://news.ycombinator.com/newest)
  - Show HN: Claude-File-Recovery (https://news.ycombinator.com/item?id=45217278)
  - Show HN: Unfucked (https://news.ycombinator.com/item?id=45211872)
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - GitHub Docs: Store and share data with workflow artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - Git Docs: git-reflog (https://git-scm.com/docs/git-reflog)
last_verified: 2026-03-01
rank: 3
---

## 元问题

无人值守 AI 长时推进里，最常见的中断不是“模型不会写”，而是**会话断裂后不可恢复**：

- 文件被多轮改写但没有可回放轨迹；
- 任务被中断后只剩日志文本，没有结构化恢复点；
- 次晨接管者无法判断该从哪一个状态继续。

根因是多数团队只做“结果审计”，没做“过程可恢复”。

## 核心解法

引入 **Workspace Recovery Envelope（工作区恢复信封）**，把每轮执行最小化为可重建单元：

1. **Append-only 操作账本**
   - 每个原子动作记录 `lineage_id/step_id/tool/input_hash/output_hash/timestamp`。
   - 只追加不覆盖，避免恢复时丢上下文。
2. **Checkpoint 指针**
   - 每 N 步生成可回滚锚点（`checkpoint_id` + `commit_sha` + `reflog_ref`）。
   - 中断后先回到最近 checkpoint，再按 step 重放。
3. **Artifact 快照**
   - 每轮将 `recovery-manifest.json` + 关键 diff + 回放结果打包成 artifacts。
   - 人工接管时先读 manifest，再决定继续/回滚/终止。

这把“运行成功率”目标升级成“恢复成功率”目标。

## 最小恢复清单

| 字段 | 说明 |
|------|------|
| `lineage_id` | 全链路主键 |
| `checkpoint_id` | 最近可恢复锚点 |
| `commit_sha` | 当前代码指纹 |
| `reflog_ref` | 本地回滚指针 |
| `pending_steps` | 未完成步骤列表 |
| `artifact_uri` | 本轮证据包地址 |
| `resume_policy` | `replay/rollback/manual` |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍重定向到 HN Popular Blogs OPML，可稳定供给长期高质量工程信号。
2. HN `show/newest/top` 同时出现 `Claude-File-Recovery`、`Unfucked`、`MemoryKit` 等恢复/版本化工具，说明“恢复能力”已是自治编程的一线痛点。
3. OpenAI Background mode 支持异步长任务，意味着任务天然会跨会话运行，恢复锚点是必需品而非可选项。
4. GitHub Actions artifacts 提供结构化产物留存路径，可作为接管入口。
5. `git reflog` 为本地历史指针提供可追溯恢复基座，适合和 checkpoint 绑定。

## 明日可执行动作

1. 新增 `recovery-manifest-lint`：缺 `checkpoint_id` 或 `resume_policy` 直接 fail。
2. 每轮执行结束自动写入 `pending_steps` 与 `reflog_ref`，禁止只写自然语言日志。
3. 在次晨 brief 固定显示“可恢复性得分”（是否具备可继续执行条件）。

## 反模式

- 只保留最终 diff，不保留中间恢复锚点。
- 只有“通过/失败”状态，没有 `pending_steps`。
- 将恢复依赖单一会话上下文，断线即失忆。
- 把 artifacts 当归档仓库，不做结构化接管入口。
