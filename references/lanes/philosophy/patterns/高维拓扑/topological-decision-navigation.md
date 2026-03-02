---
name: topological-decision-navigation
topic: 高维拓扑
evidence_band: medium-high
verified_count: 18
sources:
  - John Milnor, Morse Theory (1963)
  - Stephen Smale, Differentiable Dynamical Systems (1967)
  - Rene Thom, Stabilite structurelle et morphogenese (1972)
  - Victor Guillemin, Alan Pollack, Differential Topology (1974)
  - Charles Conley, Isolated Invariant Sets and the Morse Index (1978)
  - David Cohen-Steiner, Herbert Edelsbrunner, John Harer, Stability of Persistence Diagrams (2007)
  - Robert Ghrist, Barcodes: The Persistent Topology of Data (2008)
  - Gunnar Carlsson, Topology and Data (2009)
  - Herbert Edelsbrunner, John Harer, Computational Topology (2010)
  - W3C PROV Working Group, PROV-DM: The PROV Data Model (2013)
  - W3C Distributed Tracing Working Group, Trace Context (2021)
  - Google ClusterData 2011 Trace (2011)
  - Alibaba Cluster Trace Program (2018)
  - U.S.-Canada Power System Outage Task Force, Final Report on the August 14, 2003 Blackout in the United States and Canada (2004)
  - Bureau of Transportation Statistics, On-Time Reporting Directive (Number 14 Time Reporting) (2009)
  - U.S. Government Accountability Office, Airline Competition: Effects of Airline Practices and Airport Market Concentration on Fares and Marketing Delay (RCED-90-154) (1990)
  - European Commission, Commission Implementing Regulation (EU) 2024/2835 (2024)
  - Joint Authorities Technical Review, Boeing 737 MAX Flight Control System Report (2019)
last_verified: 2026-03-02
rank: 2
---

## 元问题

在高不确定、强约束、目标冲突的决策中，单一“最优点”思路常失效。更稳健的对象不是某个点，而是可行路径族的拓扑结构。

## 核心机制

把决策空间视作高维流形，把效用/代价视作地形函数。先识别拓扑不变量（连通分量、洞、瓶颈、分岔边界、持久结构），再在可行分量内做局部优化。

## 决策步骤

1. 建模状态坐标：资源、风险、时间、约束。
2. 构造可行域并进行拓扑分解：连通性、瓶颈、不可达区。
3. 标注路径族：稳态路径、跃迁路径、回退路径。
4. 设定分量切换准则：何时保持当前分量，何时跨分量跳转。
5. 在选定路径族内进行局部优化，而非一次性全局最优。
6. 运行中监测“地形变形”（约束变化）并重导航。

## 触发信号

- 局部最优反复打转，且全局收益长期无改善。
- 同一方案在不同上下文下结论相反。
- 目标函数和约束频繁漂移，单次最优策略不可复用。
- 关键拓扑信号只能在单环境重现，跨环境复核失败。

## 边界失效

- 维度定义错误，导致拓扑对象失真。
- 关键约束不可观测，无法构造可信可行域。
- 系统变化速度高于建模刷新速度。
- 样本过少时持久结构不稳定，易误判为噪声。

## 学派变体（不裁决）

- 期望效用单峰最优化：追求唯一最优点。
- 拓扑多路径导航：接受等价路径族并以稳健性优先。

## L5 检索测试

以下决策场景可直接检索本模式：

- 转型路径选择：渐进迁移还是跨代迁移。
- 多目标冲突：增长、利润、风险无法同时最优。
- 高切换成本系统：平台迁移、组织重构、供应链再布局。
- 生产复盘复验：拓扑信号是结构变化还是偶然噪声。

## 公开生产数据复现链路闸门（cycle 142 同化）

### 最小复验产物

- `public_data_manifest.json`: 公共数据源、采样窗口、脱敏说明。
- `pipeline_digest.json`: 代码版本、参数快照、依赖摘要。
- `topology_signature.json`: Betti 向量、bottleneck distance、关键分量图。
- `decision_replay_report.json`: 复演后的路径排序与风险指标。
- `replication_gate_report.json`: 各闸门通过/失败原因。

### 闸门阈值

1. G0 数据公开复验闸门：独立公开源 >=2，时间窗覆盖 >=70%，关键字段缺失 <=5%，脱敏违规=0。
2. G1 流程复演闸门：独立复跑 >=2，复跑成功率 >=90%，版本与参数锁定一致率=100%。
3. G2 拓扑一致性闸门：主维度 Betti 差异 <=1，归一化 bottleneck distance <=0.15，B=20 重采样持久特征保留率 >=85%。
4. G3 决策迁移闸门：路径排序 Kendall tau >=0.70，Top-3 路径重合 >=2，关键风险指标方向一致率 >=80%。
5. G4 漂移冻结闸门：连续 3 窗口中 2 次 G2/G3 失败，或连续 2 窗口 bottleneck distance >0.25，则冻结结构更新并强制重建复验链路。

## 原始命题映射卡（工程决策）

### 卡片 1：Milnor 临界值跃迁

