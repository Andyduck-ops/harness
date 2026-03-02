---
name: principal-secondary-contradiction-switch-boundary
topic: 矛盾论
evidence_band: medium-high
verified_count: 24
sources:
  - Mao Zedong, On Contradiction (1937)
  - Vladimir I. Lenin, Philosophical Notebooks (1914-1916)
  - G. W. F. Hegel, Science of Logic (1812-1816)
  - Karl Marx, Capital Vol. 1 (1867)
  - Karl Marx, Grundrisse (1857-1858)
  - Friedrich Engels, Anti-Duhring (1878)
  - Friedrich Engels, Dialectics of Nature (1873-1886)
  - Louis Althusser, Contradiction and Overdetermination (1962)
  - Immanuel Kant, Critique of Pure Reason (1781/1787)
  - Aristotle, Metaphysics (Book Gamma, c.4th century BCE)
  - Carl von Clausewitz, On War (1832)
  - Taiichi Ohno, Toyota Production System (1978)
  - Eliyahu M. Goldratt, The Goal (1984)
  - Rogers Commission Report (1986)
  - Columbia Accident Investigation Board Report (2003)
  - U.S. Bureau of Transportation Statistics, Airline On-Time Data (1987-)
  - FRED, Capacity Utilization: Manufacturing (1967-)
  - U.S. EIA, Electric Power Monthly (1973-)
  - U.S. Supreme Court, NYSRPA v. Bruen (2022)
  - CJEU, Schrems II Judgment (2020)
  - European Commission, Decision (EU) 2016/1250 (2016)
  - CJEU, Press Release No 117/15 (Schrems I, 2015)
  - European Commission, Decision 2000/520/EC (2000)
  - WTO Panel Report, EC - Hormones WT/DS26/R/USA (1997)
last_verified: 2026-03-02
rank: 1
---

## 元问题

在多矛盾并存的系统中，如何判定“主要矛盾/次要矛盾”何时发生切换，并据此重排目标函数、资源分配与行动顺序。

## 核心机制

把矛盾视为可排序的约束簇，而非固定标签。

- 主要矛盾：在当前目标与时间窗内，对系统成败贡献最大的约束簇。
- 次要矛盾：重要但暂不构成第一约束的矛盾簇。

主次关系不是静态分类，而是随条件变化的动态排序。切换的关键不是“争论哪条矛盾更重要”，而是识别是否出现了排序反转。

## 决策步骤

1. 固定目标函数与时间窗：先写清“这一轮优化什么、多久见效”。
2. 列出矛盾簇：每条矛盾写成“对象A vs 对象B + 影响链路 + 可观测指标”。
3. 当前排序：按“边际影响 x 传播速度 x 不可逆风险”给出主次序。
4. 持续观测：监控是否出现排序反转、收益衰减、耦合扩散。
5. 触发切换：满足阈值则切换主矛盾，并重排资源和动作序列。
6. 回切保护：若新主矛盾治理后未抬升总目标，执行回切与模型修正。

## 触发信号（建议阈值）

- 排序反转：次要矛盾综合分连续 3 个观测窗口高于当前主要矛盾。
- 收益衰减：继续投入主要矛盾的边际收益降到次要矛盾治理收益的 40% 以下。
- 不可逆风险抬升：次要矛盾触发跨阈值风险（合规/信誉/生命线资产），恢复成本陡增。
- 耦合扩散：次要矛盾向多个子系统扩散，形成系统级连锁失真。

## 执行闸门（cycle 164-165 同化）

- G0 目标锁定闸门：先冻结目标函数与观测时间窗 N 个窗口，避免“目标漂移”导致假切换。
- G1 双链证据闸门：切换信号至少来自两条独立链路（领先指标 + 滞后指标）且同向。
- G2 伪切换排除闸门：先做同根因迁移排查，防止把同一根因的表征漂移误判为主次反转。
- G3 总目标抬升闸门：切换后若总目标在约定窗口内未抬升，触发强制回切与模型修正。
- G4 程序同构闸门：跨法域阈值迁移前，必须先通过 `procedure_alignment_band` 与 `remedy_equivalence_score` 最小门槛，否则仅允许影子运行。
- G5 三账一致闸门：效率账、伤害账、救济账三账必须同向支持切换；任一反向即冻结主次切换。
- G6 反事实回切闸门：切换后以“未切换基线”做反事实对照，若总目标未抬升或误切换率恶化，强制回切并修模。

