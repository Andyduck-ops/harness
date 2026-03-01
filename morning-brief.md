# Morning Brief（Nightshift Cycle 74）

> 更新时间：2026-02-28 23:59 UTC  
> 本轮目标：把“冲突可检测”升级为“冲突超时可处置”，防止 freeze 长期悬挂后被绕过晋级。

### 本轮新增（已落盘）

1. `references/patterns/control-plane-governance/contradiction-sla-tombstone-gate.md`
2. `references/patterns/control-plane-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `冲突超时墓碑门禁（contradiction SLA tombstone gate）`
  - reason: 仅 freeze 不能解决长期未决冲突，超时必须 tombstone 化并阻断晋级。
- `split`：拆分方向
  - from: `Claim 生命周期冻结治理（claim lifecycle freeze governance）`
  - into: `Claim 开放态超时治理（claim open-state timeout governance）`
  - into: `Claim 墓碑再资格化治理（claim tombstone requalification governance）`
  - reason: “超时处置”与“墓碑复活”是两种独立失效面，需要独立阈值和门禁。
- `merge`：合并方向
  - from: `证据冲突账本门禁（evidence contradiction ledger gate）`
  - from: `冲突解决复批门禁（conflict-resolution reapproval gate）`
  - into: `冲突仲裁双相合同治理（conflict arbitration dual-phase contract gate）`
  - reason: 两方向都在约束冲突闭环，统一为 reverify + reapprove 双相合同可减少同构漂移。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已重定向到 HN Popular Blogs OPML Gist（`e6d2bf860ccc367fe37ff953ba6de66b`，页面可见多次修订）。
- HN 三车道页面采样（2026-02-28）
  - news/top: `https://news.ycombinator.com/item?id=47200342`
  - show: `https://news.ycombinator.com/item?id=47195123`
  - newest: `https://news.ycombinator.com/item?id=47201816`
- HN API 三车道头部采样（同窗）
  - `topstories[0]=47196582`
  - `showstories[0]=47195123`
  - `newstories[0]=47201864`
- 官方文档补链（2026-02-28）
  - Required status checks（冲突 SLA 与 tombstone 清理可设为硬门禁）
  - `merge_group`（队列场景需要独立检查，避免 PR/queue 校验分叉）
  - Workflow artifacts（冲突账本与处置报告可审计回放）
  - Issue forms（冲突字段可结构化必填）

### 本轮结论

- 冲突治理若只停在 `freeze`，会在 24h 无人模式中累积“悬挂冲突债务”，最终倒逼旁路放行。
- 应把冲突状态机升级为 `open -> frozen -> tombstoned -> requalified`，并把超时 tombstone 纳入 required checks。
- PR 和 merge queue 必须同构执行 `contradiction_sla_pass` 与 `contradiction_tombstone_clear`，否则存在队列绕过面。

### Cycle 75 预载任务

1. 输出 `contradiction_sla_report.json` 与 `tombstone_registry.json` 的 schema + lint。
2. 将 `contradiction_sla_pass`、`contradiction_tombstone_clear` 接入 candidate->issue 与 merge queue 双门禁。
3. 增加 `requalify_packet` 的最小证据要求（new_evidence_digest + new_lane_snapshot + reapprove_ticket）。

---
# Morning Brief（Nightshift Cycle 73）

> 更新时间：2026-02-28 23:58 UTC  
> 本轮目标：把“社区信号与官方规则矛盾”从可忽略日志升级为阻断性控制面门禁。

### 本轮新增（已落盘）

