---
name: hook-based-enforcement
topic: quality-enforcement
confidence: 0.90
verified_count: 3
sources:
  - OpenAI Harness Engineering (2026-02)
  - Trellis 18-round analysis (2026-02)
  - Coding-Agent-prompt-best-practice (2026-02)
last_verified: 2026-02-28
rank: 1
---

## 元问题

Agent 不会"自觉遵守"文档中的规则。
文档建议的遵守率远低于机械化强制。

## 核心解法

在 Agent 执行的关键边界点设置程序化拦截，
让违规操作在发生前被阻止或在发生后被检测。

4 个边界点（Claude Code hook 事件）：
- **SessionStart**: 注入全局上下文（spec、lessons、workflow）
- **PreToolUse**: 拦截违规 + 注入阶段上下文
- **PostToolUse**: 收集证据 + 检测知识腐化
- **SubagentStop**: 质量门（验证命令必须通过才能退出）

## 证据

- **OpenAI**: "With agents, strict linting rules become multipliers." Custom linter error messages 直接注入修复指令到 agent 上下文。
- **Trellis**: hook 强制注入 100% 生效 vs myclaude skill-rules "建议触发" 经常被忽略。
- **SKILL.md**: 4 级权限阶梯（L1 只读 → L4 外部操作），每级有升级/回退条件。

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: Python Hook** | Claude Code PreToolUse/PostToolUse/SubagentStop | Claude Code |
| **B: Custom Linter** | CI/编译时检查架构不变量 | 任何平台 |
| **C: AGENTS.md 指令** | 强指令嵌入（无 hook 时的降级）| Codex / Cursor |
| **D: Structural Test** | 测试命名规范、文件大小、依赖方向 | 任何有测试框架的项目 |

## 反模式

- 只写文档不强制执行
- Hook 逻辑过于复杂（单文件 >500 行）
- 强制但不解释（缺少 "why" 的 error message）
- 阻塞所有操作（应最小化阻塞门，corrections are cheap）
