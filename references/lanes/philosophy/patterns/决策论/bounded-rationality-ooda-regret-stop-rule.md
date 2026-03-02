---
name: bounded-rationality-ooda-regret-stop-rule
topic: 决策论
verified_count: 49
sources:
  - Daniel Bernoulli, Exposition of a New Theory on the Measurement of Risk (1738/1954 translation)
  - Frank P. Ramsey, Truth and Probability (1926)
  - John von Neumann, Oskar Morgenstern, Theory of Games and Economic Behavior (1944)
  - Abraham Wald, Statistical Decision Functions (1950)
  - Leonard J. Savage, The Foundations of Statistics (1954)
  - David Blackwell, M. A. Girshick, Theory of Games and Statistical Decisions (1954)
  - Herbert A. Simon, A Behavioral Model of Rational Choice (1955)
  - R. Duncan Luce, Howard Raiffa, Games and Decisions (1957)
  - Ralph L. Keeney, Howard Raiffa, Decisions with Multiple Objectives (1976)
  - Amos Tversky, Daniel Kahneman, Prospect Theory (1979)
  - The Presidential Commission (Rogers Commission), Challenger Accident Report (1986)
  - ESA/CNES Inquiry Board, Ariane 501 Failure Report (1996)
  - Columbia Accident Investigation Board, CAIB Report Volume I (2003)
  - U.S. SEC, Release No. 70694 on Knight Capital (2013)
  - U.S. EPA OIG, Flint Water Crisis Report No. 18-P-0221 (2018)
  - Post Office Horizon IT Inquiry, Volume 1 Report (2025)
  - Robodebt Royal Commission Report (2023)
  - Parlementaire ondervragingscommissie Kinderopvangtoeslag, Ongekend onrecht (2020)
  - WHO, International Health Regulations (2005, Third Edition)
  - European Union, Regulation (EU) 2022/2065 Digital Services Act (2022)
  - European Commission, DSA Transparency Database Launch Notice (2023)
  - CAC, 互联网信息服务算法推荐管理规定（国家网信办等部门令第9号） (2022)
  - OMB Memorandum M-24-10, Advancing Governance, Innovation, and Risk Management for Agency Use of AI (2024)
  - European Convention on Human Rights, Article 35 (1950, Protocol 15 effective 2021)
  - European Court of Human Rights, Annual Reports (2001-2025)
  - U.S. DOJ EOIR, Adjudication Statistics: New Cases and Total Completions - Historical (1983-2025 Q3)
  - U.S. DOJ EOIR, Adjudication Statistics: All Appeals Filed, Completed, and Pending (2016-2026 Q1)
  - eCFR 8 CFR 1003.38 Appeals (current through 2026-02 update)
  - SSA OIG, Audit A-05-22-51159 The SSA's Hearings Backlog and Average Processing Times (2023)
  - European Commission, DSA Transparency Database (ongoing platform statements of reasons)
  - European Commission, Research API for DSA Transparency Database (2025)
  - Google, EU DSA Transparency Report (2025 H1)
  - Oversight Board, 2024 Annual Report (2025)
  - Oversight Board, Taiwan Job Scam Warning Decision (2025)
  - European Commission, Commission Implementing Regulation (EU) 2024/2835 (2024)
  - European Commission DG CONNECT, Implementing Regulation Templates for DSA Transparency Reporting (2024)
  - X Corp, X DSA Transparency Report (Oct 2024)
  - Appeals Centre Europe, First Transparency Report (2025)
  - United Nations, Vienna Convention on the Law of Treaties (1969)
  - UN International Law Commission, Fragmentation of International Law (A/CN.4/L.682, 2006)
  - WTO, Agreement on the Application of Sanitary and Phytosanitary Measures (1994)
  - WTO SPS Committee, Decision on the Implementation of Article 4 (G/SPS/19/Rev.2, 2001+)
  - Hague Conference on Private International Law, Choice of Court Convention (2005)
  - Hague Conference on Private International Law, Judgments Convention (2019)
  - UNCITRAL, Model Law on Cross-Border Insolvency (1997)
  - European Union, Dublin III Regulation (EU) No 604/2013
  - European Union, GDPR Regulation (EU) 2016/679 (Arts. 44-49)
  - CJEU, Data Protection Commissioner v Facebook Ireland and Maximillian Schrems (C-311/18, 2020)
  - Council of the European Union, Council Framework Decision 2002/584/JHA (European Arrest Warrant)
