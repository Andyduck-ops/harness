# /harness:compound — 内循环知识复利机制

从完成的任务中提取教训，更新知识库，让系统持续变好。

**触发时机**：任务完成后，当你学到了有价值的东西

**核心理念**：每次工作都让系统变好一点 = 知识复利

---

## When to Use

| 触发场景 | 示例 | 教训类型 |
|---------|------|----------|
| **调试突破** | 花了 2 小时解决编码问题，找到根因 | Common Mistake |
| **设计决策** | 选择方案 X 而非 Y，有明确理由 | Design Decision |
| **模式发现** | 发现更好的错误处理结构 | New Pattern |
| **踩坑经验** | 发现 X 必须在 Y 之前（非显而易见） | Gotcha/Warning |
| **约定建立** | 团队达成命名规范 | Project Convention |
| **失败尝试** | 尝试了 X，因为 Y 不工作 | Forbidden Pattern |

**关键问题**："未来的 AI/开发者会从这个教训中受益吗？"

---

## Prerequisites

```bash
# 确保在 harness 项目根目录
cd $HARNESS_HOME

# 确保有 Git 版本控制
git status
```

---

## 执行流程

### Step 1: 提取教训

任务完成后，回顾工作内容：

```bash
# 读取任务输出
ls agent-outputs/

# 分析：
# - 遇到了什么问题？
# - 什么解决方案有效？
# - 出现了什么模式？
# - 犯了什么错误？
```

提取 3-5 条可操作的教训。

### Step 2: 按 Agent 架构缺陷分类

**不按技术领域分类，按 Agent 架构缺陷分类**：

| 类别 | 定义 | 示例 |
|------|------|------|
| **ANCHOR** | 抗幻觉（先观察再行动） | 执行命令前先检查文件是否存在 |
| **SHAPE** | 塑形输出（适配上下文/API 约束） | 输出必须符合特定 JSON schema |
| **DECODE** | 破译反馈（工具静默失败时二次验证） | API 返回 200 但实际失败，需检查响应体 |
| **ESCAPE** | 逃逸死锁（连续失败时换方向） | 同一方法失败 3 次后，尝试不同方法 |

### Step 3: 写入待审核教训

创建 `.harness/.pending-lessons.md`：

```markdown
# Pending Lessons from task-123

## Lesson 1: [ANCHOR] 执行前验证文件存在

**Context**: 尝试读取配置文件时失败，因为文件不存在
**Learning**: Agent 假设文件存在导致幻觉
**Action**: 在读取文件前，先用 `test -f` 验证文件存在
**Target**: references/patterns/agent-architecture/anchor-observe-first.md
**Confidence**: 0.85

## Lesson 2: [ESCAPE] 连续失败后切换方法

**Context**: 同一 API 调用失败 3 次，仍在重试
**Learning**: 无证据重试是死循环
**Action**: 失败 2-3 次后，分析根因并切换方法
**Target**: references/patterns/agent-architecture/escape-deadlock.md
**Confidence**: 0.90
```

### Step 4: 人工审核

打开 `.harness/.pending-lessons.md` 审核：

**审核清单**：
- [ ] 教训是否准确？
- [ ] 是否可操作（不太模糊）？
- [ ] 是否属于目标 pattern？
- [ ] 是否会帮助未来任务？
- [ ] 是否与现有 patterns 矛盾？

### Step 5: 批准或拒绝

**批准**：

```bash
# 手动将教训合并到对应的 pattern 文件
# 更新 confidence 和 verified_count
# Git commit
git add references/patterns/
git commit -m "compound: applied 2 lessons from task-123

via [HAPI](https://hapi.run)

Co-Authored-By: HAPI <noreply@hapi.run>"
```

**拒绝**：

```bash
# 移动到 .harness/.rejected-lessons.jsonl
echo '{"date":"2026-03-01","reason":"lesson 2 不准确"}' >> .harness/.rejected-lessons.jsonl
rm .harness/.pending-lessons.md
```

### Step 6: 升级路径

教训的生命周期：

