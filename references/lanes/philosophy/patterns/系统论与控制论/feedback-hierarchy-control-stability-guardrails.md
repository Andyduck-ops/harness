---
name: feedback-hierarchy-control-stability-guardrails
topic: 系统论与控制论
evidence_band: medium-high
verified_count: 45
sources:
  - James Clerk Maxwell, On Governors (1868)
  - Arturo Rosenblueth; Norbert Wiener; Julian Bigelow, Behavior, Purpose and Teleology (1943)
  - Norbert Wiener, Cybernetics (1948)
  - Claude E. Shannon, A Mathematical Theory of Communication (1948)
  - Ludwig von Bertalanffy, An Outline of General System Theory (1950)
  - W. Ross Ashby, An Introduction to Cybernetics (1956)
  - Kenneth E. Boulding, General Systems Theory—The Skeleton of Science (1956)
  - W. Ross Ashby, Design for a Brain (1952/1960)
  - Harry Nyquist, Regeneration Theory (1932)
  - Harold S. Black, Stabilized Feedback Amplifiers (1934)
  - Roger C. Conant; W. Ross Ashby, Every Good Regulator of a System Must Be a Model of That System (1970)
  - D. L. Parnas, On the Criteria To Be Used in Decomposing Systems into Modules (1972)
  - Leslie Lamport, Time, Clocks, and the Ordering of Events in a Distributed System (1978)
  - Nancy G. Leveson; Clark S. Turner, An Investigation of the Therac-25 Accidents (1993)
  - Mars Climate Orbiter Mishap Investigation Board, Phase I Report (1999)
  - U.S.-Canada Power System Outage Task Force, Final Report on the August 14, 2003 Blackout (2004)
  - U.S.-Canada Power System Outage Task Force, Final Report on Implementation of Task Force Recommendations (2006)
  - Seto; Krogh; Sha; Chutinan, The simplex architecture for safe on-line control system upgrades (1998)
  - Slagel; White; Dutle; Munoz; Crespo, A Verification Framework for Runtime Assurance of Autonomous UAS (2024)
  - FAA 14 CFR 25.1329 Flight guidance system (2006)
  - UNECE UN Regulation No.157 ALKS (2020)
  - SAE J3016 Taxonomy and Definitions for Terms Related to Driving Automation Systems (2021)
  - NERC EOP-008-2 Loss of Control Center Functionality (2017)
  - SEC 17 CFR 240.15c3-5 Market Access Rule (2010)
  - NTSB, Collision Between Vehicle Controlled by Developmental Automated Driving System and Pedestrian, Tempe, Arizona (2019)
  - FAA, Joint Authorities Technical Review of the Boeing 737 MAX Flight Control System (2019)
  - SEC, In the Matter of Knight Capital Americas LLC, Release No. 70694 (2013)
  - ICAO, Annex 13 Aircraft Accident and Incident Investigation (13th ed., 2024)
  - National Transportation Safety Board, The Investigative Process (official process page)
  - Columbia Accident Investigation Board, Report Volume I (2003)
  - BEA, Final Report on Air France Flight AF447 (2012)
  - WHO, Communication during patient handovers (2007)
  - U.S. DoD, MIL-STD-882E System Safety (2012)
  - IAEA PRIS, About PRIS (since 1970)
  - U.S. NRC, Data Reporting and Transparency (Action Matrix / PI datasets)
  - U.S. NRC; Nuclear Energy Institute, PI Summary and FAQ (NEI 99-02 Rev.8, 2025)
  - U.S. NRC, Inspection Manual Chapter Index (IMC 0305 latest revision)
  - U.S. NRC, NUREG-1022 Rev.3 Supplement 2 (2024)
  - IAEA, INES Users Manual (2009 edition, published 2013)
  - Google SRE Book, Service Level Objectives (2017)
  - Google SRE Book, Tracking Outages (2017)
  - Google SRE Workbook, Postmortem Culture (2018)
  - Google SRE Workbook, Error Budget Policy (2018)
  - Benjamin H. Sigelman et al., Dapper, a Large-Scale Distributed Systems Tracing Infrastructure (2010)
  - Nancy Leveson et al., STAMP Workshop (2003)
last_verified: 2026-03-02
rank: 7
---

## 元问题

当系统已进入持续反馈调节时，如何在时滞、噪声和层级约束并存的条件下保持“可控而不过控”，避免两种失真：局部纠偏有效但全局吞吐坍塌，或强力控制引发振荡与放大。