last_verified: 2026-03-02
evidence_band: medium-high
rank: 5
---

## 元问题

在信息不完备、时间受限、错误代价不对称的现实场景中，如何决定“何时停止继续观察并提交行动”，避免陷入“等更多信息”与“过早行动”的双重失误。

## 核心机制

把决策拆成四层并设置停止闸门：

1. 认知层（bounded rationality）：先承认信息与算力上限，放弃全知最优假设。
2. 节奏层（OODA）：以短闭环更新“观察-定向-决策-行动”，压缩错误暴露时间。
3. 约束层（regret guardrail）：在关键不可逆风险上设后悔上限，超过即触发阻断或回退。
4. 账本层（rollback ledger）：把“继续执行成本 vs 立即回滚成本”做并行记账，避免单 KPI 误导。

目标不是一次性最优，而是在可承受后悔边界内实现持续可改进。

## 决策步骤

1. 锁定决策窗口：明确本轮必须决断的截止时间与不可逆动作清单。
2. 构建候选动作：至少保留“立即执行/延后采样/降级执行”三类动作。
3. 定义后悔护栏：给每个动作写明最坏后果、可恢复成本、触发阈值。
4. 建立回滚账本：每轮更新回滚窗口、不可恢复成本、依赖爆炸半径与恢复时长。
5. 执行 OODA 微循环：每轮只更新少量高价值证据，不做无限扩展搜索。
6. 触发停止判定：满足“时间窗到期”或“信息价值低于行动价值”即停止观测并提交动作。
7. 提交后复盘：记录后悔来源，区分“模型错”与“执行错”，写入下一轮阈值。

## 停止规则（Stop Gates）

- 时间闸门：剩余缓冲 < 1 个执行周期时，禁止继续加样本。
- 价值闸门：新增证据导致最优动作排序变化概率低于阈值时，停止搜索。
- 风险闸门：任何候选动作触发不可逆损失上限时，优先降级或回退。
- 可逆闸门：高不确定但可回滚时允许先行动后校正；不可回滚时提高提交门槛。
- 可逆半衰期闸门：超过可逆窗口半衰期后，禁止新增承诺，必须进入强制复核。
- 反事实优势闸门：若“立即回滚”的期望损失连续 N 轮低于“继续执行”，强制停机或降级。
- 公共伤害通报闸门：一旦跨过法定或政策通报时窗，停止“内部等待”，转入公开披露与临时保护动作。
- 跨法域迁移闸门：阈值从 A 法域迁移到 B 法域前，必须完成本地申诉通道与问责链条对齐，否则仅允许影子运行。
- 申诉积压闸门：当申诉积压增速连续超过处置增速时，强制降级自动决策强度，避免制度性误伤累积。
- 程序正义闸门：高后果自动化决策若无法提供可解释理由和可操作申诉路径，默认不允许直接执行。
- 指标-伤害背离闸门：当 KPI 连续改善而申诉成功率/误伤率连续恶化 N 轮时，强制降级自动化强度并触发回滚复核。
- 纠错时延闸门：`appeal_ttr_p95` 超过 `rollback_window_hours` 对应阈值比例时，禁止扩容自动处置范围。
- 脆弱群体集中闸门：高风险群体误伤占比超过公平阈值时，必须切换人工复核优先并暂停批量执行。
- 观测窗口闸门：当公开数据保留窗口不足以支持跨周期推断时，禁止输出结构性结论，先补历史快照与外部对照样本。
- 低置信伤害闸门：当“诈骗内容 vs 反诈骗警示”语义重叠且判别置信不足时，停止直接删除/封禁，切换提示+人工复核。
- 纠偏可见性闸门：当申诉结果公开时序缺失或发布滞后超过阈值时，停止扩大自动化处置范围，优先修复披露与申诉链路。
- 时间锚点一致性闸门：`anchor_drift_days_p50` 超过阈值时，禁止跨平台阈值比较，先统一 decision/disclosure 时间锚点。
- 结案偏差闸门：`unresolved_case_ratio` 超过阈值时，禁止仅用结案样本驱动扩容，先执行未结案补权重或冻结。
- 程序等价闸门：`procedure_alignment_band` 低于 `medium` 时，仅允许本地阈值执行，不允许跨法域直接迁移。
- 处置强度等价闸门：`severity_normalization_status != normalized` 时，禁止用申诉通过率/撤销率做横向排名。
- 程序冲突分级闸门（G21）：`conflict_grade_d >= D2` 时，禁止直接迁移，仅允许影子运行或人工复核。
- 申诉时限错配闸门（G22）：`appeal_deadline_delta_days` 超过阈值时，停止自动扩容并强制本地重标定。
- 审级等效闸门（G23）：`review_tier_gap` 超过阈值时，不得沿用源法域阈值和放行节奏。
- 救济可达闸门（G24）：`remedy_equivalence_score` 低于阈值时，禁止高后果自动决策，默认降级人工优先。
- 证据可携带闸门（G25）：`evidence_portability_score` 低于阈值时，停止跨法域模型结论直接落地。
- 互认暂停/退出闸门（G26）：连续 N 轮出现 D2/D3 且纠偏失败时，触发互认暂停并进入退出流程。
- 事故后再认证闸门（G27）：发生跨法域程序错配导致高后果事故后，未完成独立复核前禁止恢复自动扩容。

