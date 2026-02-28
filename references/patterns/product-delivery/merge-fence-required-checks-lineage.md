---
name: merge-fence-required-checks-lineage
topic: product-delivery
confidence: 0.79
verified_count: 11
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-02-28)
  - Hacker News top/show/newest snapshot (2026-02-28)
  - OpenAI Docs: Background mode guide (https://platform.openai.com/docs/guides/background)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs: How Pact works (https://docs.pact.io/getting_started/how_pact_works)
  - Design Tokens Format Module (https://www.designtokens.org/tr/2025.10/format/)
  - Storybook Docs: Writing stories (https://storybook.js.org/docs/writing-stories)
last_verified: 2026-02-28
rank: 3
---

## 元问题

我们已经有了 Issue 字段、PR 关联、前端 token、后端契约与回放，但无人值守时仍会出现“看起来都做了，实际上可以绕过”的问题。
根因不是缺证据，而是这些证据没有被绑定为同一个**强制合并闸门**。

## 核心解法

使用 **Merge Fence（合并围栏）**：把四个固定方向收敛为同一组 `required status checks`，并由统一 `lineage_id` 串联。

1. **夜间推进车道（可控 + 可审计）**
   - 长任务由后台异步执行（Background mode）。
   - 只允许知识沉淀与本地 commit，禁止自动 push。
2. **前端设计系统车道（次日可实战）**
   - 必过 `design-gate`：`token_diff` + `storybook_delta`。
3. **后端契约回放车道**
   - 必过 `contract-gate`：`openapi_diff` + `pact_verify` + `replay_report`。
4. **交付闭环车道（PRD -> Pattern）**
   - Issue Form 强制 `lineage_id/prd_slice/epic_id`。
   - PR 必须关联 Issue，CI 必须上传 `lineage-manifest` 证据包。

最终只认一件事：受保护分支是否通过这组必选检查。

## 最小必过检查（建议）

| Check 名称 | 关键输入 | 失败处理 |
|-----------|----------|---------|
| `design-gate` | `token_diff`, `storybook_delta` | 阻断合并 |
| `contract-gate` | `openapi_diff`, `pact_verify`, `replay_report` | 阻断合并 |
| `lineage-gate` | `lineage_id`, `issue_link`, `artifact_index` | 阻断合并 |

## 最小 lineage 清单字段

| 字段 | 说明 |
|------|------|
| `lineage_id` | 全链路唯一主键 |
| `prd_slice` | 需求切片 |
| `epic_id` | Epic 映射 |
| `issue_id` | 执行入口 |
| `pr_number` | 交付出口 |
| `token_scope` | 前端影响面 |
| `contract_surface` | 后端契约影响面 |
| `contract_version` | 契约版本 |
| `commit_sha` | 代码指纹 |

## 本轮信号蒸馏

- OPML（`https://t.co/dwAiIjlXet`）仍可稳定提供 HN 高质量作者池。
- HN `top/show/newest` 同时出现“长期 AI 编程实战”“Spec 驱动开发”“Agent 可信性争议”等信号，指向同一结论：必须把自动推进绑定到强制闸门，而不是依赖口头流程。
- 官方文档证据链闭合：Issue Form（入口结构化）+ PR 关联（状态回写）+ Protected Branch（合并围栏）+ Artifact（审计存档）+ OpenAPI/Pact/Design Tokens/Storybook（前后端闸门输入）。

## 明日可执行动作

1. 在分支保护中将 `design-gate/contract-gate/lineage-gate` 设为 required。
2. 将 `lineage_id` 下沉到 Issue Form 必填字段，禁止手填可选。
3. 合并后只允许由 `lineage-manifest.json` 触发 Pattern 回写。

## 反模式

- 闸门存在但不是 required check（可被绕过）。
- 前端与后端各自通过，但没有统一 `lineage_id`。
- 有日志无结构化清单，次日无法快速复盘。
