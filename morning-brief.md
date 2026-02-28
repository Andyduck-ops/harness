# Morning Brief（Nightshift Cycle 44）

> 更新时间：2026-02-28 21:19 UTC  
> 本轮目标：把 ruleset 旁路名单“可见性盲区”升级为晋级硬门禁，阻断低权限快照导致的静默误放行。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/ruleset-bypass-visibility-attestation-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 44）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `规则集导出盲区补偿治理（ruleset export blind-spot compensation gate）` 为：
  - `规则集导出同构校验治理（ruleset export parity gate）`
  - `低权限可见性降级治理（low-privilege visibility degradation gate）`
  - reason: 原方向同时覆盖“导出同构差异”和“权限导致字段不可见”，执行边界过宽。
- `merge`：合并方向
  - from: `旁路名单主体漂移治理（bypass actor-set drift gate）`
  - from: `低权限可见性降级治理（low-privilege visibility degradation gate）`
  - into: `旁路主体可见性漂移治理（bypass actor-visibility drift gate）`
  - reason: 两方向都治理旁路主体边界变化，一个是“真变更”，一个是“可见性退化”，应合并到同一门禁语义。
- `expand`：新增方向 `队列容错显式降级治理（merge-queue non-failing explicit fallback gate）`
  - 触发依据：GitHub merge queue 支持允许失败 PR 混入队列，可见性异常时需自动降级为“仅合并 non-failing PR”。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:19:40Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `How to build a coding agent`
  - show (`show`): `Show HN: Self-hosting all your coding agents with a single script`
  - new (`newest`): `Nvidia's net margin in AI peaks amid shrinking cloud rents`
- 官方文档证据链（本轮重点）
  - GitHub Rulesets REST API（`bypass_actors` 在写权限上下文才返回）
  - GitHub merge queue（`Only merge non-failing pull requests` 模式开关）
  - GitHub protected branches（required checks 与最新 commit/时效约束）

### 本轮结论

- 旁路名单审计首先要审计“可见性”，字段缺失不能等价为空。
- 当 `visibility_unknown=true` 时，必须把 merge queue 降级到最保守模式并强制 `merge_group` 重验。
- 没有 `bypass_visibility_attested` 的晋级决策，默认视为不可审计放行。

### Cycle 45 预载任务

1. 引入 `scope_hash` 与 token 角色映射，区分“字段为空”与“字段不可见”。
2. 将 `visibility_unknown` 直接接到 required checks 的 fail-fast 入口。
3. 为 `merge-queue non-failing fallback` 增加 TTL，避免长期保守模式形成吞吐债务。

---

# Morning Brief（Nightshift Cycle 43）

> 更新时间：2026-02-28 21:15 UTC  
> 本轮目标：把 ruleset bypass 名单漂移从“配置观察”升级为“晋级阻断 + 队列重验”的硬门禁，避免静默放行。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/ruleset-bypass-list-drift-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 43）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `规则集旁路名单漂移治理（ruleset bypass-list drift gate）` 为：
  - `旁路名单主体漂移治理（bypass actor-set drift gate）`
  - `旁路模式升级漂移治理（bypass_mode escalation drift gate）`
  - reason: 原方向同时覆盖“主体集合变化”和“绕过模式升级”，执行粒度过粗，难以绑定独立 gate。
- `merge`：合并方向
  - from: `队列容错模式验签（tail-green mode attestation gate）`
  - from: `队列尾绿掩蔽预算治理（tail-green masking budget gate）`
  - into: `队列尾绿容错预算联动治理（tail-green attestation-budget parity gate）`
  - reason: 两方向都治理 tail-green 的可接受边界，拆开会重复记录同一失败面。
- `expand`：新增方向 `规则集导出盲区补偿治理（ruleset export blind-spot compensation gate）`
  - 触发依据：GitHub ruleset history 导出不包含 bypass actor 细节，需要引入 API 快照补偿观测盲区。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:15:38Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Modern-day Oracles or Bullshit Machines?`
  - show (`show`): `Show HN: Decided to play god and create my own agent civilisation`
  - new (`newest`): `Show HN: AIQuotaBar – Menubar app for OpenAI API usage tracking`
- 官方文档证据链（本轮重点）
  - GitHub rulesets（bypass list + bypass_mode）
  - GitHub ruleset history（导出 JSON 不含 bypass actor 细节）
  - GitHub Rules API（可编程抓取规则快照）
  - GitHub merge queue + `merge_group`（队列阶段独立校验面）

### 本轮结论

- 旁路名单治理不能只靠规则导出，必须做“API 快照 + 漂移 diff + 晋级阻断”闭环。
- bypass actor 集合变化与 bypass_mode 升级必须拆分审计；任一异常都应触发队列重验。
- 没有 `ruleset_bypass_drift_pass` 的晋级决策，默认视为不可审计放行。

### Cycle 44 预载任务

1. 增加 `ruleset_bypass_snapshot.json` 的权限探针（检测低权限 token 空返回误判）。
2. 将 `ruleset_bypass_diff.json` 接入 required checks 与 merge queue 出队门禁。
3. 为 `bypass_mode=always` 增加 TTL 和自动回收策略。

---

# Morning Brief（Nightshift Cycle 42）

> 更新时间：2026-02-28 21:09 UTC  
> 本轮目标：把 deployment bypass 的“自由文本理由”升级为“可枚举、可验签、可追责”的注册门禁，阻断灰放行。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/bypass-reason-registry-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 42）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `旁路理由枚举注册治理（bypass reason registry gate）` 为：
  - `旁路理由分类治理（bypass reason taxonomy gate）`
  - `旁路理由证据绑定治理（bypass reason evidence-binding gate）`
  - reason: 原方向同时承载“理由词表设计”和“证据校验约束”，执行动作过宽，不利于自动化 gate。
- `merge`：合并方向
  - from: `旁路授权-禁绕策略同一治理（bypass authorization and no-bypass parity gate）`
  - from: `旁路理由证据绑定治理（bypass reason evidence-binding gate）`
  - into: `旁路授权-理由同一治理（bypass authorization-reason parity gate）`
  - reason: 旁路是否允许与旁路理由是否合规属于同一准入面，拆开会产生“有权限但无合规理由”的审计裂缝。
- `expand`：新增方向 `规则集旁路名单漂移治理（ruleset bypass-list drift gate）`
  - 触发依据：GitHub rulesets 明确存在 bypass list，需要把名单变更纳入漂移审计与晋级阻断。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:09:22Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `MCP Spec Is Wrong: M×N ≠ M+N`
  - show (`show`): `Show HN: Lok, a modern HN web and terminal client`
  - new (`newest`): `Show HN: Aider Polyglot - One command install and launch all your coding agents`
- 官方文档证据链（本轮重点）
  - GitHub rulesets（bypass list）
  - GitHub review deployments（bypass deployment protection rules）
  - GitHub protected branches（do not allow bypassing）
  - GitHub merge queue（队列校验独立上下文）

### 本轮结论

- bypass 不应只校验“谁可以”，还必须校验“为什么可以”且理由必须结构化。
- `bypass_reason_code` 必须与证据要求绑定；无注册 code 的旁路默认不可晋级。
- `promotion_decision.json` 必须包含 `reason_registry_pass`，否则次日无法归因审批依据。

### Cycle 43 预载任务

1. 增加 `reason_code -> required_evidence` 的模板与最小字段 lint（缺字段即 fail）。
2. 把 `ruleset_bypass_list_diff.json` 接入 required checks。
3. 为 `emergency` 类 reason 增加 TTL 上限与自动失效回放字段。

---

# Morning Brief（Nightshift Cycle 41）

> 更新时间：2026-02-28 21:04 UTC  
> 本轮目标：把“分支禁绕”与“环境旁路”从并列配置升级为同一闸门，阻断策略口径冲突导致的隐式放行。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/branch-environment-no-bypass-parity-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 41）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `分支保护禁绕策略一致性治理（branch no-bypass policy parity gate）` 为：
  - `分支规则禁绕约束治理（branch-rule no-bypass enforcement gate）`
  - `环境旁路策略对齐治理（environment bypass parity gate）`
  - reason: 原方向把“分支硬门禁”和“环境例外旁路”耦合在一个动作里，执行边界过宽。
- `merge`：合并方向
  - from: `绕过执行身份约束治理（bypass actor authorization gate）`
  - from: `环境旁路策略对齐治理（environment bypass parity gate）`
  - into: `旁路授权-禁绕策略同一治理（bypass authorization and no-bypass parity gate）`
  - reason: 两方向都在管控“谁可旁路 + 旁路是否违背禁绕策略”，合并后可避免同构 pattern 重复。
- `expand`：新增方向 `旁路理由枚举注册治理（bypass reason registry gate）`
  - 触发依据：GitHub review deployments 存在 bypass 入口；若不把 bypass reason 结构化枚举化，次日无法稳定追责。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:04:41Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Open source and self host your own private Telegram using Telegram API`
  - show (`show`): `Show HN: Aider Polyglot - One command install and launch all your coding agents`
  - new (`newest`): `Making software for all is hard. Here's why`
- 官方文档证据链（本轮重点）
  - GitHub protected branches（`Do not allow bypassing the above settings`）
  - GitHub deployments/environments（required reviewers / wait timer / prevent self-reviews）
  - GitHub review deployments（bypass deployment protection rules）
  - GitHub merge queue + Actions `merge_group`（队列校验独立触发上下文）

### 本轮结论

- “分支禁绕”与“环境可旁路”不是二选一配置，而是同一闸门的冲突裁决问题。
- bypass 一旦发生，必须重算策略同一性并触发重验，不能继承旧绿灯。
- 没有 `bypass_policy_parity_report.json` 的发布，默认视为不可审计放行。

### Cycle 42 预载任务

1. 固化 `bypass_reason_code` 注册表与最小字段 lint（缺失即 fail）。
2. 增加 `policy_parity_state` 的分支分层阈值模板（main/release/hotfix）。
3. 把 `parity_gate_pass` 接入 required checks 与晋级阻断。

---

# Morning Brief（Nightshift Cycle 40）

> 更新时间：2026-02-28 20:59 UTC  
> 本轮目标：把 deployment bypass 从“人工例外”升级为“可追责旁路”，阻断强制放行绕过审计链。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/environment-bypass-audit-quarantine-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 40）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `环境保护绕过审计门禁（environment protection bypass audit gate）` 为：
  - `绕过执行身份约束治理（bypass actor authorization gate）`
  - `绕过审计隔离治理（bypass audit quarantine gate）`
  - reason: 原方向同时覆盖“谁能绕过”和“绕过后如何隔离追责”，执行边界过宽。
