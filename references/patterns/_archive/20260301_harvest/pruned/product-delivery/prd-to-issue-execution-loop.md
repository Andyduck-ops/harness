---
name: prd-to-issue-execution-loop
topic: product-delivery
confidence: 0.70
verified_count: 4
sources:
  - Harness PRD architecture docs (2026-02)
  - GitHub Projects/Issues workflow docs
  - OpenAI Harness Engineering (2026-02)
  - Hacker News practitioner posts (2026-02-28)
last_verified: 2026-02-28
rank: 3
---

## 元问题

PRD 往往写得很好，但无法稳定转成可执行任务，
最终出现“文档很多、交付很慢”的落差。

## 核心解法

建立 **PRD → Epic → Issue → PR → Pattern** 的闭环，并让 Agent 参与可自动化部分：

1. **PRD 切片**：按用户价值拆成 Epic，不按技术层拆
2. **Issue 原子化**：每个 Issue 必须有验收标准与边界
3. **实施追踪**：PR 必须回链 Issue 与 PRD 片段
4. **结果回灌**：上线后的经验写回 pattern（成功/失败都写）
5. **节奏控制**：日更 Issue 队列，周更 PRD 优先级

## 最小字段规范

| 对象 | 必填字段 |
|------|----------|
| PRD Slice | 用户场景、成功指标、非目标 |
| Epic | 目标结果、依赖关系、风险 |
| Issue | 输入/输出、验收标准、回滚策略 |
| PR | 影响范围、测试证据、文档同步 |

## 证据

- Harness 架构强调“仓库是大脑”，PRD 资产必须能驱动执行而非静态存档。
- GitHub Issue/Project 模型天然适合作为执行层抽象。
- HN 工程实践反复验证：可执行任务粒度比宏大文档更决定交付效率。

## 反模式

- PRD 只做愿景叙述，不映射执行单元
- Issue 仅写“实现某功能”，无验收标准
- PR 合并后不回写知识库
