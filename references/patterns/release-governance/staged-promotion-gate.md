---
name: staged-promotion-gate
topic: release-governance
confidence: 0.83
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-03-01)
  - Hacker News top/show/newest snapshots (https://news.ycombinator.com/news, https://news.ycombinator.com/show, https://news.ycombinator.com/newest)
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: Deployments and environments (https://docs.github.com/en/actions/reference/workflows-and-actions/deployments-and-environments)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-03-01
rank: 2
---

## 元问题

无人值守 AI 流程已经能在夜间持续产出，但如果把“探索产出”和“环境副作用”放在同一条车道，
要么会过度冒险，要么会因审批卡死吞吐。问题不在自动化能力，而在**晋级机制缺失**。

## 核心解法

建立 **Staged Promotion Gate（两段式晋级闸门）**：

1. **夜间证据车道（无人）**
   - 仅允许后台任务产出代码与证据，不触发部署副作用。
   - 强制落盘 `lineage-manifest` + 回放结果 + 变更审计字段。
2. **白天晋级车道（有人）**
   - 进入环境前必须通过 required reviewers。
   - 开启 `prevent self-reviews`，禁止提交者自审晋级。
3. **统一合并围栏**
   - 受保护分支启用 required status checks。
   - 对主分支启用“Require deployments to succeed before merging”。

这样可以把“夜间产出效率”与“白天发布安全”同时最大化，而不是二选一。

## 证据链

1. `https://t.co/dwAiIjlXet` 已重定向至 HN Popular Blogs OPML（Gist），可作为稳定长周期作者池。
2. HN `news/show/newest` 同时出现长期 AI 编程、开发工具链与自治可靠性讨论，短周期信号持续活跃。
3. OpenAI Background mode 支持异步长任务处理，适配夜间无阻塞批处理。
4. GitHub 官方文档明确支持：
   - 环境 required reviewers（可配置最多 6 人/组，任一批准即可继续）
   - `prevent self-reviews`（发起部署者不能自己批准）
   - 受保护分支 required status checks
   - merge 前要求 deployment 成功

## 最小晋级清单

| 字段 | 说明 |
|------|------|
| `lineage_id` | 全链路主键 |
| `risk_tier` | 风险等级（L0/L1/L2） |
| `required_checks` | 必过检查名集合 |
| `deployment_env` | 目标环境 |
| `reviewer_group` | 审批人/组 |
| `replay_report` | 回放结论与失败样本索引 |
| `commit_sha` | 代码指纹 |

## 明日可执行动作

1. 在 `.github` 增加 `promotion-manifest-lint`，字段缺失直接 fail。
2. 把 `deployment_env` 映射到 GitHub environment，并启用 required reviewers + prevent self-reviews。
3. 在受保护分支开启 required checks + require successful deployments。

## 反模式

- 让夜间 runner 直接发布到受保护环境。
- 有 required reviewers 但允许自审。
- 只要求测试通过，不要求 deployment success 再 merge。
- 证据散落在日志，缺少结构化晋级清单。