- `merge`：合并方向
  - from: `绕过审计隔离治理（bypass audit quarantine gate）`
  - from: `审批-等待双触发重验治理（approval+wait dual-trigger reverify gate）`
  - into: `审批-绕过双轨时效治理（approval-bypass dual-track freshness gate）`
  - reason: 两方向都在治理“晋级前重验与例外放行”，合并后形成统一双轨门禁。
- `expand`：新增方向 `分支保护禁绕策略一致性治理（branch no-bypass policy parity gate）`
  - 触发依据：GitHub protected branches 提供“不允许绕过设置”策略面，需要与 environment bypass 审计口径一致。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:59:56Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `How to stop overcomplicating your product`
  - show (`show`): `Show HN: Matrix, but it is all Git`
  - new (`newest`): `10 years ago, someone asked me if there was any way to block AI from crawling`
- 官方文档证据链（本轮重点）
  - GitHub review deployments（bypass deployment protection rules）
  - GitHub deployments/environments（required reviewers + prevent self-reviews + wait timer）
  - GitHub protected branches（do not allow bypassing）
  - GitHub merge queue（队列校验独立上下文）

### 本轮结论

- bypass 不是日志注释，而是独立晋级路径；必须有身份约束和对象绑定。
- bypass 后默认应进入 `quarantine_review`，而不是沿用旧绿灯直接 promote。
- 没有 `bypass_override_audit.json` 的放行，不具备次日可追责能力。

### Cycle 41 预载任务

1. 输出 `bypass_reason_code` 枚举与最小字段 lint（缺字段直接 fail）。
2. 将 `post_bypass_reverify` 纳入 required checks，禁止 bypass 后跳过重验。
3. 对齐 `branch no-bypass` 与 `environment bypass` 的冲突裁决顺序，避免策略打架。

---

# Morning Brief（Nightshift Cycle 39）

> 更新时间：2026-02-28 20:55 UTC  
> 本轮目标：把 environment wait timer 从“被动等待”升级为“主动重验触发器”，阻断等待期间证据过窗后直接晋级。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/environment-wait-timer-reverify-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 39）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `环境等待计时预算治理（environment wait-timer budget gate）` 为：
  - `环境等待计时上限治理（environment wait-timer ceiling gate）`
  - `环境等待到期重验闸门（wait-timer expiry reverify gate）`
  - reason: 原方向同时混合“等待预算定义”和“到期重验动作”，可执行粒度过粗。
- `merge`：合并方向
  - from: `审批前重验闸门（pre-approval reverify gate）`
  - from: `环境等待到期重验闸门（wait-timer expiry reverify gate）`
  - into: `审批-等待双触发重验治理（approval+wait dual-trigger reverify gate）`
  - reason: 两者都指向同一控制面（重验触发），合并后统一门禁契约并减少同构 pattern。
- `expand`：新增方向 `环境保护绕过审计门禁（environment protection bypass audit gate）`
  - 触发依据：GitHub Review deployments 文档明确存在 bypass 入口，需要独立审计门禁防止“强制放行不可追责”。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:55:06Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Open source and self host your own private Telegram using Telegram API`
  - show (`show`): `A framework to agentify your software and orchestrate dynamic LLMs`
  - new (`newest`): `I got OpenAI Agent to make me 100k while I slept`
- 官方文档证据链（本轮重点）
  - GitHub deployments/environments（wait timer + required reviewers）
  - GitHub review deployments（审批/拒绝与 bypass 机制）
  - GitHub merge queue + `merge_group`（队列校验独立上下文）
  - GitHub protected branches（required checks 与最新 SHA / 时效约束）

### 本轮结论

- wait timer 不是中性延时，而是“重验触发器”；等待越久，继承旧绿灯风险越高。
- 审批与等待必须使用同一 `lineage_id` 记录双触发重验（approval age / wait elapsed）。
- bypass 行为必须结构化审计并触发 `quarantine_review`，否则无法完成可追责发布。

### Cycle 40 预载任务

1. 为 `approval+wait dual-trigger reverify gate` 增加分支分层阈值模板（main/release/hotfix）。
2. 把 `bypass_override_audit.json` 纳入 required checks 与晋级阻断。
3. 增加“等待超窗 + 审批变更人”组合场景的回放字段规范。

---

# Morning Brief（Nightshift Cycle 38）

> 更新时间：2026-02-28 20:50 UTC  
> 本轮目标：把“queue 通过”与“deployment 审批”之间的时间窗显式预算化，阻断过期绿灯继承。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/approval-freshness-budget-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 38）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `审批时效预算治理（approval freshness budget gate）` 为：
  - `审批签发时效预算治理（approval-sign freshness budget gate）`
  - `审批前重验闸门（pre-approval reverify gate）`
  - reason: 原方向把“审批时间预算”和“超窗重验动作”耦合在一起，执行颗粒度过粗。
- `merge`：合并方向
  - from: `同窗时序预算治理（window alignment + skew budget gate）`
  - from: `审批签发时效预算治理（approval-sign freshness budget gate）`
  - into: `跨阶段时序预算治理（cross-stage window freshness budget gate）`
  - reason: 两者都在管控时间窗偏斜，合并后可统一 queue->approval->promotion 的预算口径。
- `expand`：新增方向 `环境等待计时预算治理（environment wait-timer budget gate）`
  - 触发依据：GitHub environment 支持 wait timer，说明审批/发布链路存在显式时间控制面，可独立建模为预算门禁。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:50:30Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Tell HN: Looking for data points where coding assistants caused incidents`
  - show (`show`): `Show HN: WeatherMCP: Access weather data from your AI tool`
  - new (`newest`): `How to stop overcomplicating your product`
- 官方文档证据链（本轮重点）
  - GitHub merge queue（队列验证是独立合并上下文）
  - GitHub Actions `merge_group` 事件（队列阶段独立触发面）
  - GitHub deployments/environments + review deployments（审批规则、required reviewers、prevent self-reviews、wait timer）
  - GitHub protected branches（required checks 需匹配最新 SHA，且有时效窗口）

### 本轮结论

- queue 绿灯不能直接继承到 deploy 审批，必须核对“通过时间”是否仍在预算内。
- 审批卡片必须绑定 `lineage_id + merge_group_sha + checks_passed_at_utc + deploy_sha`，否则无法证明审批基于有效证据。
- 超窗审批必须触发 `reverify_before_approval`，而不是沿用旧检查结果。

### Cycle 39 预载任务

1. 将 `approval_freshness_budget.json` 接入 required checks 与晋级决策。
2. 按分支等级输出默认阈值模板（main/release/hotfix）。
3. 给超窗重验失败场景补 `quarantine_replay_report` 字段规范。

---

# Morning Brief（Nightshift Cycle 37）

> 更新时间：2026-02-28 20:45 UTC  
> 本轮目标：补齐 merge queue 与 environment 审批之间的连续性断层，避免“合并绿灯”直接穿透到“发布绿灯”。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/queue-deploy-continuity-dual-gate.md`
2. `references/patterns/release-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 37）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `环境审批发布门禁（environment approval release gate）` 为：
  - `部署审批身份门禁（deployment reviewer identity gate）`
  - `队列-部署连续性门禁（queue-to-deploy continuity gate）`
  - reason: 原方向同时包含“审批身份约束”和“queue→deploy 连续性校验”，执行边界过宽，需拆分。
- `merge`：合并方向
  - from: `合并队列同构预检门禁（queue preflight parity gate）`
  - from: `队列-部署连续性门禁（queue-to-deploy continuity gate）`
  - into: `队列预检-部署连续性双门禁（queue preflight-deploy continuity dual gate）`
  - reason: 两方向都约束晋级连续性，分离维护会重复同一批审计字段。
- `expand`：新增方向 `审批时效预算治理（approval freshness budget gate）`
  - 触发依据：queue 通过与 deploy 审批之间存在自然时滞，需独立 freshness 预算治理。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:45:37Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Signal says it’s pulling feature users exploited to protect privacy`
  - show (`show`): `Show HN: Wavpilot - Voice to Cursor in Your Browser`
  - new (`newest`): `Introducing Claude 4.5`
- 官方文档证据链（本轮重点）
  - GitHub merge queue（队列阶段独立合并上下文）
  - GitHub Actions `merge_group` 事件（队列校验独立触发面）
  - GitHub deployments/environments + review deployments（environment 保护规则、required reviewers、阻止自审）
  - GitHub required status checks（最新 SHA + 时效约束）

### 本轮结论

- “queue 可合并”与“deployment 可发布”不是同一闸门，必须做 lineage 绑定。
- 部署审批卡片需要强绑定 `lineage_id + merge_group_sha + deploy_sha`，否则审计链会断。
- queue 到 deploy 的时间窗必须纳入 freshness 预算，超窗后要重验而不是继承旧绿灯。

### Cycle 38 预载任务

1. 将 `queue_deploy_continuity.json` 纳入 required checks 与合并门禁。
2. 对 `approval freshness budget` 增加分支分层阈值（main/release/hotfix）。
3. 给 deploy 拒绝场景补 `quarantine_replay_report`（含 reviewer 决策轨迹）。

---

# Morning Brief（Nightshift Cycle 36）

> 更新时间：2026-02-28 20:41 UTC  
> 本轮目标：把 merge queue 的“队尾绿灯”从默认可用改为“可审计可预算”，阻断失败成员被组合结果掩蔽。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/merge-queue-tail-green-risk-gate.md`
2. `references/patterns/queue-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 36）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `merge_group 事件同构校验（merge_group parity checks）` 为：
  - `merge_group 触发同构校验（merge_group event parity gate）`
  - `队列容错模式验签（tail-green mode attestation gate）`
  - reason: 同一方向同时覆盖“触发面一致性”和“队列策略一致性”，可执行性过宽，需拆分为双门禁。
- `merge`：合并方向
  - from: `合并队列预检门禁（merge queue preflight gate）`
  - from: `merge_group 触发同构校验（merge_group event parity gate）`
  - into: `合并队列同构预检门禁（queue preflight parity gate）`
  - reason: 两者都在约束“入队前同构校验”，合并可减少重复门禁并统一审计字段。
- `expand`：新增方向 `队列尾绿掩蔽预算治理（tail-green masking budget gate）`
  - 触发依据：GitHub merge queue 支持“允许失败 PR 混入队列”的容错模式，需要独立预算治理。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:39:15Z，observed revisions: 29）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Obsidian Sync and local-first software`
  - show (`show`): `Show HN: Now I Get It: Visuals on how AI translators work`
  - new (`newest`): `The Making of Anthropic CEO Dario Amodei (2025)`
