---
name: execution-proof-bundle
topic: product-delivery
confidence: 0.78
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (2026-02-28)
  - Hacker News top/show/new snapshot (2026-02-28)
  - OpenAI Background mode docs (https://platform.openai.com/docs/guides/background)
  - GitHub linking pull requests to issues docs (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs (https://docs.pact.io/)
  - Storybook Docs (https://storybook.js.org/docs/)
last_verified: 2026-02-28
rank: 3
---

## 元问题

PRD -> Epic -> Issue -> PR 的链路看似完整，但在无人值守推进时常出现“次日无法复盘”：
知道做了什么，却拿不出可重放、可审计、可复用的证据包。

## 核心解法

为每个可合并 PR 强制生成 **Execution Proof Bundle（执行证据包）**，把四个方向一次打通：

1. **前端设计系统证据**
   - `token_diff`：设计 token 变化
   - `storybook_delta`：组件状态矩阵变化
2. **后端契约与回放证据**
   - `openapi_diff`：契约变更摘要
   - `pact_verify`：契约验证结论
   - `replay_report`：关键流量回放结果
3. **交付闭环证据**
   - `issue_link`：PR 关闭对应 Issue
   - `prd_slice` / `epic_id`：需求来源映射
4. **夜间自治证据**
   - `run_id` / `commit_sha` / `timestamp`：后台执行审计字段
   - 所有产物本地落盘并 commit，不自动 push

## 本轮证据链

- `https://t.co/dwAiIjlXet` 可重定向到 HN Popular Blogs OPML，适合作为夜间稳定信号底座。
- HN `top/show/new` 同日仍有 “Spec-Driven Development”“不要盲信 AI agents” 等讨论，强化“要自动化也要可验证”的方向。
- OpenAI Background mode 支持长任务异步执行，适配夜间 runner 的分批推进。
- GitHub 官方文档支持 PR 关闭 Issue 的结构化闭环。
- OpenAPI + Pact 覆盖“定义契约 + 验证兼容”。
- Storybook 作为组件隔离验证层，可作为前端闸门证据来源。

## 执行证据包最小结构

| 字段 | 说明 |
|------|------|
| `bundle_id` | 证据包唯一标识 |
| `prd_slice` | 需求切片 |
| `epic_id` | Epic 标识 |
| `issue_link` | 对应 Issue 链接 |
| `token_diff` | 设计 token 变更 |
| `storybook_delta` | 组件可视化差异 |
| `openapi_diff` | 契约差异摘要 |
| `pact_verify` | 契约验证结果 |
| `replay_report` | 回放通过/失败详情 |
| `commit_sha` | 生成该证据包的提交 |

## 明日可执行动作

1. 在 Issue Form 增加 `proof_bundle_required` 字段并默认开启。
2. CI 增加 `proof-bundle-check`：缺任一关键字段则阻断合并。
3. 夜间 runner 对失败回放自动生成最小复现并归档到回归集。

## 反模式

- 仅要求“PR 关联 Issue”，不要求证据产物。
- 只做契约验证，不保留回放结果与复现材料。
- 让无人值守流程直接触发生产副作用，且无本地审计轨迹。