## 回滚成本账本（最小字段）

- `trigger_id`: 触发本轮停止/继续判定的证据编号。
- `rollback_window_hours`: 当前仍可低代价回滚的时间窗（小时）。
- `unrecoverable_cost`: 一旦跨窗不可恢复损失估计（资金/安全/合规）。
- `dependency_blast_radius`: 回滚涉及的上下游依赖与级联范围。
- `service_recovery_ttr`: 回滚后恢复到稳态服务所需时长。
- `decision_confidence`: 本轮决断置信带（high/medium/low）。
- `harm_notice_lag_days`: 发现风险到公众/对象收到正式告知的滞后天数。
- `appeal_backlog_ratio`: 有效申诉积压量/可处置量比值。
- `jurisdiction_migration_gap`: 迁移阈值与本地法律程序要求之间的未闭合差距。
- `harm_divergence_rounds`: KPI 改善但伤害代理恶化的连续轮次。
- `appeal_ttr_p95`: 申诉/纠错流程 p95 完结时延（天）。
- `vulnerable_group_error_share`: 脆弱群体在误伤总量中的占比。
- `observation_horizon_months`: 可公开复核数据的连续观测窗口（月）。
- `false_positive_reversal_rate`: 经申诉或复核后撤销初判的比例。
- `appeal_outcome_publication_lag_days`: 申诉结果对外披露的中位滞后天数。
- `anchor_drift_days_p50`: 决策发生时间与公开披露时间的中位偏差天数。
- `unresolved_case_ratio`: 未结案样本占总样本比例。
- `procedure_alignment_band`: 跨法域申诉/问责流程映射一致性等级（high/medium/low）。
- `severity_normalization_status`: 跨平台处置强度口径是否已归一（normalized/partial/raw）。
- `jurisdiction_pair`: 源法域→目标法域标识（如 `EU->US-CA`）。
- `conflict_grade_d`: 程序冲突等级（D0/D1/D2/D3）。
- `appeal_deadline_delta_days`: 跨法域申诉时限差（天）。
- `review_tier_gap`: 可用复核层级差（整数）。
- `evidence_portability_score`: 证据可迁移评分（0-1）。
- `remedy_equivalence_score`: 救济等效评分（0-1）。

## 触发信号

- 团队持续请求“再看一轮数据”但决策质量无实质抬升。
- 指标改善与现场恶化并存，出现证据冲突。
- 每轮分析都在增维，却没有收敛到可执行动作。
- 错误代价呈非对称放大（延迟成本或误判成本陡增）。
- 自动化决策规模扩大，但申诉积压、纠错时长和受影响人群同步上升。
- 裁决吞吐率提高但申诉成功率持续上升，出现“效率提升-伤害加剧”背离。
- 上诉处置清空率连续低于 1 且积压持续扩张，回滚窗口被纠错时延吞噬。
- 平台只披露处置量而不披露申诉结果时序，导致纠偏效果不可审计。
- 内容安全召回率上升但误触发撤销率同步上升，出现“治理强度上升-误伤上升”耦合。
- 内部裁决时间与公开披露时间持续背离，导致跨平台对比出现“同值不同义”。
- 未结案样本占比升高但仍以结案样本扩容，导致阈值被系统性低估风险。
- 各平台 action taxonomy 严重度分层不一致，却直接使用通过率/撤销率做统一排名。
- 同一模型跨法域上线后，申诉时限差与审级差同步放大，纠偏吞吐率连续下滑。
- 形式合规通过但实质救济不可达，出现“可上诉但不可救济”的伪程序正义。
- 互认机制维持运行，但外部独立审查反复判定源法域证据不可直接采用。

