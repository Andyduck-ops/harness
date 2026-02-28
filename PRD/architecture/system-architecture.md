# System Architecture — 四层架构

## 设计哲学



## 三层模型



## Layer 1: 执行层（Agent Runtime）

### 职责
- Agent 在沙盒内自主执行任务
- Hook 在边界点强制注入上下文、拦截违规、收集证据
- 权限阶梯控制 Agent 能做什么

### 核心组件

| 组件 | 触发时机 | 职责 |
|------|---------|------|
| **context-injector** | SessionStart / PreToolUse | 按阶段精确注入 spec + lessons + task context |
| **guard-rails** | PreToolUse | 拦截高风险操作（EHRB 检测）|
| **evidence-collector** | PostToolUse | 记录操作 + 结果，写入 agent-outputs/ |
| **quality-gate** | SubagentStop | 强制验证命令通过才允许退出（ralph-loop 演进）|
| **staleness-tracker** | PostToolUse(Edit/Write) | 检测代码变更与知识文件的脱节 |

### Hook 生命周期



## Layer 2: 编排层（Orchestration）

### 职责
- 按阶段推进任务流水线
- 路由失败到正确的处理路径
- 不读 spec、不读需求——职责极简

### 标准流水线



### 阶段间数据流

**核心创新：文件系统 = Agent 间通信信道**



上游 agent 输出写入 `agent-outputs/`，下游 JSONL 引用，hook 自动注入。
文件不存在时静默跳过（防御性设计）。

### 失败路由

| 失败类型 | 处理 |
|---------|------|
| 第 1 次失败 | 重试，换策略 |
| 第 2 次同类失败 | 触发 debug agent |
| 第 3 次同类失败 | 升级人工（SPARV 3-Failure Protocol）|
| 权限不足 | 升级到更高权限阶梯 |
| 缺少上下文 | 结构化求助（选项型提问）|

## Layer 3: 治理层（Governance）

### 职责
- 人在关键决策点审批
- 系统级策略定义
- 长期知识资产管理

### 人工守门点

| 守门点 | 触发条件 | 人的角色 |
|--------|---------|----------|
| **PRD 审批** | plan agent 完成 prd.md | 审核意图、边界、成功标准 |
| **教训审核** | compound 提取教训后 | 审核教训质量、决定写入位置 |
| **3-Failure 升级** | 连续 3 次同类失败 | 决定策略调整或放弃 |
| **高风险操作** | Agent 请求 L4 权限 | 确认外部/生产操作 |

### 策略文件

| 文件 | 作用 |
|------|------|
| `PRD/core-principles.md` | 12 条不可违反原则 |
| `spec/lessons/` | 分层教训库（ANCHOR/SHAPE/DECODE/ESCAPE）|
| `spec/*/index.md` | 领域知识索引 |
| `ADR/` | 架构决策记录 |

## Layer 4: 元能力层（Meta-Capability）

### 职责
- 持续从外部世界获取和蒸馏新知识
- 管理知识的评分、排序、合并、清理
- 根据项目特征生成适配的执行环境
- 自迭代改进自身的知识处理能力

### 核心模块

| 模块 | 职责 | 触发方式 |
|------|------|----------|
| **Scout** | 从信源列表 + 关键词搜索获取新知 | nightshift / calibrate |
| **Distill** | 蒸馏为 Skill 格式的结构化知识 | Scout 之后自动 |
| **Analyze** | 第一性原理交叉验证 | Distill 之后自动 |
| **Rank** | 多维评分 + rerank 排序 | 每次知识变更后 |
| **Merge** | 同构知识合并 + 过期清理 | 定期 / nightshift |

### Generator（项目适配生成器）

从 patterns/ 选择适用模式 → 结合项目特征 → 生成定制的 .harness/ 配置：

| 生成产物 | 说明 |
|---------|------|
| hooks 配置 | 哪些 hook、触发条件、严格程度 |
| agent 列表 | 需要哪些 agent、各自职责 |
| workflow 定义 | 流水线阶段和顺序 |
| quality gate 配置 | 验证命令、失败阈值 |
| spec 目录结构 | 按项目领域组织 |
| JSONL 初始内容 | 按 spec 结构生成 |

**方法论固定，实现动态适配。不教条，走项目特色。**

详见 → [meta-capability.md](./meta-capability.md) | [nightshift.md](./nightshift.md)

## 跨层交互

- **下行流**：治理层的策略通过 Hook 注入到执行层
- **上行流**：执行层的证据反馈到治理层
- **内循环**：compound 从证据中提取教训 → 沉淀到 patterns
- **外循环**：Scout 从外部获取新知 → 蒸馏 → 融入 patterns
- **生成流**：Generator 从 patterns + 项目特征 → 生成适配的执行层配置

## 跨平台设计

### 通用层（平台无关，存于 Git 仓库）



任何 AI agent 都能读 Markdown。知识与平台解耦。

### 平台适配层（生成产物）

| 目标平台 | 配置目录 | Hook 机制 | Agent 机制 |
|---------|---------|----------|----------|
| **Claude Code** | `.claude/` | Python hooks（4 种事件）| `.claude/agents/*.md` |
| **Codex** | `.agents/` | 无原生 hook（AGENTS.md 指令替代）| `.agents/skills/*/SKILL.md` |
| **Cursor** | `.cursor/` | 无原生 hook（rules 替代）| 无独立 agent |

### 降级策略

| 能力 | Claude Code | Codex | Cursor |
|------|------------|-------|--------|
| 强制注入 | ✅ Hook | ⚠️ AGENTS.md | ⚠️ Rules |
| 质量门 | ✅ SubagentStop | ❌ 靠 CI | ❌ 靠 CI |
| 渐进注入 | ✅ JSONL + Hook | ⚠️ Skill 三级加载 | ❌ 全量 |
| 夜间学习 | ✅ background agent | ✅ async task | ❌ 无 |

## 隔离保障

### 项目级隔离
- 所有 hook 有 `[ -d .harness ]` 守卫
- 无 `.harness/` 目录的项目完全不受影响

### 任务级隔离
- 每个任务的状态文件独立：`{task_dir}/.state.json`
- 多任务并行时无状态竞争

### 平台适配
- 核心逻辑平台无关（Python hooks + shell scripts）
- 平台特定配置通过 adapter 层隔离