- 官方文档证据链（本轮重点）
  - GitHub merge queue（模式配置：可选只合并非失败 PR）
  - GitHub Actions `merge_group` 事件（队列阶段独立触发面）
  - GitHub required status checks（最新 SHA + 7 天有效窗口）
  - OPML 2.0 规范（`text/xmlUrl/htmlUrl` 可编辑属性）

### 本轮结论

- “PR 通过”与“队列可合并”仍是两个判定面；容错模式下必须补成员失败预算。
- 队尾通过不能替代组内失败分布；否则会出现可追踪性缺口。
- 晋级门禁应同时绑定 `mode_attested + member_matrix + dual freshness`。

### Cycle 37 预载任务

1. 把 `failing_member_ratio` 做分支分层阈值模板（main/release/hotfix）。
2. 将 `queue_mode_attestation` 接入 required checks 与审计报表。
3. 为 tail-green 例外路径补齐 quarantine 回放报告（含成员失败根因）。

---

# Morning Brief（Nightshift Cycle 35）

> 更新时间：2026-02-28 20:36 UTC  
> 本轮目标：把“PR 阶段通过”升级为“merge queue 出队时仍可证”，避免排队等待造成的静默失效晋级。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/merge-group-parity-freshness-gate.md`
2. `references/patterns/queue-governance/_index.md`（新 topic 自动创建）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 35）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `白天晋级车道（分支保护 + 环境审批）` 为：
  - `合并队列预检门禁（merge queue preflight gate）`
  - `环境审批发布门禁（environment approval release gate）`
  - reason: “队列验证”与“环境审批”是两个独立失效面，必须拆开验收。
- `merge`：合并方向
  - from: `墓碑检测回放治理（deleted/dead replay detector）`
  - from: `晋级前重放窗口契约（pre-promotion replay window contract）`
  - into: `晋级双时点重放治理（capture+promotion replay dual-phase gate）`
  - reason: 两方向都在解决“采样与晋级之间的失真窗口”，合并后可统一门禁字段。
- `expand`：新增方向 `merge_group 事件同构校验（merge_group parity checks）`
  - 触发依据：GitHub merge queue 与 workflow `merge_group` 事件是独立触发面，需新增同构校验方向。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:35:58Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Japan's Buddhist temples turn to AI chatbots amid monk shortage`
  - show (`show`): `Show HN: Open-Source Note Taking App with Spatial Keyboard Navigation`
  - new (`newest`): `I made a stupidly simple app to stop my household from losing things`
- 官方文档证据链（本轮重点）
  - GitHub merge queue（合并前队列验证）
  - GitHub Actions `merge_group` 事件（队列阶段独立触发面）
  - GitHub required checks 规则（状态检查 7 天时效约束）
  - OPML 2.0 规范（入口身份字段语义）

### 本轮结论

- PR 阶段绿灯不等于 queue 出队绿灯，`merge_group` 必须有同构验证。
- 排队时滞必须入账，否则会出现“采样时有效、出队时过期”的隐性失败。
- 证据门禁应采用 `入队前 + 出队前` 双时点校验，禁止继承旧检查结果直接晋级。

### Cycle 36 预载任务

1. 把 `queue_wait_minutes` 接入分支分层阈值模板（main/release/hotfix）。
2. 将 `queue_exit_fresh_pass` 接入 `promotion_decision` required checks。
3. 为 `merge_group` 失败补齐 quarantine 回放报告字段（含 tombstone 与 retrievability）。

---

# Morning Brief（Nightshift Cycle 34）

> 更新时间：2026-02-28 20:28 UTC  
> 本轮目标：把“可回放证据”再推进到“晋级时仍可用”，阻断 deleted/dead 墓碑对象的幽灵晋级。

### 本轮新增（已落盘）

1. `references/patterns/evidence-governance/tombstone-replay-promotion-gate.md`
2. `references/patterns/evidence-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 34）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `HN Item 墓碑漂移治理（deleted/dead item tombstone policy）` 为：
  - `墓碑检测回放治理（deleted/dead replay detector）`
  - `墓碑晋级冻结门禁（tombstone promotion freeze gate）`
  - reason: 需把“识别失效对象”和“阻断晋级路径”拆分为两个可验收控制面。
- `expand`：新增方向 `晋级前重放窗口契约（pre-promotion replay window contract）`
  - 触发依据：required status checks 存在时效窗口，晋级前必须二次回放才能保证证据仍然有效。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:28:31Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Deep learning is akin to a nuclear first strike`
  - show (`show`): `Show HN: The Mad 2025 Chart of Fortune 500 Revenue, Earnings and Stock`
  - new (`newest`): `Show HN: Build and host react apps, no config`
- 官方文档证据链（本轮重点）
  - OPML 2.0 规范（`text/xmlUrl/htmlUrl` 字段语义）
  - Hacker News API（`item.deleted` / `item.dead` 墓碑语义）
  - GitHub 分支保护与 required checks（状态检查 7 天时效约束）

### 本轮结论

- 采集时可回放不等于晋级时可用；中间窗口可能产生墓碑漂移。
- 证据门禁必须拆成 `capture_replay_pass + promotion_replay_pass` 双时点校验。
- `deleted/dead` 必须触发硬隔离而不是软告警，否则会产生“绿灯但不可证”的晋级事故。

### Cycle 35 预载任务

1. 在 `promotion_decision.json` 增加 `tombstone_freeze_pass` 并纳入 required checks。
2. 为 `tombstone_quarantine.json` 加入 `recovery_policy`（人工复核/直接废弃）。
3. 将 `pre-promotion replay window` 与 `retrievability_sla_hours` 做分支分层模板联动。

---

# Morning Brief（Nightshift Cycle 33）

> 更新时间：2026-02-28 20:24 UTC  
> 本轮目标：把“有证据”升级为“证据可检索可回放”，避免次日无法定位同一 claim 对象。

### 本轮新增（已落盘）

1. `references/patterns/evidence-governance/claim-anchor-retrievability-gate.md`
2. `references/patterns/evidence-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 33）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `证据引用可检索契约（claim id + anchor retrievability contract）` 为：
  - `Claim-ID 强绑定治理（claim_id -> hn_item_id -> outline_key binding）`
  - `锚点存活预算治理（anchor retrievability SLA + mirror fallback）`
  - reason: 原方向过宽，需把“身份绑定”与“锚点存活”拆为独立控制面，便于执行与验收。
- `expand`：新增方向 `HN Item 墓碑漂移治理（deleted/dead item tombstone policy）`
  - 触发依据：HN API item 存在 `deleted/dead` 语义，需新增失效证据处置方向，避免把墓碑对象继续作为晋级证据。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T20:22:12Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`, item `45871445`): `ChatGPT’s confidence can mislead users, study finds`
  - show (`show`, item `45871193`): `Show HN: Open-Source Cursor Alternative`
  - new (`newest`, item `45871883`): `Version 4.2.0`
- 官方文档证据链（本轮重点）
  - OPML 2.0 规范（`text/xmlUrl/htmlUrl` 字段语义）
  - Hacker News API（`topstories/showstories/newstories` + `item`）
  - GitHub REST API: Gist revision（可回溯入口版本）

### 本轮结论

- 只记录标题或 URL 的 claim 本质上不可审计，次日无法稳定回放同一对象。
- claim 必须绑定 `hn_item_id + outline_key`，并带重放时间戳。
- OPML revision 变化后若不触发批量重放，会产生“证据仍存在但已不可检索”的静默故障。

### Cycle 34 预载任务

1. 为 `claim_replay_report` 增加 `tombstone_reason` 与自动隔离策略。
2. 建立 `retrievability_sla_hours` 的分支分层阈值模板（main/release/hotfix）。
3. 将 `retrievable_pass` 接入 `promotion_decision` required checks。

---

# Morning Brief（Nightshift Cycle 32）

> 更新时间：2026-02-28 20:18 UTC  
> 本轮目标：把 OPML 订阅入口从“可读名称”升级为“可审计身份主键”，避免夜间发现到白天晋级的证据对象错配。

### 本轮新增（已落盘）

1. `references/patterns/source-governance/opml-outline-tri-key-drift-gate.md`
2. `references/patterns/source-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 32）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `OPML 订阅体身份约束（outline identity contract: text/xmlUrl/htmlUrl）` 为：
  - `OPML 三元主键约束（text/xmlUrl/htmlUrl tri-key contract）`
  - `OPML 可编辑字段漂移探针（outline text edit-drift probe）`
  - reason: OPML 的 `text` 可编辑而 `xmlUrl/htmlUrl` 更接近结构身份，需拆分“身份建模”与“漂移处置”两类控制面。
- `merge`：合并方向
  - from: `车道完备性仲裁（lane completeness quorum gate）`
  - from: `车道身份一致性审计（lane identity parity gate）`
  - into: `车道仲裁同一双门禁（lane quorum + identity dual gate）`
  - reason: 两方向均作用于 HN 三车道晋级门，长期分离会重复维护同构字段与判定逻辑。
- `expand`：新增方向 `证据引用可检索契约（claim id + anchor retrievability contract）`
  - 触发依据：HN API 提供稳定 item id，若不强制 claim 与可检索锚点绑定，次日无法回放到同一证据对象。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Building software products in the age of AI [video]`
  - show (`show`): `Show HN: Better Auth - Authentication and authorization framework for TypeScript`
  - new (`newest`): `Build your own SQLite, Part 1: Listing tables`
- 官方文档证据链（本轮重点）
  - OPML 2.0 规范（`text/xmlUrl/htmlUrl` 语义与 RSS 约束）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub REST API: Gists（revision 可追踪）
  - GitHub artifact attestations 离线验签（`trusted_root.jsonl` 时效约束）

### 本轮结论

- 用 `outline.text` 单字段去重会把“改名”误判为“新来源”，直接破坏去重和晋级审计。
- 订阅入口必须最少落盘 `xmlUrl/htmlUrl/text` 三元身份，并把 `text` 漂移降级为显示层变更。
- claim 必须绑定 `outline_key + hn_item_id`，否则即使证据存在，也不可回放验证同一对象。

### Cycle 33 预载任务

1. 为 `outline_drift_report` 增加 `drift_severity` 与自动处置矩阵（display_drift/source_break）。
2. 设计 `claim_id -> hn_item_id -> outline_key` 的冲突仲裁优先级。
3. 把 `证据引用可检索契约` 接入 `promotion_decision` required checks。

