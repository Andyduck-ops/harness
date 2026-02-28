---
name: staleness-detection
topic: knowledge-evolution
confidence: 0.85
verified_count: 3
sources:
  - Trellis track-knowledge-staleness.py (2026-02)
  - OpenAI doc-gardening pattern (2026-02)
  - Compound Engineering @kieranklaassen (2026-02)
last_verified: 2026-02-28
rank: 2
---

## 元问题

Spec 和教训文件引用的代码会被修改，
但知识文件本身不会自动更新。
随时间推移，知识库与代码库渐行渐远——**知识腐化**。

Agent 读到过期的 spec 后，会按旧信息行动，产出错误代码。

## 核心解法

**零 LLM 腐化检测：** 用纯文本匹配检测代码变更与知识文件的脱节。

检测逻辑：
1. PostToolUse hook 捕获每次 Edit/Write 操作
2. 提取被修改的文件路径
3. 与 JSONL 中引用的文件路径取交集
4. 有交集 → 标记引用该文件的知识条目为 stale
5. SessionStart 注入腐化警告

**三个检测维度：**

| 维度 | 方法 | 成本 |
|------|------|------|
| 文件级腐化 | 修改文件 ∩ JSONL 引用文件 | 零 LLM，纯文本匹配 |
| Spec 级腐化 | 文件修改时间 vs spec 最后更新时间 | 零 LLM |
| 时间腐化 | 90 天未引用/未验证 | 零 LLM |

**处理流程：**
- 检测到腐化 → 写入 `.stale-knowledge.json`
- SessionStart 读取并注入警告块
- Agent 更新 spec/JSONL 后 → 清除对应条目
- 被新教训替代 → 标记 `superseded`

## 证据

- **Trellis**: `track-knowledge-staleness.py`（~140行），PostToolUse hook 实现
- **OpenAI**: doc-gardening agent — 自动清理过期文档（检测 last_modified + 引用频率）
- **Compound Engineering**: AGENTS.md 每晚更新 = 隐式腐化修复

## 实现变体

| 变体 | 机制 | 适用场景 |
|------|------|----------|
| **A: PostToolUse hook** | 实时检测，写入 JSON 状态文件 | Claude Code（推荐） |
| **B: CI/pre-commit** | 提交时检查 spec 引用的文件是否已变更 | 任何有 CI 的项目 |
| **C: 定期扫描** | cron/nightshift 批量检查所有引用 | 补充方案 |

## 反模式

- 用 LLM 判断知识是否过期（昂贵、不可靠、过度工程化）
- 只检测不告警（检测到腐化但 Agent 看不到）
- 只告警不清除（过期标记永远存在，告警疲劳）
- 修改 spec 后不清除腐化标记（需要闭环）
