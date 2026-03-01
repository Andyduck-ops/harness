---
name: proof-bundle-issue-form-gate
topic: product-delivery
confidence: 0.76
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-02-28)
  - Hacker News top/show/newest snapshot (2026-02-28)
  - GitHub Docs source: Syntax for issue forms (https://raw.githubusercontent.com/github/docs/main/content/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms.md)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub Docs: Storing workflow data as artifacts (https://docs.github.com/en/actions/using-workflows/storing-workflow-data-as-artifacts)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs (https://docs.pact.io/)
last_verified: 2026-02-28
rank: 3
---

## 元问题

PRD -> Epic -> Issue -> PR 的链路里，最常丢的是“执行证据字段”：
Issue 建得快，但没人强制在入口声明契约版本、回放计划和交付证据格式，导致 PR 阶段才补材料，夜间无人流程容易失真。

## 核心解法

把 Issue Form 变成证据包闸门前置层（Issue Intake Gate）：

1. **入口强约束（Issue Form）**
   - 在 Issue Form 中设置必填字段：`prd_slice`、`epic_id`、`contract_surface`、`replay_plan`、`proof_bundle_required`
   - 使用 YAML required 字段确保缺失即无法提交
2. **中段可追踪（PR 绑定 Issue）**
   - PR 描述必须带 `Fixes/Closes #issue`，让交付状态自动回写到 Issue
3. **末段可审计（Artifact 证据包）**
   - CI 将 `openapi_diff`、`pact_verify`、`replay_report`、`storybook_delta` 作为 artifacts 存档
   - 审核只看“证据包是否完整”，而非口头描述

## 本轮信号蒸馏

- `https://t.co/dwAiIjlXet` 本轮重定向至 HN Popular Blogs OPML（Gist），可作为长周期作者池。
- HN `top` 出现 `Verified Spec-Driven Development (VSDD)`，强化“规格先行 + 验证闭环”。
- HN `show` 出现 “one database per agent/tenant/document” 类工程化实践，提示多代理执行中的隔离与可追踪需求。
- HN `newest` 出现 `Agentic Engineering – Choosing the Right Level of Guidance`，与“前置闸门防失控”方向一致。

## 次日可执行模板（最小字段集）

| 字段 | 作用 |
|------|------|
| `prd_slice` | 需求来源切片 |
| `epic_id` | 与 Epic 映射 |
| `contract_surface` | 受影响接口/事件/消息契约 |
| `contract_version` | 变更前后版本 |
| `replay_plan` | 回放范围与样本来源 |
| `proof_bundle_required` | 是否阻断合并（默认 true） |
| `done_when` | 完成判定（必须含 artifacts） |

## 验证闸门建议

1. `issue-form-lint`：检查新 Issue 是否包含上述必填字段。
2. `proof-bundle-check`：PR CI 校验 artifacts 是否齐全。
3. `contract-replay-check`：若 `contract_surface != none`，则强制跑 Pact + replay。

## 反模式

- 只要求“PR 关联 Issue”，不要求 Issue 提前定义证据结构。
- 把 `contract_version` 与 `replay_plan` 放到 PR 阶段临时补填。
- CI 只看测试通过，不检查可审计 artifacts 是否存在。