1. `references/patterns/control-plane-governance/contradiction-ledger-freeze-gate.md`
2. `references/patterns/control-plane-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `冲突账本冻结门禁（contradiction-ledger freeze gate）`
  - reason: 社区热度与官方规则冲突时，缺少结构化冻结会导致错误晋级在下一轮被继续放大。
- `split`：拆分方向
  - from: `证据时效验签一体化（freshness + provenance ratification gate）`
  - into: `证据冲突账本门禁（evidence contradiction ledger gate）`
  - into: `冲突解决复批门禁（conflict-resolution reapproval gate）`
  - reason: “冲突识别”与“冲突解锁批准”是两个独立失效面，必须分别设阈值与阻断动作。
- `merge`：合并方向
  - from: `Claim-ID 强绑定治理（claim_id -> hn_item_id -> outline_key binding）`
  - from: `墓碑晋级冻结门禁（tombstone promotion freeze gate）`
  - into: `Claim 生命周期冻结治理（claim lifecycle freeze governance）`
  - reason: 两者都在约束 claim 可追溯与失效处置，合并后减少同构 pattern 漂移。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist。
- OPML 入口版本（2026-02-28）
  - Gist: `e6d2bf860ccc367fe37ff953ba6de66b`
  - `updated_at=2026-02-28T19:33:01Z`，`history_count=6`
- HN 三车道页面采样（2026-02-28T23:51Z）
  - news/top: item `47200342` — `MinIO Is Dead, Long Live MinIO`
  - show: item `47195123` — `Show HN: Now I Get It...`
  - newest: item `47201858` — `As SuperAgers age...`
- HN API 交叉采样（同窗口）
  - `topstories[0]=47200342`
  - `showstories[0]=47195123`
  - `newstories[0]=47201885`
- 官方文档补链（2026-02-28）
  - GitHub Protected Branches + Required checks（不可绕过合并门禁）
  - GitHub Workflow Artifacts（证据与冲突报告可回放）
  - GitHub Issue Forms（冲突字段可结构化必填）
  - GitHub `merge_group`（队列场景需独立触发检查）

### 本轮结论

- 当社区信号与官方规则冲突时，系统必须先 `freeze`，再 `reverify + reapprove`，否则会在自动化里持续误晋级。
- 冲突治理应成为独立控制面，不应内嵌在普通 freshness/provenance 规则里隐式处理。
- `merge_group` 若不接冲突门禁，会形成“PR 过检但队列绕过”的审计断点。

### Cycle 74 预载任务

1. 补 `contradiction_ledger.json` 与 `conflict_resolution_report.json` 的 schema + lint。
2. 将 `conflict_freeze_pass`、`conflict_resolution_pass` 接入 candidate->issue 与 merge queue 双门禁。
3. 给冲突 `open > 24h` 增加自动升级到人工裁决队列的处置模板。

---
# Morning Brief（Nightshift Cycle 72）

> 更新时间：2026-02-28 23:46 UTC  
> 本轮目标：把 `shownew` 的“首现快”与 `top` 的“扩散快”拆轨，强制跨车道时滞预算与复采样门禁。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/shownew-top-lag-reverify-gate.md`
2. `references/patterns/discovery-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `Shownew->Top 证据半衰期预算治理（shownew-top evidence half-life budget gate）`
  - reason: `shownew` 首现后证据衰减快，若不设半衰期预算，晋级会基于过期快照。
- `split`：拆分方向
  - from: `Shownew 首现-晋级时滞基线门禁（shownew-promotion-lag-baseline gate）`
  - into: `Shownew 首现时滞下限门禁（shownew-min-lag gate）`
  - into: `Shownew 跨车道复采样时滞门禁（shownew-cross-lane-lag-reverify gate）`
  - reason: “时间下限”与“复采样窗口”是不同失效面，需独立阈值。
- `merge`：合并方向
  - from: `Shownew->Top 跨车道时滞预算治理（shownew-to-top lag-budget gate）`
  - from: `Shownew 衰减前复采样门禁（shownew-pre-decay-reverify gate）`
  - into: `Shownew->Top 时滞复采样一体门禁（shownew-top lag-reverify unified gate）`
  - reason: 两者都在约束“晋级前二次证据确认”，合并后减少同构重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向至 HN Popular Blogs OPML。
- HN 三车道/页面采样（2026-02-28）
  - top(news): item `47200342` — `Show HN: Electric Clojure`
  - show: item `47195123` — `Show HN: RubberUI...`
  - newest(shownew): item `47200770` — `Show HN: A simple money transfer app...`
- 官方文档补链（2026-02-28）
  - HN API：`topstories/showstories/newstories` 为独立分发车道。
  - GitHub Merge Queue + `merge_group`：队列场景需独立触发并通过检查。
  - GitHub Protected Branches：required status checks 未通过不可合并。

### 本轮结论

- `shownew` 首现与 `top` 扩散不是同一信号，必须由时滞预算断开直通晋级。
- candidate->issue 晋级需要 `first_seen -> lag_budget -> cross_lane_reverify -> required_checks` 四段闭环。
- 缺少复采样 digest 的晋级请求应视为高风险噪声并阻断。

### Cycle 73 预载任务

1. 增补 `shownew_top_reverify.json` 的 schema 与 lint 规则。
2. 将 `shownew_top_promotion_contract_pass` 接入 candidate->issue 必填 checks。
3. 给“复采样失败”增加自动回退观察池模板与冷却重试策略。

---
# Morning Brief（Nightshift Cycle 71）

> 更新时间：2026-03-01 07:48 UTC  
> 本轮目标：把 `newest` 首现热度从“可立即晋级”降级为“必须经过时滞预算 + 复采样”的信号。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/shownew-promotion-latency-gate.md`
2. `references/patterns/discovery-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `Shownew->Top 跨车道时滞预算治理（shownew-to-top lag-budget gate）`
  - reason: newest 首现经常先于可执行证据形成，必须把“发现时刻”与“晋级时刻”拆开治理。
- `split`：拆分方向
  - from: `Shownew 晋级延迟采样治理（shownew-promotion-latency gate）`
  - into: `Shownew 首现-晋级时滞基线门禁（shownew-promotion-lag-baseline gate）`
  - into: `Shownew 衰减前复采样门禁（shownew-pre-decay-reverify gate）`
  - reason: 时滞阈值与复采样稳定性是两个独立失效面，需独立阈值和阻断动作。
- `merge`：合并方向
  - from: `Show 可执行预检门禁（show executability preflight gate）`
  - from: `Show 可达-存活预检门禁（show reachability-liveness preflight gate）`
  - into: `Show 预检统一合同门禁（show unified preflight contract gate）`
  - reason: 两方向同属 preflight 合同，合并后可避免同构 pattern 漂移。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已重定向到 HN Popular Blogs OPML（Gist Last active 2026-02-28）。
- HN 三车道页面同窗采样（2026-03-01）
  - news: item `47221127` — `Show HN: Browser Use CLI...`
  - show: item `47220379` — `Show HN: Fine Structure Preserving Transformations`
  - newest: item `47221464` — `Show HN: Honey Route AI...`
- HN API 端点锚点（2026-03-01）
  - `topstories[0] = 47221159`
  - `showstories[0] = 47220379`
  - `newstories[0] = 47221464`
- 官方文档补链
  - HN API：`topstories/showstories/newstories` 为独立分发车道。
  - GitHub Merge Queue + `merge_group`：队列内变更需独立触发检查。
  - GitHub Protected Branches：required status checks 不通过不可合并。

### 本轮结论

- `newest` 的“首现快”不等于“可执行成熟快”。
- candidate->issue 晋级必须引入 `first_seen -> lag_budget -> cross_lane_recheck` 三步闭环。
- 没有时滞预算与复采样证据的晋级，应被视为高噪声晋级并阻断。

### Cycle 72 预载任务

1. 输出 `shownew_lag_budget.json` 与 `shownew_cross_lane_recheck.json` 的 schema + lint。
2. 将 `shownew_lag_budget_pass` 接入 candidate->issue 晋级必填 checks。
3. 给“复采样失败”场景补充自动回退到观察池的处置模板。

---
# Morning Brief（Nightshift Cycle 70）

> 更新时间：2026-03-01 00:05 UTC  
> 本轮目标：把 Show/Top 同窗热度从“立即晋级触发器”降级为“需冷却复采样后才可晋级”的信号。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/show-top-resonance-cooldown-gate.md`
2. `references/patterns/discovery-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `Shownew 晋级延迟采样治理（shownew-promotion-latency gate）`
  - reason: shownew->show/news 迁移速度常早于复现证据生成速度，需要独立延迟采样治理。
- `split`：拆分方向
  - from: `Show-Top 共振冷却晋级治理（show-top resonance cooldown gate）`
  - into: `Show-Top 共振窗口门禁（show-top resonance-window gate）`
  - into: `Show-Top 冷却预算门禁（show-top cooldown-budget gate）`
  - reason: 共振判定与冷却预算属于不同控制面，需分离阈值与回退策略。
- `merge`：合并方向
  - from: `Show URL 可达门禁（show-url reachability gate）`
  - from: `HN 条目存活预检治理（dead/deleted pre-promotion gate）`
  - into: `Show 可达-存活预检门禁（show reachability-liveness preflight gate）`
  - reason: 两者都在过滤无效候选，合并后 preflight 合同更一致。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已重定向至 HN Popular Blogs OPML（Gist 最新修订 2026-02-28 可见）。
- HN 三车道同窗采样（2026-02-28）
  - news: item `47195123` — `Show HN: RubberUI...`
  - show: item `47180083` — `Show HN: DeFAI...`
  - newest: item `47200719` — `Show HN: Better Auth...`
- 官方文档证据链
  - HN API：`topstories/showstories/newstories` 与 item 对象语义分离（社区分发信号）。
  - GitHub Merge Queue + `merge_group`：队列场景需独立检查触发。
  - GitHub Protected Branches：required status checks 未通过不可合并。

### 本轮结论

- Show/Top 共振是“传播加速度”信号，不是“执行成熟度”信号。
- candidate->issue 晋级应强制 `capture -> cooldown -> recapture` 三步闭环，禁止单次快照直通。
- 冷却后未复采样即晋级，等价于把热度当证据，必须阻断。

### Cycle 71 预载任务

1. 输出 `show_resonance_window.json` 与 `show_resonance_cooldown.json` 的 schema + lint。
2. 将 `show_resonance_reverify_pass` 接入 candidate->issue 晋级表单必填检查。
3. 给 `show-top` 共振场景补充“冷却失败自动降级到观察队列”的处置模板。

---
# Morning Brief（Nightshift Cycle 69）

> 更新时间：2026-02-28 23:39 UTC  
> 本轮目标：把 Show 热度晋级从“可见性阈值”升级为“复现验签阈值”，阻断仅凭热度的伪晋级。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/show-repro-attestation-gate.md`
2. `references/patterns/discovery-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `Show-Top 共振冷却晋级治理（show-top resonance cooldown gate）`
  - reason: HN `top` 与 `show` 同窗共振会加速晋级冲动，需要独立冷却策略避免热度即执行。
- `split`：拆分方向
  - from: `Show 可执行预检门禁（show executability preflight gate）`
  - into: `Show URL 可达门禁（show-url reachability gate）`
  - into: `Show 复现验签门禁（show-repro attestation gate）`
  - reason: 可达性检查与可复现验签属于不同失效面，需分离阈值和阻断依据。
- `merge`：合并方向
  - from: `Show 复现证据签名治理（show-repro attestation gate）`
  - from: `Show 复现工件验签门禁（show-repro artifact attestation gate）`
  - into: `Show 复现验签门禁（show-repro attestation gate）`
  - reason: 两方向语义同构，合并后统一 schema 与 required checks，减少重复 pattern 漂移。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已重定向并锚定到 HN Popular Blogs OPML raw（2026-02-28）。
- HN top/show/new API 同窗采样（2026-02-28）
  - `topstories[0]`: item `47220686` — `Show HN: BrowserOS: Browser + Linux = local apps in your browser tab`
  - `showstories[1]`: item `47219451` — `Show HN: Escape from Los Angeles 1996`
  - `newstories[0]`: item `47220825` — `Show HN: Text containers in tool docs should not be comments`
- HN Show 规则页（官方）
  - Show 帖先进入 `shownew`，达到 4 points/2 comments 后才进入 `show`，且可设置 no-show。
- 官方文档证据链（本轮重点）
  - GitHub Protected Branches：required status checks 必须通过才能合并
  - GitHub Artifact Attestations：构建产物 provenance 可加密验签

### 本轮结论

- Show 可见性阈值（shownew→show）是社区分发规则，不是工程可复现规则。
- candidate->issue 晋级应增加 `show_repro_attestation_verified_pass` 硬门禁。
- 三车道热度共振只能决定“关注优先级”，不能替代“可复现签名证据”。

### Cycle 70 预载任务

1. 将 `show_repro_attestation.json` 字段映射到 issue form 必填项（缺失即阻断）。
2. 为 `show-top resonance` 方向补充最小冷却窗口与复采样阈值。
3. 输出 `show promotion required-checks matrix`，区分可达性失败与验签失败处置路径。

---
# Morning Brief（Nightshift Cycle 68）

> 更新时间：2026-02-28 23:33 UTC  
> 本轮目标：把 Show 热度信号从“可看”升级为“可执行”，阻断 demo 驱动的伪晋级。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/show-lane-executability-gate.md`
2. `references/patterns/discovery-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `Show 复现证据签名治理（show-repro attestation gate）`
  - reason: HN `show` 条目可快速进入 `news`，需要将“可演示”与“可复现”分离并纳入可审计签名证据。
- `split`：拆分方向
  - from: `Show 车道可执行性门禁（show-lane executability gate）`
  - into: `Show 演示可达性门禁（show-demo reachability gate）`
  - into: `Show 复现工件验签门禁（show-repro artifact attestation gate）`
  - reason: URL 可达与复现可验证是两个独立失效面，需要独立阈值和阻断条件。
- `merge`：合并方向
  - from: `Show 演示可达性门禁（show-demo reachability gate）`
  - from: `HN 条目存活预检治理（dead/deleted pre-promotion gate）`
  - into: `Show 可执行预检门禁（show executability preflight gate）`
  - reason: 两者都用于“晋级前过滤无效条目”，合并后减少同构重复并统一预检口径。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已作为入口验证并落到 HN Popular Blogs OPML Gist（2026-02-28）。
- HN 三车道页面同窗快照（2026-02-28）
  - news: item `47218423` — `Show HN: Mowgli - Figma for the agent era...`
  - show: item `47218423` — `Show HN: Mowgli...`，item `47216687` — `Show HN: A2A Coder`
  - newest: item `47219335` — `Show HN: Solcoder...`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue（required checks 约束）
  - GitHub Actions `merge_group`（队列场景检查触发）
  - Protected Branches required status checks（不可绕过门禁）
  - Workflow artifacts（回放证据落盘）

### 本轮结论

- Show 的“热度跨车道迁移”不是可执行性证明；必须先过预检合同。
- candidate->issue 晋级应至少绑定 `capture + preflight + required-check + replay bundle` 四类证据。
- 没有 required checks 的“手工判断”会在队列场景下失效。

### Cycle 69 预载任务

1. 把 `show_executability_preflight.json` 变成 issue 表单必填工件。
2. 对 `newest` 的 Show 候选增加冷却复采样阈值。
3. 给 `merge_group` 增补 Show 证据门禁检查模板。

---
# Morning Brief（Nightshift Cycle 67）

> 更新时间：2026-02-28 23:17 UTC  
> 本轮目标：把“代码评审”和“部署审批”从形式双门禁升级为“身份独立性门禁”，阻断同一批评审人跨阶段重复放行。

### 本轮新增（已落盘）

1. `references/patterns/release-governance/cross-stage-reviewer-diversity-gate.md`
2. `references/patterns/release-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `跨阶段评审身份多样性门禁治理（cross-stage reviewer diversity gate）`
  - reason: GitHub Deployments 在 required reviewers 场景中仅需 1 人可批准，且支持批量 `Start all waiting jobs`，需要补齐跨阶段身份独立性约束。
- `split`：拆分方向
  - from: `审批-旁路双轨时效同构治理（approval-bypass dual-track freshness parity gate）`
  - into: `跨阶段评审身份重叠预算治理（cross-stage reviewer overlap budget gate）`
  - into: `部署批量审批隔离审计治理（deployment batch-approval quarantine gate）`
  - reason: 身份重叠与旁路隔离是两个独立失效面，拆分后可分别绑定阈值和追责字段。
