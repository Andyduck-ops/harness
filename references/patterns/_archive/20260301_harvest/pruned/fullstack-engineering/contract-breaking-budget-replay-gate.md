---
name: contract-breaking-budget-replay-gate
topic: fullstack-engineering
confidence: 0.77
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28, revisions=6)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, item 47196582)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, item 47195123)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, items 47198926/47198676)
  - Hacker News API (https://github.com/HackerNews/API)
  - OpenAPI Specification v3.1.2 (https://spec.openapis.org/oas/v3.1.2.html)
  - Pact docs: provider verification (https://docs.pact.io/provider)
  - GitHub Docs: required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
merge_upgrade_of:
  - references/patterns/fullstack-engineering/backend-contract-first.md
  - references/patterns/fullstack-engineering/contract-replay-verification-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

在 24h 无人推进里，“契约优先”经常在落地时退化成二选一：

- 要么太严，任何差异都阻断，导致交付停摆；
- 要么太松，靠人工判断 `breaking`，导致不兼容变更混入主干。

根因不是“有没有契约”，而是**没有把破坏性变更预算与消费者回放覆盖绑定成同一个可审计闸门**。

## 核心解法

建立 **Contract Breaking Budget + Replay Gate（CBBRG）**：

1. **语义差异分级（Semantic Diff）**
   - 以 `openapi.yaml` 为基线，CI 自动计算 `added/changed/removed`。
   - 标记 `breaking_delta`（删除字段、收窄约束、状态码语义变化等）。
2. **破坏预算（Breaking Budget）**
   - 每个迭代窗口设定 `max_breaking_delta`，超出即 `hold`。
   - 预算不是豁免，而是把“可接受破坏”显式化并可追责。
3. **消费者回放覆盖（Consumer Replay Coverage）**
   - Provider 变更后必须通过 Pact provider verification 与关键回放集。
   - 若 `replay_coverage < threshold`，即使 diff 较小也不得晋级。
4. **合并门禁（Required Checks）**
   - 将 `contract_diff`, `provider_verify`, `replay_verify`, `budget_decision` 设为 required checks。
   - 任一失败，禁止合并，避免夜间“先并后补”。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `contract_diff_report.json` | `base_sha`, `head_sha`, `breaking_delta`, `diff_summary` | `breaking_delta` 必须可追溯 |
| `breaking_budget.json` | `window_id`, `max_breaking_delta`, `used_delta`, `decision` | `used_delta > max` => `hold` |
| `provider_verify_report.json` | `provider_version`, `consumer_matrix`, `failed_pairs` | 有失败对 => `fail` |
| `replay_coverage.json` | `suite_id`, `critical_paths`, `coverage_ratio`, `failed_cases` | 低于阈值 => `fail` |
| `promotion_packet.json` | `decision`, `blocked_reason`, `required_checks` | 无完整 checks 不得晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 当前重定向到 HN Popular Blogs OPML（Gist），且存在多次修订，说明“信源入口稳定”不等于“结论可直接复用”，必须绑定版本与预算。
- HN `top/show/newest` 同时活跃，且 `newest` 分钟级刷新（本轮采样出现 59m/1m 条目），表明无人时窗里变更速率很高，二值门禁容易失真。
- HN API 提供 `topstories/showstories/newstories` 稳定入口，适合把三榜采样落为可回放主键。
- OpenAPI 规范提供机器可读契约基线；Pact provider verification 提供消费者视角的兼容性验证；两者结合才能覆盖“定义正确 + 消费可用”。
- GitHub required status checks 可把预算与验证结果变成不可绕过的合并约束，避免“口头通过”。

## 反模式

- 只有 `breaking/non-breaking` 文本标签，没有定量预算账本。
- 只做 OpenAPI diff，不做 provider verification 与回放覆盖。
- 回放只看“是否通过”，不记录覆盖率与失败对清单。
- 检查项不是 required checks，夜间可被临时绕过。