## 核心机制

把系统治理拆为三类耦合约束并联动：

1. 增益约束：控制动作幅度必须与系统恢复能力匹配，禁止把短期偏差放大成长期震荡。
2. 时滞约束：观测-判断-执行链路的总时延必须低于系统可恢复窗口。
3. 层级约束：局部控制策略不可破坏全局生存函数，必要时牺牲局部峰值换全局稳定。

目标不是“最快纠偏”，而是在扰动持续存在时维持可持续调节能力。

## 决策步骤

1. 生存函数锁定：先定义全局不可破坏约束（安全、现金流、关键服务可用性）。
2. 回路建模：标注平衡回路/增强回路及主要时滞链，识别过冲风险源。
3. 多样性评估：估计扰动多样性与控制多样性差值，缺口过大先补观测与执行通道。
4. 分层控幅：快回路负责抑振，慢回路负责结构修正，禁止单回路承担全部纠偏。
5. 小步可逆干预：先执行可回滚动作并监测相位滞后，再放大控制力度。
6. 越阈降级：触发振荡阈值时立即降增益或切换控制架构，暂停局部最优目标。
7. 接口契约复核：跨组织/跨模块接口必须在语义（单位、状态、时序）与权限上逐项验收，缺任一项禁止放大自动控制动作。

## 验证闸门（Validation Gates）

- G1 振荡触发：同一误差连续 3 个窗口放大且控制输入同步增加，视为过控风险。
- G2 时滞触发：校正时滞/扰动主周期 > 0.5，禁止继续加大增益，先改链路时延。
- G3 层级触发：局部 KPI 连续改善但全局指标连续 2 个窗口恶化，立即重排目标优先级。
- G4 熔断触发：控制动作不可回滚或关键回路不可观测时，停止自动调节并升级人工治理。
- G5 契约触发：跨组织接口出现单位、时序或状态语义不一致时，立即冻结自动闭环并启动接口重认证。
- G6 级联触发：本地检测延迟 + 协调延迟超过系统级联窗口时，转入应急降级并切换为最小风险运行态。

## 触发信号

- 告警处理越快，系统波动越大（典型过控信号）。
- 单团队效率提升，但端到端交付周期变长。
- 同一问题在不同时间窗反复回潮，且补丁越来越重。
- 跨团队争论集中在责任归属而非回路结构与时滞证据。
- 跨组织交付中频繁出现“单位换算”“状态定义”“时钟基准”争议。
- 告警在本地可见但跨团队不可见，且处置顺序相互冲突。

## 边界失效

- 关键反馈链缺监测点，导致控制对象不可观测。
- 激励与控制权限分离，执行层无法按控制目标动作。
- 目标函数频繁改写，控制系统持续追逐移动靶。
- 干预动作不可逆且缺少回滚路径。
- 外部扰动速度长期超过模型刷新速度，既有参数失效。
- 接口契约只做字段对齐，不做语义/时序/权限三重验收。

## Cycle 141 同化补强（公开样本）

1. Mars Climate Orbiter（1999）：
   - 证据点：接口文档要求公制而地面软件输出英制冲量，长周期累积漂移导致轨道插入失败。
   - 方法含义：小误差在长时滞链路中会跨层放大，接口语义一致性应纳入控制闸门。
2. 北美 2003 大停电（2004/2006 报告）：
   - 证据点：本地监测故障与跨实体协调迟滞叠加，引发级联扩散；后续通过强制可靠性标准形成治理闭环。
   - 方法含义：检测延迟与协调延迟必须分层预算，不能只优化单层响应速度。
3. Therac-25（1985-1987）：
   - 证据点：操作节奏与软件状态机时序错配，且组织反馈链迟缓，造成高风险失效。
   - 方法含义：人机时序约束属于接口契约的一部分，不能只看功能接口。

## 新增可执行账本（cycle 141）

- Observability-Actuation Parity Ledger：
  - 关键状态可观测覆盖率不足时，禁止增益上调。
  - 关键动作可执行覆盖率不足时，先补执行权限再调参。
- Multi-Layer Delay Budget：
  - 分别记录检测延迟、判定延迟、协调延迟。
  - 当累计时滞超过级联窗口，优先降级运行而非继续追求局部 KPI。

## 学派变体（不裁决）

