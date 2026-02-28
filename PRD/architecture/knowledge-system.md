# Knowledge System — 渐进注入与知识进化

## 设计目标

解决 Agent 的两个根本矛盾：
1. **需要足够上下文才能做好工作** vs **上下文窗口是有限资源**
2. **每次任务都在产出知识** vs **知识不会自动积累到系统中**

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
| Garbage collection agents | compound + staleness tracking | Harness 更结构化 |
| Quality grades | validation gates | 类似 |
