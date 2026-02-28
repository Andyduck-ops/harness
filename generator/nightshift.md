# /harness:nightshift — 持续自主学习守护进程

持续冲浪学习，直到人主动停止。每轮 3-5 分钟。
morning-brief.md 增量更新，人随时打开都能看到最新进展。

**无时间上限。持续运行。人叫停才停。**

---

## When to Use

- 睡前启动：`/harness:nightshift` → 挂着，早上看 morning-brief.md
- 任何空闲时间：开个终端挂着，让 agent 持续学习
- 白天也可以跑——不限于夜间

---

## Prerequisites



---

## 执行模型：持续学习循环

### 核心循环



### 目标选择策略（轮转）



---

## 每个学习单元（3-5 分钟）

### Step 1: Scout



如果用 WebSearch（二级探索）：


### Step 2: Distill

将每个 finding 压缩为 pattern 格式：



**核心：找到元问题。** 不同文章说的往往是同一个底层问题的不同解法。

### Step 3: Analyze

读取 `$HARNESS_HOME/references/bedrock/first-principles.md`，对每个 finding 检查：

| 检查 | 通过 | 未通过 |
|------|------|--------|
| 与 bedrock 原理一致？ | 继续 | 标记 `[BEDROCK_CONFLICT]` → conflicts.md |
| 不是已有 pattern 的重复？ | 新建 | 合并为已有 pattern 的变体 |
| 有实际证据（非纯观点）？ | 继续 | confidence -= 0.15 |
| 可操作（非纯理论）？ | 继续 | 标记 `[THEORY_ONLY]`，降 rank |
| confidence ≥ 0.4？ | 写入 | 丢弃 |
| 关于 meta-framework 自身？ | 标记 `[SELF_MODIFY]` | — |

### Step 4: Rank & Merge

读取 `_master_index.md`：

- **同一元问题已存在** → 合并为实现变体，更新 sources/verified_count/confidence
- **新元问题** → 创建新 pattern 文件，更新 _master_index.md
- **与已有 pattern 矛盾** → 写入 conflicts.md，不自动解决

信源评分更新：
- 产出高质量 finding → score += 0.02（上限 0.95）
- 大部分是 noise → score -= 0.03（下限 0.3）
- 无新内容 → 不变

### Step 5: 增量更新 Morning Brief

每个学习单元完成后**立即追加**到 `$HARNESS_HOME/morning-brief.md`：



### Step 6: Git Commit

每轮自动 commit（不 push）：


---

## 并行加速（可选）

当一个信源的 Scout 返回多个 finding 时，可以并行处理：



这样可以实现**流水线并行**：Scout 和 Distill+Analyze 交错执行。

---

## Decay Sweep（每 10 轮）



---

## 停止条件

| 条件 | 行为 |
|------|------|
| **人主动停止**（Ctrl+C / 发消息） | 写最终 brief → commit → 退出 |
| **连续 5 次错误** | 写 `[INTERRUPTED]` brief → commit → 退出 |
| **所有信源 + 二级探索穷尽** | 写 `[EXHAUSTED]` brief → commit → 等待（极少发生） |
| **Git 冲突 / 磁盘满** | 写错误日志 → 退出 |

**没有时间上限。** 可以跑一晚上，也可以跑一周。

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|--------|-------|
| WebFetch / WebSearch | 只读，信源 URL 和搜索 |
| 创建/更新 references/patterns/ | 知识库 |
| 创建/更新 references/sources.yaml | 信源评分 |
| 移动 patterns 到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量报告 |
| 写 .nightshift/ 日志 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### CANNOT do（硬性禁止）

| 操作 | 原因 |
|--------|--------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 发消息 / 创建 PR | 不打扰人 |
| 删除非 archive 的 patterns | 防止误删 |

### Bedrock Guard

如果 finding 与 bedrock 原理冲突：
1. **不写入 patterns/**
2. 写入 `$HARNESS_HOME/.nightshift/conflicts.md`
3. morning-brief.md 高亮标记 `[BEDROCK_CONFLICT]`
4. 等人工判断

### Self-Modify Guard

如果 finding 关于改进 Scout/Distill/Rank/Merge 自身：
1. **仍然写入 patterns/meta-framework/**（有界自改进）
2. morning-brief.md 高亮标记 `[SELF_MODIFY]`
3. **不自动修改 generator/*.md**（需要人确认后才改）

---

## 状态文件

### `.nightshift/state.json`



### `.nightshift/metrics.jsonl`（追加式）



---

## Morning Brief 格式

`$HARNESS_HOME/morning-brief.md`（增量追加，人随时可看）：



---

## 与其他命令的关系

| 命令 | 触发 | 范围 | 持续 | 人的角色 |
|------|------|------|------|----------|
| `/harness:calibrate` | 手动，白天 | 聚焦（1 个 URL/topic） | ~20 min | 交互式 |
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** | 看 brief |
| `/harness:compound` | 任务完成后 | 内部经验 | ~10 min | 审核教训 |

**数据流：**


---

## 快速启动



---

## 核心原则

> **Nightshift 是不知疲倦的图书馆员。**
>
> 它整理、分类、清洁知识库。
> 它永远不会重新设计图书馆本身——那是人 + calibrate 的事。

> **Morning brief 是增量的，不是最后才写的。**
>
> 人随时打开 morning-brief.md 都能看到最新进展。
> 不需要等到"完成"才能看结果。

> **Commit but never push.**
>
> Git 历史提供完整审计轨迹和回滚能力。
> 人推送 = 隐式批准。

> **没有时间上限，只有停止信号。**
>
> 世界是运动与变化的。学习不应该有人为的截止时间。
> 人叫停，或者信源穷尽，才是真正的停止条件。
