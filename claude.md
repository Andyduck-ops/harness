# Claude 对 Harness 的基本认识

## 核心定位
Harness 是一个**自进化 AI Agent 执行环境工程系统**。
- 不写代码，而是构建让 Agent 可靠产出代码的整个环境
- 核心资产是执行环境（Harness），代码是副产品

## 关键理念
1. **Harness First**: Agent 遇到困难时，修环境，不修 prompt
2. **Mechanical Enforcement > Documentation**: 能用 hook/linter/CI 强制的，绝不只写文档
3. **Progressive Disclosure**: 入口 ~100 行目录，详情按需加载
4. **Knowledge Compounding**: 每次任务完成后，系统变得更好
5. **Living Knowledge**: 知识必须流动，世界是运动与变化的
6. **Self-Evolving**: 方法论固定，实现动态适配，系统可以改进自己

## 三层知识腐化速度
- **Bedrock（原理）**: 几乎不变 - 来自 Brooks/Lamport/Taleb/Hickey 等的第一性原理
- **Patterns（模式）**: 季度级 - references/patterns/ 下的可复用模式
- **Practices（实践）**: 周级~日级 - 具体实现细节

## 元能力系统（自进化）

### 双循环知识进化

| 循环 | 输入 | 输出 | 触发 | 持续 |
|------|------|------|------|------|
| **内循环（compound）** | 自己的任务经验 | ANCHOR/SHAPE/DECODE/ESCAPE 教训 | 任务完成后 | ~10 min |
| **外循环（calibrate）** | 外部文章/博客/官方文档 | patterns/ 知识库 | 手动，白天 | ~20 min |
| **夜间学习（nightshift）** | 全部信源 + 探索 | patterns/ + morning-brief.md | 手动启动 | 无上限 |

**数据流**：
```
外部世界 → calibrate/nightshift → patterns/（外循环）
                                      ↓
内部经验 → compound → 新教训 → patterns/（内循环）
                                      ↓
                                   sleep（压缩）
```

**核心理念**：
- **Compound（内循环）**: 知识复利 = 每次工作都让系统变好一点
- **Calibrate（外循环）**: 从外部世界获取新知识，按需加载
- **Nightshift（持续学习）**: Agent 持续自主冲浪学习，无时间上限
- **Sleep（压缩）**: 定期压缩、合并、清理 patterns/

**自迭代**: Harness 可以改进自己的知识获取和处理方式

## Nightshift 的核心特征
- **两个独立实现**：
  - **nightshift**（AI 工程实践）：半衰期 1-3 年，怎么做（How）
  - **nightshift-phi**（哲学与方法论）：半衰期 10-100 年，为什么这样做（Why）
  - 两者共享 L1-L7 约束，但知识库物理隔离
- **三角色 Team 架构**：Cartographer（Lead）、Scout、Analyst
- **持续运行**: 无时间上限，人叫停才停
- **增量更新**: morning-brief.md 实时追加，人随时可看
- **L1-L7 学习原则**（Anti-Governance-Recursion）：
  - L1: 学习是压缩不是积累（饱和门：per-topic ≤ 5 patterns）
  - L2: 默认同化，例外创建（Assimilate-First）
  - L3: 注意力有限（方向上限 ≤ 15）
  - L4: 周期性压缩（每 5 cycles 强制压缩）
  - L5: 检索测试 + 功能去重
  - L6: 显式衰减（10 cycles → dormant，30 cycles → archive）
  - L7: 不量化不可量化的
- **安全边界**: 可以更新 references/patterns/，但不能修改 PRD/bedrock/generator/
- **质量保障**:
  - Noise Filter: 标记 [NOISE] 的直接丢弃
  - Confidence Threshold: < 0.4 不写入
  - Bedrock Guard: 与核心原理冲突 → 不写入，等人处理
  - Merge 压缩: 同构知识强制合并
  - Decay 机制: 10 cycles 无引用 → dormant → 30 cycles → archive

## 当前问题
nightshift 产出的 patterns 文件可能过于臃肿（如 agent-scope-identity-memory-governance.md 390 行）。
需要设计一个 sleep 模式来定期压缩、合并、清理这些文档。

## 设计原则（14 条核心原则）
见 PRD/core-principles.md，每次设计决策前必须检查是否违反。
