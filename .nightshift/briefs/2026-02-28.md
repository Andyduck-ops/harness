# Morning Brief（Nightshift Cycle 8）

> 更新时间：2026-02-28 18:12 UTC  
> 本轮目标：把 `Issue -> PR -> Artifact` 统一为可审计的 lineage 主键，避免次日无法快速验收。

## 本轮新增（已落盘）

1. `product-delivery/issue-pr-artifact-lineage-manifest`

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：本轮确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/newest`：已采样，核心信号包括：
  - top: `I tried using Claude Code for a month. Here's what I learned`
  - show: `SQLite for Rivet Actors: One database per agent, tenant, or document`
  - newest: `A lot of us are using Cursor AI to do coding ...`
- 官方证据链已补齐：GitHub Issue Forms、PR-issue linking、Actions Artifacts、OpenAPI、Pact、Design Tokens、Storybook。

## 本轮结论

- 无人流程里“有日志但不可审计”的核心原因是缺少统一主键，不是缺少更多测试步骤。
- 应把 `lineage_id` 在 Issue 阶段定义，并贯穿到 PR 与 artifacts 命名。
- 回放与证据命名必须标准化：`{case_id}_{contract_version}_{commit_sha}.json`。

## Cycle 9 预载任务

1. 增加 `lineage-manifest-check`（缺字段直接 fail）。
2. 产出 `.github/ISSUE_TEMPLATE` 可复制片段（含 `lineage_id` 与双闸门字段）。
3. 将 `lineage-manifest.json` 接入 Pattern 回写流程，作为唯一入参。

---

> 历史：Cycle 7 的 `proof-bundle-issue-form-gate` 已保留在 `product-delivery` 主题。