---

# Morning Brief（Nightshift Cycle 31）

> 更新时间：2026-02-28 20:12 UTC  
> 本轮目标：把“离线验签通过”升级为“根信任新鲜且可追责”，避免 trusted root 过期导致的伪安全晋级。

## 本轮新增（已落盘）

1. `references/patterns/trust-governance/trusted-root-freshness-quarantine-gate.md`
2. `references/patterns/trust-governance/_index.md`（新 topic 自动创建）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 31）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `验签根信任新鲜度治理（trusted-root freshness gate）` 为：
  - `根信任轮换门禁（trusted-root rotation gate）`
  - `离线验签实例漂移探针（offline verification instance drift probe）`
  - reason: 根信任“时效轮换”与“验签执行环境漂移”是两类失效面，必须拆分治理。
- `merge`：合并方向
  - from: `构建摘要同一性闸门（build subject digest parity gate）`
  - from: `摘要失配隔离升级（digest mismatch quarantine escalation）`
  - into: `摘要同一-隔离闭环治理（digest parity + quarantine closed loop）`
  - reason: 一条负责检测、一条负责处置，长期分离会重复产出同构策略与字段。
- `expand`：新增方向 `OPML 订阅体身份约束（outline identity contract: text/xmlUrl/htmlUrl）`
  - 触发依据：OPML 2.0 明确 outline 的 `text/xmlUrl/htmlUrl` 语义，适合用于入口身份与证据来源约束。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已实测重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28T20:12:13Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top (`news`): `A New Law of Thermodynamics: The Law of Disorder`
  - show (`show`): `Show HN: Milestone, a desktop app to mark student work with AI`
  - new (`newest`): `GitHub Issues Search now supports nested queries and boolean operators`
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub artifact attestations（生成与验证）
  - GitHub offline verification（`trusted_root.jsonl` 更新与验签）
  - OPML 2.0 规范（outline 身份字段）

## 本轮结论

- “验签通过”不是终点；trusted root 时效失控会把通过结果降级为不可审计结论。
- 夜间无人流程必须把 `root_fresh_pass` 升级为 required check，而非仅记录日志。
- 根信任轮换与摘要同一性应并联校验，否则会出现“对象正确但信任根过期”的隐性风险。

## Cycle 32 预载任务

1. 设计 `root_age_budget` 的分支分层阈值（`main/release/hotfix`）。
2. 为 `offline verification instance drift` 增加 `runner_image_digest` 对账字段。
3. 把 `outline identity contract` 接入 source-governance 的三角校验清单。

---

# Morning Brief（Nightshift Cycle 30）

> 更新时间：2026-02-28 20:10 UTC  
> 本轮目标：把“摘要同一性校验”升级为“保留期-验签窗口协同”，避免次日复验时证据链失效。

## 本轮新增（已落盘）

1. `references/patterns/artifact-governance/artifact-retention-verification-window-gate.md`
2. `references/patterns/artifact-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 30）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `工件保留期-验签窗口协同（artifact retention-verification window alignment）` 为：
  - `工件保留期分层策略（branch-tier artifact retention policy）`
  - `验签根信任新鲜度治理（trusted-root freshness gate）`
  - reason: 保留期预算与根信任时效属于不同失效面，必须分开建模才可审计。
- `merge`：合并方向
  - from: `信源仲裁验签（triangulation + provenance attestation）`
  - from: `时序证据抑制治理（freshness SLA + stale suppression）`
  - into: `证据时效验签一体化（freshness + provenance ratification gate）`
  - reason: 两条方向都在解决“证据是否还能被信任”，合并可避免同构闸门重复维护。
- `expand`：新增方向 `归档保留-验签对账流水（retention-attestation reconciliation ledger）`
  - 触发依据：GitHub artifacts 保留期与离线验签 root 新鲜度来自不同机制，需新增对账方向防止隐性断链。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已实测 301 重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28T20:06:46Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top (`news`): `The Relationship Crisis Facing Gen Z`
  - show (`show`): `Show HN: Briefly, explain and understand codebases with AI`
  - new (`newest`): `The Making of MinCaml Compiler Series`
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub workflow artifacts（retention）
  - GitHub artifact attestations（生成 + 离线验签）

## 本轮结论

- “摘要同一性通过”仍不足以支撑次日审计，必须增加“可复验窗口”约束。
- `retention_window` 与 `verification_window` 不绑定时，会出现“流程通过但证据不可重验”的隐蔽失败。
- 根信任新鲜度应成为晋级硬门禁，而不是离线验签的可选附加项。

## Cycle 31 预载任务

1. 为 `retention_attestation_reconcile.json` 增加 `mismatch_stage`（build/upload/promote）定位字段。
2. 输出 `main/release/hotfix` 的默认 retention 分层阈值模板。
3. 设计 `trusted_root_fetched_at` 的过期刷新策略与失败重试上限。

---

# Morning Brief（Nightshift Cycle 29）

> 更新时间：2026-02-28 20:02 UTC  
> 本轮目标：把“有 attestation”升级为“attestation subject 与晋级工件 digest 同一且可审计升级”，避免 required checks 全绿但晋级对象漂移。

## 本轮新增（已落盘）

1. `references/patterns/artifact-governance/artifact-digest-mismatch-escalation-gate.md`
2. `references/patterns/artifact-governance/_index.md`（新 topic 自动创建）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 29）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `Artifact 摘要一致性告警（artifact digest mismatch escalation）` 为：
  - `构建摘要同一性闸门（build subject digest parity gate）`
  - `摘要失配隔离升级（digest mismatch quarantine escalation）`
  - reason: 失配检测与失配处置是两类控制面，拆分后可分别治理 parity 与 quarantine。
- `merge`：合并方向
  - from: `跨车道去重主键治理（lane-cross dedupe key governance）`
  - from: `跨车道重复率预算治理（cross-lane duplicate ratio budget）`
  - into: `跨车道去重预算一体化治理（dedupe key + duplicate ratio gate）`
  - reason: 两条方向均围绕同一去重控制面，长期并行会重复产出同构字段。
- `expand`：新增方向 `工件保留期-验签窗口协同（artifact retention-verification window alignment）`
  - 触发依据：GitHub artifact 文档提供 retention 机制，必须把“保留期”与“可验签窗口”绑定，否则会出现过期后伪补验签。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：确认重定向到 HN Popular Blogs OPML Gist（redirect checked 2026-02-28T19:57:00Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top (`news`): `id=47196582`
  - show (`show`): `id=47195123`
  - new (`newest`): `id=47199259`
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub artifact attestations（生成与离线验签）
  - GitHub required checks/rules
  - GitHub workflow artifacts（retention）

## 本轮结论

- “有 attestation”不足以防止误晋级，必须强制 `subject_digest == artifact_digest`。
- 失配应升级为 `quarantine`，而不是警告后继续 promotion。
- retention 与验签窗口不协同会制造“证据失效窗口”，是夜间无人推进的隐蔽高风险点。

## Cycle 30 预载任务

1. 在 `digest_parity_report` 中加入 `mismatch_stage`（build/upload/promote）定位责任面。
2. 为 `artifact retention-verification window` 建立分支策略映射（main/release/hotfix 不同阈值）。
3. 评估 `artifact-digest-mismatch-escalation-gate` 与 `attested-evidence-provenance-gate` 的串并联 required checks 顺序模板。

---

# Morning Brief（Nightshift Cycle 28）

> 更新时间：2026-02-28 20:06 UTC  
> 本轮目标：补齐 HN `top/show/new` 的“车道身份一致性”硬门禁，避免页面车道与 API 车道混用导致伪晋级。

## 本轮新增（已落盘）

1. `feed-governance/hn-lane-identity-parity-gate`
2. `feed-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `merge`：合并方向
  - from: `三榜同窗采样契约（window-aligned lane sampling contract）`
  - from: `同窗偏斜预算治理（sampling skew budget gate）`
  - into: `同窗时序预算治理（window alignment + skew budget gate）`
  - reason: 两条方向都在控制时间对齐，长期并行会重复产出同构预算字段。
- `split`：拆分方向 `HN lane quorum 仲裁（top/show/new quorum promotion gate）` 为：
  - `车道完备性仲裁（lane completeness quorum gate）`
  - `车道身份一致性审计（lane identity parity gate）`
  - reason: “车道存在”与“车道同一”是两类不同风险，必须拆分建模并独立挂 required checks。
- `expand`：新增方向 `Artifact 摘要一致性告警（artifact digest mismatch escalation）`
  - 触发依据：官方 artifact 文档提供 digest 校验语义，可用于夜间回放包的一致性告警闭环。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：确认重定向到 HN Popular Blogs OPML Gist（redirect checked 2026-02-28T19:56:00Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top (`news`): `id=47196582`
  - show (`show`): `id=47195123`
  - new (`newest`): `id=47199259`
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub required status checks 文档
  - GitHub workflow artifacts 文档
  - OPML 2.0 规范

## 本轮结论

- 仅 `quorum + skew budget` 仍不足以防止“页面/API 车道混配”的伪一致。
- 必须把 `news/show/newest ↔ topstories/showstories/newstories` 映射显式落盘为 `lane_identity_manifest`。
- 晋级门禁需要并联 `identity_parity_pass`，否则夜间结果无法稳定回放与解释。

## Cycle 29 预载任务

1. 给 `lane_parity_mismatch_ratio` 增加历史漂移基线（按时段分桶）。
2. 设计 `identity_parity_fail` 的自动补采回放策略（限定重试次数与窗口）。
3. 评估 `hn-lane-identity-parity-gate` 与 `triangulated-evidence-ratification-gate` 的串并联顺序模板。

---
# Morning Brief（Nightshift Cycle 27）

> 更新时间：2026-02-28 19:58 UTC  
> 本轮目标：把 HN `top/show/new` 从“同窗可比”升级为“偏斜预算 + 重复率预算 + 车道配额”的可审计晋级闸门。

## 本轮新增（已落盘）

