---
name: required-checks-snapshot-closure-gate
topic: product-delivery
confidence: 0.79
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Syncari – AI-driven Infrastructure as Code Automation")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "A Proposal for Implementing Claude Code in the Browser")
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Huge pages and garbage collection in the Java virtual machine")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Open social network")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "DuckDB + LLMs to parse and process arbitrary CSV files")
  - GitHub Docs: About protected branches (required status checks) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-status-checks)
  - GitHub Docs: About rulesets (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: Creating issue templates for your repository (https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-issue-templates-for-your-repository)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub GraphQL Reference: `MergeQueueParametersInput` (`groupingStrategy`) (https://docs.github.com/en/graphql/reference/input-objects#mergequeueparametersinput)
  - GitHub Docs: About code scanning merge protection (https://docs.github.com/en/code-security/code-scanning/managing-your-code-scanning-configuration/set-code-scanning-merge-protection)
merge_upgrade_of:
  - references/patterns/ci-governance/required-check-pending-deadlock-gate.md
  - references/patterns/product-delivery/prd-epic-contract-replay-closure-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

`PRD -> Epic -> Issue -> PR` 字段闭环即使完整，也仍会在最终晋级点失真：
需求侧记录的“必跑检查集合”与实际 merge 时规则面上的 required checks 可能已经漂移（重命名、替换、事件面缺失、被规则叠加覆盖），
结果是“流程看似闭环，执行并非同一闭环”。

## 核心解法

建立 **Required Checks Snapshot Closure Gate（RCSCG）**，把“需求声明的检查集合”和“合并时真实检查集合”绑定为同一阻断条件。

1. 入口冻结（Issue Form）
   - Issue Form 必填 `required_checks_profile`、`required_checks_expected[]`、`contract_epoch`。
2. 中段回链（PR 关联）
   - PR 必须关联 Issue，并回填 `required_checks_profile` 与 `lineage_id`。
3. 双时点快照
   - 生成 `required_checks_baseline.json`（Issue/PR 入场时）；
   - 生成 `required_checks_runtime.json`（merge_group 出场前）。
4. 漂移判定
   - 生成 `required_checks_drift_report.json`，判定是否发生删除、重命名、事件面缺失（尤其 `merge_group`）。
5. 合并围栏
   - required checks 必须并联：
     - `required_checks_snapshot_pass`
     - `required_checks_drift_pass`
     - `contract_replay_closure_pass`

## 最小证据协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `required_checks_baseline.json` | `lineage_id`, `required_checks_profile`, `required_checks_expected[]`, `captured_at_utc` | baseline 缺失或空集合 |
| `required_checks_runtime.json` | `lineage_id`, `required_checks_runtime[]`, `event_surface[]`, `captured_at_utc` | 未覆盖 `merge_group` 事件面 |
| `required_checks_drift_report.json` | `removed_checks[]`, `renamed_checks[]`, `missing_events[]`, `drift_pass` | `drift_pass=false` 仍晋级 |
| `promotion_closure.json` | `required_checks_snapshot_pass`, `required_checks_drift_pass`, `contract_replay_closure_pass`, `decision` | 任一为 false 仍 `promote` |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到同一 OPML Gist，但该 Gist 本身会修订，说明入口稳定不等于规则面稳定。
2. HN `news/show/newest` 同窗持续高频变化，验证“夜间自动推进”和“检查面漂移”会同时发生，不能依赖一次性配置假设。
3. GitHub `merge_group` 文档明确指出：使用 merge queue 时，如 workflow 未在 `merge_group` 触发，required checks 不会报告。
4. GitHub required checks 规则与故障排查文档共同约束：检查需要在正确事件面、正确提交上下文中回报，否则可能 Pending/失效。
5. GitHub rulesets 可以与分支保护叠加，意味着“实际 required checks 集合”会随策略面变化；必须做运行时快照对账。
6. Issue Form 与 PR 关联机制提供了把“需求声明检查集合”传导到交付出口的结构化路径。

## 明日可执行动作

1. 在 Issue Form 新增 `required_checks_expected[]` 与 `required_checks_profile` 必填项。
2. CI 增加 `required_checks_baseline/runtime/drift` 三件套并上传 artifact。
3. 将 `required_checks_snapshot_pass` 与 `required_checks_drift_pass` 接入受保护分支 required checks。

## 反模式

- 只校验“有没有 checks 通过”，不校验“通过的是不是同一集合”。
- PR 路径校验齐全，但 merge queue 缺失 `merge_group` 触发。
- ruleset 或 branch protection 变更后继续复用旧的晋级结论。
- Issue 中没有声明预期 checks，导致“事后解释型”门禁无法审计。

## Cycle 103 同化增量：双平面门禁一致性（Status Checks vs Merge Protection）

目标：把 `required checks` 平面与 `merge protection` 平面统一纳入闭环，避免“状态检查全绿但仍不可合并”造成的信息失真。

1. 入口结构化增强（Issue Form Metadata）
   - GitHub Issue Form 支持 `id`、`validations.required`，并可在模板层声明 `projects` 与 `type`。
   - 动作：在 issue 入口补齐结构化元数据（`lineage_id`、`contract_epoch`、`required_checks_profile`），禁止仅靠正文自然语言传递。
2. 回链语义增强（PR Closure Semantics）
   - GitHub 文档明确 `Closes/Fixes` 触发关闭与默认分支语义强绑定，且手动关联上限为 10 个 issue。
   - 动作：`promotion_closure.json` 必须记录“默认分支合并事件”与“关联方式（keyword/manual）”，防止仅凭 PR 文本判定闭环。
3. merge queue 分组策略入账（Grouping Strategy as Contract）
   - GitHub GraphQL `MergeQueueParametersInput` 暴露 `groupingStrategy`（`ALLGREEN` / `HEADGREEN`）。
   - 动作：`required_checks_runtime.json` 新增 `merge_queue_grouping_strategy` 字段；若为 `HEADGREEN`，强制补跑 lineage 对应的 replay 样本，避免“组内头提交绿灯掩盖个体漂移”。
4. 双平面门禁并联（Status Checks + Code Scanning Merge Protection）
   - GitHub 文档明确：Code scanning merge protection 独立于 status checks，且不应用于 merge queue group。
   - 动作：晋级门禁拆成两条并联：
     - `required_checks_drift_pass`
     - `code_scanning_merge_protection_pass`
   - 任一失败均阻断，禁止用“checks 全绿”替代安全面结论。

## Cycle 103 检索锚点（L5）

- `issue form validations required projects type lineage_id`
- `merge queue groupingStrategy ALLGREEN HEADGREEN`
- `code scanning merge protection not status checks merge queue group`