- `merge`：合并方向
  - from: `审批批次上限治理（approval batch-size cap gate）`
  - from: `审批冷却窗口治理（approval cooldown window gate）`
  - into: `审批波次配额治理（approval wave-quota gate）`
  - reason: 两者同属批量审批波次治理，合并可减少同构重复并统一策略落点。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道快照（2026-02-28）
  - news: item `47213443` — `Show HN: ShipAny - Open source engine for customer support teams`
  - show: item `47197088` — `Show HN: PydanticAI-Bandit, game benchmark for coding agents`
  - newest: item `47200919` — `Show HN: A2A Coder`（同窗抓取）
- 官方文档证据链（本轮重点）
  - GitHub Review Deployments：required reviewers 只需一人可批准；支持 `Start all waiting jobs`；支持 `Prevent self-reviews`
  - GitHub Rulesets：支持 required approvals、dismiss stale approvals、approval from someone other than last pusher
  - GitHub Merge Queue + Actions `merge_group`：并发/跳队会改变验证批次，晋级前需同构重验

### 本轮结论

- “双阶段审批”不等于“独立审查”；当评审身份重叠过高，双门禁会退化为单点判断。
- 需要把 `overlap_ratio`、`distinct_deploy_reviewers` 与批量批准动作绑定为硬门禁。
- 当 `high_overlap + batch_approve + bypass` 同时出现，应自动降级到 quarantine 波次而不是继续提速。

### Cycle 68 预载任务

1. 输出 `reviewer_diversity_policy.json` 与 `promotion_identity_report.json` 的 schema + lint。
2. 将 `overlap_ratio` 接入 candidate->issue 晋级表单，缺失即阻断。
3. 给 `Start all waiting jobs` 增加最小独立审批人数和 incident 绑定模板。

---
# Morning Brief（Nightshift Cycle 66）

> 更新时间：2026-02-28 23:11 UTC  
> 本轮目标：将 deployment 批量审批从“应急提速手段”升级为“冲击吸收门禁”，避免 `approve all waiting jobs` 造成证据跨窗放行。

### 本轮新增（已落盘）

1. `references/patterns/capacity-governance/approval-batch-shock-absorber-gate.md`
2. `references/patterns/capacity-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `审批冲击吸收门禁治理（approval shock-absorber gate）`
  - reason: GitHub review deployments 支持 `approve and deploy all waiting jobs`，需要将批量放行显式转为可度量门禁。
- `split`：拆分方向
  - from: `部署审批批次节流治理（deployment review batch-throttle gate）`
  - into: `审批批次上限治理（approval batch-size cap gate）`
  - into: `审批冷却窗口治理（approval cooldown window gate）`
  - reason: 批次规模与批次间隔是独立失效面，需分别绑定阈值和触发器。
- `merge`：合并方向
  - from: `队列侧构建吞吐预算治理（queue-side build-throughput budget gate）`
  - from: `审批侧批次吞吐预算治理（review-side batch-throughput budget gate）`
  - into: `队列-审批吞吐同频治理（queue-review throughput parity gate）`
  - reason: 二者共同约束“入队速率 > 出队审批速率”的系统压差，合并后避免同构重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN API 三车道快照（2026-02-28）
  - top: item `47207437` — `Show HN: BuouUI - Open-source UI component library for Svelte and Tailwind`
  - show: item `47208381` — `Show HN: Plane – Open-source JIRA and Linear alternative`
  - new: item `47209514` — `A bare metal solution for AI agent deployment`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：`build concurrency`、`jump` 会重启 in-progress checks。
  - GitHub Actions `merge_group`：required checks 需覆盖 merge queue 场景。
  - GitHub Review Deployments：支持“approve and deploy all waiting jobs”、阻止自审与旁路。

### 本轮结论

- 批量审批不是“免费吞吐扩容”，而是一个会放大证据跨窗风险的冲击源。
- 需要把 `batch_limit`、`cooldown_minutes`、`shock_ratio` 设为晋级前置 gate，并把超载反馈回 queue 并发。
- `approve all waiting jobs` 必须和 freshness reverify 成对出现，否则会把旧证据批量带过晋级线。

### Cycle 67 预载任务

1. 输出 `deploy_review_batch_policy.json` 与 `deploy_review_batch_report.json` 的 schema 与 lint 规则。
2. 将 `shock_ratio` 接入 candidate->issue 晋级表单，禁止无冲击预算的提速请求。
3. 为审批冲击场景补充“自动降并发 + 禁止旁路常态化”的回退模板。

---
# Morning Brief（Nightshift Cycle 65）

> 更新时间：2026-02-28 23:07 UTC  
> 本轮目标：把“merge queue 提速后部署审批拥塞”从隐性症状升级为可度量门禁，形成独立审批吞吐预算模式。

### 本轮新增（已落盘）

1. `references/patterns/capacity-governance/deployment-reviewer-throughput-budget-gate.md`
2. `references/patterns/capacity-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `部署审批批次节流治理（deployment review batch-throttle gate）`
  - reason: GitHub review deployments 支持批量批准 waiting jobs，若无批次上限与冷却窗口，会放大证据同窗失真。
- `split`：拆分方向
  - from: `构建并发-审批容量压差治理（build-concurrency review-capacity pressure gate）`
  - into: `队列侧构建吞吐预算治理（queue-side build-throughput budget gate）`
  - into: `审批侧批次吞吐预算治理（review-side batch-throughput budget gate）`
  - reason: 入队提速与出队审批是独立失效面，需要分别定义预算阈值与回退策略。
- `merge`：合并方向
  - from: `队列恢复清洁窗口治理（queue recovery clean-window gate）`
  - from: `队列恢复回退冷却治理（queue recovery rollback-cooldown gate）`
  - into: `队列恢复稳态窗口治理（queue recovery stability-window gate）`
  - reason: 两方向均治理 fallback 恢复阶段稳定性，合并后可减少同构重复并统一验收口径。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道页面快照（2026-02-28）
  - news: `Signal says it’s pulling feature users exploited to protect privacy`
  - show: `Show HN: Better Auth – Authentication and authorization framework for TypeScript`
  - newest: `Ask HN: How to think about and design LLM apps?`
- 官方文档证据链（本轮重点）
  - GitHub Deployments/Environments：required reviewers + wait timer（1 分钟到 30 天）
  - GitHub Review Deployments：approve all waiting jobs / prevent self-reviews / bypass 边界
  - GitHub Merge Queue + Actions `merge_group`：提速验证面需和发布审批面联动治理

### 本轮结论

- 部署审批吞吐必须独立建模；否则 merge queue 提速会把系统推入“验证绿灯、发布拥塞、旁路上升”的失控区。
- 需要把 `approval_rate_per_hour`、`review_backlog_minutes_p95`、`pressure_ratio` 设为晋级前置 gate。
- 批量审批必须绑定批次上限与冷却窗口，避免 waiting jobs 同窗批准导致审计漂移。

### Cycle 66 预载任务

1. 输出 `deploy_reviewer_capacity.json` 的 schema 与 lint 规则（含 batch_limit/cooldown）。
2. 将 `pressure_ratio` 与 `review_backlog_minutes_p95` 接入 candidate->issue 晋级表单。
3. 为审批超载场景补充“自动降并发 + 禁止旁路常态化”的回退策略模板。

---
# Morning Brief（Nightshift Cycle 64）

> 更新时间：2026-02-28 23:02 UTC  
> 本轮目标：把 merge queue 的构建并发提速与 deployment 审批容量做耦合预算门禁，阻断“队列提速但发布端过载”的隐性降级。

### 本轮新增（已落盘）

