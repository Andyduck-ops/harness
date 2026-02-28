---
name: nightshift
description: |
  持续自主学习守护进程。给定几个大方向，Agent Team 自主探索、发现、蒸馏、验证，
  动态填充知识地图。无时间上限，人叫停才停。
hooks:
  stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/stop-guard.py"
  subagent_stop:
    - hooks:
      - type: command
        command: "python3 $HOME/.codex/skills/nightshift/scripts/stop-guard.py"
---

# Nightshift — 持续自主学习守护进程

> **不知疲倦的知识制图者。给几个大方向，自己探索整片大陆。**

---

## 激活



或 codex exec 非交互模式：



---

## Step 0: 初始化

读取项目状态：

1. 检查 `$CWD` 是否有 `.harness/` 或 harness 仓库结构
2. 读取现有知识地图：
   - `references/patterns/_master_index.md` — 已有 patterns
   - `references/sources/{topic}.yaml` — 信源评分（按 topic 分文件）
   - `.nightshift/state.json` — 上次状态（如存在，断点续传）
3. 从用户 prompt 提取**大方向**（seeds）
4. 创建 `.nightshift/` 目录（如不存在）

---

## Step 1: 组建 Team

使用 `spawn_team` 创建三角色团队：



### 模型分配

| 角色 | 模型 | 理由 |
|------|------|------|
| cartographer | gpt-5.3-codex | 需要强推理做知识拓扑和方向决策 |
| scout | gpt-5.2 | 搜索探索不需要顶级推理，节约成本 |
| analyst | gpt-5.3-codex | 第一性原理验证需要深度思考 |

通过 agent role config 实现模型差异化：
- `~/.codex/agents/scout.toml` 中设置 `model = "gpt-5.2"`
- cartographer 和 analyst 继承全局 `gpt-5.3-codex`

---

## Step 2: Cartographer 启动循环

Cartographer 是 Lead，执行以下持续循环：



### 知识地图分析（空白识别）

Cartographer 读取 `_master_index.md`，对每个 topic 目录评估：

| 信号 | 含义 |
|------|------|
| topic 目录下 < 3 patterns | 薄弱区域，优先探索 |
| 最近 10 轮无新 pattern | 停滞区域，换角度探索 |
| 多个 `[CONFLICT]` 标记 | 争议区域，需要更多证据 |
| 用户大方向未覆盖 | 全新区域，初始探索 |
| pattern 平均 confidence < 0.6 | 低置信区域，需要更多验证 |

### 探索指令格式

Cartographer → Scout 的消息：



---

## Step 3: Scout 探索循环

Scout 持续执行：



### Scout 的关键行为

- **广度优先**：每个指令搜索多个角度，不在一个信源上深挖
- **意外发现（Serendipity）**：如果搜索中遇到与当前指令无关但有价值的内容，额外发给 cartographer 标记 `[SERENDIPITY]`
- **二级探索**：当直接搜索结果不够时，从已有 patterns 的关键词出发做关联搜索
- **去重**：跳过 `sources/{topic}.yaml` 中 score < 0.4 的信源

---

## Step 4: Analyst 验证循环

Analyst 持续执行：



### Analyze 检查表

| 检查 | 通过 | 未通过 |
|------|------|--------|
| 与 bedrock 原理一致？ | 继续 | `[BEDROCK_CONFLICT]` → conflicts.md |
| 不是已有 pattern 的重复？ | 新建 | 合并为已有 pattern 的变体 |
| 有实际证据（非纯观点）？ | 继续 | confidence -= 0.15 |
| 可操作（非纯理论）？ | 继续 | `[THEORY_ONLY]`，降 rank |
| confidence ≥ 0.4？ | 通过 | 丢弃，通知 cartographer |
| 关于 meta-framework 自身？ | `[SELF_MODIFY]` | — |

### Distill 核心原则

> 不同文章说的往往是同一个元问题的不同解法。
> Distill 的核心任务是**找到元问题**，而非堆积具体方案。
> 同一元问题只保留一条 pattern，包含所有实现变体。

---

## Step 5: Rank & Merge（Cartographer 执行）

收到 Analyst 的验证结果后：

- **同一元问题已存在** → 合并为实现变体，更新 sources/verified_count/confidence
- **新元问题** → 创建新 pattern 文件，更新 _master_index.md
- **与已有 pattern 矛盾** → 写入 conflicts.md，不自动解决
- **Serendipity 发现** → 评估是否需要开辟新 topic 目录

信源评分更新：
- 产出高质量 finding → score += 0.02（上限 0.95）
- 大部分是 noise → score -= 0.03（下限 0.3）
- 无新内容 → 不变

---

## Step 6: Morning Brief 增量更新

### 滚动窗口策略（防 24h 膨胀）

**`morning-brief.md` 只保留最近 50 条**，旧条目自动归档。

每轮 Merge 后：
1. 追加新条目到 `morning-brief.md` 头部
2. 如果超过 50 条 → 尾部溢出条目移入 `.nightshift/briefs/{date}.md`
3. 人随时打开 morning-brief.md 都是**最近 50 条**
4. 完整历史在 `.nightshift/briefs/` 按日期分文件

---

## Step 7: Decay Sweep（每 10 轮）

Cartographer 每 10 个 cycle 执行一次：

1. 扫描所有 patterns，找 90 天无引用无验证的
2. confidence 衰减 -0.05
3. 低于 0.3 的移入 `archive/`
4. 更新 `_master_index.md`