- 稳态优先（homeostasis） vs 受控扰动适应优先（anti-fragile adaptation）。
- 集中式全局调度 vs 分布式局部自组织。
- 机理模型先行控制 vs 数据在线学习控制。
- 固定设定点跟踪最优 vs 可生存域（viability envelope）优先。
- 最小扰动稳定优先 vs 激励探测（persistent excitation）优先。

## L5 检索测试

以下决策场景可直接检索本模式：

- 供应链牛鞭效应：优先加库存、降增益，还是重构反馈链路。
- SRE 告警风暴：优先加自动化动作，还是降频并重排阈值。
- 组织治理：局部部门 KPI 优化是否正在制造全局系统振荡。
- 跨组织接口升级：是否满足语义/时序/权限三重契约后再启用自动闭环。
- 事故复盘后整改：应先补监测链路还是先加控制强度。

## 与既有模式边界

- 与 `实践论/praxis-feedback-loop-governance` 的边界：
  - 实践论强调行动-反思双回路。
  - 本模式强调反馈稳定性参数（增益、时滞、层级约束）与过控防护。

- 与 `决策论/bounded-rationality-ooda-regret-stop-rule` 的边界：
  - 决策论回答“何时停止观测并提交行动”。
  - 本模式回答“行动后如何保持闭环稳定并避免振荡放大”。

- 与 `认识论与知识验证/falsification-evidence-threshold-model-update-gate` 的边界：
  - 认识论回答“何时更新认知模型”。
  - 本模式回答“在不更新模型前提下，如何通过控制结构维持系统可控性”。

## 原始证据链摘要

- Maxwell/Nyquist/Black 给出反馈稳定与负反馈工程化的原始链路。
- Wiener/Rosenblueth/Bigelow 把目的性行为与控制反馈统一为可分析框架。
- Shannon 提供噪声与通信容量边界，为控制信号质量设硬约束。
- Bertalanffy/Boulding 把系统层级与开放结构引入跨学科治理语法。
- Ashby 提供必要多样性与适应机制，构成“扰动-控制匹配”不变量基础。
- Conant-Ashby 把“调节器必须持有系统模型”明确为控制充分性条件。
- Parnas/Lamport 把接口边界与事件顺序形式化，提供跨组织契约复核语法。
- MCO 与 2003 停电报告补足“多层时滞与接口契约失配导致级联失效”的公开证据链。

## Cycle 144 同化补强（控制架构切换协议 + 在线学习接管边界）

### 元问题

当系统需要从规则/机理控制切换到在线学习控制时，如何在不突破可生存域的前提下完成接管，避免两类失真：学习器过早接管导致不可逆放大，或接管过晚导致控制性能持续退化。

### 同化判定（L2）

- 场景 A（电网）：集中调度切到区域自治，属于“时滞 + 层级”既有元问题的协议细化。
- 场景 B（自动驾驶）：规则控制切到学习策略或人工接管，属于“接口契约 + 熔断”既有元问题的边界细化。
- 场景 C（金融风控）：规则引擎切到在线策略，属于“过控防护 + 可回滚”既有元问题的分阶段细化。

结论：同化到既有 pattern，不新建。

### 控制架构切换协议（新增）

1. 生存域锚定：先锁定不可突破边界（安全、合规、关键服务可用性、最大可承受损失）。
2. 模式判定：识别稳态/漂移/突变工况，明确规则控制与学习控制的主辅关系。
3. 接管契约登记：定义作用域、时长、撤销条件与回切冷却窗。
4. 影子运行对账：学习器先影子运行，与基线控制器完成反事实对账。
5. 渐进接管：按小流量→分区→全局放大，每级都绑定回滚预算。
6. 失败回退：任一关键闸门失败即降级并冻结在线学习更新。

### 新增验证闸门（G7-G11）

- G7 权限租约闸门：无显式租约（作用域/时长/撤销条件），学习器不得写入执行平面。
- G8 后悔上界闸门：实时后悔或损失斜率越界，立即降级接管并触发回滚。
- G9 漂移隔离闸门：分布漂移超阈且解释失败时，学习器只保留观测权。
- G10 安全探索预算闸门：探索预算耗尽，自动切回稳态控制。
- G11 人类否决时延闸门：人工覆盖命令到执行时延超阈，禁止提升接管比例。

### 新增公开反例库（cycle 144）

1. Uber ATG Tempe 事故（NTSB 2019）：
   - 证据点：对象识别与接管逻辑未在边界内及时触发，关键窗口未执行等效制动冗余。
   - 方法含义：在线策略接管必须绑定“最小风险动作 + 人工否决时延”双闸门。
