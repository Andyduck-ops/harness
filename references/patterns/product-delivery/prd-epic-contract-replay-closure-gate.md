---
name: prd-epic-contract-replay-closure-gate
topic: product-delivery
confidence: 0.82
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-03-01)
  - HN top lane snapshot (https://news.ycombinator.com/news, checked 2026-03-01)
  - HN show lane snapshot (https://news.ycombinator.com/show, checked 2026-03-01)
  - HN newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-03-01)
  - HN top item: Verified Spec-Driven Development (https://news.ycombinator.com/item?id=47197595, checked 2026-03-01)
  - HN top item: 747s and Coding Agents (https://carlkolon.com/2026/02/27/engineering-747-coding-agents/, checked 2026-03-01)
  - GitHub Docs: Syntax for issue forms (https://docs.github.com/en/enterprise-server@3.16/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: Linking a pull request to an issue (https://docs.github.com/en/issues/tracking-your-work-with-issues/linking-a-pull-request-to-an-issue)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: REST API best practices (follow redirects) (https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api)
  - OpenAPI Specification (https://spec.openapis.org/oas/latest.html)
  - Pact Docs: Provider verification (https://docs.pact.io/provider)
  - HN lanes snapshot（news: id=47202708 "Microgpt", show: id=47201816 "Show HN: DreamBOMB", newest: id=47203831 "A Transition Experiment by reaching back in internet history"）(2026-03-01)
  - OpenAI Structured Outputs guide（`strict: true` 保证输出匹配 JSON Schema；JSON mode 仅保证有效 JSON）(https://platform.openai.com/docs/guides/structured-outputs)
  - Anthropic Tool Use docs（tool `input_schema` 使用 JSON Schema 定义输入合同）(https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/implement-tool-use)
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

## Cycle 97 同化增量：PRD 信息保真三重闭环

目标：把 `PRD -> spec -> tasks -> code` 的损失点从“事后解释”改成“发布前阻断”。

1. 字段保真（Field Fidelity）
   - GitHub Issue Form 支持 YAML `body` 输入与 `validations.required`，可把 `prd_slice_id`、`epic_id`、`contract_epoch`、`replay_plan_id` 固化为必填输入。
   - 结论：PRD 语义必须先编码成结构化字段，再进入任务和代码环节，禁止自然语言裸传。

2. 回链保真（Linkage Fidelity）
   - GitHub 关闭关键字仅在 PR 指向默认分支时生效，`Closes #x` 不可脱离分支语义理解。
   - 结论：仅“PR 关联成功”不足以证明闭环，必须与默认分支合并事实绑定。

3. 事件面保真（Event-Surface Fidelity）
   - GitHub Actions 文档明确：merge queue 场景必须触发 `merge_group`，否则 required checks 不会上报。
   - 故障排查文档进一步指出：路径过滤导致 required workflow 不触发，会卡在 `Waiting for status to be reported`。
   - 结论：PRD 到 code 的最终验收要覆盖 `pull_request + merge_group` 双事件面，避免“检查看似存在但实际未执行”。

4. 证据面保真（Evidence Fidelity）
   - `t.co` 入口验证与 GitHub REST redirect 规则（`301` 永久更新、`302/307` 临时跟随）说明：证据采集要有可追溯重定向链，而不是硬编码链接。
   - 结论：`lineage_mapping.json` 与 `contract_replay_report.json` 之外，增加 `evidence_chain.json`（source_url, final_url, redirect_type, checked_at）。

5. 社区信号同化（非主证据）
   - HN `Verified Spec-Driven Development` 与 `747s and Coding Agents` 显示实践侧正在收敛到“spec-first + verification gate + human review”。
   - 这些仅作为热区信号，不替代官方规范。

## 检索测试（L5）

- 查询：`issue form validations required prd_slice_id contract_epoch`
  - 命中：本 pattern
  - 动作：把 PRD 核心字段前置成 issue form 必填
- 查询：`Closes #10 default branch keyword ignored non-default`
  - 命中：本 pattern
  - 动作：将“关联成功”升级为“默认分支合并闭环”
- 查询：`merge_group required checks not reported merge queue`
  - 命中：本 pattern
  - 动作：workflow 触发面强制 `pull_request + merge_group`
- 查询：`Waiting for status to be reported path filtering required workflow`
  - 命中：本 pattern
  - 动作：required workflow 禁止 path/branch 跳过策略

## Cycle 119 同化增量：Schema-Lock 中间产物（PRD -> Spec 信息保真）

目标：解决 `PRD -> spec -> arch -> tasks -> code` 过程中“字段还在、语义已丢”的隐形损失。

1. 把“结构化输出”前置到需求转译层
   - OpenAI Structured Outputs 文档明确：`strict: true` 时输出会匹配开发者给定的 JSON Schema；而 JSON mode 仅保证是有效 JSON，不保证字段语义完整。
   - 动作：在 `PRD -> spec` 和 `spec -> tasks` 两段都强制 schema-locked 生成，禁止自由文本直接进入执行环节。
2. 把 agent/tool 交互合同化
   - Anthropic tool use 文档明确 `input_schema` 采用 JSON Schema。
   - 动作：多 agent 流程中，需求转译工具统一复用同一份 schema contract，避免不同执行器各自“近似理解”导致字段漂移。
3. 为 PECRCG 增加中间证据件
   - 新增 `spec_lock_manifest.json`：
     - `lineage_id`
     - `contract_epoch`
     - `schema_id`
     - `schema_hash`
     - `required_fields_pass`
   - 规则：`required_fields_pass=false` 时直接阻断 `contract_replay_closure_pass`。
4. 同化结论（L2）
   - 新证据仍落在同一元问题：`需求血缘` 与 `契约回放` 的闭环真实性。
   - 判定：同化到本 canonical pattern，不新建 topic/pattern。

## Cycle 119 检索锚点（L5）

- `structured outputs strict true json schema vs json mode`
- `anthropic tool input_schema json schema contract`
- `prd spec tasks schema lock manifest required fields pass`