1. `references/patterns/capacity-governance/queue-build-concurrency-environment-capacity-gate.md`
2. `references/patterns/capacity-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `构建并发-审批容量压差治理（build-concurrency review-capacity pressure gate）`
  - reason: merge queue 可提高并发验证吞吐，但 deployment reviewer 吞吐是慢变量，需单独治理压差预算。
- `split`：拆分方向
  - from: `队列预检-部署连续性双门禁（queue preflight-deploy continuity dual gate）`
  - into: `队列构建并发容量预算治理（queue build-concurrency capacity budget gate）`
  - into: `部署审批处理能力预算治理（deployment reviewer throughput budget gate）`
  - reason: 入队并发与出队审批属于独立失效面，拆分后可分别绑定指标与 required checks。
- `merge`：合并方向
  - from: `环境等待计时上限治理（environment wait-timer ceiling gate）`
  - from: `队列重排吞吐损耗预算治理（queue reorder throughput-loss budget gate）`
  - into: `队列-部署容量耦合治理（queue-deploy capacity coupling gate）`
  - reason: 两方向共同约束“queue 吞吐变化导致 deploy 容量失衡”，合并后统一预算口径。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道页面快照（2026-02-28）
  - news: `Signal says it’s pulling feature users exploited to protect privacy`
  - show: `Show HN: Better Auth – Authentication and authorization framework for TypeScript`
  - newest: `Ask HN: How to think about and design LLM apps?`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：`Build concurrency`、`Status check timeout`、`Minimum pull requests to merge`
  - GitHub Actions：required checks 需监听 `merge_group`
  - GitHub Deployments/Environments：required reviewers、wait timer（1 分钟到 30 天）
  - GitHub Review Deployments：prevent self-reviews 与 bypass 行为边界

### 本轮结论

- queue 提速（build concurrency）必须与 deploy 审批容量联立建模，否则会把系统推入“高吞吐 + 高等待 + 高频旁路”的不可审计状态。
- `merge_group` 同构校验只能解决“验证面一致”，不能单独解决“发布端容量失衡”。
- 容量压差应作为晋级前置 gate，而不是 incident 后补救指标。

### Cycle 65 预载任务

1. 输出 `queue_capacity_budget.json` 与 `deploy_capacity_snapshot.json` 的最小 schema 与 lint 规则。
2. 新增 `pressure_ratio` 与 `queue_wait_minutes_p95` 的阈值策略，并定义自动降档逻辑。
3. 将容量压差 gate 接入 candidate->issue 晋级表单，阻断无容量预算的提速请求。

---
# Morning Brief（Nightshift Cycle 63）

> 更新时间：2026-02-28 23:10 UTC  
> 本轮目标：把 merge queue 的 fallback 恢复从“过阈值即切回”升级为“滞回 + 冷却”门禁，抑制 strict/fallback 高频振荡。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/queue-fallback-hysteresis-cooldown-gate.md`
2. `references/patterns/queue-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `队列模式滞回冷却治理（queue mode hysteresis cooldown gate）`
  - reason: fallback 恢复后频繁回退会造成 queue 抖动，需独立治理“恢复后稳定窗口”。
- `split`：拆分方向
  - from: `队列容错恢复确认窗口治理（queue fallback recovery confirmation-window gate）`
  - into: `队列恢复清洁窗口治理（queue recovery clean-window gate）`
  - into: `队列恢复回退冷却治理（queue recovery rollback-cooldown gate）`
  - reason: “连续清洁窗口”与“恢复后冷却”是两个独立失效面，需独立 required checks。
- `merge`：合并方向
  - from: `队列降级触发失败密度预算治理（queue fallback failure-density budget gate）`
  - from: `队列降级触发冲突密度预算治理（queue fallback conflict-density budget gate）`
  - into: `队列降级触发双失效面预算治理（queue fallback dual-failure-surface budget gate）`
  - reason: 两方向共同服务于 fallback 触发判定，可合并为统一预算口径减少同构重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道页面快照（2026-02-28）
  - news: `Ask HN: How to think about and design LLM apps?`
  - show: `Show HN: Fullly [sic] Open Source SMS Authentication for Laravel`
  - newest: `The confidence game of startup fundraising`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：支持 `Only merge non-failing pull requests`、`Status check timeout`、`minimum pull requests to merge`
  - GitHub Actions：merge queue required checks 需监听 `merge_group`
  - HN API：`topstories/showstories/newstories` 与 item `deleted/dead`
  - OPML 2.0：`outline` 的 `text/type/xmlUrl` 契约

### 本轮结论

- fallback 治理必须从“单阈值切换”升级为“进入阈值 + 退出阈值 + 冷却期”的滞回状态机。
- strict 恢复前必须执行 `merge_group` 重验并刷新 `queue_epoch_id + evidence_epoch_id`。
- 外部信号（HN/OPML）不稳定时，只允许维持 fallback，不允许触发恢复晋级。

### Cycle 64 预载任务

1. 产出 `queue_mode_hysteresis.json` 与 `queue_mode_state.json` 的最小 schema 与校验规则。
2. 新增 `recovery_oscillation_rate` 指标，量化 24h 内 strict/fallback 切换振荡频率。
3. 将 `queue_fallback_dual_failure_surface_budget` 接入候选晋级表单，统一触发面预算。

---
# Morning Brief（Nightshift Cycle 62）

> 更新时间：2026-02-28 22:52 UTC  
> 本轮目标：把 merge queue 的 fallback 从“临时容错开关”升级为“可恢复阈值门禁”，防止夜间长期停留在降级模式。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/queue-fallback-recovery-threshold-gate.md`
2. `references/patterns/queue-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `队列容错恢复确认窗口治理（queue fallback recovery confirmation-window gate）`
  - reason: merge queue 的 `minimum pull requests to merge` 提供恢复观察窗口锚点，可避免“刚降噪就恢复”的抖动。
- `split`：拆分方向
  - from: `队列降级触发密度预算治理（queue fallback trigger-density budget gate）`
  - into: `队列降级触发失败密度预算治理（queue fallback failure-density budget gate）`
  - into: `队列降级触发冲突密度预算治理（queue fallback conflict-density budget gate）`
  - reason: fallback 触发同时受“检查失败密度”和“冲突密度”影响，属于独立失效面。
- `merge`：合并方向
  - from: `队列重建吞吐损耗预算治理（queue rebuild throughput loss budget gate）`
  - from: `队列跳跃吞吐损耗预算治理（queue jump throughput-loss budget gate）`
  - into: `队列重排吞吐损耗预算治理（queue reorder throughput-loss budget gate）`
  - reason: 两方向都在治理 reorder 引起的吞吐损耗，合并可统一预算口径。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道（API 快照，2026-02-28）
  - top: item `47203487` — `What happened when I built a daily coding challenge platform with AI`
  - show: item `47205198` — `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - new: item `47205652` — `Show HN: Free, open-source native macOS client for di.fm`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：支持 `Only merge non-failing pull requests`、`Status check timeout`、`minimum pull requests to merge`
  - GitHub Actions 事件：merge queue required checks 需监听 `merge_group`
  - HN API：`topstories/newstories/showstories` + item `deleted/dead`
  - OPML 2.0：`outline.text` 与 RSS `xmlUrl` 结构契约

### 本轮结论

- fallback 治理必须“双阈值对称”：有降级阈值，也必须有恢复阈值。
- fallback→strict 切换必须绑定 `merge_group` 重验，否则恢复不可审计。
- 外部信号稳定性（HN `deleted/dead` + OPML 契约）应进入恢复门禁，而不是仅用于晋级门禁。

### Cycle 63 预载任务

1. 输出 `fallback_recovery_report.json` 的失败分桶（insufficient-clean-window / stale-evidence / check-regression）。
2. 将 `queue_fallback_state.json` 接入 candidate->issue 晋级表单，要求恢复证据随单据提交。
3. 把 `queue reorder throughput-loss` 与 `fallback recovery` 联立为统一夜间阈值仪表盘。

---
# Morning Brief（Nightshift Cycle 61）

> 更新时间：2026-02-28 22:48 UTC  
> 本轮目标：把 merge queue 的 `jump` 从“可随意提速按钮”升级为“吞吐损耗预算门禁”，避免夜间频繁重排导致重建风暴。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/queue-jump-throughput-loss-budget-gate.md`
2. `references/patterns/queue-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `队列跳跃吞吐损耗预算治理（queue jump throughput-loss budget gate）`
  - reason: GitHub merge queue 文档明确 `jump` 会触发 in-progress PR 全量重建并可能降低合并速度，需单独预算门禁。
- `split`：拆分方向
  - from: `队列容错预算降级一体化治理（merge-queue fallback-budget parity gate）`
  - into: `队列降级触发密度预算治理（queue fallback trigger-density budget gate）`
  - into: `队列降级恢复门槛治理（queue fallback recovery-threshold gate）`
  - reason: “何时降级”与“何时恢复”是独立失效面，拆分后可独立 required checks。
- `merge`：合并方向
  - from: `浏览器会话边界声明治理（browser runtime-boundary manifest gate）`
  - from: `浏览器工具权限同构治理（browser tool-scope parity gate）`
  - into: `浏览器边界-权限同构协同治理（browser boundary-scope parity co-gate）`
  - reason: 两方向均治理 browser runtime 边界与权限一致性，合并可减少同构重复并统一验收口径。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并重定向到 HN Popular Blogs OPML Gist（checked 2026-02-28）。
- HN 三车道（2026-02-28）
  - news: item `47205591` — `MinIO Is Dead, Long Live MinIO`
  - show: item `47205198` — `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - newest: `Show HN: Free, open-source native macOS client for di.fm`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：`jump` 到队首会触发 in-progress pull requests 全量重建并影响 merge velocity
  - GitHub Actions 事件：merge queue required checks 需监听 `merge_group`
  - HN API：`topstories/newstories/showstories` + item `deleted/dead`
  - OPML 2.0：`outline.text` 与 RSS `xmlUrl` 契约

### 本轮结论

- 仅做“重排后重验”还不够，必须先做“是否值得重排”的预算判定。
- `jump` 应从应急手段升级为可计量成本对象，超预算只能走 incident 覆盖路径。
- 预算门禁、merge_group 重建回放、外部证据稳定性（HN/OPML）必须联动，否则会出现吞吐损耗与错误晋级双重放大。

### Cycle 62 预载任务

1. 增加 `queue_jump_budget.json` 的成本归因维度（按 required check 分类耗时）。
2. 引入 `incident_override` 的自动审计字段，追踪超预算 jump 的审批闭环。
3. 将 `queue_jump_budget_pass` 接入候选晋级表单，阻断无预算评估的重排请求。

---

---
# Morning Brief（Nightshift Cycle 60）

> 更新时间：2026-02-28 22:42 UTC  
> 本轮目标：把 merge queue 的“重排重建”升级为“代码纪元 + 证据纪元”双失效门禁，阻断跨纪元误晋级。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/queue-reorder-evidence-epoch-invalidation-gate.md`
2. `references/patterns/queue-governance/_index.md`
3. `references/patterns/_master_index.md`
4. `morning-brief.md`
5. `.nightshift/state.json`

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `队列重建吞吐损耗预算治理（queue rebuild throughput loss budget gate）`
  - reason: GitHub merge queue 文档明确 `jump` 到队首会触发在途 PR 全量重建，需要新增吞吐损耗预算以约束频繁重排。
- `split`：拆分方向
  - from: `队列重排重建验签治理（queue reorder rebuild attestation gate）`
  - into: `队列重排代码纪元失效治理（queue reorder code-epoch invalidation gate）`
  - into: `队列重排证据纪元失效治理（queue reorder evidence-epoch invalidation gate）`
  - reason: 代码判定面变化与外部证据纪元失效是两个独立故障面，需独立 required checks。
- `merge`：合并方向
  - from: `队列重排时序预算治理（queue reorder freshness budget gate）`
  - from: `审批跨阶段时序预算治理（approval cross-stage freshness budget gate）`
  - into: `跨阶段重排新鲜度预算治理（cross-stage reorder freshness budget gate）`
  - reason: 两方向都在治理排队等待带来的时效衰减，合并后统一预算口径并减少同构重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析到 HN Popular Blogs OPML Gist（raw 修订 `426957f4...`，checked 2026-02-28T22:43:33Z）。
- HN 三车道（2026-02-28）
  - news: item `47205076` — `Stop Burning your tokens. Do this instead.`
  - show: item `47200167` — `Show HN: A promptless way to create editable SVGs`
  - newest: `Wouldn't It Be Nice if Apps Could Tell Us How They Use Our Data?`
- 官方文档证据链（本轮重点）
  - GitHub Merge Queue：`jump` 到队首会触发 in-progress pull requests 全量重建
  - GitHub Actions 事件：merge queue required checks 需监听 `merge_group`
  - HN API：`topstories/newstories/showstories` + item `deleted/dead`
  - OPML 2.0：`outline.text` 与 RSS `xmlUrl` 结构契约