2. Boeing 737 MAX JATR（FAA 2019）：
   - 证据点：系统级切换条件与接管假设未被完整集成验证。
   - 方法含义：控制架构切换要以系统级契约验证为前置，不得依赖隐含假设。
3. Knight Capital（SEC 2013）：
   - 证据点：上线与失控拦截链失效导致短时大规模错误执行。
   - 方法含义：在线策略接管必须具备独立断路机制与可即时回退路径。

### L5 检索测试（新增）

- 自动驾驶雨夜工况：先过 G9 漂移隔离，再按 G8 后悔上界决定接管比例。
- 交易风控在线接管：先登记 G7 权限租约，若 G8 越界立即回退并冻结参数。
- 云资源调度 RL 接管：按可用区分级推进，每级检查 G10 与 G11，失败即降级。
- 医疗分诊在线学习：高后果标签默认人工终审，未过 G7/G11 不得进入自动处置闭环。

### cycle 144 学派变体（不裁决）

- 机理鲁棒控制优先 vs 端到端在线学习控制优先。
- 确定性最坏情形保证优先 vs 概率风险约束与期望性能优先。
- 双重控制（边控制边辨识）优先 vs 稳态分离原则（先辨识后控制）优先。

## Cycle 145 同化补强（接管失败复盘模板 + 阈值跨行业校准）

### 元问题

当接管已经失败且事件已经发生时，如何在不落入“归责替代治理”的前提下，用同一套复盘语法把事故证据转换为可执行阈值更新，并可跨行业复用。

### 同化判定（L2）

- 场景 A（自动驾驶）：人类否决时延与最小风险动作触发链，属于既有 G7-G11 接管边界的事后验证层。
- 场景 B（电网与交易系统）：回滚窗口与失控拦截链，属于既有 G6/G8 的阈值重标定层。
- 场景 C（医疗 handover）：交接信息缺口导致控制权断裂，属于既有“接口契约”母问题的跨行业映射。

结论：部分覆盖，执行同化，不新建 pattern。

### 接管失败复盘模板（R1-R8）

1. R1 事件冻结与证据封存：时间线、控制输入、告警流、人工接管日志缺一不可。
2. R2 失效分层映射：至少标出主失效层（观测/决策/执行/治理）与次失效层，禁止单点归责。
3. R3 闸门回放：逐条回放 G1-G11，标注“未触发/误触发/触发未执行”，定位首个失守闸门。
4. R4 阈值无量纲化：统一产出 `r_override`、`r_regret`、`r_drift`、`r_rollback` 四个比值。
5. R5 跨行业校准：把行业阈值映射为 T0/T1/T2/T3 风险带，并记录行业特例与不可迁移假设。
6. R6 动作绑定：每一风险带必须绑定唯一动作集（冻结/降级/限流/回滚/人工接管）。
7. R7 影子复演：修正后先在影子环境复演，未通过不得恢复接管比例。
8. R8 发布追踪：结论、阈值更新、责任归属、复验日期四项齐备后方可关单。

### 跨行业阈值校准样本（cycle 145）

1. Columbia CAIB（2003）：
   - 证据点：技术失效与组织决策链耦合，复盘必须分层而非单因归责。
   - 方法含义：R2/R8 要把治理层变量显式并入阈值更新记录。
2. AF447 BEA 最终报告（2012）：
   - 证据点：自动化脱离后的人机状态感知断裂，手动接管窗口被压缩。
   - 方法含义：`r_override` 应作为接管安全边界的一等指标，而非附属观测项。
3. ICAO Annex 13（2024）+ NTSB Investigative Process：
   - 证据点：事故调查以预防复发为目标，流程必须保证证据链完整与可复核。
   - 方法含义：R1-R8 采用“事实-分析-建议-跟踪”闭环，抑制事后叙事漂移。
4. MIL-STD-882E（2012）：
   - 证据点：风险接受与审批权限分层明确，可映射风险带到治理动作。
   - 方法含义：R5/R6 需要把阈值和审批权限绑定，避免“有阈值无执行权”。
5. WHO handover（2007）：
   - 证据点：交接最小信息集缺失会导致控制权中断与错误放大。
   - 方法含义：把医疗交接语法映射为接口契约检查清单，可迁移到高风险自动化系统。

### Cycle 145 检索场景（L5）

