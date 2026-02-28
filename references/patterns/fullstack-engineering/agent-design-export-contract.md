---
name: agent-design-export-contract
topic: fullstack-engineering
confidence: 0.78
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (2026-03-01)
  - Hacker News top/show/new snapshots (https://news.ycombinator.com/news, https://news.ycombinator.com/show, https://news.ycombinator.com/newest)
  - HN Top: AI apps have hidden cognitive debt (https://news.ycombinator.com/item?id=45216790)
  - HN Show: Mowgli, Figma for the agent era, with design export (https://news.ycombinator.com/item?id=45217620)
  - HN New: How to Build a VSDD Workflow for Reliable AI Coding and Product Delivery (https://news.ycombinator.com/item?id=45218721)
  - Design Tokens Community Group Format Module (https://www.designtokens.org/tr/drafts/format/)
  - Storybook Docs: UI Testing (https://storybook.js.org/docs/testing/ui-testing)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-03-01
rank: 3
---

## 元问题

设计系统在 AI 时代的新瓶颈不是“没有组件”，而是**设计到执行之间没有机器可验证的交接契约**。

结果是：Agent 能快速产出页面，但每天都在重复返工同一类问题（token 漂移、交互不一致、可访问性漏检）。

## 核心解法

建立 **Agent Design Export Contract Gate（ADEC）**，把“设计稿”升级成“可执行交接包 + 必过闸门”：

1. **设计导出契约化**
   - 固定导出 `token_schema + component_contract + interaction_matrix + acceptance_checks`。
   - 严禁把截图或自然语言描述当唯一输入。
2. **Storybook 测试前置**
   - 在组件层执行 interaction/a11y/visual 测试，并在 CI 中运行。
   - 页面层只允许装配，不新增局部视觉规则。
3. **Required Checks 上锁**
   - 将 `design-contract-gate` 设为分支 required check，未通过不可合并。
4. **Token Drift Lint**
   - 校验 token 语义层与组件 props 映射，发现 drift 直接 fail。

## 最小交接包

| 字段 | 作用 |
|------|------|
| `lineage_id` | 贯穿 Issue/PR/Artifact 的审计主键 |
| `token_schema` | 设计 token 结构与版本 |
| `component_contract` | 组件 API 与状态契约 |
| `interaction_matrix` | 关键交互场景矩阵 |
| `a11y_requirements` | 可访问性基线 |
| `visual_baseline_ref` | 视觉基线快照引用 |
| `required_checks` | 必过闸门清单 |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到 HN Popular Blogs OPML，说明长期信号池稳定可复用。
2. HN top 对“AI 应用隐藏认知债务”的讨论强化了“快速生成 != 可维护交付”这一风险。
3. HN show 的 Mowgli（面向 agent 时代的设计导出）直接说明“设计可导出契约”已成为一线实践痛点。
4. HN new 的 VSDD 工作流强调“规范先行 + 自动验证”的路径，与交接契约化一致。
5. Design Tokens 规范明确目标是让设计决策可被工具与代码系统一致消费，支持机器可验证输入。
6. Storybook 官方文档给出 interaction、accessibility、visual tests 与 CI 路径，具备工程落地条件。
7. GitHub protected branches 的 required checks 提供“闸门不可绕过”的官方执行面。

## 反模式

- 仅给 Agent 一句“做得好看一点”，不提供结构化交接包。
- token 存在但无版本与 drift 校验，组件逐步偏离。
- Storybook 只做展示，不做 CI 闸门。
- 视觉/可访问性检查只在发布前人工补验。