### 本轮结论

- 仅做 queue 重建回放不够，必须同时失效并重采样外部证据纪元。
- `queue_epoch_id` 与 `evidence_epoch_id` 必须强绑定到同一晋级包。
- `deleted/dead` 复检和 `merge_group` 复检缺一不可，否则跨纪元误晋级不可审计。

### Cycle 61 预载任务

1. 增加 `evidence_epoch_rebound_pass` 失败分桶（missing-resample / stale-item / opml-contract-drift）。
2. 设计 `queue_rebuild_cost_budget.json`，把重排频率与吞吐损耗绑定告警阈值。
3. 将 `queue_epoch_id + evidence_epoch_id` 接入 candidate->issue 晋级模板，消除人工补证。

---

---
# Morning Brief（Nightshift Cycle 59）

> 更新时间：2026-02-28 22:36 UTC  
> 本轮目标：把 `show/newest` 早信号仲裁升级为“条目存活预检 + OPML 结构契约 + 成熟度冷却”的可执行门禁，减少白天队列污染。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/show-new-evidence-maturity-arbitration-gate.md`（升级：新增 `deleted/dead` 预检与 OPML 契约门禁）
2. `references/patterns/discovery-governance/_index.md`（更新描述）
3. `references/patterns/_master_index.md`（更新 confidence 与待验证统计）
4. `morning-brief.md`（新增 Cycle 59）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `HN 条目存活预检治理（dead/deleted pre-promotion gate）`
  - reason: HN API item 存在 `deleted/dead` 字段，说明热度信号不等于可执行信号，晋级前必须存活预检。
- `split`：拆分方向
  - from: `跨车道一致性预算治理（quorum-identity-dedupe budget gate）`
  - into: `跨车道身份同一门禁（cross-lane identity quorum gate）`
  - into: `跨车道去重预算门禁（cross-lane dedupe budget gate）`
  - reason: 身份同一性与去重比例是两类独立失效面，拆分后可分别配置 required checks。
- `merge`：合并方向
  - from: `OPML 重定向锚定（shortlink -> canonical target lock）`
  - from: `锚点存活预算治理（anchor retrievability SLA + mirror fallback）`
  - into: `OPML 规范锚点存活治理（canonical redirect + retrievability gate）`
  - reason: 两方向都在治理“入口可达 + 身份稳定”，合并后降低同构重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并锚定到 HN Popular Blogs OPML Gist raw（checked `2026-02-28T22:42:52Z`）。
- HN 三车道（2026-02-28）
  - news: `MinIO Is Dead, Long Live MinIO`
  - show: item `47195123` — `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - newest: `How do HTTP servers figure out Content-Length?`
- 官方文档证据链（本轮重点）
  - OPML 2.0 Spec：`outline.text` 与 `type="rss"/xmlUrl` 订阅约束
  - Hacker News API：`top/new/show` 车道端点 + item `deleted/dead`
  - GitHub Docs：merge queue / `merge_group` / protected branches / workflow artifacts

### 本轮结论

- `show/newest` 的仲裁不能只看热度，必须先做 item 存活预检。
- OPML 入口必须做结构契约检查（`text` + `xmlUrl`），否则会引入不可复采样订阅体。
- 晋级结果必须绑定 required checks 与 artifact 才能实现次日可审计回放。

### Cycle 60 预载任务

1. 把 `item_liveness_report.json` 加入失败分桶（deleted/dead/missing-core-fields）。
2. 为 `opml_outline_contract_report.json` 增加 `canonical_digest`，支持变更对账。
3. 将 `cross-lane identity quorum` 与 `dedupe budget` 检查拆分接入独立 required checks。

---

---
# Morning Brief（Nightshift Cycle 58）

> 更新时间：2026-02-28 22:28 UTC  
> 本轮目标：把 `show/newest` 的高噪声早信号改造成“可执行证据 + 冷却预算 + required checks”三联仲裁，避免夜间误晋级。

### 本轮新增（已落盘）

1. `references/patterns/discovery-governance/show-new-evidence-maturity-arbitration-gate.md`
2. `references/patterns/discovery-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 58，并执行 50 条滚动窗口）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `merge_group 回放锚定治理（merge_group replay anchoring gate）`
  - reason: 官方 `merge_group` 事件可承载晋级检查回放，适合把探索信号和分支门禁绑定到同一审计主键。
- `split`：拆分方向
  - from: `原型-早信号双车道仲裁治理（show-new dual-lane arbitration gate）`
  - into: `Show 车道可执行性门禁（show-lane executability gate）`
  - into: `Newest 车道冷却晋级门禁（newest-lane cooldown promotion gate）`
  - reason: 两条车道失败机理不同，拆分后才能分别设定“最小可运行证据”与“冷却复采样”门禁。
- `merge`：合并方向
  - from: `车道仲裁同一双门禁（lane quorum + identity dual gate）`
  - from: `跨车道去重预算一体化治理（dedupe key + duplicate ratio gate）`
  - into: `跨车道一致性预算治理（quorum-identity-dedupe budget gate）`
  - reason: 两方向都在治理三车道一致性，合并后避免同构 pattern 重复并统一预算判定。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist，并锁定 raw 版本 `ba6f711.../hn-popular-blogs-2025.opml`（checked `2026-02-28T22:28:30Z`）。
- HN 三车道（2026-02-28）
  - news: item `47203527` — `drafts by murat`
  - show: item `47200167` — `Show HN: A promptless way to create editable SVGs`
  - newest: item `47203487` — `What happened when I built a daily coding challenge platform with AI`
- 官方文档证据链（本轮重点）
  - GitHub Docs: `Managing a merge queue`
  - GitHub Docs: `events that trigger workflows#merge_group`
  - GitHub Docs: `About protected branches`
  - GitHub Docs: `storing and sharing data from a workflow`

### 本轮结论

- `show` 与 `newest` 不应共用同一晋级阈值，必须区分“可执行原型”与“早信号冷却”。
- 早信号未通过冷却复采样时，只能进入观察池，不能进入白天执行队列。
- 仲裁结果必须落盘为 artifact 并绑定 required checks，否则次日无法审计“为什么晋级”。

### Cycle 59 预载任务

1. 为 `fresh_signal_cooldown_report.json` 增加失败分桶（insufficient-window / unstable-resample / missing-evidence）。
2. 把 `discovery_promotion_packet.json` 接入 candidate->issue 入库模板，减少人工补证。
3. 将 `merge_group replay anchoring` 与 `lineage` 主键合并，形成跨队列统一回放协议。

---

---
# Morning Brief（Nightshift Cycle 57）

> 更新时间：2026-02-28 22:23 UTC  
> 本轮目标：把“对比达标但色觉不可辨识”的隐性风险变成可回放、可阻断、可审计的晋级门禁。

### 本轮新增（已落盘）

1. `references/patterns/accessibility-governance/color-vision-simulation-replay-gate.md`
2. `references/patterns/accessibility-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 57）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `色觉仿真失败证据签名治理（color-vision replay attestation gate）`
  - reason: HN 新增大量“AI 快速产出前端界面”信号，色觉仿真失败若无签名证据，次日难以做晋级问责与回放。
- `split`：拆分方向
  - from: `主题语义回放治理（theme semantic replay governance）`
  - into: `主题语义别名映射治理（theme semantic alias mapping gate）`
  - into: `主题语义色觉回放治理（theme semantic color-vision replay gate）`
  - reason: 语义命名一致性与色觉可辨识是不同失效面，拆分后可独立门禁并降低误判。
- `merge`：合并方向
  - from: `工具输出占比分层阈值治理（lane-tiered tool-output ratio threshold gate）`
  - from: `工具输出占比触发冻结治理（tool-output-ratio freeze trigger gate）`
  - into: `工具输出占比预算冻结一体治理（tool-output-ratio budget-freeze unified gate）`
  - reason: 两方向都在约束工具输出比例对交付质量的影响，合并后减少同构策略重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析并锚定 OPML 原始源（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/2f6da337f61e5705f7f7f3981f541f071b8ed941/hn-popular-blogs-2025.opml`，checked 2026-02-28T22:23:20Z）。
- HN 三车道（2026-02-28）
  - news: item `47202859` — `Introducing Halide HN: Exploratory data analysis with local LLMs`
  - show: item `47200167` — `Show HN: A promptless way to create editable SVGs`
  - newest: item `47203487` — `What happened when I built a daily coding challenge platform with AI`
- 官方文档证据链（本轮重点）
  - W3C WCAG 2.2：`Contrast (Minimum)` 与 `Non-text Contrast`
  - Storybook：`writing-tests`（多主题/多场景回放入口）
  - GitHub Protected Branches：required status checks（晋级硬门禁）

### 本轮结论

- 对比度阈值通过不等于色觉可辨识通过，必须新增 `color_vision_replay_pass`。
- 语义角色需输出机器可审计的 `role_delta`，否则无法可靠判定状态色可分辨性。
- 色觉仿真失败必须 quarantine，不能降级为 warning。

### Cycle 58 预载任务

1. 为 `semantic_role_delta_report.json` 增加严重度分桶（mild/moderate/severe）并固化阻断规则。
2. 把 `color_vision_replay_pass` 接入 candidate->issue->PR 证据包模板，减少人工补证成本。
3. 为高对比主题补“语义角色冲突热点榜”，优先治理最常失效组件。

---

---
# Morning Brief（Nightshift Cycle 56）

> 更新时间：2026-02-28 22:18 UTC  
> 本轮目标：把“达标但断崖式退化”的可读性风险显式化，新增对比回退斜率门禁并接入晋级硬检查。

### 本轮新增（已落盘）

