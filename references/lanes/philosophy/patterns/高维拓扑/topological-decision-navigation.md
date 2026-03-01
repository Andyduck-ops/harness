---
name: topological-decision-navigation
topic: 高维拓扑
evidence_band: medium-high
verified_count: 8
sources:
  - John Milnor, Morse Theory (1963)
  - Stephen Smale, Differentiable Dynamical Systems (1967)
  - Rene Thom, Stabilite structurelle et morphogenese (1972)
  - Victor Guillemin, Alan Pollack, Differential Topology (1974)
  - Charles Conley, Isolated Invariant Sets and the Morse Index (1978)
  - Robert Ghrist, Barcodes: The Persistent Topology of Data (2008)
  - Gunnar Carlsson, Topology and Data (2009)
  - Herbert Edelsbrunner, John Harer, Computational Topology (2010)
last_verified: 2026-03-01
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

## 原始证据链摘要

- Milnor/Conley/Smale/Thom 给出“临界点-不变集-结构稳定-突变边界”框架。
- Ghrist/Carlsson/Edelsbrunner-Harer 给出“持久结构优先于瞬时噪声”的可计算路径。