- 原始命题：子水平集拓扑只在临界值处改变。
- 决策动作：把代价函数跨临界值作为强制切换点（回滚、重选工作点、停止自动扩容）。
- 可执行判据：Betti 数跳变与参数跨阈值同时出现且持续 3 个窗口，30 分钟内目标分量停留占比 >=80%。

### 卡片 2：Smale 双曲稳定

- 原始命题：双曲不变集在小扰动下保持定性结构稳定。
- 决策动作：接近非双曲边界时优先降阶运行、减载或解耦，而非继续推高吞吐。
- 可执行判据：局部谱半径 rho >=0.95 持续 3 个窗口即触发动作，执行后恢复时间 P95 下降 >=20%。

### 卡片 3：Conley 指数延拓不变

- 原始命题：孤立不变集的 Conley index 在 continuation 下保持不变。
- 决策动作：指数变化时触发强动作（熔断、回滚、隔离租户）。
- 可执行判据：跨版本 index 变化且故障复现率上升 >=15%，自动执行回滚并标记拓扑触发事件。

### 卡片 4：持久同调稳定性

- 原始命题：persistence diagram 对小扰动稳定，长条更可能是结构而非噪声。
- 决策动作：只对持久度高于阈值 tau 的特征触发结构性动作。
- 可执行判据：B=20 次重采样中保留率 >=85% 才允许扩容/路由改写，否则仅告警。

### 卡片 5：PROV + Trace Context 证据链

- 原始命题：若无法复原实体-活动-主体关系与跨服务调用链，拓扑判断不可复验。
- 决策动作：将拓扑触发动作绑定到可审计证据图（trace id + 溯源关系），无证据链则降级为观察信号。
- 可执行判据：拓扑触发事件需满足 trace 覆盖率 >=95%，且关键节点均可回溯到来源数据与处理步骤。

## Cycle 166 同化补强（跨行业异常反例库 + 阈值漂移样本）

本轮继续同化，不新建 pattern。目标是把“跨环境复核失败”从单事件判断推进到跨行业可对照、跨窗口可追踪的漂移治理。

### 同化判定（L2 三场景）

1. 电网调度与故障隔离：局部拥塞是否演化为连通分量断裂，决定局部重配还是跨分量切换。  
2. 云服务/微服务发布：少量异常 trace 是否代表结构路径漂移，决定继续灰度还是立即回滚。  
3. 供应链重路由：单节点异常是否触发全局路径族坍缩，决定临时绕行还是冻结扩容并重标定阈值。  

结论：部分覆盖，执行同化到 `topological-decision-navigation`。

### 跨行业异常反例库（最小字段）

- `case_id`: 反例编号  
- `industry`: 行业标签（power/aviation/platform-governance/supply-chain/...）  
- `window`: 观测窗口  
- `topology_signature_before`: 变更前拓扑签名（Betti/关键分量）  
- `topology_signature_after`: 变更后拓扑签名  
- `anomaly_trigger`: 异常触发条件与阈值  
- `drift_direction`: 阈值漂移方向（放宽/收紧/测量偏移）  
- `action_taken`: 执行动作（降级/隔离/回滚/冻结）  
- `rollback_outcome`: 回退结果与恢复时长  
- `false_trigger_flag`: 误报/漏报标签  

### 原始样本锚点（跨行业）

1. **电网（工业控制）**：2003 北美大停电最终报告，给出热极限、树线接触与告警链路失效的联动阈值样本。  
2. **航空运行口径（交通网络）**：BTS 准点定义（计划到达 +15 分钟）与 GAO 对“计划时间漂移”导致口径偏移的原始审计样本。  
3. **平台治理（公共数字基础设施）**：EU 2024/2835 透明度模板中 Precision/Recall 与撤销计数字段，作为误报/漏报与制度回滚的公开样本。  
4. **航空自动化控制**：JATR 737 MAX 报告中错误 AOA 与 MCAS 触发链，作为“测量偏移导致触发阈值前移”的高后果反例。  

### 阈值漂移闸门（G5-G8）

- G5 异常优先闸门：出现高后果异常且拓扑签名突变时，先冻结结构动作并转人工复核。  
- G6 漂移确认闸门：连续窗口出现拓扑距离与路径排序劣化，才允许进入阈值重标定。  
- G7 跨行业迁移闸门：同类异常在至少两个行业复现且动作方向一致，才允许上升为通用阈值规则。  
- G8 回退闸门：重标定后若两窗口内误触发率上升且收益不达标，强制回退到上版阈值。  

### 可证伪条件（F6-F8）

- F6：高后果异常触发后若未观察到拓扑签名突变，则“异常优先冻结”降级为候选规则。  
- F7：漂移确认通过但动作收益不优于基线，则“漂移驱动重标定”不成立。  
- F8：跨行业样本显示统一阈值持续反向失效，则统一阈值假设失效。  

## 原始证据链摘要

- Milnor/Conley/Smale/Thom 给出“临界点-不变集-结构稳定-突变边界”框架。
- Cohen-Steiner/Edelsbrunner/Harer/Ghrist/Carlsson 给出“持久结构优先于瞬时噪声”的可计算路径。
- PROV-DM/Trace Context/公开集群 trace 给出“生产数据可复验链路”的跨系统表达与复演基础。