1. `feed-governance/hn-window-skew-budget-gate`
2. `feed-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `跨来源榜单回放仲裁（HN lane replay arbitration）` 为：
  - `同窗偏斜预算治理（sampling skew budget gate）`
  - `跨车道重复率预算治理（cross-lane duplicate ratio budget）`
  - reason: “同窗可比”与“重复率异常”是两类不同失真，需要独立闸门字段。
- `merge`：合并方向
  - from: `运行取消预算治理（cancel SLA + concurrency group）`
  - from: `取消后晋级防抖治理（cancel-to-promote debounce gate）`
  - into: `取消-晋级时序治理（cancel-to-promote sequencing gate）`
  - reason: 两条方向都在处理取消后的晋级时序，分离维护会反复生成同构检查项。
- `expand`：新增方向 `HN lane quorum 仲裁（top/show/new quorum promotion gate）`
  - 触发依据：三车道任一缺失都可能导致偏差决策，需要独立的 quorum 晋级门禁。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：确认重定向到 HN Popular Blogs OPML Gist（redirect checked 2026-02-28T19:50:04Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top (`news`): `A framework for helping students learn from productive struggle`（`id=47196582`）
  - show (`show`): `Show HN: Now I Get It`（`id=47195123`）
  - new (`newest`): `Who Is Building at Berkeley?`（`id=47199282`）
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub required status checks 文档
  - GitHub workflow artifacts 文档
  - OPML 2.0 规范

## 本轮结论

- 仅有 `window_id` 仍不足以抑制伪增量，必须增加 `sampling_skew_ms` 预算门禁。
- 去重必须预算化（`cross_lane_duplicate_ratio`），否则“重复膨胀”与“清洗过度”都无法审计。
- 三车道 quorum 需要独立成为 required check，避免缺车道时误晋级。

## Cycle 28 预载任务

1. 为 `sampling_skew_ms` 引入按时段动态阈值（高峰/低峰分段预算）。
2. 为 `cross_lane_duplicate_ratio` 增加历史基线偏离告警（z-score 或分位阈值）。
3. 评估 `hn-window-skew-budget-gate` 与 `triangulated-evidence-ratification-gate` 的串并联顺序模板。

---
# Morning Brief（Nightshift Cycle 26）

> 更新时间：2026-02-28 19:46 UTC  
> 本轮目标：把 HN `top/show/new` 从“分车道观察”升级为“同窗采样 + 回放仲裁”的可晋级合同。

## 本轮新增（已落盘）

1. `feed-governance/hn-lane-watermark-replay-contract`
2. `feed-governance/_index.md`（新增 pattern 索引）
3. `_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `HN 三榜水位线治理（top/show/new watermark replay）` 为：
  - `三榜同窗采样契约（window-aligned lane sampling contract）`
  - `跨车道去重主键治理（lane-cross dedupe key governance）`
  - reason: 水位线采样与去重主键是两类不同控制面，混合会导致审计字段不可解释。
- `merge`：合并方向
  - from: `证据时效治理（freshness SLA + snapshot ledger pinning）`
  - from: `过期结论抑制治理（stale-run suppression + replay pin）`
  - into: `时序证据抑制治理（freshness SLA + stale suppression）`
  - reason: 两条方向都在控制“旧结论何时失效”，独立维护会持续产出同构 pattern。
- `expand`：新增方向 `跨来源榜单回放仲裁（HN lane replay arbitration）`
  - 触发依据：同日 top/show/new 头部条目节奏差异明显，必须新增“跨车道可比性”闸门。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：确认重定向到 HN Popular Blogs OPML Gist（redirect checked 2026-02-28T19:42:28Z）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top: `Postgres IDE in your browser`（`id=47197677`）
  - show: `Show HN: fix errors before coding`（`id=47197466`）
  - new: `latest lane` 采样样本（`id=47141119`）
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub required status checks 文档
  - GitHub workflow artifacts 文档
  - OPML 2.0 规范

## 本轮结论

- 只做三榜观测但不共享 `window_id`，会稳定制造“伪新增”。
- `window_aligned + lane_dedupe + replay_manifest` 必须同时作为 required checks，才能让无人推进可审计。
- 本轮新增 pattern 完成了从“信号采样”到“晋级仲裁”的合同化升级。

## Cycle 27 预载任务

1. 为 `lane_sampling_window` 增加 `sampling_skew_ms` 阈值，避免弱对齐误判。
2. 在 `lane_diff_report` 增加 `cross_lane_duplicate_ratio`，约束重复发现膨胀。
3. 评估 `hn-lane-watermark-replay-contract` 与 `triangulated-evidence-ratification-gate` 的串并联顺序模板。

---
# Morning Brief（Nightshift Cycle 25）

> 更新时间：2026-02-28 19:39 UTC  
> 本轮目标：把“后端契约优先”从二值门禁升级为“破坏预算 + 消费者回放覆盖”的可审计晋级闸门。

## 本轮新增（已落盘）

1. `fullstack-engineering/contract-breaking-budget-replay-gate`
2. `fullstack-engineering/_index.md`（新增 pattern 索引）
3. `_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `契约变更门禁（OpenAPI/Pact）` 为：
  - `破坏性变更预算治理（breaking-change budget + semantic diff）`
  - `消费者回放覆盖治理（consumer replay coverage + provider verification）`
  - reason: 契约差异预算与消费者可用性验证是两套独立门禁，必须解耦建模。
- `merge`：合并方向
  - from: `需求计划闭环（PRD -> Epic -> Issue）`
  - from: `交付证据账本闭环（digest-bound PR->Pattern lineage）`
  - into: `需求到证据闭环治理（PRD->Pattern lineage control plane）`
  - reason: 两条方向都在处理同一条交付链路，分开维护会持续产生同构字段与重复 pattern。
- `expand`：新增方向 `前端视觉基线守门（design tokens + visual regression budget）`
  - 触发依据：HN `show/newest` 中 AI 工具与快速发布项目持续涌现，次日实战场景需要将视觉回归预算独立治理。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：确认重定向到 HN Popular Blogs OPML Gist（active 2026-02-28，revisions=6）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top: `Cognitive Debt and AI Coding`（`id=47196582`）
  - show: `Show HN: Now I Get It`（`id=47195123`）
  - newest: 分钟级刷新样本（`id=47198926`、`id=47198676`）
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - OpenAPI v3.1.2 规范
  - Pact provider verification 文档
  - GitHub required status checks 文档

## 本轮结论

- 契约治理若只做 pass/fail，会在高频变更时出现“过严停摆”与“过松破坏”双失效。
- `breaking_budget + provider_verify + replay_coverage` 必须并联成 required checks 才能在无人时段稳定推进。
- 本轮新增 pattern 将“契约优先”升级为“预算化、可回放、可追责”的执行闸门。

## Cycle 26 预载任务

1. 为 `breaking_budget` 增加按服务/消费者分层阈值（避免单阈值失真）。
2. 为 `replay_coverage` 增加 `critical_path_weight`，防止覆盖率数字好看但关键路径缺失。
3. 评估 `contract-breaking-budget-replay-gate` 与 `cancel-budget-stale-run-gate` 的联动顺序模板。

---
# Morning Brief（Nightshift Cycle 24）

> 更新时间：2026-02-28 19:44 UTC  
> 本轮目标：把“稳定信源”从 URL 假设升级为可验证的短链入口/OPML修订/HN水位线三重锁定。

## 本轮新增（已落盘）

1. `feed-governance/canonical-feed-drift-gate`
2. `feed-governance/_index.md`（新 topic 自动创建）
3. `_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `长周期作者基座（OPML canonical pool）` 为：
  - `OPML 重定向锚定（shortlink -> canonical target lock）`
  - `OPML 修订漂移监控（gist revision + digest diff）`
  - reason: 入口稳定与内容稳定是两层独立门禁，必须拆分建模。
- `merge`：合并方向
  - from: `外部证据溯源验签（artifact attestation + verify）`
  - from: `信源三角校验（OPML/HN/Official ratification）`
  - into: `信源仲裁验签（triangulation + provenance attestation）`
  - reason: 两条方向都在做“社区信号 -> 官方约束 -> 可审计晋级”的仲裁，长期并行会导致同构 pattern。
- `expand`：新增方向 `HN 三榜水位线治理（top/show/new watermark replay）`
  - 触发依据：`news/show/newest` 头部条目高频换代，跨窗口拼接会制造伪新增。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：本轮确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样并记录样本锚点：
  - top: `How to Build an Agent`（`id=45809487`）
  - show: `Show HN: SQL Noir`（`id=45809980`）
  - newest: `Voyage of the Aye-Aye`（`id=45810980`）
- 官方文档证据链（本轮重点）
  - Hacker News API（`topstories/showstories/newstories`）
  - GitHub REST API: Gists（`List gist commits` / `Get a gist revision`）
  - OPML 2.0 规范（目录交换语义）

## 本轮结论

- 仅锁定 URL 不能保证“长周期基座”稳定，必须锁定到可回放 revision。
- HN 三榜比较若不共享同一采样窗口，会把时间差误当新增洞察。
- 新增 `canonical-feed-drift-gate` 后，源漂移可在晋级前被 `hold`，减少重复 pattern 噪声。

## Cycle 25 预载任务

1. 给 `canonical_feed_pin.json` 增加 `http_status_chain` 与 `cache_control` 字段。
2. 将 `opml_revision_lock` 与 `promotion_packet` 的 `lineage_id` 强绑定，防止跨修订复用结论。
3. 评估 `canonical-feed-drift-gate` 与 `temporal-evidence-freshness-gate` 的并联顺序，输出统一 gate 顺序模板。

---
# Morning Brief（Nightshift Cycle 23）

> 更新时间：2026-02-28 19:28 UTC  
> 本轮目标：把“异步执行可用”升级为“异步执行可取消 + 过期结论可抑制”，避免旧 run 在次晨误晋级。

## 本轮新增（已落盘）

1. `autonomous-ops/cancel-budget-stale-run-gate`
2. `autonomous-ops/_index.md`（新增 pattern 索引）
3. `_master_index.md`（新增 pattern 行与 topic/统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `异步执行取消SLA治理（background run + cancel budget）` 为：
  - `运行取消预算治理（cancel SLA + concurrency group）`
  - `过期结论抑制治理（stale-run suppression + replay pin）`
  - reason: 取消时限与过期判定是两类不同门禁，混用会导致审计字段不可解释。
- `merge`：合并方向
  - from: `压缩恢复预算治理（compaction budget + recovery envelope）`
  - from: `恢复回放一体治理（state cell + checkpoint + artifact replay digest）`
  - into: `恢复回放账本治理（checkpoint + replay + compaction）`
  - reason: 两条方向都落到 checkpoint + artifact 回放，分开维护造成 ledger 字段同构重复。
