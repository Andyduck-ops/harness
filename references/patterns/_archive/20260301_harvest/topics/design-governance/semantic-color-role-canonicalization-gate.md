---
name: semantic-color-role-canonicalization-gate
topic: design-governance
confidence: 0.78
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T22:07:41Z)
  - Hacker News API topstories item 43387092 (sampled 2026-02-28, title: "Npm package with all possible semver combinations")
  - Hacker News API showstories item 43385853 (sampled 2026-02-28, title: "Show HN: Browser AI Agent to automate your browser with Gemini")
  - Hacker News API newstories item 43386402 (sampled 2026-02-28, title: "Thinking deeply about Theming and Color Naming")
  - Design Tokens Community Group Format Module (https://www.designtokens.org/tr/drafts/format/)
  - Storybook Docs: Test your components (https://storybook.js.org/docs/writing-tests)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Controlling permissions for GITHUB_TOKEN (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)
last_verified: 2026-02-28
rank: 3
---

## 元问题

无人值守前端迭代里，Agent 很容易把颜色命名写成“视觉值导向”（`blue-500`、`gray-900`），
而不是“语义角色导向”（`surface-primary`、`text-muted`）。

结果是：

1. 主题切换时 alias 链局部漂移，组件视觉通过但语义失真；
2. 颜色值改动被当成普通样式 diff，无法触发晋级阻断；
3. 设计系统在多 agent 并发改动下出现“同名不同义”与“同义不同名”。

本质问题：**缺少“语义角色规范化 + alias 可回放 + required checks”一体化门禁。**

## 核心解法

建立 **Semantic Color Role Canonicalization Gate（SCRCG）**：

1. **角色先于色值**
   - 先定义 `role_catalog`（surface/text/border/interactive/signal），再映射到具体 token。
   - 禁止在组件层直接引用品牌色 token（只能引用语义角色 token）。
2. **alias 拓扑可验证**
   - 设计 token 引用必须可解析为无环 DAG；出现循环或悬空引用直接 fail。
   - 每次变更输出 `token_alias_graph.json`，用于晋级回放。
3. **主题回放矩阵**
   - Storybook 里强制跑 light/dark/high-contrast 三套快照与 a11y 检查。
   - 只要任一主题失败，`theme_replay_pass=false`，禁止 merge。
4. **晋级硬门禁**
   - required checks 至少包含：
     - `token_role_canonicalization_pass`
     - `theme_replay_pass`
     - `a11y_contrast_pass`
5. **最小权限提交**
   - 自动化工作流只授予完成 token 校验所需权限，避免高权限 bot 直接绕过门禁。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `tokens/role-catalog.json` | `role_id`, `semantic_intent`, `allowed_aliases` | 缺 `semantic_intent` 或 alias 越权即 fail |
| `artifacts/token_alias_graph.json` | `node_id`, `ref`, `resolved_to`, `cycle_detected` | `cycle_detected=true` 直接 quarantine |
| `artifacts/theme_replay_matrix.json` | `theme`, `story_id`, `visual_pass`, `a11y_pass` | 任一 `visual_pass/a11y_pass=false` 禁止晋级 |
| `promotion_packet.json` | `token_role_canonicalization_pass`, `theme_replay_pass`, `a11y_contrast_pass`, `blocked_reason` | 任一门禁失败即冻结 PR 晋级 |

## 证据链

1. `t.co/dwAiIjlXet` 持续重定向到 HN Popular Blogs OPML，说明可用作稳定长周期信号入口。
2. HN `newstories` 直接出现 `Thinking deeply about Theming and Color Naming`，说明语义色名已是当下高价值痛点。
3. Design Tokens 规范明确 token 之间可以通过引用建立关系，适合做 alias 图回放与漂移检测。
4. Storybook 官方将测试能力（交互、视觉、可访问性）作为组件质量基线，可承载主题矩阵门禁。
5. GitHub protected branches 的 required status checks 机制可把 `token_role_canonicalization_pass` 变成不可绕过的合并条件。
6. GitHub `GITHUB_TOKEN` 权限可在 workflow 级显式收敛，避免自动化对门禁策略进行高权限旁路。
7. HN API `topstories/showstories/newstories` 三车道可持续提供主题命名与组件工程实践的增量证据。

## 反模式

- 在组件内硬编码品牌色值，绕过语义角色层。
- 只跑默认主题快照，不跑多主题对照。
- token lint 只检查格式，不检查 alias 拓扑与语义映射。
- required checks 缺少 token 语义门禁，导致“视觉能过、语义失真”仍可合并。
