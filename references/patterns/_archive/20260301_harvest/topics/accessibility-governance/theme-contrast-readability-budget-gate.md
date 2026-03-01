---
name: theme-contrast-readability-budget-gate
topic: accessibility-governance
confidence: 0.77
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/426957f043dc0054f95aae6c19de1d0b4ecc2bb2/hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:13:06Z)
  - Hacker News API topstories item 47197267 (sampled 2026-02-28, title: "Obsidian Sync now has a headless client")
  - Hacker News API showstories item 47195123 (sampled 2026-02-28, title: "Show HN: Now I Get It – Translate scientific papers into interactive webpages")
  - Hacker News API newstories item 47200840 (sampled 2026-02-28, title: "The Bitter Lesson is coming for AI products, not just AI research")
  - W3C WCAG 2.2 Understanding SC 1.4.3 Contrast (Minimum) (https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
  - W3C WCAG 2.2 Understanding SC 1.4.11 Non-text Contrast (https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
  - Storybook Docs: Writing tests / test your components (https://storybook.js.org/docs/writing-tests)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-02-28
rank: 3
---

## 元问题

语义色名规范化通过后，前端仍会在多主题切换时出现“可读性回退”：

1. token 名称语义正确，但主题映射后文本对比度跌破可读阈值；
2. 组件视觉快照通过，但非文本控件边界对比不足，交互可见性下降；
3. 无人值守发布只看 lint/单主题截图，导致“语义正确、可读性失效”仍可晋级。

本质问题：**缺少“文本+非文本对比预算 + 多主题回放 + 分支晋级门禁”的统一治理。**

## 核心解法

建立 **Theme Contrast Readability Budget Gate（TCRBG）**：

1. **双阈值预算模型**
   - 文本对比：按 WCAG SC 1.4.3 设预算阈值（正文与大字号分级）。
   - 非文本对比：按 WCAG SC 1.4.11 设交互组件边界阈值。
2. **主题回放矩阵**
   - 对 light/dark/high-contrast 逐主题执行 Storybook 测试与可访问性检查。
   - 输出 `theme_contrast_matrix.json`，记录每个 story 的文本/非文本预算结果。
3. **晋级硬门禁**
   - 在 protected branch required checks 中并列强制：
     - `text_contrast_budget_pass`
     - `non_text_contrast_budget_pass`
     - `theme_replay_pass`
4. **隔离与回放**
   - 任一主题任一预算失败即 quarantine，不允许从 candidate 晋级到 merge。
   - 将失败快照与阈值差值写入 `promotion_packet.json` 便于回放复盘。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `artifacts/theme_contrast_matrix.json` | `theme`, `story_id`, `text_ratio`, `non_text_ratio`, `threshold`, `pass` | 任一 `pass=false` 直接冻结晋级 |
| `artifacts/theme_replay_manifest.json` | `themes`, `stories_total`, `stories_failed`, `checked_at` | 覆盖主题不完整即 fail |
| `promotion_packet.json` | `text_contrast_budget_pass`, `non_text_contrast_budget_pass`, `theme_replay_pass`, `blocked_reason` | 任一 gate 失败必须 `blocked_reason` 非空 |

## 证据链

1. `t.co/dwAiIjlXet` 仍稳定重定向到 HN Popular Blogs OPML Gist，可持续提供高信噪比发现入口。
2. HN top/show/new 三车道持续有“工程实践 + agent 自动化 +产品化反思”新输入，说明主题可读性问题会在真实交付中持续出现。
3. WCAG 2.2 对文本与非文本对比分别定义可操作标准，适合直接映射为自动化预算门禁。
4. Storybook 官方测试路径可承载多主题回放，是前端“次日可实战”的最低成本落点。
5. GitHub protected branches 的 required status checks 能把可读性预算从“建议”提升为“不可绕过晋级条件”。

## 反模式

- 只在默认主题跑视觉回归，不跑多主题对照。
- 只检查文本颜色，不检查按钮边界/图标等非文本对比。
- 把对比失败降级为 warning，不阻断晋级。
- 仅存截图不存阈值与失败差值，导致复盘不可验证。
