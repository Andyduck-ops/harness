---
name: color-vision-simulation-replay-gate
topic: accessibility-governance
confidence: 0.79
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/2f6da337f61e5705f7f7f3981f541f071b8ed941/hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:23:20Z)
  - Hacker News news item 47202859 (sampled 2026-02-28, title: "Introducing Halide HN: Exploratory data analysis with local LLMs")
  - Hacker News show item 47200167 (sampled 2026-02-28, title: "Show HN: A promptless way to create editable SVGs")
  - Hacker News newest item 47203487 (sampled 2026-02-28, title: "What happened when I built a daily coding challenge platform with AI")
  - W3C WCAG 2.2 Understanding SC 1.4.3 Contrast (Minimum) (https://www.w3.org/WAI/WCAG22/Understanding/contrast-minimum.html)
  - W3C WCAG 2.2 Understanding SC 1.4.11 Non-text Contrast (https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
  - Storybook Docs: Writing tests (https://storybook.js.org/docs/writing-tests)
  - GitHub Docs: About protected branches / required status checks (https://docs.github.com/articles/types-of-required-status-checks)
last_verified: 2026-02-28
rank: 3
---

## 元问题

仅以 WCAG 文本/非文本绝对阈值做门禁，仍会漏掉一个高频故障面：

1. 常规主题与默认快照全部通过，但在色觉缺陷场景（如 protanopia/deuteranopia）中关键语义色角色不可区分；
2. 团队把“对比达标”误当成“语义可辨识达标”，导致状态色（成功/警告/危险）在特定用户群体下失真；
3. 无人值守流程不回放色觉仿真，回归只能在人工体验阶段才暴露。

本质问题：**缺少“色觉仿真回放 + 对比预算 + 晋级硬门禁”的三联治理。**

## 核心解法

建立 **Color Vision Simulation Replay Gate（CVSRG）**，与现有对比预算并列执行：

1. **仿真矩阵**
   - 对每个 `theme x story x semantic_role` 生成正常视图与色觉仿真视图（至少 protanopia、deuteranopia、tritanopia）。
2. **双预算判定**
   - 继续执行文本/非文本对比预算（WCAG 阈值）。
   - 新增语义可区分预算：同一 story 下关键角色的最小可区分距离 `role_delta_min` 不得低于阈值。
3. **required checks 并列硬门禁**
   - `text_contrast_budget_pass`
   - `non_text_contrast_budget_pass`
   - `color_vision_replay_pass`
   - `semantic_role_disambiguation_pass`
4. **失败隔离**
   - 任一色觉仿真场景失败即 quarantine，禁止自动晋级。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `artifacts/color_vision_replay_manifest.json` | `theme`, `story_id`, `simulation_type`, `checked_at`, `pass` | 任一 `pass=false` 即 fail |
| `artifacts/semantic_role_delta_report.json` | `theme`, `story_id`, `role_pair`, `delta`, `threshold`, `pass` | 任一关键 `role_pair` 失败即 fail |
| `artifacts/theme_contrast_matrix.json` | `theme`, `story_id`, `text_ratio`, `non_text_ratio`, `pass` | 对比预算失败不得被仿真通过掩盖 |
| `promotion_packet.json` | `color_vision_replay_pass`, `semantic_role_disambiguation_pass`, `blocked_reason` | 任一 gate 失败必须阻断晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 仍稳定指向 HN Popular Blogs OPML 原始订阅体，适合作为持续探索入口。
2. HN `news/show/newest` 同步采样显示“AI 加速交付 + 前端体验输出”持续活跃，意味着无障碍回退风险会频繁进入真实发布流。
3. WCAG 2.2 对文本与非文本对比给出可执行阈值，可作为基线预算层。
4. Storybook 官方测试入口可承载多主题与批量回放，是色觉仿真落地的最低成本执行面。
5. GitHub required status checks 可把 `color_vision_replay_pass` 变成不可绕过门禁，而非事后建议。

## 反模式

- 只跑默认主题截图，不跑色觉仿真回放。
- 把“颜色对比达标”直接等价为“语义角色可辨识”。
- 仅记录视觉截图，不落盘可机器判定的 `role_delta` 指标。
- 色觉仿真失败仍允许自动晋级，依赖人工验收兜底。
