---
name: issue-pr-artifact-lineage-manifest
topic: product-delivery
confidence: 0.78
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-02-28)
  - Hacker News top/show/newest snapshot (2026-02-28)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs (https://docs.pact.io/)
  - Design Tokens Format Module (https://www.designtokens.org/tr/drafts/format/)
  - Storybook Docs (https://storybook.js.org/docs/get-started/frameworks/web-components-webpack5)
last_verified: 2026-02-28
rank: 3
---

## 元问题

无人值守链路里最常见的审计断点是：
Issue、PR、CI artifacts 都存在，但三者无法稳定对齐到同一个“执行证据主键”，次日很难快速判断这次变更是否真的完成了前端设计系统与后端契约回放要求。

## 核心解法

把 `Issue -> PR -> Artifact` 固化为同一条 **Lineage Manifest**（血缘清单）：

1. **Issue 入口建主键**
   - Issue Form 强制字段：`lineage_id`、`prd_slice`、`token_scope`、`contract_surface`、`contract_version`、`replay_plan`。
   - `required: true`，缺失即禁止创建。
2. **PR 中段做绑定**
   - PR 描述必须包含 `Closes/Fixes #issue` 和 `lineage_id`。
   - 让状态回写与证据主键同时成立。
3. **CI 末段产出清单**
   - 统一生成 `lineage-manifest.json`，字段覆盖前端与后端闸门结果。
   - 统一上传 artifacts，命名必须带 `contract_version + commit_sha`。
4. **Nightshift 落盘守门**
   - 仅当 manifest 完整且可追溯时，允许进入 Pattern 回写与本地 commit。

## 最小 Manifest 字段

| 字段 | 说明 |
|------|------|
| `lineage_id` | 本次执行全链路唯一标识 |
| `issue_id` | Issue 编号 |
| `pr_number` | PR 编号 |
| `prd_slice` | 需求切片 |
| `token_scope` | 前端设计 token 影响面 |
| `storybook_delta` | 组件差异证据 |
| `contract_surface` | API/事件契约影响面 |
| `contract_version` | 契约版本号 |
| `pact_verify` | 契约测试结果 |
| `replay_report` | 回放结果摘要 |
| `commit_sha` | 代码指纹 |

## 命名规范（回放与证据）

- 回放失败样本：`{case_id}_{contract_version}_{commit_sha}.json`
- 证据包建议：`{lineage_id}/artifacts/{artifact_type}_{contract_version}_{commit_sha}.{ext}`

## 本轮信号蒸馏

- OPML 长周期池继续可用：`https://t.co/dwAiIjlXet` 当前重定向到 HN Popular Blogs OPML（Gist）。
- HN `top` 出现“长期实战 Agent 工程经验”类帖子，强化“过程可追溯”优先级。
- HN `show/newest` 继续出现 Agent 工程与工具化讨论，说明“证据主键化”是稳定推进的必要基础设施。
- 官方文档证据链可闭合：Issue Form 必填、PR 关联、Actions artifact、OpenAPI、Pact、Design Tokens、Storybook 均有明确规范入口。

## 明日可执行动作

1. 在 `.github/ISSUE_TEMPLATE` 增加 `lineage_id` 与双闸门字段。
2. CI 新增 `lineage-manifest-check`，缺字段直接阻断。
3. 将 `lineage-manifest.json` 作为合并后 Pattern 回写的唯一输入。

## 反模式

- 只要求 PR 关联 Issue，不要求证据主键一致。
- 只上传测试日志，不产出结构化 manifest。
- 前端/后端各自通过，但没有统一交付指纹。