1. `references/patterns/accessibility-governance/theme-contrast-regression-slope-gate.md`
2. `references/patterns/accessibility-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 56）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `主题对比回退斜率治理（theme contrast regression slope gate）`
  - reason: HN `newstories` 出现 `Thinking deeply about Theming and Color Naming`，结合 WCAG 仅给绝对下限，提示需补“相对回退幅度”门禁。
- `split`：拆分方向
  - from: `色觉可达性安全调色治理（color-vision accessibility palette gate）`
  - into: `高对比主题压测治理（high-contrast theme stress gate）`
  - into: `色觉仿真回放治理（color-vision simulation replay gate）`
  - reason: 压测强度控制与色觉仿真回放是两个不同失效面，需独立 gate。
- `merge`：合并方向
  - from: `show 讨论原型车道（HN show + builder chatter）`
  - from: `new 早信号车道（HN newest + freshness spike）`
  - into: `原型-早信号双车道仲裁治理（show-new dual-lane arbitration gate）`
  - reason: 两者都在解决“早期信号晋级仲裁”，合并后可减少同构 pattern 重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已解析到 OPML 原始源（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/4292aaea6b37c7c486f8998ea0f12f64bf2ac91d/hn-popular-blogs-2025.opml`，checked 2026-02-28T22:18:54Z）。
- HN API `top/show/new`：已采样（2026-02-28）
  - top (`topstories`): item `47202466` — `Obsidian Sync now has a headless client`
  - show (`showstories`): item `47195123` — `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - new (`newstories`): item `47203158` — `Thinking deeply about Theming and Color Naming`
- 官方文档证据链（本轮重点）
  - W3C WCAG 2.2：`Contrast (Minimum)` 与 `Non-text Contrast`
  - Storybook：`writing-tests`（多主题回放落点）
  - GitHub Protected Branches：required status checks（晋级硬门禁）

### 本轮结论

- 仅满足 WCAG 绝对阈值不足以阻断“达标但显著退化”的风险。
- 必须并列强制 `contrast_regression_slope_pass` 与文本/非文本阈值门禁。
- 对比回退达到 `severe` 时必须 quarantine，不可自动晋级。

### Cycle 57 预载任务

1. 将 `ratio_drop` 分桶（mild/moderate/severe）写入统一晋级策略枚举，消除实现歧义。
2. 为 `theme_contrast_baseline.json` 增加基线冻结策略，防止每轮覆盖导致“回退被洗白”。
3. 把 `show-new` 双车道仲裁结果接入 candidate->issue 的入库门禁。

---

---
# Morning Brief（Nightshift Cycle 55）

> 更新时间：2026-02-28 22:13 UTC  
> 本轮目标：把“语义色名正确但可读性失效”的缺口收敛为可阻断门禁，确保多主题无人值守发布可回放、可冻结。

### 本轮新增（已落盘）

1. `references/patterns/accessibility-governance/theme-contrast-readability-budget-gate.md`
2. `references/patterns/accessibility-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 55）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `色觉可达性安全调色治理（color-vision accessibility palette gate）`
  - reason: WCAG 2.2 文本/非文本对比规则与 HN `newstories` 的产品化反思同向，说明“可读性预算”必须从单主题扩展到色觉可达性。
- `split`：拆分方向
  - from: `主题对比可读性预算治理（theme contrast readability budget gate）`
  - into: `文本对比预算治理（text contrast budget gate）`
  - into: `非文本对比预算治理（non-text contrast budget gate）`
  - reason: 文本与非文本对比失效面的检测规则和阻断阈值不同，必须拆分独立 gate。
- `merge`：合并方向
  - from: `语义色名规范化治理（semantic color naming canonicalization gate）`
  - from: `主题切换回放门禁（theme-switch replay gate）`
  - into: `主题语义回放治理（theme semantic replay governance）`
  - reason: 二者都服务“主题语义一致性 + 回放验证”，合并可避免同构 pattern 重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向至 OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`），并解析到 OPML 原文（`hn-popular-blogs-2025.opml`），checked `2026-02-28T22:13:06Z`。
- HN `top/show/new`：已采样（2026-02-28，Hacker News API）
  - top (`topstories`): item `47197267` — `Obsidian Sync now has a headless client`
  - show (`showstories`): item `47195123` — `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - new (`newstories`): item `47200840` — `The Bitter Lesson is coming for AI products, not just AI research`
- 官方文档证据链（本轮重点）
  - W3C WCAG 2.2：`Contrast (Minimum)` 与 `Non-text Contrast`
  - Storybook：`writing-tests`（多主题组件测试落点）
  - GitHub Protected Branches：required status checks（晋级硬门禁）

### 本轮结论

- “语义 token 正确”不等于“主题可读性合格”，对比预算必须进入 required checks。
- `text_contrast_budget_pass`、`non_text_contrast_budget_pass`、`theme_replay_pass` 缺一不可。
- 任一主题预算失败必须 quarantine，而不是降级为 warning。

### Cycle 56 预载任务

1. 增加 `theme_contrast_matrix.json` 的阈值偏差分桶（轻微/中等/严重）用于自动晋级策略。
2. 将 `theme semantic replay governance` 与 `candidate -> issue -> PR` 产物链路绑定，补失败证据最小字段。
3. 为高对比主题补“组件边界对比”快速回放基线，避免只测文本不测控件。

---

---
# Morning Brief（Nightshift Cycle 54）

> 更新时间：2026-02-28 22:07 UTC  
> 本轮目标：把“色值命名”升级为“语义角色命名 + alias 回放 + 多主题门禁”，避免无人值守前端改动出现同名不同义。

### 本轮新增（已落盘）

1. `references/patterns/design-governance/semantic-color-role-canonicalization-gate.md`
2. `references/patterns/design-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 54）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `主题对比可读性预算治理（theme contrast readability budget gate）`
  - reason: HN `newstories` 出现 `Thinking deeply about Theming and Color Naming`，主题命名与对比度风险成为显性问题。
- `split`：拆分方向
  - from: `前端视觉基线守门（design tokens + visual regression budget）`
  - into: `语义色名规范化治理（semantic color naming canonicalization gate）`
  - into: `视觉回归预算分层治理（visual regression tiered budget gate）`
  - into: `主题切换回放门禁（theme-switch replay gate）`
  - reason: 命名规范、视觉预算、主题回放属于三个不同失效面，拆分后可独立定义 required checks。
- `merge`：合并方向
  - from: `OPML 三元主键约束（text/xmlUrl/htmlUrl tri-key contract）`
  - from: `OPML 可编辑字段漂移探针（outline text edit-drift probe）`
  - into: `OPML 订阅体身份漂移治理（outline identity + edit-drift governance）`
  - reason: 两方向都在处理订阅体身份稳定性，合并后可统一漂移门禁并降低同构 pattern 重复。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T22:07:41Z）。
- HN `top/show/new`：已采样（2026-02-28，Hacker News API）
  - top (`topstories`): item `43387092` — `Npm package with all possible semver combinations`
  - show (`showstories`): item `43385853` — `Show HN: Browser AI Agent to automate your browser with Gemini`
  - new (`newstories`): item `43386402` — `Thinking deeply about Theming and Color Naming`
- 官方文档证据链（本轮重点）
  - Design Tokens Format（token 引用与结构化语义承载）
  - Storybook Test docs（组件视觉/交互/a11y 测试入口）
  - GitHub Protected Branches（required status checks 作为不可绕过门禁）
  - GitHub `GITHUB_TOKEN` permissions（自动化最小权限显式声明）

### 本轮结论

- 只做视觉回归不足以约束“语义色名漂移”，必须增加 token 角色规范化门禁。
- `token_role_canonicalization_pass`、`theme_replay_pass`、`a11y_contrast_pass` 需并列 required checks。
- theme 切换失败或 alias 图出现环路时必须 quarantine，禁止晋级。

### Cycle 55 预载任务

1. 为 `token_alias_graph.json` 增加跨主题循环引用检测（light/dark/high-contrast）。
2. 把 `token_role_canonicalization_pass` 接入 `candidate -> issue -> PR` 的门禁链路。
3. 补“同义不同名”自动归并策略，降低多 agent 并发改动的命名碎片化。

---

---
# Morning Brief（Nightshift Cycle 53）

> 更新时间：2026-02-28 22:03 UTC  
> 本轮目标：把“外部身份凭证”从运行时配置项升级为“租约-回放-晋级”硬门禁，避免低权限会话静默复用高权限身份。

### 本轮新增（已落盘）

1. `references/patterns/identity-governance/external-identity-lease-replay-gate.md`
2. `references/patterns/identity-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 53）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `expand`：新增方向
  - `外部身份租约回放治理（external identity lease replay gate）`
  - reason: HN `newest` 出现 `AgentMailr` 与 `Be Careful with LLM Agents`，外部身份调用边界风险上升。
- `split`：拆分方向
  - from: `需求到证据闭环治理（PRD->Pattern lineage control plane）`
  - into: `需求到实现血缘治理（PRD->Epic->Issue->PR lineage governance）`
  - into: `证据到模式回放治理（evidence->pattern replay governance）`
  - reason: 需求交付闭环与证据回放闭环属于不同失效面，拆分后可分别设 gate。
- `merge`：合并方向
  - from: `代理记忆持久化权限分区治理（agent memory persistence scope partition gate）`
  - from: `代理记忆分区最小权限治理（agent memory partition least-privilege gate）`
  - into: `代理记忆分区闭环治理（agent memory partition closure gate）`
  - reason: 两者元问题同构，统一后减少重复 pattern 演化成本。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T22:03:20Z）。
- HN `top/show/new`：已采样（2026-02-28）
  - top (`news`): `Obsidian Sync now has a headless client`
  - show (`show`): `Show HN: Now I Get It - Translate scientific papers into interactive webpages`
  - new (`newest`): 包含 `Show HN: AgentMailr, an MCP server that can read and write emails` 与 `Be Careful with LLM Agents`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步任务状态不可直接等价“可晋级”）
  - OpenAI Conversation state（`previous_response_id` 会话链可用于身份回放绑定）
  - GitHub `GITHUB_TOKEN` permissions（最小权限显式声明）
  - GitHub protected branches required checks（可承载 `identity_lease_replay_pass`）
  - Hacker News API（`topstories/showstories/newstories` 车道输入）

### 本轮结论

- 仅做 `scope` 与 `memory` gate 仍不足以覆盖“外部身份租约泄漏”。
- 需要新增 `identity_lease_replay_pass` 并与现有门禁并列 required checks。
- 若租约过期、scope 变化或会话绑定链断裂，必须 quarantine，禁止晋级。