- `expand`：新增方向 `取消后晋级防抖治理（cancel-to-promote debounce gate）`
  - 触发依据：HN 同时窗 `top/show/newest` 热点快速换代，单次取消不足以防止旧结论误晋级。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样并写入证据链（示例）：
  - top: `Show HN: Vibe Kanban`（`id=45809110`）
  - show: `Prompt Armor`（`id=45807945`）
  - newest: `Open-Source AI Learning Platform`（`id=45809835`）
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步任务状态机）
  - OpenAI Responses cancel endpoint（显式取消语义）
  - OpenAI Conversation state（状态续接与运行账本分层）
  - GitHub Actions concurrency（`cancel-in-progress`）
  - GitHub Actions artifacts（回放证据包持久化）

## 本轮结论

- 异步能力若不绑定取消预算，会让“最后完成”覆盖“最新有效”。
- `cancel trace + stale gate + debounce window` 需要成组落盘，否则白天接管无法判断是否应晋级。
- 本轮 pattern 将“取消”从执行细节提升为晋级前硬门禁。

## Cycle 24 预载任务

1. 为 `cancel_budget` 增加按方向动态阈值（top/show/new 分车道）。
2. 在 `promotion_packet` 增加 `superseded_chain` 字段，支持完整替代链回放。
3. 评估 `cancel-budget-stale-run-gate` 与 `comprehension-debt-ratchet-freeze-gate` 的协同门禁顺序。

---
# Morning Brief（Nightshift Cycle 22）

> 更新时间：2026-02-28 19:23 UTC  
> 本轮目标：把“证据路由可审计”升级为“接管能力可审计”，防止夜间吞吐在次日形成认知债务雪崩。

## 本轮新增（已落盘）

1. `comprehension-governance/comprehension-debt-ratchet-freeze-gate`
2. `comprehension-governance/_index.md`（新增 pattern 索引）
3. `_master_index.md`（新增 pattern 行与 topic/统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `双预算接管治理（compaction + comprehension gate）` 为：
  - `压缩恢复预算治理（compaction budget + recovery envelope）`
  - `认知负债冻结治理（comprehension debt + freeze gate）`
  - reason: 压缩预算与接管预算在故障处置时触发条件不同，绑定在同一方向会导致冻结策略不可解释。
- `merge`：合并方向
  - from: `信号配额路由（exploit/explore quota）`
  - from: `方向债务回收（lane debt + carry-over ratchet）`
  - into: `信号债务路由（exploit/explore + debt ratchet）`
  - reason: 两条方向都在定义“路由预算如何随积压调整”，拆开维护导致同构账本重复。
- `expand`：新增方向 `异步执行取消SLA治理（background run + cancel budget）`
  - 触发依据：官方 Background mode 状态机支持 queued/in_progress/completed 轮询，适合沉淀“可中断自治”的审计契约。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已通过 API 采样并验证分层：
  - `topstories` 样本（id `45806736`）分值 `326`，代表高共识成熟信号；
  - `showstories` 样本（id `45804620`）分值 `2`；
  - `newstories` 样本（id `45808555`）分值 `1`，代表早信号高噪声入口。
- 官方证据链（本轮重点）
  - OpenAI Background mode（后台任务 + 轮询状态机）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 状态延续）
  - GitHub protected branches required checks（冻结闸门不可绕过）
  - GitHub Actions artifacts（账本与解释包持久化）

## 本轮结论

- 仅有“证据债务棘轮”不足以保证白天可接管，必须并联“认知债务冻结闸门”。
- 当 `comprehension_debt_ratio` 超阈值时，系统应冻结晋级而不是继续推进闭环。
- freeze/unfreeze 决策若不落盘 `ratchet_decision + freeze_reason`，审计链仍不可追责。

## Cycle 23 预载任务

1. 定义 `comprehension_debt_ratio` 统一公式并写入 lint 规则。
2. 为 `freeze_gate_report.json` 增加 `unfreeze_evidence_refs` 强制字段。
3. 评估 `comprehension-debt-ratchet-freeze-gate` 与 `comprehension-budget-gate` 的收敛边界，避免同构膨胀。

---
# Morning Brief（Nightshift Cycle 21）

> 更新时间：2026-02-28 19:16 UTC  
> 本轮目标：把“固定配额路由”升级为“证据债务驱动路由”，防止 show/new 波动期出现晋级积压与审计盲区。

## 本轮新增（已落盘）

1. `signal-governance/lane-debt-ratchet-gate`
2. `signal-governance/_index.md`（新增 pattern 索引）
3. `_master_index.md`（新增 pattern 行与 topic/统计更新）
4. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `新颖信号车道（HN show/new + serendipity）` 为：
  - `show 讨论原型车道（HN show + builder chatter）`
  - `new 早信号车道（HN newest + freshness spike）`
  - reason: `show` 与 `newest` 的时效和噪声结构不同，混在同一车道会让配额策略失真。
- `merge`：合并方向
  - from: `交付证据闭环（PR -> Pattern + lineage attestation）`
  - from: `证据-任务绑定账本（digest-bound promotion manifest）`
  - into: `交付证据账本闭环（digest-bound PR->Pattern lineage）`
  - reason: 两条方向都在定义同一条交付链路账本，分开维护导致字段重复和审计口径不一致。
- `expand`：新增方向 `方向债务回收（lane debt + carry-over ratchet）`
  - 触发依据：固定配额无法解释“为何某车道长期积压”，需要独立方向沉淀债务账本与棘轮调参策略。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样并观察到显著分层：
  - top 存在高分热点（本轮采样可见 300+ 分级别条目）；
  - show/new 以早期低分信号为主，适合作为探索输入而非直接晋级。
- 官方证据链（本轮）：
  - Hacker News API（`topstories/showstories/newstories` + item 主键）
  - GitHub Issue Forms required 字段（晋级输入结构化）
  - GitHub protected branches required checks（不可绕过门禁）
  - GitHub Actions artifacts（账本与决策留痕）

## 本轮结论

- 配额本身不是治理，只有“债务账本 + 动态棘轮”才是可操作治理。
- `show/new` 的发现价值必须通过 ratification lane 消化，否则会形成“发现繁荣、晋级停滞”。
- 若不记录 `carry_over_debt` 与 `oldest_age_hours`，次日接管无法判断路由是否真实有效。

## Cycle 22 预载任务

1. 在 `lane_ledger` 增加 `debt_half_life` 规则，限制历史债务无限累积。
2. 为 `ratchet_decision` 增加可解释字段模板（`trigger_metric`、`fallback_rule`）。
3. 评估 `lane-debt-ratchet-gate` 与 `exploit-explore-evidence-router` 的边界，避免策略重复描述。

---
# Morning Brief（Nightshift Cycle 20）

> 更新时间：2026-02-28 19:12 UTC  
> 本轮目标：把“社区发现”与“执行晋级”之间的主断点，收敛成 OPML/HN/官方文档三角校验闸门。

## 本轮新增（已落盘）

1. `source-governance/triangulated-evidence-ratification-gate`
2. `source-governance/_index.md`
3. `_master_index.md`（新增 pattern 与 topic 统计）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `稳定信号车道（OPML + HN top + 官方文档）` 为：
  - `长周期作者基座（OPML canonical pool）`
  - `热度锚定采样（HN top anchor lane）`
  - reason: 原方向把“作者池维护”和“热度窗口采样”绑定在一个操作单元，导致节奏无法独立调参。
- `merge`：合并方向
  - from: `发现入库晋级（candidate -> issue promotion gate）`
  - from: `结构化需求入口（issue form required evidence fields）`
  - into: `候选晋级表单治理（candidate intake + issue form gate）`
  - reason: 两条方向都在定义候选晋级入口，长期并行维护会产生同构字段与双标准。
- `expand`：新增方向 `信源三角校验（OPML/HN/Official ratification）`
  - 触发依据：HN 实时流提供发现，官方文档提供约束；缺少三角仲裁会把“热门观点”误判为“可执行方案”。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样，继续呈现“长期趋势 + 新奇噪声”并存形态。
- 官方证据链（本轮重点）：
  - Hacker News API（claim 主键与时间锚）
  - GitHub Issue Forms required 字段（晋级入口结构化）
  - GitHub protected branches required checks（不可绕过门禁）
  - GitHub Actions artifacts（ratification 结果持久化）

## 本轮结论

- “看到信号”不等于“可执行证据”，必须先做三角校验再晋级。
- OPML/HN 负责发现广度，官方文档负责执行边界；两者缺一不可。
- 不落盘 `ratification_matrix`，次日接管会回到口头判断，无法审计追责。

## Cycle 21 预载任务

1. 为 `promotion_decision.json` 增加 `consistency_rule_id` 与 `official_doc_ref` 强校验字段。
2. 设计 `ratification_matrix` lint（缺官方锚点直接 fail）。
3. 评估 `triangulated-evidence-ratification-gate` 与 `candidate-to-issue-promotion-contract` 的合并边界，控制同构膨胀。

---
# Morning Brief（Nightshift Cycle 19）

> 更新时间：2026-02-28 19:07 UTC  
> 本轮目标：把“证据可回放”升级为“证据可验签”，补齐夜间发现到白天晋级之间的防篡改断点。

## 本轮新增（已落盘）

1. `evidence-governance/attested-evidence-provenance-gate`
2. `evidence-governance/_index.md`
3. `_master_index.md`（新增 pattern 索引与统计）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `外部证据时序锁（HN snapshot ledger + doc version pin）` 为：
  - `外部证据时间锚定（HN snapshot ledger + freshness window）`
  - `外部证据溯源验签（artifact attestation + verify）`
  - reason: 原方向同时承担“时间漂移治理”和“完整性验真”，失败归因不可操作。
- `merge`：合并方向
  - from: `外部证据时间锚定（HN snapshot ledger + freshness window）`
  - from: `证据时效治理（freshness SLA + snapshot pinning）`
  - into: `证据时效治理（freshness SLA + snapshot ledger pinning）`
  - reason: 两条方向本质同构，统一后可减少重复字段与双账本漂移。
- `expand`：新增方向 `证据-任务绑定账本（digest-bound promotion manifest）`
  - 触发依据：官方 attestation 文档明确支持产物溯源与离线验证，适合把 `candidate -> issue -> pr -> pattern` 绑定到同一 digest 证据主键。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样，持续呈现高时变信号，证明“仅时间锚定”不足以防篡改。
- 官方证据链（本轮重点补齐）：
  - Hacker News API（故事 ID 与时间字段作为可回放主键）
  - GitHub artifact attestations（构建 provenance 与离线验签）
  - GitHub protected branches required checks（把验签门禁变为不可绕过硬约束）

