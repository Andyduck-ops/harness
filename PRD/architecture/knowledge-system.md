# Knowledge System — 渐进注入与知识进化

## 设计目标

解决 Agent 的三个根本矛盾：
1. **需要足够上下文才能做好工作** vs **上下文窗口是有限资源**
2. **每次任务都在产出知识** vs **知识不会自动积累到系统中**
3. **外部最佳实践每天在变** vs **系统的知识库是静态的**

## 知识分层架构



## JSONL 精确注入机制

### 格式



### 注入规则

| 字段 | 必填 | 说明 |
|------|------|------|
| `file` | ✅ | 相对于 `.harness/` 的路径 |
| `reason` | ✅ | 为什么需要这个文件（Agent 可读） |
| `type` | 可选 | `"file"` 或 `"directory"`（目录只读 .md 文件） |

### 各阶段注入策略

| 阶段 | 总是注入 | 条件注入 |
|------|---------|----------|
| **所有阶段** | lessons/index.md, prd.md | — |
| **implement** | spec/{relevant-domain}/index.md | 从 prd.md 自动提取文件路径 |
| **check** | 验证命令列表 | agent-outputs/implement-result.md |
| **debug** | check 失败证据 | agent-outputs/check-result.md |
| **finish** | 全部 agent-outputs/ | — |

### Token 预算

| 注入内容 | 预算 |
|---------|------|
| lessons/index.md | < 1000 tokens |
| 单个 spec/index.md | < 2000 tokens |
| agent-outputs/ 单文件 | < 3000 tokens |
| 总注入量 | < 8000 tokens |

## 教训分类框架：ANCHOR/SHAPE/DECODE/ESCAPE

### 为什么不用 NEVER/ALWAYS/CHECK？

传统分类（行为规范）犯了拟人化谬误。Agent 不是人——是 "Text-in/Text-out Brain in a Vat"。

教训应该按 **Agent 架构缺陷** 分类，而非人类行为规范：

| 类型 | 修补的缺陷 | Agent 读到后的行为改变 | 示例 |
|------|-----------|---------------------|------|
| **ANCHOR** | 幻觉（Hallucination） | 停止假设，转而观察真实状态 | "修改文件前必须先 Read" |
| **SHAPE** | 窗口限制 & 语法死板 | 改变生成策略，适配约束 | "不要 cat 大文件" |
| **DECODE** | 感知黑盒（Blindness） | 停止盲推，追加二次验证 | "sed 无输出 ≠ 成功" |
| **ESCAPE** | 局部最优（Looping） | 放弃当前思路，换方向 | "连续失败 2 次改策略" |

### 教训生命周期



### 三级升级路径

| 级别 | 存储 | 验证次数 | 执行方式 | 归宿 |
|------|------|---------|---------|------|
| L1 实验 | ANCHOR/SHAPE/DECODE/ESCAPE.md | 1-2x | 仅注入参考 | → L2 或废弃 |
| L2 规范 | spec/{domain}/index.md | 3-9x | JSONL 注入 | → L3 或保留 |
| L3 自动化 | hook / linter / CI | 10+x | 机械化强制 | 归档到 ADR |

教训的最终归宿不是文档——是自动化。

## 知识腐化治理

### 检测

| 维度 | 方法 | 成本 |
|------|------|------|
| 文件级 | 修改文件 ∩ JSONL 引用文件 | 零 LLM |
| Spec 级 | 修改时间启发式 | 零 LLM |
| 任务级 | check 通过后提示更新 | 低 LLM |

### 处理

- 腐化检测 → `.harness/.stale-knowledge.json`
- SessionStart 注入腐化警告
- Agent 更新 spec 后清除标记
- 90 天未引用 → 标记 stale
- 被新教训替代 → 标记 superseded

## 与 OpenAI 模式的对照

| OpenAI | Harness | 差异 |
|--------|---------|------|
| AGENTS.md ~100行目录 | AGENTS.md ~100行目录 | 一致 |
| docs/ 按文档类型分 | spec/ 按领域分 + lessons/ 按缺陷分 | Harness 更精确 |
| Custom linters | hooks + linters | Harness 增加了运行时拦截 |
| Garbage collection agents | compound + staleness + nightshift | Harness 自动化程度更高 |
| Quality grades | validation gates | 类似 |

## Pattern Store — Skill 格式知识库

### 为什么用 Skill 格式

知识大部分是同构的——不同文章说的往往是同一个元问题的不同解法。
存储格式必须：可索引、可排序、可热插拔、可压缩合并。

### Pattern 格式

每个 pattern 是一个独立的 Markdown 文件，带 YAML frontmatter：

```yaml
---
name: progressive-disclosure
topic: context-injection
confidence: 0.95
verified_count: 12
sources:
  - openai-harness-engineering (2026-02)
  - agent-skills-ce (2026-01)
last_verified: 2026-02-28
rank: 1
---

## 元问题
Agent 上下文窗口有限，全量注入导致关键信息被淹没。

## 核心解法
入口文件 ~100 行只放指针，详细内容按需加载。

## 证据
- OpenAI: AGENTS.md ~100行 + docs/ 深层结构
- BrowseComp: token usage explains 80% of performance variance

## 实现变体
- Hook 注入式（Trellis JSONL）
- Skill 三级加载（Agent-Skills-for-CE）
- 目录 + references/（OpenAI）

## 反模式
- 单个巨型指令文件（>2000行）
- 全量注入不分阶段
```

### Topic 子文件夹

```
references/patterns/
├── context-injection/      # 上下文注入
├── quality-enforcement/    # 质量强制
├── agent-lifecycle/        # Agent 生命周期
├── knowledge-evolution/    # 知识进化
├── meta-framework/         # 元框架自身的模式
└── _master_index.md        # 全局索引 + top ranking
```

每个 topic 有 `_index.md` 摘要，由 Merge 模块自动生成/更新。

### Rerank 机制

多维评分（5 维度加权）：

| 维度 | 权重 | 说明 |
|------|------|------|
| 来源可信度 | 0.2 | 官方 > 大佬 > 社区 |
| 证据强度 | 0.3 | 定量 > 案例 > 经验 |
| 实践验证次数 | 0.25 | compound 反馈的使用频率 |
| 时效性 | 0.15 | 近期发现加分，Lindy 效应也加分 |
| 原理一致性 | 0.1 | 与 bedrock 原理的对齐程度 |

**定期衰减：** 90 天无引用、无验证 → 分数衰减 → 归档。

### 压缩合并规则

- 同一元问题只保留一条 pattern，包含所有实现变体
- 超阈值 topic → 压缩摘要 + 归档详情
- 矛盾的 patterns → 标记 [CONFLICT]，不自动解决
- patterns/ 超 100 条时触发强制合并

## 双循环知识进化

| 循环 | 输入 | 输出 | 触发 |
|------|------|------|------|
| **内循环（compound）** | 自己的任务经验 | ANCHOR/SHAPE/DECODE/ESCAPE 教训 | 任务完成后 |
| **外循环（calibrate）** | X/博客/官方文档 | 更新的 patterns/ | 手动/nightshift |

**汇聚点：** compound 成熟教训（verified_count ≥ 3）自动提名升级到 patterns/。
外循环新知 + 内循环经验 → Merge 合并 → Generator 投影到项目。

详见 → [meta-capability.md](./meta-capability.md) | [nightshift.md](./nightshift.md)
