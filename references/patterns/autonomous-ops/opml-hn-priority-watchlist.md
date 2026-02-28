---
name: opml-hn-priority-watchlist
topic: autonomous-ops
confidence: 0.77
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (2026-02-28)
  - Hacker News top/show/new snapshot (2026-02-28)
  - GitHub Projects custom fields docs
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间巡航如果只盯 HN 实时流，会被短时噪声牵引；
如果只盯长期博客池，又会错过当天新信号。

## 核心解法

用 **长短融合 watchlist**：

1. **长周期池（OPML）**：作为稳定作者源，控制知识方向漂移。
2. **短周期池（HN top/show/new）**：捕捉当天新项目和突发趋势。
3. **统一评分卡**：每轮按“可执行度 / 证据质量 / 与四大方向契合度”打分。
4. **阈值入库**：分数达标才进入 pattern 主索引。

## 推荐评分字段

| 字段 | 取值 |
|------|------|
| `actionability` | 1-5（是否可明日实战） |
| `evidence_quality` | 1-5（是否有官方文档或可验证实现） |
| `focus_fit` | 1-5（与四大方向匹配度） |
| `novelty` | 1-5（是否提供新增视角） |
| `final_score` | 加权总分（建议阈值 >= 14） |

## 明日执行动作

1. 从 OPML 先选 12 位高相关作者做 `priority-watchlist`。
2. 每轮仅允许 3 条 HN 快讯进入深挖，超出部分进入候选池。
3. 通过评分字段自动生成次晨 Brief 排序。

## 反模式

- HN 热点全量追踪，无筛选阈值。
- OPML 全量订阅，无优先级分层。
- 发现很多，落盘很少，无法形成可复用知识资产。
