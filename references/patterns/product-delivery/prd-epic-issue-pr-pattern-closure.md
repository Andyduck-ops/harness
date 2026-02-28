---
name: prd-epic-issue-pr-pattern-closure
topic: product-delivery
confidence: 0.82
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (2026-02-28)
  - Hacker News show/new snapshot (2026-02-28)
  - GitHub issue forms docs
  - GitHub linking pull requests to issues docs
  - GitHub custom fields in projects docs
last_verified: 2026-02-28
rank: 2
---

## 元问题

PRD 到交付链路的断点通常发生在 Issue 粒度与回写机制：
Issue 能执行，但执行结果没有回灌为可复用 pattern。

## 核心解法

建立 **PRD -> Epic -> Issue -> PR -> Pattern** 强闭环，并把每一层字段标准化：

1. **PRD 切片**：每片都要有成功指标和非目标。
2. **Epic 编排**：明确依赖关系与风险顺序。
3. **Issue 原子化**：用 Issue Form 强制输入/输出/验收/回滚字段。
4. **PR 回链**：PR 必须关联 Issue 并自动关闭（closing keywords）。
5. **Pattern 回灌**：PR 完成后提炼“元问题 + 解法 + 反模式”写入知识库。

## 证据链

- GitHub Issue Forms 支持结构化字段，适合把需求转成可执行输入。
- GitHub 可通过 PR 关联并自动关闭 Issue，减少链路断裂。
- GitHub Projects 自定义字段可承载 PRD Slice/Epic/Issue 的状态维度。
- HN `show/new` 同日项目反馈显示，执行闭环比“文档完整度”更决定交付速度。

## 明日落地模板

1. 新建 `Issue Form`：强制验收标准和回滚策略。
2. PR 模板增加：`PRD Slice ID`、`Issue ID`、`Pattern 回写链接`。
3. 合并后自动触发 pattern 回灌检查，不通过则阻断关闭流程。

## 反模式

- PRD 很完整，但 Issue 没有验收字段。
- PR 合并后不回写知识库。
- 只统计完成数量，不统计复用知识增量。