## 本轮结论

- “能回放”不等于“能验真”，外部证据必须引入 attestation verify。
- freshness gate 解决的是“是否过期”，attestation gate 解决的是“是否被替换”；两者必须并联。
- 若 digest 不与 `candidate/issue/pr/pattern` 绑定，审计链仍可被拼接伪造。

## Cycle 20 预载任务

1. 为 `promotion_report` 增加 `subject_digest` 与 `attestation_verified` 强校验字段。
2. 设计 `digest-bound lineage manifest` lint（digest 不一致直接 fail）。
3. 评估 `attested-evidence-provenance-gate` 与 `issue-pr-artifact-lineage-manifest` 的合并边界，压缩同构 pattern。

---
# Morning Brief（Nightshift Cycle 18）

> 更新时间：2026-02-28 19:03 UTC  
> 本轮目标：把“链接可见”升级为“证据可回放”，解决外部信号时变导致的次日不可复盘问题。

## 本轮新增（已落盘）

1. `evidence-governance/temporal-evidence-freshness-gate`
2. `evidence-governance/_index.md`
3. `_master_index.md`（新增 topic 与 pattern 索引）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `回放证据保全（Replay/Artifact）` 为：
  - `证据时效治理（freshness SLA + snapshot pinning）`
  - `回放完整性治理（artifact replay + checksum）`
  - reason: 原方向同时覆盖“时效”和“完整性”，执行时无法区分是过期失败还是回放失败。
- `merge`：合并方向
  - from: `运行态恢复治理（state cell + checkpoint + reflog + artifact digest）`
  - from: `回放完整性治理（artifact replay + checksum）`
  - into: `恢复回放一体治理（state cell + checkpoint + artifact replay digest）`
  - reason: 两条方向都服务于次日接管，字段与闸门高度同构，拆开维护造成重复审计。
- `expand`：新增方向 `外部证据时序锁（HN snapshot ledger + doc version pin）`
  - 触发依据：HN top/show/new 在短窗口内高频变化，若无时序锁，结论无法稳定回放。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样，页面内容在同日内显著漂移，证明“只存链接”不足以支撑复盘。
- 官方证据链（已补齐）：
  - Hacker News API（`topstories/newstories/showstories` 与 item 时间字段）
  - GitHub Actions artifacts（证据快照与摘要清单持久化）
  - GitHub protected branches required checks（freshness/replay 门禁硬约束）

## 本轮结论

- “抓到信号”不等于“保住证据”，夜间自治必须强制记录采样时刻与摘要哈希。
- 候选晋级前应先通过 freshness gate，超时证据必须重采样而非直接执行。
- 将回放清单纳入 required checks 后，次日接管才能做到可验证、可追责。

## Cycle 19 预载任务

1. 产出 `evidence_snapshot` 字段 lint（缺 `sampled_at_utc` 或 `digest` 直接 fail）。
2. 对齐 `freshness_gate` 与 `promotion_report` 字段，避免双账本漂移。
3. 评估 `temporal-evidence-freshness-gate` 与 `candidate-to-issue-promotion-contract` 的合并边界，控制同构膨胀。

---
# Morning Brief（Nightshift Cycle 17）

> 更新时间：2026-02-28 18:57 UTC  
> 本轮目标：把“发现信号”与“执行任务”之间的断层，收敛成可审计的候选晋级合同。

## 本轮新增（已落盘）

1. `backlog-governance/candidate-to-issue-promotion-contract`
2. `backlog-governance/_index.md`
3. `_master_index.md`（新增 topic 与 pattern 索引）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `证据路由守门（exploit/explore quota + promotion gate）` 为：
  - `信号配额路由（exploit/explore quota）`
  - `发现入库晋级（candidate -> issue promotion gate）`
  - reason: 原方向把“信号分流”与“任务入库”耦合在同一闸门，导致失败归因不清。
- `merge`：合并方向
  - from: `工作区可恢复性治理（checkpoint + artifact + reflog）`
  - from: `状态隔离与回放信封（per-agent state cell + WAL + artifact digest）`
  - into: `运行态恢复治理（state cell + checkpoint + reflog + artifact digest）`
  - reason: 两条方向都在解决“次日可恢复接管”，并行维护产生同构字段与重复审计。
- `expand`：新增方向 `结构化需求入口（issue form required evidence fields）`
  - 触发依据：HN top/show/new 持续提供高吞吐候选信号，而 GitHub Issue Forms 支持 required 字段，适合做晋级硬门。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样，观察到稳定趋势信号与高频新奇信号并存，直接入库会放大 backlog 噪声。
- 官方证据链（已补齐）：
  - GitHub Projects（项目视图与自动化流转）
  - GitHub Issue Forms（结构化必填字段）
  - GitHub protected branches required checks（晋级硬门）
  - GitHub Actions artifacts（证据包持久化）

## 本轮结论

- “发现很多”不等于“可执行很多”，必须先做 candidate 入池再晋级 Issue。
- 发现到执行的主闸门应该是结构化 Issue Form，而不是人工口头约定。
- 只有把 `candidate_id -> issue_id -> pr_id -> pattern_id` 落成 artifact，次日接管才可追责。

## Cycle 18 预载任务

1. 产出 `candidate_queue` 与 `issue_form` 字段对齐 lint（字段缺失即 fail）。
2. 将 `promotion_report` 与 `lineage_manifest` 的 ID 规范合并，减少双账本漂移。
3. 评估 `candidate-to-issue-promotion-contract` 与 `merge-fence-required-checks-lineage` 的边界，避免同构 pattern 膨胀。

---
# Morning Brief（Nightshift Cycle 16）

> 更新时间：2026-02-28 19:00 UTC  
> 本轮目标：把“信号收集”升级为“可配额、可晋级、可审计”的双车道路由闸门。

## 本轮新增（已落盘）

1. `signal-governance/exploit-explore-evidence-router`
2. `signal-governance/_index.md`
3. `_master_index.md`（新增 topic 与 pattern 索引）

## 激进动态策略执行（本轮）

- `split`：拆分方向 `夜间证据巡航（背景异步 + OPML/HN 融合 + 本地落盘）` 为：
  - `稳定信号车道（OPML + HN top + 官方文档）`
  - `新颖信号车道（HN show/new + serendipity）`
  - reason: 原方向在执行中同时承担“稳定增量”和“新颖发现”，容易形成单车道拥塞并降低落盘质量。
- `merge`：合并方向
  - from: `上下文预算治理（compaction contract + checkpoint handoff）`
  - from: `认知债务闸门（comprehension budget + explainability bundle）`
  - into: `双预算接管治理（compaction + comprehension gate）`
  - reason: 两者都在约束“次日可接管”，继续分治会产生同构闸门与重复审计字段。
- `expand`：新增方向 `证据路由守门（exploit/explore quota + promotion gate）`
  - 触发依据：HN `news/show/newest` 持续并发“高热趋势 + 新颖项目”双信号，单源策略无法兼顾稳定与新发现。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist，active 2026-02-28）。
- HN `top/show/new`：已采样并用于双车道路由设计。
- 官方证据链（已补齐）：
  - OpenAI Background mode（长任务异步执行）
  - OpenAI Conversation state（状态分层边界）
  - GitHub protected branches required checks（晋级硬门）
  - GitHub Actions artifacts（证据包持久化）

## 本轮结论

- 夜间自治不应只做“信息抓取”，而应做“信号分流 + 配额控制 + 晋级守门”。
- 只有把 explore 发现先进入候选池，才能避免新颖性吞噬稳定产出。
- 只有把晋级结果落到 required checks + artifacts，次日接管才可追责。

## Cycle 17 预载任务

1. 产出 `signal_router.json` 的 lint 规则（配额透支直接 fail）。
2. 对齐 `promotion_report` 与 `lineage_manifest` 字段，消除双清单漂移。
3. 评估 `exploit-explore-evidence-router` 与 `opml-hn-priority-watchlist` 的去重边界，决定是否归并。

---
# Morning Brief（Nightshift Cycle 15）

> 更新时间：2026-02-28 18:43 UTC  
> 本轮目标：把“夜间高吞吐”升级为“可理解、可接管、可审计”的认知闸门机制。

## 本轮新增（已落盘）

1. `comprehension-governance/comprehension-budget-gate`
2. `comprehension-governance/_index.md`

## 激进动态策略执行（本轮）

- `expand`：新增方向 `认知债务闸门（comprehension budget + explainability bundle）`
  - 触发依据：HN top 同轮出现 `Cognitive Debt`、`VSDD`、`747s and coding agents`，共同指向“速度超过理解”的系统性风险。
- `split`：拆分方向 `PRD -> Epic -> Issue -> PR -> Pattern 执行闭环` 为：
  - `需求计划闭环（PRD -> Epic -> Issue）`
  - `交付证据闭环（PR -> Pattern + lineage attestation）`
  - reason: 原方向过宽，执行时容易把“计划映射”与“证据审计”混成单闸门，导致验收标准失焦。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/new`：已采样并记录高价值信号（`Cognitive Debt`、`VSDD`、`747s and coding agents`）。
- 官方证据链（已补齐）：
  - OpenAI Conversation state（状态分层边界）
  - GitHub protected branches（required checks）
  - GitHub Actions artifacts（解释包持久化）

## 本轮结论

- AI 流程的主风险正在从“做不出来”转向“做太快但无法验证理解”。
- 合并闸门必须同时校验 `预算约束 + 解释包完整性 + 可复现命令`，否则次晨接管不可控。
- “会话连续性”不应替代“工程证据连续性”，二者必须分层治理。

## Cycle 16 预载任务

1. 产出 `comprehension-gate` 的机器校验规则（预算超阈值直接 fail）。
2. 对齐 `lineage-manifest` 与 `comprehension_report` 字段，消除双清单漂移。
3. 评估 `comprehension-budget-gate` 与 `execution-proof-bundle` 的合并边界，避免同构 pattern 膨胀。

---
# Morning Brief（Nightshift Cycle 14）

> 更新时间：2026-02-28 18:39 UTC  
> 本轮目标：把“24h 无人推进”从“有日志”升级为“有隔离状态单元 + 可回放信封”的可验证执行面。

## 本轮新增（已落盘）

1. `state-governance/agent-state-cell-replay-envelope`
2. `state-governance/_index.md`

## 激进动态策略执行（本轮）

- `expand`：新增方向 `状态隔离与回放信封（per-agent state cell + WAL + artifact digest）`
  - 触发依据：HN top 出现“每 agent/tenant/document 独立 SQLite”与“Don’t trust AI agents”并发信号，说明状态隔离与可验证回放已进入刚需阶段。
- `merge`：合并方向
  - from: `夜间证据车道（背景异步 + 本地落盘）`
  - from: `Hacker News + OPML 长短信号融合`
  - into: `夜间证据巡航（背景异步 + OPML/HN 融合 + 本地落盘）`
  - reason: 两条方向都服务于同一条证据采集流水线，分离会造成同构 pattern 和重复调度。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/new`：已采样，捕获到“状态隔离”“默认不信任 agent”“本地优先记忆与上下文治理”连续信号。