| 级别 | 存储位置 | 验证次数 | 执行方式 | 归宿 |
|------|---------|---------|---------|------|
| **L1 实验** | patterns/{category}/lessons.md | 1-2x | 仅注入参考 | → L2 或废弃 |
| **L2 规范** | patterns/{category}/index.md | 3-9x | 强注入 | → L3 或保留 |
| **L3 自动化** | hook / linter / CI | 10+x | 机械化强制 | 归档到 bedrock |

**教训的最终归宿不是文档——是自动化。**

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|------|------|
| 读取 agent-outputs/ | 分析任务结果 |
| 写 .harness/.pending-lessons.md | 待审核教训 |
| 读取 references/patterns/ | 检查现有 patterns |

### CANNOT do（需人审核）

| 操作 | 原因 |
|------|------|
| 直接修改 references/patterns/ | 需人审核批准 |
| 修改 PRD/ | 意图资产需人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| Git commit（自动） | 人审核后才提交 |

---

## 与其他命令的关系

| 命令 | 触发 | 范围 | 持续 | 人的角色 |
|------|------|------|------|----------|
| `/harness:calibrate` | 手动，白天 | 聚焦（1 个 URL/topic） | ~20 min | 交互式 |
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** | 看 brief |
| `/harness:compound` | 任务完成后 | 内部经验 | ~10 min | 审核教训 |
| `/harness:sleep` | 定期/手动 | patterns/ 压缩 | ~30 min | 审核报告 |

**数据流**：

```
外部世界 → calibrate/nightshift → patterns/（外循环）
                                      ↓
内部经验 → compound → 新教训 → patterns/（内循环）
                                      ↓
                                   sleep（压缩）
```

---

## 5 层安全模型

### Layer 1: 人工审核门（强制）

```
compound 提取教训 → 写入 .pending-lessons.md
                          ↓
                    人审核
                          ↓
              批准（写入 patterns/）
              拒绝（丢弃）
```

### Layer 2: Git 版本控制（强制）

每次更新创建 commit：

```bash
git commit -m "compound: applied 3 lessons from task-123"
```

回滚：`git revert <commit-hash>`

### Layer 3: 大小限制（强制）

```
MAX_PATTERN_LINES = 200      # 单个 pattern 上限
MAX_LESSON_LINES = 50        # 单次 compound 上限
```

超过 → 触发 `/harness:sleep` 压缩

### Layer 4: 验证命令（推荐）

每个教训包含验证方法：

```json
{
  "lesson": "Always use const for non-reassigned variables",
  "verify_cmd": "pnpm lint | grep prefer-const",
  "expected": "0 errors"
}
```

### Layer 5: 分层存储（推荐）

```
Layer 1 (stable):  references/bedrock/
                   - 人工编写，几乎不变

Layer 2 (patterns): references/patterns/
                   - Compound 写入，人审核

Layer 3 (temp):    .harness/.pending-lessons.md
                   - 待审核，试用期
```

---

## 快速启动

```bash
# 任务完成后
/harness:compound

# 审核教训
cat .harness/.pending-lessons.md

# 批准并合并
# 手动编辑 references/patterns/ 文件
git add references/patterns/
git commit -m "compound: applied lessons from task-123

via [HAPI](https://hapi.run)

Co-Authored-By: HAPI <noreply@hapi.run>"
```

---

## 核心原则

> **Compound 是知识复利引擎。**
>
> 每次任务都产出隐性知识（踩坑经验、修复策略、API 怪癖）。
> 不提取 = 知识负利率。提取并沉淀 = 知识复利。

> **教训按 Agent 架构缺陷分类，不按技术领域。**
>
> ANCHOR/SHAPE/DECODE/ESCAPE 是 Agent 的 4 个架构缺陷。
> 按缺陷分类让教训更容易被检索和应用。

> **教训的最终归宿不是文档——是自动化。**
>
> L1 实验 → L2 规范 → L3 自动化（hook/linter/CI）。
> 高频教训必须编码到工具，不能停留在文档级别。

> **人审核是强制的，不是可选的。**
>
> AI 提取教训的准确率 ~90%。人审核提升到 98%。
> 无人审核会污染知识库，降低系统可靠性。
