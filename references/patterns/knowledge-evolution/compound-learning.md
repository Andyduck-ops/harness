---
name: compound-learning
topic: knowledge-evolution
confidence: 0.90
verified_count: 4
sources:
  - Compound Engineering @kieranklaassen (2026-02)
  - OpenAI Harness Engineering (2026-02)
  - Trellis compound loop (2026-02)
  - Code Factory learning loop (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

Agent 每次任务都在产出隐性知识（踩坑经验、修复策略、API 怪癖），
但这些知识随着 session 结束而消失。
下一次相似任务从零开始，重复相同的错误。

**每次工作后不提取教训 = 知识负利率。**

## 核心解法

任务完成后执行**内循环（compound loop）**：

1. **回顾** — 读取 agent-outputs/（实现结果、check 结果、debug 历史）
2. **提取** — 蒸馏 3-5 条可复用教训
3. **分类** — 按 ANCHOR/SHAPE/DECODE/ESCAPE 归类（按 agent 架构缺陷）
4. **审核** — 人审核批准（高杠杆守门点）
5. **沉淀** — 写入 spec/lessons/，session-start 自动注入

**知识复利 = 每次工作都让系统变好一点。**

## 证据

- **Compound Engineering**: 夜间回顾 session → 提取教训 → 更新 AGENTS.md → 次日自动执行
- **OpenAI**: "When the agent struggles, identify what is missing and feed it back into the repository"
- **Trellis**: `/trellis:compound` 命令实现（347行），5层安全模型
- **Code Factory**: 每次 PR 后自动提取风险教训到 risk-policy.json

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: 命令触发** | `/compound` 手动触发，人审核后写入 | 低频、高控制（初始推荐） |
| **B: 自动触发** | task 完成后自动提取，人批量审核 | 高频、采纳率 >60% 后升级 |
| **C: 夜间批量** | nightshift 回顾当日所有 session | 大团队、高吞吐 |

## 升级路径

| 级别 | 存储 | 验证次数 | 执行方式 | 归宿 |
|------|------|---------|---------|------|
| L1 实验 | lessons/ANCHOR.md 等 | 1-2x | 仅注入参考 | → L2 或废弃 |
| L2 规范 | spec/{domain}/index.md | 3-9x | JSONL 注入 | → L3 或保留 |
| L3 自动化 | hook / linter / CI | 10+x | 机械化强制 | 归档 |

**教训的最终归宿不是文档——是自动化。**

## 反模式

- 只积累不清理（教训膨胀，噪声淹没信号）
- 全自动无人审核（低质量教训污染知识库）
- 教训停留在文档级别（高频教训应编码到工具）
- 教训按技术领域分类（应按 agent 架构缺陷分类）
