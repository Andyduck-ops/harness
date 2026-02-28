---
name: dual-gate-execution-card
topic: product-delivery
confidence: 0.79
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (2026-02-28)
  - Hacker News top/show/new snapshot (2026-02-28)
  - OpenAI Background mode docs (https://platform.openai.com/docs/guides/background)
  - GitHub linking pull requests to issues docs (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs (https://docs.pact.io/)
  - Design Tokens Community Group Format Module (https://www.designtokens.org/tr/drafts/format/)
last_verified: 2026-02-28
rank: 3
---

## 元问题

PRD -> Epic -> Issue -> PR 的链路常见“看起来闭环、实际上失真”：
前端缺少可执行的设计系统约束，后端缺少契约回放硬闸门，最终无法稳定沉淀为可复用 pattern。

## 核心解法

把每个 Issue 标准化为 **Dual Gate Execution Card（双闸门执行卡）**，并由夜间 runner 自动推进：

1. **前端闸门（Design System Gate）**
   - 明确 `token_scope`（本次涉及的设计 Token）
   - 要求 `storybook_delta`（组件状态差异）
2. **后端闸门（Contract Replay Gate）**
   - 明确 `openapi_diff`（契约变更）
   - 要求 `pact_verify` + `replay_result`
3. **闭环闸门（Delivery Closure Gate）**
   - PR 必须显式关联 Issue（closing keywords）
   - 合并后 24h 内回写 pattern，否则退回 `needs-knowledge-sync`
4. **无人推进闸门（Unattended Guardrail）**
   - 长耗时任务走后台队列（Background mode）
   - 仅允许知识库写入与本地 commit，保留可审计轨迹

## 执行卡最小字段（可直接落 Issue Form）

| 字段 | 说明 |
|------|------|
| `prd_slice` | 对应 PRD 切片 |
| `epic_id` | 对应 Epic |
| `token_scope` | 受影响 design tokens |
| `storybook_delta` | 组件可视化差异链接 |
| `openapi_diff` | 契约差异摘要 |
| `pact_verify` | 契约验证结果 |
| `replay_result` | 关键流量回放结果 |
| `pattern_backlink` | 合并后回写 pattern 链接 |

## 证据链（本轮）

- `https://t.co/dwAiIjlXet` 已重定向到 HN Popular Blogs OPML，可作为稳定作者池。
- HN `top/show/new` 同日仍持续出现 AI 工程化与自动化执行相关项目，适合作为当日增量信号。
- OpenAI Background mode 官方文档支持异步长任务，适合夜间批处理执行。
- GitHub 官方文档明确 PR 关联 Issue 的闭环方式（closing keywords）。
- OpenAPI + Pact 官方文档分别覆盖契约定义与兼容验证。
- Design Tokens Community Group 规范为前端设计系统落地提供统一格式基线。

## 明日可执行动作

1. 新建统一 Issue Form：强制收集双闸门字段。
2. CI 串联检查：`design-gate -> contract-gate -> pr-link-gate`。
3. 合并后自动触发 pattern 回写检查，超时回退状态。

## 反模式

- 只做 PR 关联，不做设计系统与契约回放验证。
- 只跑契约校验，不保留可回放失败资产。
- 合并后不回写 pattern，知识无法复用。
