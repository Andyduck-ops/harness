---
name: frontend-system-first
topic: fullstack-engineering
confidence: 0.68
verified_count: 3
sources:
  - overreacted.io (from HN Popular Blogs OPML)
  - web.dev patterns and performance guidance
  - Hacker News showstories snapshot (2026-02-28)
last_verified: 2026-02-28
rank: 3
---

## 元问题

“明天就要做出非常厉害的前端设计”通常失败在：
先写页面，再补规则，导致视觉一致性、可访问性、性能都失控。

## 核心解法

采用 **System First**：先定义设计系统最小闭环，再批量产出页面。

1. **Design Tokens**：颜色、间距、字体、圆角、阴影先定标尺
2. **Primitive Components**：Button/Card/Input/Modal 先做语义层
3. **Composition Patterns**：Dashboard、Form、Table 等组合模板
4. **Performance Gate**：LCP/CLS 预算前置，不合格不进入模板层
5. **A11y Gate**：键盘可达、语义标签、对比度成为默认规则

## 执行模板（面向 Agent）

| 层级 | 产物 | 验收 |
|------|------|------|
| Token | `tokens.(json|ts)` | 变量命名统一、无硬编码颜色 |
| Primitive | `/components/ui/*` | API 一致、支持主题扩展 |
| Section | `/components/sections/*` | 复用率高于单页魔改 |
| Page | `/app/*` | 仅装配，不引入局部设计规则 |

## 证据

- HN 热门博客中长期高频出现“组件抽象/系统化设计”实践。
- web.dev 持续强调性能和可访问性应内建，而不是上线前补救。
- 当日 Show HN 项目中，交互类产品普遍采用组件化表达而非一次性页面脚本。

## 反模式

- 直接从 Page 开始写 UI
- 每个页面独立定义样式变量
- 只做视觉稿，不做可执行组件契约
