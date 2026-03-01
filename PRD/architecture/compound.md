# Compound — 内循环知识复利机制

## 核心理念

**知识复利 = 每次工作都让系统变好一点**

Agent 每次任务都在产出隐性知识（踩坑经验、修复策略、API 怪癖），但这些知识随着 session 结束而消失。下一次相似任务从零开始，重复相同的错误。

**每次工作后不提取教训 = 知识负利率。**

Compound 是 Harness 的内循环知识进化机制：任务完成后提取教训，沉淀到知识库，让系统持续变好。

---

## 设计目标

解决 Agent 的知识积累问题：

1. **隐性知识流失** — 每次任务产出的经验不会自动积累
2. **重复犯错** — 相同错误在不同 session 重复出现
3. **知识孤岛** — 个人经验无法转化为团队资产

---

## 架构设计

### 内循环 vs 外循环

| 维度 | 内循环（Compound） | 外循环（Calibrate/Nightshift） |
|------|-------------------|-------------------------------|
| **输入** | 自己的任务经验 | 外部文章/博客/官方文档 |
| **输出** | ANCHOR/SHAPE/DECODE/ESCAPE 教训 | patterns/ 知识库 |
| **触发** | 任务完成后 | 手动/定期 |
| **持续** | ~10 min | ~20 min / 无上限 |
| **人的角色** | 审核教训 | 交互式/看 brief |

**汇聚点**：Compound 成熟教训（verified_count ≥ 3）自动提名升级到 patterns/。

---

## 执行流程

### 1. 提取教训

任务完成后，回顾工作内容：
- 遇到了什么问题？
- 什么解决方案有效？
- 出现了什么模式？
- 犯了什么错误？

提取 3-5 条可操作的教训。

### 2. 按 Agent 架构缺陷分类

**不按技术领域分类，按 Agent 架构缺陷分类**：

| 类别 | 修补的缺陷 | Agent 行为改变 | 示例 |
|------|-----------|---------------|------|
| **ANCHOR** | 幻觉（Hallucination） | 停止假设，转而观察真实状态 | "修改文件前必须先 Read" |
| **SHAPE** | 窗口限制 & 语法死板 | 改变生成策略，适配约束 | "不要 cat 大文件" |
| **DECODE** | 感知黑盒（Blindness） | 停止盲推，追加二次验证 | "sed 无输出 ≠ 成功" |
| **ESCAPE** | 局部最优（Looping） | 放弃当前思路，换方向 | "连续失败 2 次改策略" |

### 3. 写入待审核教训

创建 `.harness/.pending-lessons.md`：

```markdown
# Pending Lessons from task-123

## Lesson 1: [ANCHOR] 执行前验证文件存在

**Context**: 尝试读取配置文件时失败，因为文件不存在
**Learning**: Agent 假设文件存在导致幻觉
**Action**: 在读取文件前，先用 `test -f` 验证文件存在
**Target**: references/patterns/agent-architecture/anchor-observe-first.md
**Confidence**: 0.85
```

### 4. 人工审核

审核清单：
- [ ] 教训是否准确？
- [ ] 是否可操作（不太模糊）？
- [ ] 是否属于目标 pattern？
- [ ] 是否会帮助未来任务？
- [ ] 是否与现有 patterns 矛盾？

### 5. 批准或拒绝

**批准**：手动将教训合并到对应的 pattern 文件，更新 confidence 和 verified_count，Git commit

**拒绝**：移动到 `.harness/.rejected-lessons.jsonl`

---

## 三级升级路径

| 级别 | 存储位置 | 验证次数 | 执行方式 | 归宿 |
|------|---------|---------|---------|------|
| **L1 实验** | patterns/{category}/lessons.md | 1-2x | 仅注入参考 | → L2 或废弃 |
| **L2 规范** | patterns/{category}/index.md | 3-9x | 强注入 | → L3 或保留 |
| **L3 自动化** | hook / linter / CI | 10+x | 机械化强制 | 归档到 bedrock |

**教训的最终归宿不是文档——是自动化。**

高频教训必须编码到工具，不能停留在文档级别。

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

**可靠性计算**：
- 无 compound: R = 95%（单次 AI session）
- 有 compound（人审核）: R = 95% × 98% = 93%
- 有 compound（全自动）: R = 95% × 90% = 85.5% ❌

**结论**：人审核是强制的，不是可选的。

### Layer 2: Git 版本控制（强制）

每次更新创建 commit，可回滚：

```bash
git commit -m "compound: applied 3 lessons from task-123"
```

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

```
外部世界 → calibrate/nightshift → patterns/（外循环）
                                      ↓
内部经验 → compound → 新教训 → patterns/（内循环）
                                      ↓
                                   sleep（压缩）
```

| 命令 | 触发 | 范围 | 持续 | 人的角色 |
|------|------|------|------|----------|
| `/harness:calibrate` | 手动，白天 | 聚焦（1 个 URL/topic） | ~20 min | 交互式 |
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** | 看 brief |
| `/harness:compound` | 任务完成后 | 内部经验 | ~10 min | 审核教训 |
| `/harness:sleep` | 定期/手动 | patterns/ 压缩 | ~30 min | 审核报告 |

---

## 核心原则

### 1. Compound 是知识复利引擎

每次任务都产出隐性知识（踩坑经验、修复策略、API 怪癖）。不提取 = 知识负利率。提取并沉淀 = 知识复利。

### 2. 教训按 Agent 架构缺陷分类，不按技术领域

ANCHOR/SHAPE/DECODE/ESCAPE 是 Agent 的 4 个架构缺陷。按缺陷分类让教训更容易被检索和应用。

### 3. 教训的最终归宿不是文档——是自动化

L1 实验 → L2 规范 → L3 自动化（hook/linter/CI）。高频教训必须编码到工具，不能停留在文档级别。

### 4. 人审核是强制的，不是可选的

AI 提取教训的准确率 ~90%。人审核提升到 98%。无人审核会污染知识库，降低系统可靠性。

---

## 实现细节

详见 → [generator/compound.md](../generator/compound.md)
