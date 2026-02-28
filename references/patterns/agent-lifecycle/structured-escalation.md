---
name: structured-escalation
topic: agent-lifecycle
confidence: 0.85
verified_count: 3
sources:
  - Coding-Agent-prompt-best-practice SKILL.md (2026-02)
  - Trellis dispatch analysis (2026-02)
  - OpenAI Harness Engineering (2026-02)
last_verified: 2026-02-28
rank: 2
---

## 元问题

Agent 遇到不确定性时有两种失败模式：
1. **静默降级** — 猜测答案继续执行，产出低质量结果
2. **开放式提问** — "我不确定该怎么办" 把认知负担推给人

两者都浪费人的带宽。

## 核心解法

**选项型求助（Option-Based Escalation）**：
Agent 必须提供结构化的选择题，而非开放式问答。

求助消息格式：



**关键设计：**
- 总是有默认选项（人不回复也能继续）
- 总是有推荐（减少人的认知负担）
- 总是展示已尝试方案（证明不是懒求助）

## 证据

- **SKILL.md**: 定义了"选项型提问"模板，禁止开放式求助
- **Trellis dispatch**: Plan agent 拒绝模糊需求时写 REJECTED.md（结构化拒绝 = 结构化求助的对偶）
- **OpenAI**: Agent legibility — "The code LLMs write should be easy to review" — 同理，求助也应易于审批

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: Agent prompt 指令** | 在 Agent 系统提示中定义求助模板 | 任何平台 |
| **B: Hook 拦截** | SubagentStop 检测到未解决问题时强制格式化 | Claude Code |
| **C: CLI 交互** | 选项直接渲染为终端菜单 | 有 CLI 交互的环境 |

## 反模式

- 开放式提问（"我该怎么办？"）
- 静默降级（猜测答案继续执行）
- 无默认选项（人不回复则永远卡住）
- 求助不展示已尝试方案（可能在重复人已知的信息）
