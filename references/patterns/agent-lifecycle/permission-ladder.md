---
name: permission-ladder
topic: agent-lifecycle
confidence: 0.85
verified_count: 3
sources:
  - Coding-Agent-prompt-best-practice SKILL.md (2026-02)
  - SPARV EHRB risk detection (2026-02)
  - OpenAI Harness Engineering (2026-02)
last_verified: 2026-02-28
rank: 2
---

## 元问题

Agent 默认拥有所有工具权限，
但大多数任务只需要读写代码，不需要删除文件或访问网络。
过宽的权限 = 更大的爆炸半径。

## 核心解法

将 Agent 能力分为 4 个递增级别，
每个级别有明确的升级条件和回退条件：

| 级别 | 能力 | 升级触发 | 回退条件 |
|------|------|---------|----------|
| **L1 只读** | 读代码、读文档、搜索 | 需要运行测试 | — |
| **L2 测试** | 运行测试、lint、静态分析 | 需要修改代码 | 测试引入新失败 |
| **L3 修改** | 编辑代码、运行回归测试 | 需要外部操作 | 回归测试失败 |
| **L4 外部** | 发布、生产操作、网络请求 | — | 人工显式授权 |

**每一级都有"降级保险"：** 如果操作导致质量下降（如测试失败），
自动回退到更低权限级别。

## 证据

- **SKILL.md (Coding-Agent-prompt-best-practice)**: 完整定义了 L1-L4 阶梯，每级含触发/回退条件
- **SPARV**: EHRB 高风险检测（Environment/High-impact/Reversibility/Boundary）守卫 L3/L4 边界
- **OpenAI**: "Structure your repository so agents can navigate" — 隐含最小权限原则

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: Hook 守卫** | PreToolUse hook 检查当前权限级别，拦截越权操作 | Claude Code（有 hook） |
| **B: AGENTS.md 指令** | 在 Agent 定义中限定可用工具列表 | Codex / 通用 |
| **C: CI 隔离** | 不同 CI stage 使用不同权限的 runner | 任何 CI 系统 |

## 反模式

- 所有 Agent 默认拥有全部权限
- 只有二元（只读/全部）权限，无中间级别
- 升级不需要理由（Agent 应说明"为什么需要更高权限"）
- L4 无人工审批（外部操作必须有人确认）
