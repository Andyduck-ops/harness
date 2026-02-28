---
name: progressive-disclosure
topic: context-injection
confidence: 0.95
verified_count: 3
sources:
  - OpenAI Harness Engineering (2026-02)
  - Agent-Skills-for-Context-Engineering (2026-01)
  - Trellis 18-round analysis (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

Agent 上下文窗口有限。全量注入导致关键信息被淹没，
token 使用量解释了 80% 的性能差异（BrowseComp 研究）。

## 核心解法

入口文件 ~100 行只放指针，详细内容按需加载。三级：
1. **元数据**（总是加载）：index.md、lessons/index.md
2. **指令**（按任务/阶段加载）：spec、prd.md、agent-outputs
3. **数据**（按需加载）：源码文件、日志、详细参考

## 证据

- **OpenAI**: AGENTS.md ~100 行 + docs/ 深层结构。"When everything is marked important, nothing is."
- **Agent-Skills-for-CE**: 三级加载实现 87% token reduction（Digital Brain 案例）
- **BrowseComp 研究**: token usage explains 80% of performance variance, tool calls ~10%, model choice ~5%
- **Trellis JSONL**: 按阶段注入 implement.jsonl / check.jsonl，节省 60%+ token

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: Hook 注入式** | JSONL 声明 + PreToolUse hook 自动注入 | Claude Code（有 hook 系统）|
| **B: Skill 三级加载** | metadata → instructions → data 渐进加载 | Codex（Skill 格式）|
| **C: 目录 + references/** | AGENTS.md 目录 + docs/ 按需导航 | 通用（任何平台）|

## 反模式

- 单个巨型指令文件（>2000 行）
- 全量注入不分阶段
- 把 AGENTS.md 当百科全书而非目录
- "When everything is marked important, nothing is" — OpenAI