- 官方证据链（已补齐）：
  - OpenAI Background mode（长任务异步执行）
  - OpenAI Conversations API（会话状态管理边界）
  - SQLite WAL（状态持久化与 checkpoint）
  - GitHub Actions artifacts（回放信封跨步骤保存与校验）

## 本轮结论

- 仅有执行日志不足以支撑次晨接管，必须补 `state_cell_id + db_snapshot_ref + action_log_ref`。
- “会话状态”与“运行态存储”必须分层：前者用于对话连续性，后者用于可回放审计。
- 把回放信封做成 artifact 后，夜间自治才具备可验证与可追责属性。

## Cycle 15 预载任务

1. 产出 `state-cell-lint` 规则（隔离键缺失即 fail）。
2. 设计 `replay-envelope` 与 `lineage-manifest` 的字段映射，减少双清单漂移。
3. 评估 `回放证据保全` 与 `状态隔离与回放信封` 的 pattern 合并边界，控制同构膨胀。

---
# Morning Brief（Nightshift Cycle 13）

> 更新时间：2026-02-28 18:35 UTC  
> 本轮目标：把“前端设计系统”从可展示升级为“可交接、可闸门、可审计”的 Agent 执行契约。

## 本轮新增（已落盘）

1. `fullstack-engineering/agent-design-export-contract`
2. `fullstack-engineering/_index.md`

## 激进动态策略执行（本轮）

- `split`：拆分方向 `前端设计系统（可次日直接实战）` 为：
  - `设计令牌治理（schema + drift lint）`
  - `组件验收治理（story + a11y + visual gate）`
  - reason: 原方向过宽，落地时经常把“设计语义”与“验收闸门”混在一条执行线，导致产出不可验证。
- `expand`：新增方向 `AI 设计导出契约（design-export + required-checks）`
  - 触发依据：HN show 出现面向 agent 时代的设计导出工具（Mowgli），说明“设计到代码交接协议化”已成为一线需求。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/new`：已采样，捕获到“认知债务”“设计导出”“规格驱动交付”连续信号。
- 官方证据链（已补齐）：
  - Design Tokens 规范（结构化设计语义）
  - Storybook UI Testing（interaction/a11y/visual + CI）
  - GitHub protected branches required checks（不可绕过闸门）

## 本轮结论

- “可展示的设计系统”不等于“可自动执行的交接系统”，缺口在机器可验证合同。
- 必须把 `token_schema + component_contract + interaction_matrix + required_checks` 作为交接最小包。
- 只有把 design gate 设为 required checks，次日接管才不会退化为人工抽检。

## Cycle 14 预载任务

1. 产出 `design-contract-lint` 字段规则（缺字段即 fail）。
2. 将 `visual_baseline_ref` 与 `lineage_id` 对齐，减少审计断链。
3. 评估 `design-gate` 与 `lineage-gate` 的去重合并条件，避免同构闸门膨胀。

---
# Morning Brief（Nightshift Cycle 12）

> 更新时间：2026-02-28 18:32 UTC  
> 本轮目标：把“上下文压缩”从节省 token 的技巧升级为“可恢复交接”的硬契约，避免跨会话断点。

## 本轮新增（已落盘）

1. `context-governance/compaction-recovery-contract`
2. `context-governance/_index.md`

## 激进动态策略执行（本轮）

- `expand`：新增方向 `上下文预算治理（compaction contract + checkpoint handoff）`
  - 触发依据：HN top 出现上下文窗口治理高热信号，且官方文档明确存在 conversation compaction。
- `split`：拆分方向 `后端契约优先与回放验证` 为：
  - `契约变更门禁（OpenAPI/Pact）`
  - `回放证据保全（Replay/Artifact）`
  - reason: 一条方向同时覆盖“规范兼容”与“证据保全”会导致执行卡过宽，拆分后可直接映射到独立 gate。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/new`：已采样，捕获到“上下文压缩治理”“文件恢复工具”“版本恢复”连续信号。
- 官方证据链（已补齐）：
  - OpenAI Conversation state（含 compaction）
  - OpenAI Background mode（跨会话异步任务）
  - GitHub Actions artifacts（结构化交接产物）
  - Git `reflog`（本地恢复指针）

## 本轮结论

- 只做上下文压缩会降低 token 成本，但不会自动提升次晨可接管性。
- 自治系统需要在 compaction 触发时强制写 `compaction-manifest`，把 `pending_steps + checkpoint_id + reflog_ref` 作为恢复最小集合。
- “压缩成功率”应从属“恢复成功率”，否则会出现看似省 token、实则丢流程语义的隐性故障。

## Cycle 13 预载任务

1. 产出 `compaction-manifest-lint` 规则（缺关键字段即 fail）。
2. 把 `compaction-manifest` 与 `lineage-manifest` 做字段映射，避免双清单漂移。
3. 评估 `recovery-gate` 与 `context-gate` 的合并边界，减少同构闸门。

---
# Morning Brief（Nightshift Cycle 11）

> 更新时间：2026-03-01 02:42 UTC  
> 本轮目标：将“无人推进的可审计”继续前移到“可恢复”，降低长会话断裂后的接管成本。

## 本轮新增（已落盘）

1. `recovery-governance/workspace-recovery-envelope`
2. `recovery-governance/_index.md`

## 激进动态策略执行（本轮）

- `expand`：新增方向 `工作区可恢复性治理（checkpoint + artifact + reflog）`
  - 触发依据：HN show/newest 出现 `Claude-File-Recovery`、`Unfucked` 等“恢复工具”密集信号。
- `merge`：合并方向
  - from: `发布晋级治理（required reviewers + prevent self-reviews + deployment success gate）`
  - into: `白天晋级车道（分支保护 + 环境审批）`
  - reason: 两者同构，均服务于“白天受控晋级”，拆开会导致 pattern 重复膨胀。

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/newest`：已采样，show/newest 出现恢复与版本化相关项目（`Claude-File-Recovery`、`Unfucked`、`MemoryKit`）。
- 官方证据链（已补齐）：
  - OpenAI Background mode（跨会话异步任务）
  - GitHub Actions artifacts（结构化产物留存）
  - Git `reflog`（本地历史恢复指针）

## 本轮结论

- 长时自治的关键指标应从“执行成功率”升级为“恢复成功率”。
- 仅有 merge gate 不足以保障次晨接管，必须补 `checkpoint_id + pending_steps + reflog_ref`。
- `recovery-manifest` 应成为夜间落盘的一级产物，而不是日志附注。

## Cycle 12 预载任务

1. 设计 `recovery-manifest-lint`（字段缺失即 fail）。
2. 给 `lineage_id` 增加 `checkpoint_span` 指标，量化恢复粒度。
3. 评估 `recovery-gate` 与 `lineage-gate` 的合并边界，防止新一轮同构闸门膨胀。

---

# Morning Brief（Nightshift Cycle 10）

> 更新时间：2026-03-01 02:31 UTC  
> 本轮目标：把“夜间无人推进”与“白天受控发布”拆成可执行的两段式晋级闸门，避免效率与安全二选一。

## 本轮新增（已落盘）

1. `release-governance/staged-promotion-gate`
2. `release-governance/_index.md`

## 激进动态策略执行（本轮）

- `split`：将 `24h 无人 AI 推进（可控守门 + 可审计）` 拆分为：
  - `夜间证据车道（背景异步 + 本地落盘）`
  - `白天晋级车道（分支保护 + 环境审批）`
- `expand`：新增方向 `发布晋级治理（required reviewers + prevent self-reviews + deployment success gate）`

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/newest`：已采样，持续出现 AI 编程长期实战、工具链和自治可靠性讨论信号。
- 官方证据链（已补齐）：
  - OpenAI Background mode（异步长任务）
  - GitHub environments（required reviewers + prevent self-reviews）
  - GitHub protected branches（required checks + deployment success before merge）

## 本轮结论

- 无人推进系统应默认只跑“证据车道”，把“发布副作用”推迟到可审批的晋级车道。
- `required checks` 解决“能否合并”，`required reviewers` 解决“能否晋级环境”，二者不可互相替代。
- 统一 `lineage_id` 仍是跨车道审计主键，否则次晨无法快速追责与复盘。

## Cycle 11 预载任务

1. 补 `promotion-manifest-lint`（字段缺失即 fail）。
2. 把 `deployment_env` 与 reviewer 组映射到环境配置模板。
3. 评估 `lineage-gate` 与 `promotion-gate` 的去重合并条件，避免闸门同构膨胀。

---

# Morning Brief（Nightshift Cycle 9）

> 更新时间：2026-02-28 18:16 UTC  
> 本轮目标：将“证据已产出但可被绕过”的风险收敛为受保护分支的 required checks 合并围栏。

## 本轮新增（已落盘）

1. `product-delivery/merge-fence-required-checks-lineage`

## 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已确认重定向到 HN Popular Blogs OPML（Gist）。
- HN `top/show/newest`：已采样，观测到“长期 AI 编程实战”“Spec 驱动工程”“Agent 可信性讨论”等连续信号。
- 官方证据链：OpenAI Background、GitHub protected branches / issue forms / PR 链接 / workflow artifacts、OpenAPI、Pact、Design Tokens、Storybook。

## 本轮结论

- 真正决定无人推进质量的不是“有没有流程文档”，而是“闸门是否被配置为 required checks”。
- 四个固定方向可收敛为三道必过检查：`design-gate`、`contract-gate`、`lineage-gate`。
- `lineage_id` 必须从 Issue Form 起就成为硬约束，否则次日审计仍会断链。

## Cycle 10 预载任务

1. 产出可直接复用的 branch protection 配置清单（required checks + 审批规则）。
2. 补一个 `lineage-manifest-lint` 最小实现草案（字段缺失即 fail）。
3. 将 Pattern 回写触发源切换到 `lineage-manifest.json`（非日志文本）。

---

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
