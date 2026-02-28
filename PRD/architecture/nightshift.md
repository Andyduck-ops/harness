# Nightshift — 持续自主学习守护进程

## 设计目标

Agent 持续冲浪学习，每轮 3-5 分钟，直到人主动停止。
morning-brief.md 增量更新，人随时打开都能看到最新进展。

**不是批处理任务，是持续运行的学习守护进程。**

---

## 执行模型

### 持续循环（非批处理）



**没有时间上限。** 世界是运动与变化的，学习不应有人为截止时间。

### 目标选择策略（轮转）

1. sources.yaml 中分数最高、距上次扫描最久的信源
2. 信源扫完 → 二级探索（从 pattern 关键词出发搜索新信源）
3. 二级也穷尽 → 等待/退出（极少发生）

---

## 每个学习单元

| 步骤 | 耗时 | 动作 |
|------|------|------|
| Scout | 1-2 min | WebFetch/WebSearch 信源，提取 findings |
| Distill | 1 min | 压缩为 Skill 格式，找到元问题 |
| Analyze | 1 min | 对照 bedrock 验证，评分 |
| Rank+Merge | <1 min | 写入/合并 patterns，更新 index |
| Brief | <1 min | 增量追加 morning-brief.md |

可并行：Scout A 和 Distill+Analyze B 交错执行。

---

## Morning Brief 格式

`$HARNESS_HOME/morning-brief.md`（增量追加，人随时可看）：



---

## 执行环境

### Claude Code



### Codex



---

## 停止条件

| 条件 | 行为 |
|------|------|
| 人主动停止 | 写最终 brief → commit → 退出 |
| 连续 5 次错误 | 写 `[INTERRUPTED]` brief → commit → 退出 |
| 所有信源 + 二级探索穷尽 | 写 `[EXHAUSTED]` brief → commit → 等待 |
| Git 冲突 / 磁盘满 | 写错误日志 → 退出 |

---

## 安全边界

### 可以做（自主执行）

| 操作 | 说明 |
|------|------|
| WebFetch / WebSearch | 读取信源内容 |
| 创建/更新 references/ | 知识库更新 |
| 创建/更新 patterns/ | 模式更新 |
| 移动到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量简报 |
| 写 .nightshift/ 日志 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### 不可以做（硬性禁止）

| 操作 | 原因 |
|------|------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 发消息 / 创建 PR | 不打扰人 |
| 删除非 archive 的 patterns | 防止误删 |

---

## 质量保障

### 防止知识污染

1. **Noise Filter**: Distill 标记 [NOISE] 的直接丢弃
2. **Confidence Threshold**: < 0.4 不写入 patterns/
3. **Conflict Detection**: 矛盾写入 conflicts.md，不自动解决
4. **Bedrock Guard**: 与核心原理冲突 → 不写入，等人处理

### 防止膨胀

1. **Merge 压缩**: 同构知识强制合并
2. **Decay 机制**: 90 天无引用 → 分数衰减 → 归档
3. **总量控制**: patterns/ > 100 条时触发强制合并
4. **蒸馏上限**: 单篇文章 < 500 词

### 防止自迭代失控

1. **有界自改进**: 只改知识获取/处理方式，不改核心原则
2. **[SELF_MODIFY] 标签**: morning brief 高亮
3. **回滚能力**: 所有变更通过 git commit，可随时回退

---

## 与 calibrate 的关系

| 命令 | 触发 | 范围 | 持续 |
|------|------|------|------|
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** |
| `/harness:calibrate` | 手动，白天 | 聚焦 1 个 URL/topic | ~20 min |
| `/harness:init` 内置 | 新项目初始化 | 最近 7 天轻量检查 | ~10 min |

nightshift 是持续学习守护进程，calibrate 是按需定向校准。
