---
name: required-checks-snapshot-closure-gate
topic: product-delivery
confidence: 0.79
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01)
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Syncari – AI-driven Infrastructure as Code Automation")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "A Proposal for Implementing Claude Code in the Browser")
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Huge pages and garbage collection in the Java virtual machine")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Open social network")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "DuckDB + LLMs to parse and process arbitrary CSV files")
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top title: "Microgpt")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top title: "Show HN: Xmloxide – an agent made rust replacement for libxml2")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top title: "Ask HN: What did you find out or explore today?")
  - HN news lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01, top item id: 47202708, top title: "747s and Coding Agents")
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01, top item id: 47201816, top title: "Show HN: DreamBOMB")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top item id: 47203831, top title: "A Transition Experiment by reaching back in internet history")
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01, top item id: 47203590, top title: "SpecLock: Lightweight specs that your AI coding tool can understand")
  - GitHub Docs: About protected branches (required status checks) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-status-checks)
  - GitHub Docs: Troubleshooting required status checks (required source / 7-day freshness / skipped semantics) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-status-checks)
  - GitHub Docs: About rulesets (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
  - GitHub Docs: Available rules for rulesets (`workflows do not use branch/path/tag filters`) (https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets)
  - GitHub Docs: Troubleshooting rulesets (`required status checks` naming format / exact name / source) (https://docs.github.com/en/enterprise-server@3.19/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules)
  - GitHub Docs: Troubleshooting required workflows (new ruleset workflow won't run on existing open PRs unless branch updates/reopen) (https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-workflows)
  - GitHub Docs: Managing a merge queue (`Require all queue entries to pass required checks`, `Status check timeout` 5-60 mins) (https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Troubleshooting required workflows（仅支持 `pull_request`/`pull_request_target`/`merge_group`，并忽略 workflow 级 filters 与 `types`）(https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-workflows)
  - GitHub Docs: Troubleshooting required workflows（由 `GITHUB_TOKEN` 触发的事件不会触发 ruleset workflow；`cancel-in-progress` 可能导致 required workflow 不按预期执行）(https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules#troubleshooting-required-workflows)
  - GitHub Docs: Troubleshooting rulesets insights（ruleset insights 在 PR 合并或尝试合并后才记录）(https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/troubleshooting-rules)
  - GitHub Docs: Skipping workflow runs (workflow-level skip leaves checks pending) (https://docs.github.com/en/actions/how-tos/manage-workflow-runs/skip-workflow-runs)
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

## Cycle 107 同化增量：Ruleset Workflow 触发面与 Merge Queue 真实门禁

目标：把“声明 required checks”升级为“可运行、可触发、可对账”的真实门禁，减少 PRD 到交付出口的隐藏损失。

1. Ruleset Required Workflows 的触发范围不是“按工作流自身过滤器”
   - GitHub 文档明确：ruleset workflow 不使用目标 workflow 文件中的 `branches` / `paths` / `tags` 过滤器，且默认采用 workflow 的默认 activity types。
   - 动作：新增 `ruleset_effective_scope.json`，显式记录 ruleset 实际触发面，禁止沿用“工作流文件里写了过滤器就会生效”的假设。
2. 新增 required workflow 后，已有 open PR 不会自动补跑
   - GitHub 故障排查文档明确：将 workflow 加入 ruleset 后，已打开 PR 需更新基分支、推送新提交或重新打开，才会执行新 required workflow。
   - 动作：在 `required_checks_runtime.json` 增加 `recheck_trigger`（`base_branch_updated` / `new_commit` / `reopened`），没有触发记录则阻断晋级。
3. Merge queue 还存在队列级门禁配置差异
   - GitHub merge queue 文档给出两个关键配置：`Require all queue entries to pass required checks` 与 `Status check timeout`（5-60 分钟）。
   - 动作：把 `queue_pass_policy` 与 `status_check_timeout_minutes` 纳入 `required_checks_runtime.json`，并在 drift 报告中新增 `queue_policy_drift`。
4. 本轮同化结论（L2）
   - 新证据仍解决同一元问题：`需求声明 checks` 与 `合并时真实 checks` 的一致性。
   - 判定：同化到本 pattern，不新建 topic/pattern。

## Cycle 107 检索锚点（L5）

- `required workflows do not use branches paths tags filters`
- `required workflow added to ruleset existing open pull request not run`
- `merge queue require all queue entries pass required checks timeout`

## Cycle 113 同化增量：检查身份漂移（Name / Source / Freshness）

目标：解决“checks 列表看起来一致，但合并时身份并不一致”的隐性失真。

1. check 名称格式要做类型化标准化
   - GitHub ruleset 故障排查文档给出 required status checks 的三种名称格式：`workflow_job_name`、`workflow_name / job_name`（reusable workflow）、`other_checks_name`。
   - 同文档明确：required checks 判定不区分 workflow、matrix、event trigger type；只看最终 check 名称与来源。
   - 动作：新增 `required_checks_identity_manifest.json`，字段至少包含 `check_name`、`check_kind`、`source_app`、`event_surface`。
2. source pinning 必须入闸
   - GitHub protected branches 文档允许 required status checks 绑定 expected source（GitHub App）。
   - 动作：对关键 checks 启用 expected source，防止同名 check 被非预期 app 伪通过。
3. freshness 窗口与 skipped 语义要单独治理
   - GitHub 文档要求 required checks 需在近 7 天内在仓库成功完成才可作为晋级依据。
   - 同文档指出：workflow 被 path/branch/commit-message 规则整体跳过会保持 Pending；而 job 级 `if` 跳过通常报告 Success。
   - 动作：drift 报告新增 `freshness_pass` 与 `skip_semantics_pass`，Pending-by-skip 直接阻断。
4. 同化结论（L2）
   - 新证据仍是同一元问题：`需求声明 checks` 与 `合并时真实 checks` 的一致性对账。
   - 判定：同化到本 pattern，不新建 pattern/topic。

## Cycle 113 检索锚点（L5）

- `required status checks naming format workflow job reusable workflow`
- `required status checks do not take workflow matrix event trigger into account`
- `required status checks expected source github app`
- `required checks must have completed successfully in last seven days`
- `workflow skipped due to path filtering pending`

## Cycle 115 同化增量：Ruleset Workflow 触发完整性（token 触发/并发取消/可观测滞后）

目标：解决“required checks 已声明，但 required workflow 实际未执行或执行证据滞后”的隐藏失真。

1. 触发面必须按 ruleset 实际语义建模，而不是按 workflow 文件假设
   - GitHub 故障排查文档明确：ruleset required workflows 仅支持 `pull_request`、`pull_request_target`、`merge_group`，并忽略 workflow 级过滤器（包括 `types`）。
   - 动作：`required_checks_runtime.json` 新增 `ruleset_supported_events[]` 与 `ruleset_filters_ignored=true`，如果运行面缺 `merge_group` 则阻断。
2. `GITHUB_TOKEN` 触发链不能当作 required workflow 证据来源
   - 同文档明确：由 `GITHUB_TOKEN` 触发的事件不会执行 ruleset workflows。
   - 动作：`required_checks_identity_manifest.json` 新增 `trigger_actor_class`；当 `trigger_actor_class=github_token` 时，标记 `ruleset_workflow_executable=false` 并强制补跑。
3. 并发取消策略会破坏 required workflow 稳定触发
   - 文档明确：ruleset workflows 不应配置 `concurrency` 的 `cancel-in-progress`，否则在最新 commit 上可能不按预期运行。
   - 动作：`required_checks_drift_report.json` 新增 `concurrency_cancel_in_progress_detected`；命中即 `drift_pass=false`。
4. 规则洞察存在记录时滞，不能替代运行时快照
   - 文档指出：ruleset insights 仅在 PR 合并/尝试合并后记录。
   - 动作：保留 `baseline/runtime/drift` 三件套为主审计源，insights 仅作事后对账，不作为放行依据。
5. 同化结论（L2）
   - 新证据仍是同一元问题：`需求声明 checks` 与 `合并时真实 checks` 的一致性对账。
   - 判定：同化到本 pattern，不新建 topic/pattern。

## Cycle 115 检索锚点（L5）

- `ruleset required workflow supports pull_request pull_request_target merge_group`
- `ruleset workflow ignores workflow filters and types`
- `events triggered by GITHUB_TOKEN do not run ruleset workflows`
- `cancel-in-progress may cause required workflow not to run as expected`
- `ruleset insights are only available after merge or merge attempt`