## 边界失效

- 后悔函数不可定义，导致护栏形同虚设。
- 反馈时滞显著大于 OODA 周期，快速循环反而放大噪声。
- 对手主动操纵信号，Orientation 层被污染。
- 目标函数频繁重写，停止闸门不断漂移。
- 极端尾部风险不可上界时，局部 regret 最小化会误导。
- 阈值跨法域迁移未做程序对齐，导致“技术可执行”但“制度不可执行”。
- 闸门被 Goodhart 化：团队围绕通过阈值优化指标而非降低真实伤害。
- 纠错链路失真：申诉入口、证据回收、裁决执行口径不一致，导致账本字段不可比。
- 公平性代理失效：把“统一阈值”误当“公平”，忽略脆弱群体风险暴露差异。
- 透明性名义存在但访问受限（登录/token/窗口截断），导致外部研究无法复核长期漂移。
- 时间锚点混用：把 decision-time 与 disclosure-time 混作同一字段，导致滞后偏差被吞没。
- 处置强度未归一：不同平台“删除/降权/标注”被当成同强度动作，横向结论失真。
- 程序冲突未分级：将 D2/D3 场景误判为 D0/D1，导致不应迁移的阈值进入生产执行。
- 互认退出条件缺失：程序错配被长期“临时豁免”并逐步制度化。
- 事故后不再认证：高后果失效后直接恢复扩容，重复触发同类程序性伤害。

## Cycle 158 同化补强（跨平台口径统一映射规则）

### 映射最小规范（Mapping Spec v1 for Decision Gates）

1. 时间锚点双字段：所有样本必须并行记录 `decision_time` 与 `disclosure_time`，禁止单字段替代。
2. 结案状态分层：申诉样本按 `resolved/unresolved` 强制分层，扩容判定默认使用加权口径。
3. 程序链路映射：申诉入口、复核层级、问责终点必须完成一一映射并标注 `procedure_alignment_band`。
4. 处置强度归一：删除/降权/限流/警示统一映射到严重度等级后，才允许横向比较通过率和撤销率。

### 样本同化结论

- `EU 2024/2835 + 官方模板` 提供机器可读字段与定义锚点，可直接落地 G17/G20。
- `X DSA 报告` 提供平台侧链路样本，但若无严重度归一会放大口径错配风险。
- `Appeals Centre Europe` 提供外部复核视角，可校准平台自报与独立争议处置之间的漂移。

## Cycle 160 同化补强（跨法域程序冲突分级与解冲条件）

### 冲突分级 D0-D3

1. D0（等价差异）：申诉入口、时限、审级、救济效果和披露义务可一一映射，允许直接迁移。
2. D1（轻度差异）：存在单点流程差异，但可由补偿动作闭合（额外告知/人工复核），允许限域迁移。
3. D2（实质差异）：两项及以上关键程序不等价（如时限+审级断层），仅允许影子运行或人工优先。
4. D3（根本冲突）：核心程序权利缺失或不可兼容，禁止迁移，必须本地重建阈值与流程。

### 解冲动作语法

- 若 `conflict_grade_d = D0` 且 `review_tier_gap = 0`：允许直接放行，但保留抽样复核。
- 若 `conflict_grade_d = D1`：降级自动化强度并限定场景，完成补偿动作后方可扩容。
- 若 `conflict_grade_d = D2`：禁止生产迁移，进入影子运行 + 双账本观察窗口。
- 若 `conflict_grade_d = D3`：强制冻结迁移，触发互认暂停与独立审查。

### 失败反例同化

- `M.S.S. v Belgium and Greece (ECtHR, 2011)`：成员国程序被默认等效，未拦截接收国系统性缺陷，触发 D3 级教训。
- `Maher Arar Inquiry (Canada, 2006)`：跨法域协作缺少有效救济与核验，触发 G24/G25 失败链条。
- `Boeing 737 MAX JATR/NTSB (2019)`：跨辖区认证假设未经独立复核，事故后才被动再认证，验证 G27 的必要性。