- 自动驾驶接管事故后，如何计算 `r_override` 来决定接管比例恢复节奏。
- 电网跨区失稳后，如何用 `r_rollback` 校准回退窗口并绑定强制动作。
- 交易系统误交易后，如何把风控阈值映射到统一风险带并触发审批链。
- 医疗分诊模型误判后，如何用最小交接信息集重建人工终审边界。

### cycle 145 学派变体（不裁决）

- 跨行业统一阈值优先 vs 行业特异阈值优先。
- 事故后立即收紧阈值优先 vs 先保业务连续再渐进收紧。
- 因果可解释复盘优先 vs 统计预测有效复盘优先。

## Cycle 148 同化补强（核电/SRE 长时序校准 + 复盘自动化指标）

### 元问题

当系统已经具备接管失败复盘机制后，如何把“复盘结论”稳定转化为“可执行阈值更新”，并在核电与 SRE 这类高后果、长时序系统中维持可比较性，避免“每次复盘都重新定义标准”。

### 同化判定（L2）

- 场景 A（核电）：保护定值与监管阈值跨周期校准，属于既有“增益-时滞-层级约束”母问题的长时序扩展。
- 场景 B（SRE）：告警风暴后的自动化动作比例调整，属于既有“过控防护 + 回滚预算”母问题的执行细化。
- 场景 C（跨域复盘）：核电与 SRE 的事件分级、交接质量、回放一致性映射，属于既有“接口契约 + 复盘闸门”统一语法扩展。

结论：部分覆盖，执行同化，不新建 pattern。

### 新增公开长时序样本（cycle 148）

1. IAEA PRIS（since 1970）+ NRC PI/Action Matrix（2000 起）：
   - 证据点：核电领域存在长期公开、可审计、可横向对照的事件与性能指标链。
   - 方法含义：阈值更新必须绑定“跨窗口一致性”，不能用单窗口偶然改善替代长期校准。
2. NRC NEI 99-02 Rev.8（2025）+ NUREG-1022 Rev3 Sup2（2024）：
   - 证据点：核电事件上报、PI 计算与监管分级有明确制度语法。
   - 方法含义：复盘自动化应优先对齐制度定义，避免“指标同名异义”导致校准漂移。
3. Google SRE Book/Workbook（2017/2018）+ Dapper（2010）：
   - 证据点：SRE 领域给出 SLO、error budget、事故追踪与回放数据化实践。
   - 方法含义：自动化复盘指标必须绑定观测基础设施与触发预算，否则无法形成闭环治理。
4. STAMP（Leveson）：
   - 证据点：事故分析可被统一建模为约束控制失效，而不止是部件故障。
   - 方法含义：核电与 SRE 可共享“约束失守 -> 闸门失守 -> 动作映射”框架。

### 新增验证闸门（G12-G15）

- G12 长时序漂移一致性闸门：新阈值至少在两个独立长窗口同向有效；若方向反转，禁止上线自动控制增强。
- G13 误触发/漏触发双预算闸门：误触发预算与漏触发预算必须同时满足，否则仅保留观测权。
- G14 复盘可重演闸门：同一事件在标准回放管线下必须得到一致的“首个失守闸门 + 动作建议”；不一致则冻结参数更新。
- G15 跨层时延闭合闸门：检测、决策、执行、人工覆盖时延总和不得超过级联窗口阈值；超阈值先降级再调参。

### 新增自动化复盘指标

- `r_false_trip`：误触发率 = 非必要触发次数 / 总触发次数。
- `r_missed_trip`：漏触发率 = 应触发未触发次数 / 应触发机会次数。
- `r_delay_to_window`：时延比 = p95(检测+决策+执行+覆盖时延) / 级联窗口。
- `r_handoff_loss`：交接信息缺损率 = 缺失关键字段数 / 应有关键字段数。
- `r_replay_divergence`：回放分歧率 = 同事件多次回放结论不一致次数 / 回放总次数。

### Cycle 148 检索场景（L5）

- 核电大修后重启：是否允许提升控制增益，还是先通过 G12/G13/G15 再放量。
- SRE 告警风暴后调参：是否提高自动化动作比例，还是先压低阈值并冻结高风险动作。
- 跨域同类误触发事件：应优先归因为阈值问题，还是交接断裂/回放分歧问题。

### cycle 148 学派变体（不裁决）

- 保守安全壳优先（核电防御纵深） vs 误差预算驱动迭代优先（SRE）。
- 机理可证明控制优先 vs 数据驱动在线校准优先。
- 集中审批分层治理优先 vs 一线值班自治与快速回滚优先。
