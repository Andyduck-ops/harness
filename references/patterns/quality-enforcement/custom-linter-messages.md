---
name: custom-linter-messages
topic: quality-enforcement
confidence: 0.85
verified_count: 3
sources:
  - OpenAI Harness Engineering (2026-02)
  - Trellis hook-based enforcement (2026-02)
  - Code Factory CI patterns (2026-02)
last_verified: 2026-02-28
rank: 2
---

## 元问题

Linter/测试报出的错误信息是给人看的，不是给 Agent 看的。

Agent 读到 `error: no-unused-vars` 后知道"有未使用变量"，
但不知道该**怎么修**——是删除变量、补充使用、还是改为下划线前缀？

标准错误信息缺乏修复指令，Agent 只能猜测或反复尝试。

## 核心解法

**Linter error message = 修复指令。**

将 linter 的错误输出增强为包含修复指令的结构化消息：



**OpenAI 原文："With agents, strict linting rules become multipliers.
 Custom linter error messages directly inject fix instructions into the agent's context."**

## 证据

- **OpenAI**: Custom linter messages 是 Harness Engineering 的核心实践，直接提升 agent 自修复率
- **Trellis**: Hook-based enforcement 证实了"强制执行 > 文档建议"——同理，"修复指令 > 错误描述"
- **Code Factory**: CI gate 中的 structured error output 让 agent 能自动修复 80%+ lint 错误

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: 自定义 linter 规则** | ESLint plugin / custom rule 输出增强消息 | JS/TS 项目 |
| **B: PostToolUse 后处理** | Hook 截获 lint 输出，追加修复建议 | Claude Code |
| **C: Structural Tests** | 专门的测试检查架构不变量，失败消息含修复步骤 | 任何有测试框架的项目 |
| **D: CI 脚本包装** | `lint.sh` 包装原始 linter，追加修复建议 | 任何 CI 系统 |

## Structural Tests 示例

不变量检查（比 linter 更强）：
- 文件命名规范（`*.test.ts` 必须与 `*.ts` 一一对应）
- 依赖方向（`ui/` 不能导入 `db/`）
- 文件大小上限（单文件 > 500 行触发拆分建议）
- API 响应格式一致性

每个 structural test 的失败消息都应包含：
1. **什么违规了**（具体文件/行）
2. **为什么这是规则**（背景）
3. **怎么修**（具体步骤）

## 反模式

- 只用标准 linter 错误信息（Agent 无法理解修复意图）
- 修复建议过于笼统（"请修复此错误" ≈ 没说）
- 不包含文件路径和行号（Agent 不知道"在哪修"）
- 修复建议与项目风格不一致（建议的代码风格与项目不同）