## 边界失效

- 目标漂移：目标函数未锁定，导致“今天增长、明天稳定”反复切换。
- 指标滞后：只看滞后指标，把短期噪声误判为主次切换。
- 伪切换：同一根因在不同表征间迁移，但被误判为新主矛盾。
- 权力捕获：资源按组织地位分配，而非按约束强度分配。
- 稳态幻觉：把阶段性稳定当长期稳定，错过结构性相变窗口。
- Goodhart 假反转：指标被策略性优化后显示“次要矛盾上升”，但真实系统风险未变。
- 冲击型误切换：外生短冲击拉高单窗口异常，触发过早切换，回切率持续攀升。
- 过度决定误归因：多因耦合场景强行单因归因，导致治理动作与真实主导约束错位。
- 形式合规-实质失配：法域 A 的阈值直接迁移到法域 B，表面合规但救济链路不等价，导致主矛盾误切换。
- 申诉可上达-救济不可达：有申诉入口但复核层级/时限不闭合，长期把效率矛盾转化为正当性矛盾。
- 时间锚点错配假反转：`decision_time` 与 `disclosure_time` 混用导致伪反转，触发错误切换与高回切率。

## Cycle 165 同化补强（跨法域阈值迁移失败反例库）

- 新增反例轴：比例衡量阈值迁移失败（Bruen）、数据充分性阈值迁移失败（Schrems I/II + Safe Harbor/Privacy Shield）、风险治理阈值迁移失败（WTO Hormones）。
- 同化判定：部分覆盖，保留母 pattern，不新建子 pattern。
- 决策约束：跨法域迁移中，若程序同构与救济等价任一不满足，默认不切换主矛盾。

## 学派变体（不裁决）

- 单矛盾主导：强调主要矛盾可被局部清晰定位。
- 过度决定：强调主要矛盾总被多重矛盾结构性共同决定。
- 形式逻辑护栏：强调先维持命题一致性，再谈矛盾转化。
- 辩证切换：强调命题冲突背后是条件与结构变化，不可静态处理。

## L5 检索测试

以下决策场景可直接检索本模式：

- 扩产 vs 质量：订单暴涨时，何时从“产能不足”切换为“质量失稳”主导。
- 增长 vs 合规：获客效率与监管风险冲突时，何时从增长优先切换到生存合规优先。
- 降本 vs 保供：供应链成本优化与交付确定性冲突时，何时切换为韧性优先。
- 迁移 vs 正当性：把法域 A 有效阈值迁移到法域 B 时，何时判断主矛盾已从效率不足转为程序/救济失配。

## 与既有模式边界

- 与 `实践论/praxis-feedback-loop-governance` 的边界：
  - 实践论回答“如何双回路纠偏”。
  - 本模式回答“纠偏前先判定哪条矛盾是主导对象”。

- 与 `高维拓扑/topological-decision-navigation` 的边界：
  - 高维拓扑回答“在既定目标权重下如何选稳健路径”。
  - 本模式回答“目标权重何时必须改写（主次切换）”。

## 原始证据链摘要

- Mao/Lenin/Hegel 提供“矛盾推动运动、主次可转化”的核心方法框架。
- Marx/Engels 提供“结构性矛盾与阶段切换”的历史-经济学展开。
- Althusser 补充“过度决定”视角，约束单因果切换叙事。
- Kant/Aristotle 提供形式逻辑边界，防止把语义冲突误作结构矛盾。
- Clausewitz 提供“主努力方向切换”的战争论原型，补足高压约束下的优先级重排语法。
- Ohno/Goldratt 提供制造系统中的瓶颈迁移原始框架，对应“主次约束排序反转”可执行证据。
- Rogers/CAIB 报告提供航天高后果场景下“进度-安全主次切换”失败反例链。
- BTS/FRED/EIA 长时序数据提供跨行业（航空/制造/能源）公开观测基线，支持阈值漂移复验。
- Bruen/Schrems I-II/Safe Harbor/Privacy Shield/WTO Hormones 提供跨法域阈值迁移失败反例链，约束“阈值可移植=主次可切换”的错误假设。
