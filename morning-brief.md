# Morning Brief（Nightshift Cycle 7）

> 更新时间：2026-02-28 18:07 UTC  
> 本轮目标：把“执行证据包”前移到 Issue 入口，减少无人流程的末端补材料风险。

## 本轮新增（已落盘）

1. `product-delivery/proof-bundle-issue-form-gate`

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：本轮确认重定向到 HN Popular Blogs OPML（Gist），继续作为长周期作者池。
- HN `top/show/newest`：已采样，核心信号包括：
  - top: `Verified Spec-Driven Development (VSDD)`
  - show: `SQLite for Rivet Actors – one database per agent, tenant, or document`
  - newest: `Agentic Engineering – Choosing the Right Level of Guidance`
- 官方证据链已补齐：GitHub Issue Forms 语法（官方 docs 源仓库）、GitHub PR-issue linking、GitHub Artifacts、OpenAPI、Pact。

## 本轮结论

- 证据包不应只在 PR 阶段补齐，必须在 Issue Form 阶段先定义字段与完成判据。
- 可控守门的关键不是“多跑测试”，而是“入口字段 + 中段关联 + 末段证据存档”三段闭环。
- 对 24h 无人推进，最小可审计单元应固定为 `Issue -> PR -> artifacts bundle -> commit`。

## Cycle 8 预载任务

1. 产出 `proof_bundle_required=true` 的 Issue Form 示例片段（可直接复制到 `.github/ISSUE_TEMPLATE`）。
2. 给 `proof-bundle-check` 增加缺失字段提示文案（不是只报 fail）。
3. 定义回放失败样本命名规范：`{case_id}_{contract_version}_{commit_sha}.json`。

---

> 历史：Cycle 6 的 `execution-proof-bundle` 已保留在 `product-delivery` 主题。
