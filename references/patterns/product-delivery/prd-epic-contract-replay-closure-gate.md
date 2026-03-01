---
name: prd-epic-contract-replay-closure-gate
topic: product-delivery
confidence: 0.80
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01)
  - HN news lane sample item 47202032 (https://news.ycombinator.com/item?id=47202032, checked 2026-03-01)
  - HN show lane sample item 47195530 (https://news.ycombinator.com/item?id=47195530, checked 2026-03-01)
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs: Provider verification (https://docs.pact.io/provider)
last_verified: 2026-03-01
rank: 3
---

## 元问题

`PRD -> Epic -> Issue -> PR` 链路即使字段齐全，仍可能在“后端契约回放”环节断裂：
人能看到 PR 关闭了 Issue，但无法证明该变更对应的契约版本确实被回放验证通过。

## 核心解法

建立 **PRD-Epic Contract Replay Closure Gate（PECRCG）**，把“需求血缘”和“契约回放”绑成同一必过门禁：

1. **入口守恒**
   - 在 Issue Form 强制 `prd_slice_id`、`epic_id`、`contract_surface`、`contract_epoch`、`replay_plan_id`。
2. **中段回链**
   - PR 必须 `Closes/Fixes #issue`，并携带相同 `contract_epoch`。
3. **末段回放**
   - CI 必须产出 `contract_replay_report.json`，包含 `contract_epoch`、`provider_verify_pass`、`replay_pass`。
4. **合并围栏**
   - protected branch required checks 必须同时包含：
     - `lineage_mapping_pass`
     - `contract_provider_verify_pass`
     - `contract_replay_closure_pass`

## 最小证据包

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `lineage_mapping.json` | `prd_slice_id`, `epic_id`, `issue_id`, `pr_number`, `contract_epoch` | 任一映射缺失即阻断 |
| `contract_replay_report.json` | `contract_epoch`, `provider_verify_pass`, `replay_pass`, `digest` | `provider_verify_pass=false` 或 `replay_pass=false` 即阻断 |
| `promotion_closure.json` | `lineage_mapping_pass`, `contract_replay_closure_pass`, `required_checks` | required checks 不完整即阻断 |

## 证据链

- HN `news/show/newest` 同窗采样继续体现“发现热度”和“执行成熟度”分离，不能用热度替代契约回放。
- GitHub Issue Form + PR 关联机制能稳定建立需求血缘字段传递。
- GitHub protected branches required checks 提供不可绕过的合并落点。
- OpenAPI 定义契约基线，Pact provider verification 提供消费者/提供者兼容验证，二者共同支撑 `contract_epoch` 可回放语义。

## 明日可执行动作

1. 在 Issue 模板新增 `contract_epoch` 与 `replay_plan_id` 必填字段。
2. CI 增加 `lineage_mapping.json` 与 `contract_replay_report.json` 一致性检查。
3. 将 `contract_replay_closure_pass` 加入受保护分支 required checks。

## 反模式

- 只校验 PR 关联 Issue，不校验 `contract_epoch` 一致性。
- 有契约测试无回放报告，或有回放报告无血缘映射。
- required checks 写在文档里但未接到分支保护规则。
