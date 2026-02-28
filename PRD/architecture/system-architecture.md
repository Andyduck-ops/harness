# System Architecture — 三层架构

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

## 跨层交互



- **下行流**：治理层的策略（原则、spec、lessons）通过 Hook 注入到执行层
- **上行流**：执行层的证据（agent-outputs、staleness）反馈到治理层
- **闭环**：compound 命令从证据中提取教训 → 人审核 → 写入 spec → 下次注入

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
