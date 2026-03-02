---
name: selection-pressure-strategy-drift-adaptation-gates
topic: 演化与适应
evidence_band: medium-high
verified_count: 23
sources:
  - Charles Darwin, On the Origin of Species (1859)
  - Charles Darwin; Alfred Russel Wallace, On the Tendency of Species to form Varieties... (1858)
  - Ronald A. Fisher, The Genetical Theory of Natural Selection (1930)
  - Sewall Wright, Evolution in Mendelian Populations (1931)
  - J. B. S. Haldane, The Causes of Evolution (1932)
  - Theodosius Dobzhansky, Genetics and the Origin of Species (1937)
  - W. D. Hamilton, The genetical evolution of social behaviour. I (1964)
  - Motoo Kimura, Evolutionary Rate at the Molecular Level (1968)
  - Stephen Jay Gould; Richard C. Lewontin, The spandrels of San Marco... (1979)
  - John H. Holland, Hidden Order (1995)
  - George R. Price, Selection and Covariance (1970)
  - Richard E. Lenski et al., Long-Term Experimental Evolution in E. coli I (1991)
  - Richard Lenski, LTEE Project Archive (ongoing)
  - John A. Endler, Natural Selection in the Wild (1986)
  - C. S. Holling, Resilience and Stability of Ecological Systems (1973)
  - Michael T. Hannan; John Freeman, The Population Ecology of Organizations (1977)
  - James G. March, Exploration and Exploitation in Organizational Learning (1991)
  - Jens Rasmussen, Risk Management in a Dynamic Society (1997)
  - United Nations, Vienna Convention on the Law of Treaties (1969)
  - Court of Justice of the European Union, C-311/18 Schrems II (2020)
  - European Commission, Implementing Decision (EU) 2021/914 (2021)
  - Federal Aviation Administration, Boeing 737 MAX Return to Service (2020)
  - European Union Aviation Safety Agency, AD 2021-0039 (2021)
last_verified: 2026-03-02
rank: 10
---

## 元问题

在环境约束持续变化、目标函数可能漂移的系统中，如何以最小不可逆代价保持长期适配，而不是陷入“局部成功-全局失配”的迟滞循环。

## 核心机制

把演化治理拆成四层：

1. 选择压力层：识别外部约束变化，并把压力映射为可观测阈值。
2. 变异试探层：在可回滚边界内生成策略变体，避免把单一路径绑定为唯一真解。
3. 筛选更新层：按适配度函数比较变体，淘汰低效规则并保留可迁移机制。
4. 制度记忆层：把有效变体固化为新基线，同时记录失效条件与退场规则。

目标不是永远最优，而是持续可适配。

## 决策步骤

1. 定义不变量：先锁定不可牺牲约束（安全、合规、生存边界）。
2. 量化失配：用趋势与阈值定义“当前策略是否失配”。
3. 选择路径：在微调、模块替换、范式重构三类路径中选一条主路径。
4. 小样本试探：低成本、短周期、可回滚地验证候选变体。
5. 闸门评估：达阈值则扩展部署，未达阈值则撤回并切换变体。
6. 入库复盘：沉淀触发条件、回滚成本与迁移边界，准备下一轮选择压力。

## 验证闸门（Validation Gates）

- G1 压力识别闸门：外部约束变化被稳定观测并通过独立路径复核。
- G2 适配增益闸门：关键指标净改善超过最小有效增量（MEI）。
- G3 可逆性闸门：失败时可在限定窗口恢复到安全基线。
- G4 迁移稳定闸门：在相邻场景复验仍有效，不是偶发命中。
- G5 漂移探测闸门：误判率斜率、阈值触发频率、反馈时滞同时异常才判定为真漂移。
- G6 漂移归因闸门：先区分环境漂移/测量漂移/执行漂移，归因不清禁止改阈值。
- G7 双轨重标定闸门：旧阈值与候选阈值并行影子运行，排序一致性达标后才切换。
- G8 漂移可逆闸门：切换后必须满足窗口内回滚与回滚损失上限，否则冻结扩容。
- G9 解冻放行闸门：连续窗口稳定且高风险反例闭环后，才解除漂移冻结。
- G10 触发等价闸门：跨法域迁移前先映射“同风险触发”的等价条件，等价失败禁止直迁。
- G11 最小回滚窗口闸门：必须显式给出 Tmin/Tmax 与触发证据，窗口不可审计则禁止扩容。
- G12 双法域影子闸门：新旧法域并行观测至少一个完整业务周期，未达一致性不切主。
- G13 救济可达闸门：迁移后申诉/纠偏路径在目标法域可达且时延受控，否则自动降级。
- G14 逆迁移封顶闸门：回滚累计损失、二次伤害和监管风险超过上限时，停止反复切换并触发重构。

## Cycle 161 同化补强（选择压力阈值漂移）

本轮不新建 pattern，沿 L2 同化到现有母模式，补齐“长期阈值漂移 + 反例库 + 解冻条件”。

### 决策步骤（增量）