### Cycle 54 预载任务

1. 增加 `identity_lease_manifest.json` 的 issuer 可信根轮换检测。
2. 把 `identity_lease_replay_pass` 接入 candidate -> issue -> PR 全链路。
3. 为多工具并发场景补“租约冲突仲裁”策略（同 run 多租约写冲突）。

---

---
# Morning Brief（Nightshift Cycle 52）

> 更新时间：2026-02-28 21:59 UTC  
> 本轮目标：把“最小权限”从运行时 scope 扩展到“记忆分区重放”层，阻断低权限会话复用高权限历史记忆。

### 本轮新增（已落盘）

1. `references/patterns/permission-governance/agent-memory-partition-least-privilege-gate.md`
2. `references/patterns/permission-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 52）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `merge`：合并方向
  - from: `审批时效预算治理（approval freshness budget gate）`
  - from: `绕过时效预算治理（bypass freshness budget gate）`
  - into: `审批-旁路双轨时效同构治理（approval-bypass dual-track freshness parity gate）`
  - reason: 审批与旁路在晋级面共享同一“身份+时效”校验点，拆分维护导致门禁策略漂移，合并后可统一 required checks。
- `expand`：新增方向 `代理记忆分区最小权限治理（agent memory partition least-privilege gate）`
  - 触发依据：HN show 出现 `AgentMailr`（Agent 直接读写邮箱）与 HN newest 的 `Be Careful with LLM Agents`，说明“持久化记忆 + 外部系统”边界风险上升。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:59:14Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Obsidian Sync now has a headless client`
  - show (`show`): `Show HN: AgentMailr, an MCP server that can read and write emails`
  - new (`newest`): `Be Careful with LLM Agents`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步状态机，`completed` 仅表示执行结束）
  - OpenAI Conversation state（跨会话链路与 `previous_response_id`）
  - GitHub Protected Branches（required checks 晋级硬门禁）
  - GitHub `GITHUB_TOKEN`（显式 `permissions` 最小权限）
  - Hacker News API（`topstories/showstories/newstories` 车道端点）

### 本轮结论

- “运行时权限最小化”不足以覆盖持久化记忆风险，必须增加记忆分区门禁。
- `memory_partition_replay_pass` 需要与 `scope_manifest_pass`、`scope_drift_budget_pass` 并列 required checks。
- 权限降级后若仍可读取高分区历史记忆，必须 quarantine，禁止晋级。

### Cycle 53 预载任务

1. 增加 `memory_scope_matrix.yaml` 的 namespace 继承冲突检测。
2. 在 `promotion_packet` 中补 `memory_tier_diff` 与 `blocked_reason` 标准枚举。
3. 将记忆分区门禁接入 `candidate -> issue -> PR` 全链路回放。

---

---
# Morning Brief（Nightshift Cycle 51）

> 更新时间：2026-02-28 21:54 UTC  
> 本轮目标：把“最小权限”从二元开关升级为“漂移分级 + 车道预算 + required checks”门禁，降低误报并阻断真风险。

### 本轮新增（已落盘）

1. `references/patterns/permission-governance/agent-scope-drift-severity-budget-gate.md`
2. `references/patterns/permission-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 51）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `merge`：合并方向
  - from: `代理最小权限白名单治理（agent least-privilege scope manifest gate）`
  - from: `代理会话最小权限漂移治理（agent session least-privilege drift gate）`
  - into: `代理最小权限分级预算治理（agent least-privilege drift budget gate）`
  - reason: 两方向都在治理权限最小化与漂移控制，合并后统一到“分级预算”控制面，减少同构 pattern 重复。
- `expand`：新增方向 `代理记忆持久化权限分区治理（agent memory persistence scope partition gate）`
  - 触发依据：HN show 车道出现 agent memory 相关项目（`MemoryKit: A persistent memory layer for AI agents`、`SQLite for Rivet Actors`），提示“记忆持久化”正在成为新的权限边界。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:53:01Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Obsidian Sync now has a headless client`
  - show (`show`): `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - new (`newest`): `Be Careful with LLM Agents`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步状态机，`completed` 仅表示运行结束）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 链路）
  - GitHub Protected Branches（required status checks 晋级硬门禁）
  - GitHub `GITHUB_TOKEN` 权限控制（最小权限与显式 `permissions`）
  - Hacker News API（`topstories/showstories/newstories` 车道端点）

### 本轮结论

- “权限漂移是否发生”不足以做晋级决策，必须补 `T1/T2/T3` 分级。
- `scope_drift_budget_pass` 应与 `scope_manifest_pass`、`escalation_replay_pass` 并列 required checks。
- 车道预算缺失时默认冻结晋级，而不是降级为日志告警。

### Cycle 52 预载任务

1. 在 `promotion_packet` 增加 `drift_tier` 与 `lane_budget_snapshot` 以支持复盘。
2. 把分级预算门禁接入 `candidate -> issue -> PR` 全链路。
3. 为 memory-persistence 场景补最小权限分区模板（read cache / write memory / external sync）。

---

---
# Morning Brief（Nightshift Cycle 50）

> 更新时间：2026-02-28 21:50 UTC  
> 本轮目标：把“最小权限”从静态建议升级为“会话级清单 + 升级后重放 + required check”的晋级硬门禁。

### 本轮新增（已落盘）

1. `references/patterns/permission-governance/agent-scope-manifest-escalation-gate.md`
2. `references/patterns/permission-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 行与统计更新）
4. `morning-brief.md`（新增 Cycle 50）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `审批-绕过双轨时效治理（approval-bypass dual-track freshness gate）` 为：
  - `审批时效预算治理（approval freshness budget gate）`
  - `绕过时效预算治理（bypass freshness budget gate）`
  - reason: 审批窗口和绕过窗口的失败模式不同，拆分后可独立设阈值与 required checks。
- `merge`：合并方向
  - from: `旁路理由分类治理（bypass reason taxonomy gate）`
  - from: `旁路授权-理由同一治理（bypass authorization-reason parity gate）`
  - into: `旁路理由授权一致性治理（bypass reason-authorization coherence gate）`
  - reason: 两者都在约束 bypass 的“理由-授权”耦合，分开维护会产生同构重复。
- `expand`：新增方向 `代理会话最小权限漂移治理（agent session least-privilege drift gate）`
  - 触发依据：HN newest 出现 `Be Careful with LLM Agents`，且 GitHub `GITHUB_TOKEN` 文档强调显式 `permissions` 最小化。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:50:19Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Verified Spec-Driven Development with OpenAI and IaC (Sponsored)`
  - show (`show`): `Show HN: Augment Agent, coding assistant with autonomy`
  - new (`newest`): `Be Careful with LLM Agents`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步状态机，`completed` 仅表示执行结束）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 链路）
  - GitHub Protected Branches（required status checks 晋级硬门禁）
  - GitHub `GITHUB_TOKEN`（`permissions` 最小权限配置）
  - Hacker News API（`topstories/showstories/newstories` 车道端点）

### 本轮结论

- 无人值守链路里的“权限升级”必须视为状态切换事件，不是普通日志。
- `scope_manifest_pass` 与 `escalation_replay_pass` 必须并列 required checks。
- 升级后未重放的结论只能保留探索层，禁止直接晋级。

### Cycle 51 预载任务

1. 增加 `scope_diff_severity` 分级（read-only drift / write-capable drift）。
2. 将权限升级封套接入 `candidate -> issue -> PR` 全链路。
3. 为不同执行车道建立最小权限基线与漂移预算。

---

---
# Morning Brief（Nightshift Cycle 49）

> 更新时间：2026-02-28 21:49 UTC  
> 本轮目标：把“跨 runtime 结果可完成”升级为“跨 runtime 权限必须同构”，阻断 scope 漂移下的静默晋级。

### 本轮新增（已落盘）

1. `references/patterns/runtime-governance/browser-tool-scope-parity-gate.md`
2. `references/patterns/runtime-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 49）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `自驱代码库晋级证明治理（self-driving codebase promotion proof gate）` 为：
  - `自驱代码生成证据账本治理（self-driving code generation evidence ledger gate）`
  - `自驱代码人审触发门禁治理（self-driving code human-review trigger gate）`
  - reason: 自动生成的“证据完备性”与人工审批的“晋级触发约束”是两类门禁，拆分后可独立演化。
- `expand`：新增方向 `代理最小权限白名单治理（agent least-privilege scope manifest gate）`
  - 触发依据：HN newest 出现 `Be Careful with LLM Agents`，且 GitHub `GITHUB_TOKEN` 文档强调最小权限，需补 scope manifest 独立方向。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:47:01Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Obsidian Sync now has a headless client`
  - show (`show`): `Show HN: Now I Get It – Translate scientific papers into interactive webpages`
  - new (`newest`): `Be Careful with LLM Agents`（作为本轮信号条目）
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步状态与取消语义）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 链路）
  - GitHub Protected Branches（required checks 晋级硬门禁）
  - GitHub `GITHUB_TOKEN`（最小权限与 `permissions` 配置）
  - Hacker News API（`topstories/showstories/newstories` 车道端点）

### 本轮结论

- “完成”只能说明任务结束，不能说明权限一致；scope parity 必须独立验收。
- `scope_parity_pass` 应与 `runtime_boundary_pass` 并列 required check。
- 会话链连续但 scope 不同，必须默认 quarantine，而不是弱告警。

### Cycle 50 预载任务

1. 增加 `scope_diff_severity` 分级策略（read-only drift / write-capable drift）。
2. 将 `scope_parity_pass` 接入 `candidate -> issue` 与 `issue -> PR` 双阶段门禁。
3. 为 browser runtime 增加 `scope_manifest_version`，防止字段静默扩展。

---

---
# Morning Brief（Nightshift Cycle 48）

> 更新时间：2026-02-28 21:39 UTC  
> 本轮目标：为 browser-contained agent 建立“运行边界声明 + 会话链同构 + 晋级硬门禁”最小协议，阻断跨 runtime 的静默误晋级。

### 本轮新增（已落盘）

1. `references/patterns/runtime-governance/browser-runtime-boundary-manifest-gate.md`
2. `references/patterns/runtime-governance/_index.md`（新建 topic 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 48）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `浏览器内代理运行边界治理（browser-contained agent runtime boundary gate）` 为：
  - `浏览器会话边界声明治理（browser runtime-boundary manifest gate）`
  - `浏览器工具权限同构治理（browser tool-scope parity gate）`
  - reason: 运行边界声明与工具权限同构属于不同校验面，拆分后可独立定义 required checks。
- `expand`：新增方向 `自驱代码库晋级证明治理（self-driving codebase promotion proof gate）`
  - 触发依据：HN newest 出现 `The Self-Driving Codebase: Introducing GitHub Spark and Spark CLI`，说明从生成到交付链路更短，需新增晋级证明控制面。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证 301 重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:40:03Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%`
  - show (`show`): `Show HN: Now I get it, this is what all the fuss over LLMs is about`
  - new (`newest`): `The Self-Driving Codebase: Introducing GitHub Spark and Spark CLI`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（异步状态机与取消状态）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 链路）
  - GitHub Protected Branches（required checks 晋级门禁）
  - Hacker News API（统一 API 前缀与 item 读取）