## 学派变体（不裁决）

- 期望效用最优化：强调一致性公理与全局最优。
- 有限理性满意化：强调在资源约束下达到“足够好”。
- 信息价值优先：强调持续采样以降低不确定性。
- 速度闭环优先：强调先行动再纠偏以降低暴露窗口。

## L5 检索测试

以下决策场景可直接检索本模式：

- 安全应急：何时停止归因并先隔离受影响系统。
- 医疗急诊：何时停止追加检查并先执行抢救动作。
- 供应链波动：何时冻结采购与排产，避免双向失衡。
- 软件发布：何时停止灰度并先回滚，避免缺陷跨依赖级联。
- 公共治理：何时停止“等待更多调查”并先执行保护性措施。
- 社会保障自动化：何时停止批量自动追缴并先切换到人工复核与暂停执行。
- 平台治理：何时停止自动处置扩张并先修复申诉与解释链路。
- 跨法域迁移：当阈值技术可执行但本地申诉/问责链条未闭合时，应该触发哪一级降级、何时允许解冻放行。
- 跨境数据治理：当形式合规已满足但实质救济不可达时，是否应把 D2 升级为 D3 并冻结迁移。
- 安全关键认证迁移：事故后何时允许从“暂停互认”恢复到“受控放行”。

## 与既有模式边界

- 与 `实践论/praxis-feedback-loop-governance` 的边界：
  - 实践论回答“行动后如何双回路纠偏”。
  - 本模式回答“行动前/行动中何时停止观测并提交动作”。

- 与 `矛盾论/principal-secondary-contradiction-switch-boundary` 的边界：
  - 矛盾论回答“主导约束何时切换”。
  - 本模式回答“在既定主导约束下何时结束信息采样并决断”。

- 与 `高维拓扑/topological-decision-navigation` 的边界：
  - 高维拓扑回答“在可行空间选哪条路径更稳健”。
  - 本模式回答“何时停止路径搜索并提交当前路径”。

## 原始证据链摘要

- Bernoulli / von Neumann-Morgenstern / Savage 给出规范性决策公理基线。
- Wald / Blackwell-Girshick 建立统计决策与风险最小化框架。
- Simon 提供有限理性与满意化，约束“全局最优”假设。
- Luce-Raiffa / Keeney-Raiffa 扩展到多目标与现实权衡结构。
- Tversky-Kahneman 提供行为偏离证据，提示需显式设置后悔与偏差护栏。
- Challenger、CAIB、Ariane 501、Knight Capital、Flint、Horizon IT Inquiry 提供跨行业高时滞失败样本，证实“延迟停止会放大回滚成本”。
- Robodebt、Ongekend onrecht、WHO IHR、EU DSA/CAC 规定、OMB M-24-10 提供公共治理与跨法域迁移样本，证实“阈值迁移若缺程序对齐，会把效率优化转化为制度性误触发”。
- ECHR 年报（2001-2025）、EOIR 公开上诉/结案时序（1983-2026）与 SSA 听证积压审计（2023）提供连续 backlog/inflow/outflow 样本，支持把“申诉积压闸门”从概念规则推进到可标定阈值。
- DSA Transparency Database、Commission Research API、Google EU DSA 报告与 Oversight Board 年报/案例共同补足平台治理一手时序证据，支持把“申诉结果公开时序 + 误触发反例库”并入停止规则。
- EU 2024/2835 与官方模板给出字段定义和可机器校验口径，X 报告与 Appeals Centre Europe 报告提供平台侧/外部侧双视角样本，支持把“口径统一映射规则”推进为可执行放行门槛。
- Vienna Convention、ILC Fragmentation 与 HCCH/UNCITRAL 系列文本提供跨法域冲突解读与拒绝承认框架，支持 D0-D3 分级语法落地。
- GDPR（Art.44-49）与 Schrems II 判决证明“形式合规不等于实质等效”，支撑 G24/G25 的强制闸门化。
- Dublin III 与 ECtHR 反例（M.S.S.）表明程序错配可在互认机制中累积为系统性伤害，支持 G26/G27 的暂停与再认证条件。