1. 漂移初筛：先过 G5，排除单点噪声触发。
2. 归因拆分：按 G6 拆分环境/测量/执行漂移，避免错因修复。
3. 双轨重标定：按 G7 并行运行旧阈值与候选阈值，观测排序稳定性。
4. 小流量切换：只在可回滚窗口内做受控切换，强制执行 G8。
5. 冻结与解冻：若高后果风险上升则冻结扩容；仅在 G9 达标后解冻。
6. 入库复盘：记录漂移类型、误判代价、回滚时序、迁移边界。

## Cycle 162 同化补强（跨法域迁移回滚窗口标定）

本轮继续同化，不新建 pattern，补齐“跨法域迁移时回滚窗口如何标定”的可执行语法与反例边界。

### 决策步骤（增量）

1. 触发等价映射：先过 G10，把源法域触发条件映射成目标法域可审计条件。
2. 窗口定标：按 G11 给出回滚窗口 `Tmin/Tmax`、代价上限 `Cmax` 与证据链。
3. 双轨观测：按 G12 在双法域并行影子运行，比较误判率、纠偏时延与救济到达率。
4. 受控切主：仅在一致性达标时切主；否则保持降级运行并回写差异账本。
5. 救济复核：按 G13 验证迁移后救济可达性，未达标立即回滚或冻结扩容。
6. 逆迁移封顶：若达到 G14 条件，停止频繁切换，转入制度重构或架构重分层。

## 触发信号

- 关键指标持续偏离目标，且偏差斜率加速。
- 外部规则或供给结构突变，旧策略解释力快速下降。
- 局部修补频率升高，但全局收益边际递减。
- 决策时滞显著大于环境变化周期。
- 阈值触发密度异常升高或异常衰减，且与风险结果背离。
- 同类场景误判率在多窗口连续上行，修补后仍不回落。
- 同一迁移策略在不同法域出现“合规通过但救济失灵”的结构性背离。
- 回滚窗口在跨法域执行中被反复延长，导致二次伤害累积超过预算。

## 边界失效

- 目标函数频繁重写，导致“适配优劣”无法比较。
- 反馈链断裂或严重滞后，选择压力被错误感知。
- 系统高耦合且不可回滚，试探成本超过生存窗口。
- 组织拒绝淘汰旧规则，制度记忆被历史包袱占满。
- 观测口径漂移未校正时直接改阈值，会把测量误差误判为环境漂移。
- 激励结构惩罚回滚，导致 G8/G9 名存实亡。
- 跨法域触发条件无法建立可审计映射，导致 G10 形同虚设。
- 回滚窗口未制度化且审批链条不透明，导致 G11/G12 无法复核。
- 目标法域救济链路拥塞或不可达，导致 G13 通过但实际纠错失败。

## 学派变体（不裁决）

- 渐进优化优先 vs 断裂跃迁优先。
- 适应主义优先 vs 结构决定论优先。
- 探索优先 vs 利用优先。

## L5 检索测试

以下决策场景可直接检索本模式：

- 市场突变：需求结构在 48 小时内反转时，如何启动“快试探+快回滚”。
- 技术替代：关键技术栈被新范式压制时，何时先做模块替换而非全量重构。
- 合规升级：旧流程失效时，如何先过可逆性闸门再放大迁移。
- 竞争加剧：可靠性阈值年内持续抬升时，如何区分真漂移与指标口径漂移。
- 安全治理：事故率上升但 KPI 达标时，何时冻结吞吐扩容并触发回滚。
- 平台生态：兼容成本指数上升时，何时设定弃旧阈值而不是无限兼容。

## 与既有模式边界

- 与 `决策论/bounded-rationality-ooda-regret-stop-rule` 的边界：
  - 决策论解决“何时停止采样并行动”。
  - 本模式解决“行动展开后如何在策略漂移中持续适配”。

- 与 `实践论/praxis-feedback-loop-governance` 的边界：
  - 实践论强调行动-反馈双回路纠偏。
  - 本模式强调在选择压力变化下的“变异-筛选-固化”演化闭环。

- 与 `复杂性科学与涌现/local-rules-global-pattern-emergence-governance-thresholds` 的边界：
  - 复杂性模式解释局部规则如何涌现宏观行为。
  - 本模式给出策略层“何时换代、何时淘汰”的治理闸门。

## 原始证据链摘要

- Darwin/Wallace 提供自然选择作为适配更新的原始框架。
- Fisher/Wright/Haldane/Dobzhansky 建立群体遗传与适配动力学的可操作语法。
- Hamilton/Kimura/Gould-Lewontin 给出“适配并非单一路径”的关键反例约束。
- Price 将选择变化拆解为可计算协方差项，防止把口径变化误判为压力增强。
- Lenski LTEE 给出跨万代时间窗的长期漂移与分化样本，支持阈值漂移的时序验证。
- Endler/Holling补齐自然系统中的选择强度测量与相变边界，约束线性漂移假设。
- Hannan-Freeman/March/Rasmussen 将阈值漂移落到组织与社会技术系统，补齐跨行业迁移与回滚治理语法。
- Vienna Convention 提供跨法域规则变更与中止的程序骨架，为触发等价映射与回滚合法性定标。
- Schrems II 与 EU 2021/914 给出数据跨境迁移的“先冻结后重标定”原始样本，约束直接迁移冲动。
- FAA/EASA 对 737 MAX 的分阶段复飞路径提供“跨监管域窗口标定 + 双轨验证”反例与可执行模板。
