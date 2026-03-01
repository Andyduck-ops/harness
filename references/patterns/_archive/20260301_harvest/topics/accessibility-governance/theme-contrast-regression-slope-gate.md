---
name: theme-contrast-regression-slope-gate
topic: accessibility-governance
confidence: 0.78
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/4292aaea6b37c7c486f8998ea0f12f64bf2ac91d/hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:18:54Z)
  - Hacker News API topstories item 47202466 (sampled 2026-02-28, title: "Obsidian Sync now has a headless client")
  - Hacker News API showstories item 47195123 (sampled 2026-02-28, title: "Show HN: Now I Get It – Translate scientific papers into interactive webpages")
  - Hacker News API newstories item 47203158 (sampled 2026-02-28, title: "Thinking deeply about Theming and Color Naming")
  - W3C WCAG 2.2 Understanding SC 1.4.3 Contrast (Minimum) (https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
  - W3C WCAG 2.2 Understanding SC 1.4.11 Non-text Contrast (https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
  - Storybook Docs: Writing tests (https://storybook.js.org/docs/writing-tests)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/articles/types-of-required-status-checks)
last_verified: 2026-02-28
rank: 3
---

## 元问题

只做 WCAG 绝对阈值门禁会遗漏一个高频失效面：

1. 改版后对比度仍“刚好达标”（例如文本 4.6:1），但相对基线出现大幅回退（例如从 11.8:1 降到 4.6:1）；
2. 单主题检查通过，多主题切换后某些组件在 dark/high-contrast 中出现可见性断崖；
3. 无人值守流程只看 `pass/fail`，看不到“回退斜率”是否已经逼近失效边界。

本质问题：**缺少“绝对阈值 + 相对回退斜率 + 多主题回放”的联合门禁。**

## 核心解法

建立 **Theme Contrast Regression Slope Gate（TCRSG）**：

1. **双层预算**
   - 绝对预算：继续使用 WCAG 文本/非文本阈值。
   - 回退预算：对每个 `theme x story x token_role` 计算 `ratio_drop = baseline_ratio - current_ratio`，并设置 `ratio_drop_max`。
2. **斜率分层**
   - `mild`: `ratio_drop <= 0.8`
   - `moderate`: `0.8 < ratio_drop <= 1.6`
   - `severe`: `ratio_drop > 1.6`
   - `severe` 直接 quarantine，`moderate` 需人工批准且不可自动晋级。
3. **主题矩阵回放**
   - 在 Storybook 回放 `light/dark/high-contrast`，同时落盘绝对阈值与回退斜率。
4. **分支硬门禁**
   - required checks 并列强制：
     - `text_contrast_budget_pass`
     - `non_text_contrast_budget_pass`
     - `contrast_regression_slope_pass`
     - `theme_replay_pass`

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `artifacts/theme_contrast_baseline.json` | `theme`, `story_id`, `token_role`, `baseline_ratio`, `captured_at` | 无基线不得评估回退 |
| `artifacts/theme_contrast_regression.json` | `theme`, `story_id`, `token_role`, `current_ratio`, `ratio_drop`, `severity` | 存在 `severity=severe` 直接 fail |
| `artifacts/theme_replay_manifest.json` | `themes`, `stories_total`, `stories_failed`, `checked_at` | 主题覆盖不全即 fail |
| `promotion_packet.json` | `text_contrast_budget_pass`, `non_text_contrast_budget_pass`, `contrast_regression_slope_pass`, `theme_replay_pass`, `blocked_reason` | 任一 gate 失败必须冻结晋级 |

## 证据链

1. `t.co/dwAiIjlXet` 仍稳定重定向到 OPML 原始订阅体，可持续作为探索入口，但不提供“回退斜率”语义，需流程层补齐。
2. HN `top/show/new` 同步采样持续出现“AI 自动化 + 设计命名”相关信号，说明主题与可读性回退仍是活跃工程问题。
3. WCAG 2.2 对文本与非文本给出绝对底线，可作为第一层门禁。
4. Storybook 官方测试路径可承载多主题批量回放，适合计算 `ratio_drop`。
5. GitHub required status checks 可把 `contrast_regression_slope_pass` 变成不可绕过的晋级条件。

## 反模式

- 仅看“是否达标”，不记录 `baseline_ratio` 与 `ratio_drop`。
- 基线在每轮自动覆盖，导致回退被“重写成正常”。
- 只测 light 主题，把 dark/high-contrast 作为非阻断项。
- 对 `moderate/severe` 回退继续自动晋级，直到线上暴露可读性故障。