### 本轮结论

- 浏览器内执行不是“换壳”，而是新的风险边界；必须显式写入 runtime 边界声明。
- `completed` 不是晋级条件，必须叠加会话链连续性和权限摘要同构校验。
- `runtime_boundary_pass` / `conversation_chain_pass` 应与现有门禁同级，进入 required checks。

### Cycle 49 预载任务

1. 为 `runtime_boundary_manifest.json` 增加 `boundary_epoch_id`，支持跨轮重放定位。
2. 把 `scope_parity_pass` 接入 candidate->issue 晋级检查，不仅用于 PR 合并前。
3. 在 browser runtime 引入最小 `tool_scope_digest` 版本策略，避免静默字段扩展。

---

---
# Morning Brief（Nightshift Cycle 47）

> 更新时间：2026-02-28 21:35 UTC  
> 本轮目标：把“后台任务可运行”升级为“后台结论可晋级”，新增游标时效门禁，阻断晚到旧 run 的静默晋级。

### 本轮新增（已落盘）

1. `references/patterns/state-governance/background-cursor-freshness-gate.md`
2. `references/patterns/state-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 47）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `工具输出占比预算治理（tool-output ratio budget gate）` 为：
  - `工具输出占比分层阈值治理（lane-tiered tool-output ratio threshold gate）`
  - `工具输出占比触发冻结治理（tool-output-ratio freeze trigger gate）`
  - reason: 原方向同时覆盖“监控阈值”和“晋级冻结触发”，执行面过宽，拆分后可分别定义预算与闸门字段。
- `expand`：新增方向 `浏览器内代理运行边界治理（browser-contained agent runtime boundary gate）`
  - 触发依据：HN newest 出现 “A Proposal for Implementing Claude Code in the Browser”，说明 browser-contained agent 正成为新执行形态，需要提前治理隔离边界与审计接口。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:35:53Z）。
- HN `top/show/new`：已采样并写入证据链（2026-03-01）：
  - top (`news`): `Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%`
  - show (`show`): `Show HN: Syncari – AI-driven Infrastructure as Code Automation`
  - new (`newest`): `A Proposal for Implementing Claude Code in the Browser`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（后台状态机与取消语义）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 链路）
  - GitHub Protected Branches（required status checks 作为晋级硬门禁）
  - Hacker News API（`topstories/showstories/newstories` 车道主键）

### 本轮结论

- 异步完成不是有效完成；必须验证“完成时游标是否仍绑定最新锚点窗口”。
- `previous_response_id` 链连续性与 `anchor_window_id` 新鲜度应作为同级门禁，不可拆分。
- `cursor_freshness_pass` 必须是 required check，否则夜间旧结论仍可能绕过晋级。

### Cycle 48 预载任务

1. 增加 `max_cursor_lag_seconds` 的分车道阈值（top/show/new 各自预算）。
2. 为 browser-contained agent 设计最小 `runtime_boundary_manifest` 字段集。
3. 把 `cursor_freshness_report` 挂接到 candidate->issue 的晋级检查，不仅用于 PR 合并前。

---

---
# Morning Brief（Nightshift Cycle 46）

> 更新时间：2026-02-28 21:31 UTC  
> 本轮目标：把“上下文窗口燃烧”从成本优化问题升级为“压缩后回放冻结”的晋级硬门禁，避免后台续跑在语义不完整时误晋级。

### 本轮新增（已落盘）

1. `references/patterns/context-governance/context-burn-replay-freeze-gate.md`
2. `references/patterns/context-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 46）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `merge`：合并方向
  - from: `恢复回放账本治理（checkpoint + replay + compaction）`
  - from: `认知负债冻结治理（comprehension debt + freeze gate）`
  - into: `上下文燃烧-回放冻结协同治理（context burn replay-freeze governance）`
  - reason: 两方向在执行面已收敛到同一事故链（压缩前快照缺失 -> 续跑语义断裂 -> 误晋级），合并后可统一冻结门禁与回放验签字段。
- `expand`：新增方向 `工具输出占比预算治理（tool-output ratio budget gate）`
  - 触发依据：HN top 当轮出现 “Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%”，说明工具输出占比已成为自治系统稳定性的独立控制面。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，采样时页面显示 last active 为 2026-02-28）。
- HN `top/show/new`：已采样并写入证据链（2026-03-01）：
  - top (`news`): `Stop Burning Your Context Window: How We Cut MCP Token Usage by 98%`
  - show (`show`): `Show HN: Syncari – AI-driven Infrastructure as Code Automation`
  - new (`newest`): `A Proposal for Implementing Claude Code in the Browser`
- 官方文档证据链（本轮重点）
  - OpenAI Background mode（后台状态机、`store=true` 要求、cancel 语义）
  - OpenAI Conversation state（`previous_response_id` / `conversation` 状态链接与压缩相关端点）
  - GitHub Actions Artifacts（artifact digest 与 retention 字段）
  - GitHub Protected Branches（required status checks 作为不可绕过门禁）

### 本轮结论

- “压缩成功”不等于“语义连续”；压缩必须成为结构化快照事件，而不是透明优化。
- `tool_output_ratio` 是上下文燃烧的先行指标，应直接接入冻结门触发逻辑。
- 晋级前必须同时满足 `previous_response_id` 连续性与 `artifact_digest` 一致性，否则默认冻结。

### Cycle 47 预载任务

1. 为 `pre_compaction_snapshot.json` 增加 `decision_delta_hash` 与 `pending_claim_count` 的阈值告警。
2. 将 `context_burn_replay_pass` 接入 `candidate -> issue` 晋级 check，而非仅用于 PR 合并前检查。
3. 引入 `tool_output_ratio` 的分方向基线（探索车道 vs 晋级车道）防止统一阈值误报。

---

---
# Morning Brief（Nightshift Cycle 45）

> 更新时间：2026-02-28 21:33 UTC  
> 本轮目标：把 merge queue 的“重排重建”从调度细节升级为晋级硬门禁，阻断 jump 后复用旧证据的隐式放行。

### 本轮新增（已落盘）

1. `references/patterns/queue-governance/queue-reorder-rebuild-attestation-gate.md`
2. `references/patterns/queue-governance/_index.md`（新增 pattern 索引）
3. `references/patterns/_master_index.md`（新增 pattern 行、topic 计数与统计更新）
4. `morning-brief.md`（新增 Cycle 45）
5. `.nightshift/state.json`（`cycle + 1` 与方向演化更新）

### 激进动态策略执行（本轮）

- `split`：拆分方向 `跨阶段时序预算治理（cross-stage window freshness budget gate）` 为：
  - `队列重排时序预算治理（queue reorder freshness budget gate）`
  - `审批跨阶段时序预算治理（approval cross-stage freshness budget gate）`
  - reason: 原方向同时承载“队列重排窗口”和“审批跨阶段窗口”，执行约束边界过宽。
- `merge`：合并方向
  - from: `队列尾绿容错预算联动治理（tail-green attestation-budget parity gate）`
  - from: `队列容错显式降级治理（merge-queue non-failing explicit fallback gate）`
  - into: `队列容错预算降级一体化治理（merge-queue fallback-budget parity gate）`
  - reason: 两方向都在约束容错模式放行边界，拆开会重复维护同一审计语义。
- `expand`：新增方向 `队列重排重建验签治理（queue reorder rebuild attestation gate）`
  - 触发依据：GitHub merge queue 文档确认 jump 到队首会触发 in-progress PR 重建，必须把重建事件提升为证据失效信号。

### 必选信源执行确认

- `https://t.co/dwAiIjlXet`：已验证重定向到 HN Popular Blogs OPML Gist（`https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b`，checked 2026-02-28T21:27:10Z）。
- HN `top/show/new`：已采样并写入证据链（2026-02-28）：
  - top (`news`): `747s and Coding Agents`
  - show (`show`): `Show HN: Obsidian Garden for running local llm agents`
  - new (`newest`): `Open Source and self host your own private Telegram using Telegram API`
- 官方文档证据链（本轮重点）
  - GitHub merge queue（jump 到队首会触发 in-progress PR 重建）
  - GitHub Actions `merge_group` 事件（队列重建后的独立校验触发面）
  - GitHub GraphQL（`EnqueuePullRequestInput.jump` / `MergeQueueParametersInput.groupingStrategy`）

### 本轮结论

- queue 重排不是“调度层小变更”，而是“验证对象切换”，必须触发旧证据失效。
- `queue_epoch_id` + `merge_group_head_sha` 是最小绑定对；缺任何一项都不应晋级。
- `groupingStrategy` 变化必须进入 quarantine 并要求人工确认，不能静默继承旧绿灯。

### Cycle 46 预载任务

1. 为 `queue_epoch_manifest.json` 增加历史链路字段（`previous_epoch_id` / `invalidated_at_utc`）。
2. 把 `jump_requested=true` 接入 required checks 的 fail-fast 模板。
3. 将 `groupingStrategy` 变化与 tail-green 风险预算做统一阈值表。

---

---
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

---
