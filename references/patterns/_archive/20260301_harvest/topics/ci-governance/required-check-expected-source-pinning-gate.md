---
name: required-check-expected-source-pinning-gate
topic: ci-governance
confidence: 0.79
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Clojure MCP - A Clojure library for building MCP servers")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "A Proposal for Implementing Claude Code in the Browser")
  - GitHub Docs: About protected branches (require status checks from a specific app + unique job names) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Troubleshooting required status checks (unexpected source and merge_group trigger requirements) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-status-checks)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About rulesets (simultaneous rule application with most restrictive result) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
merge_upgrade_of:
  - references/patterns/ci-governance/required-check-pending-deadlock-gate.md
  - references/patterns/product-delivery/required-checks-snapshot-closure-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

在 24h 无人推进里，很多团队已经做了 required checks 集合校验，但仍会在“来源身份”层面失效：

- 同名 check 可以由不同 workflow 或不同 GitHub App 上报；
- merge queue 进入 `merge_group` 后，若事件面未覆盖，来源会被替换为“缺席”；
- rulesets 与 branch protection 叠加时，真实生效规则可能改变“期望来源”。

结果是“看起来通过的是同名 check”，但并不是同一个身份主体，审计链失真。

## 核心解法

建立 **Required Check Expected Source Pinning Gate（RCESPG）**：
把每个 required check 从“名字校验”升级为“名字 + 来源 + 事件面”三元同一校验。

1. 来源钉住
   - 为每个 required check 声明 `expected_source`（GitHub App slug / workflow identity）。
2. 事件面并联
   - 强制 `pull_request` 与 `merge_group` 两个事件面都上报同一来源身份。
3. 规则面快照
   - 采集 rulesets + branch protection 的运行时快照，形成 `effective_required_rules`。
4. 结果判定
   - 仅当 `name_match && source_match && surface_match` 同时为真，`required_check_identity_pass=true`。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `required_check_identity_contract.json` | `check_name`, `expected_source`, `required_events[]` | 缺少 `expected_source` |
| `required_check_identity_runtime.json` | `event`, `check_name`, `reported_source`, `sha`, `conclusion` | `reported_source` 缺失或与 contract 不同 |
| `required_check_identity_diff.json` | `source_mismatch[]`, `event_missing[]`, `identity_pass` | `identity_pass=false` 仍晋级 |
| `promotion_decision.json` | `required_check_identity_pass`, `required_checks_snapshot_pass`, `decision` | 任一 false 仍 `promote` |

建议新增 required checks：

- `required_check_identity_pass`
- `required_check_source_pinning_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到 OPML Gist，证明入口稳定但内容长期演化，要求身份校验可回放。
2. HN `news/show/newest` 同窗样本显示夜间信号持续高频变化，说明自动推进必须抵御“同名不同源”误判。
3. GitHub protected branches 文档明确支持将 status check 绑定到特定 app 来源，并要求 job 名唯一，直接指向“来源身份”是一等约束。
4. GitHub troubleshooting 文档指出 required checks 在来源不符合预期或缺少 `merge_group` 触发时会阻塞合并，验证事件面和来源必须联动校验。
5. GitHub rulesets 文档说明多个规则会同时应用且取更严格结果，证明“期望来源”必须基于运行时规则面快照，而非静态假设。

## 反模式

- 只校验 check 名称，不校验来源 app/workflow 身份。
- `pull_request` 路径校验来源，`merge_group` 路径不校验。
- ruleset 变更后继续复用旧来源白名单。
- 同名 job 在多个 workflow 里复用，导致 required checks 结果不可区分。
