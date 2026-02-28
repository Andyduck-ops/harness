---
name: 24h-unattended-ai-loop
topic: autonomous-ops
confidence: 0.72
verified_count: 3
sources:
  - OpenAI Harness Engineering (2026-02)
  - Hacker News showstories snapshot (2026-02-28)
  - HN Popular Blogs OPML gist (updated 2026-02-28)
last_verified: 2026-02-28
rank: 3
---

## 元问题

团队希望 Agent 在 24 小时内无人值守推进，但“自动化执行”与“可控风险”经常冲突：
跑得越久，偏航与噪声累积的概率越高。

## 核心解法

把“连续运行”拆成 **可审计闭环**，不是单线程无限跑：

1. **Scout 采集**：固定窗口拉取新信号（HN Top/Show/New + 高价值博客）
2. **Analyst 蒸馏**：每条发现映射到元问题（避免信息堆积）
3. **Cartographer 落盘**：原子更新 pattern + index + brief
4. **Gate 守门**：仅允许知识库写入与本地 commit，禁止 push 与业务代码写入
5. **Human Checkpoint**：次日通过 morning-brief 快速审批方向

## 关键机制

| 机制 | 作用 | 失败补救 |
|------|------|----------|
| 时间窗采样（如每轮 30-60 分钟） | 防止上下文爆炸 | 超时则中断该轮并记录 |
| Confidence 门槛（<0.4 丢弃） | 抑制噪声 | 进入候选池不入主索引 |
| Rolling brief（最近 50 条） | 保持可读性 | 旧条目归档到 `.nightshift/briefs/` |
| Commit but never push | 审计可回滚 | 人工审核后再推送 |

## 证据

- OpenAI 提倡将失败与经验回灌到仓库，形成可复用工程资产。
- HN 当日 Show HN 持续出现“Agent/自动化开发”项目，说明该方向高速演进。
- HN Popular Blogs 的 OPML 提供了长期高信噪比作者池，适合作为夜间巡航信源底座。

## 反模式

- 让 Agent 直接改业务代码并自动部署
- 无分层索引，只追加长日志
- 只追新帖不做蒸馏与去重
- 没有“停止条件”的自动化循环