---

## 停止条件

| 条件 | 行为 |
|------|------|
| **人主动停止**（Ctrl+C / 发消息） | 写最终 brief → commit → close_team → 退出 |
| **连续 5 次 Scout 错误** | 写 `[INTERRUPTED]` brief → commit → 退出 |
| **所有方向 + 二级探索穷尽** | 写 `[EXHAUSTED]` brief → 等待新指令 |
| **Git 冲突 / 磁盘满** | 写错误日志 → 退出 |

**没有时间上限。** 可以跑一晚上，也可以跑一周。

stop-guard.py hook 确保 agent 不会因为"觉得做完了"而自行退出——
只有上述 4 个条件才是合法的停止理由。

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|--------|-------|
| WebSearch / WebFetch | 只读，搜索和读取 |
| 创建/更新 references/patterns/ | 知识库写入 |
| 创建/更新 references/sources/{topic}.yaml | 信源评分（按 topic 分） |
| 移动 patterns 到 archive/ | 衰减清理 |
| 写 morning-brief.md | 增量报告 |
| 写 .nightshift/ 日志和状态 | 内部状态 |
| Git commit（不 push） | 版本控制 |

### CANNOT do（硬性禁止）

| 操作 | 原因 |
|--------|--------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 修改项目源代码 | 超出知识管理范围 |
| Git push | 人审核后才推 |
| 删除非 archive 的 patterns | 防止误删 |

---

## 状态持久化 & 分形索引架构

**24h 连续运行 ≈ 300-480 轮。必须有分形多层索引 + 膨胀控制。**

### 核心原则：渐进披露（Progressive Disclosure）

每一层都是下一层的摘要，每一层都自包含可读。
人在任何层级停下来都能获得完整的理解，往下钻才看到更多细节。

### 5 层分形结构



### 层间一致性规则

**每次写入 Level 3（pattern）时，必须同步更新 Level 2 和 Level 1：**

1. 写入/更新 `{topic}/{pattern}.md` (L3)
2. 更新 `{topic}/_index.md` (L2) — 添加或更新该 pattern 行
3. 更新 `_master_index.md` (L1) — 更新该 topic 的统计摘要
4. 追加 `morning-brief.md` (L0) — 添加新发现条目

**这是原子操作——4 层全更新后才 git commit。**

### 第二天归档（零债务交接）

人第二天打开仓库时：

1. **30 秒了解**：读 `morning-brief.md` → 昨晚发现了什么
2. **5 分钟概览**：读 `_master_index.md` → 知识地图全貌
3. **按需深入**：点进感兴趣的 topic → `_index.md` → 具体 pattern
4. **审核决策**：
   - `git log --oneline` 看变更历史
   - 满意 → `git push`（隐式批准）
   - 不满意 → `git revert` 或手动修改
   - conflicts.md → 人工裁决矛盾

### 膨胀控制规则

| 层级 | 文件 | 上限 | 触发动作 |
|------|------|------|----------|
| L0 | `morning-brief.md` | 50 条 | 溢出 → `.nightshift/briefs/{date}.md` |
| L1 | `_master_index.md` | 每 topic ≤ 8 行 | topic 太多 → 分组（`## 核心 / ## 探索中`） |
| L2 | `{topic}/_index.md` | 50 patterns/topic | 超限 → 拆分子 topic |
| L3 | `{pattern}.md` | 300 行 | 拆分为子 pattern（同目录） |
| L4 | `sources/{topic}.yaml` | 50 条 | 低分归档 → `sources/archive/` |
| — | `metrics/*.jsonl` | 按日期轮转 | 每天新文件 |
| — | `state.json` | 覆盖式 | 永远 < 5KB |

### Cartographer 健康检查（每 5 轮）

1. 检查各层文件大小 → 触发分裂/归档
2. 验证层间一致性 → L2 每条都能指向 L3 文件
3. 检查 sources 去重 → 跨 topic 同 URL 合并
4. metrics 日期轮转 → 新日期新文件



---

## 动态方向演化

**这是 nightshift 的核心创新：方向不是固定的，而是随着探索动态演化。**

Cartographer 在每轮结束后更新方向策略：

1. **扩展**：发现新的有价值子领域 → 添加到 active_directions
2. **收缩**：某方向连续 5 轮无新 findings → 移入 exhausted_directions
3. **分裂**：一个方向太宽泛 → 拆分为更具体的子方向
4. **合并**：两个方向实质是同一问题 → 合并
5. **Serendipity 注入**：Scout 的意外发现 → 可能催生全新方向



---

## 与 vcp-knowledge-sea 的关系

nightshift 产出的是**可操作的工程 patterns**（怎么做），
vcp-knowledge-sea 产出的是**启发性的方法论洞察**（怎么想）。

两者互补，不重叠。nightshift 的 patterns 可以作为 vcp-knowledge-sea 的素材来源。

---

## 核心原则

> **Nightshift 是不知疲倦的知识制图者。**
> 给它几个大方向，它自己探索整片大陆，动态调整路线。

> **Morning brief 是增量的。**
> 人随时打开都能看到最新进展，不需要等"完成"。

> **方向是活的，不是死的。**
> 探索过程中不断发现新的子领域、合并重复、淘汰穷尽的方向。

> **Commit but never push.**
> Git 历史提供完整审计轨迹。人推送 = 隐式批准。

> **没有时间上限，只有停止信号。**
> 世界是运动与变化的。学习不应该有人为的截止时间。
