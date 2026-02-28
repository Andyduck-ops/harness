# Core Principles — Harness 的不可违反原则

> 这 14 条原则从 18 轮 Trellis 分析、OpenAI Harness Engineering、意图工程暴论、
> 圆桌辩论（Brooks/Lamport/Taleb/Hickey/Karpathy）、以及元能力框架设计中提炼而来。
> 每条原则都经过多轮辩论验证。违反任何一条都应触发审查。

---

## 第一类：执行环境原则（Harness > Code）

### P1. Harness First

**Agent 遇到困难时，修环境，不修 prompt。**

当 Agent 反复失败，正确的反应不是"换个说法重试"，而是诊断环境中缺少什么——
工具、抽象、文档、还是验证机制——然后把缺失的能力编码到仓库里。

每一次环境改进都是对未来所有任务的投资。

> 来源：OpenAI "When the agent struggles, diagnose what's missing and build it into the repo."

### P2. Mechanical Enforcement > Documentation

**能用 hook / linter / CI 强制的，绝不只写文档。**

Agent 不会"自觉遵守"。有效约束必须是程序化的：
- PreToolUse hook → 拦截违规操作
- Custom linter → 检测架构不变量
- Structural test → 验证命名/大小/依赖方向
- CI gate → 合并前自动质量门

文档的角色是解释 "why"，不是约束 "what"。

> 来源：OpenAI "With agents, strict linting rules become multipliers."
> 验证：Trellis hook 强制注入 vs myclaude skill-rules "建议触发" — 前者100%生效，后者经常被忽略。

### P3. Progressive Disclosure

**入口 ~100 行目录，详情按需加载。**

不要把所有知识塞进一个文件。Agent 的上下文窗口是稀缺资源：
- 入口文件（AGENTS.md / index.md）只放指针
- 详细内容按阶段、按任务类型精确注入
- 高频信息常驻，低频信息按需

> 来源：OpenAI AGENTS.md ~100行 + docs/ 深层结构
> 验证：Trellis JSONL 按阶段注入 implement.jsonl / check.jsonl — 节省 60%+ token

---

## 第二类：知识资产原则（Intent > Code）

### P4. Repo as Single Brain

**不在仓库里的知识，等于不存在。**

Slack 讨论、口头约定、个人笔记——Agent 看不到。
所有设计决策、架构选择、项目规范、教训都必须版本化并存在仓库中。

> 来源：OpenAI "Slack discussions and tacit human knowledge are invisible to agents."

### P5. Intent ID Traceability

**每条关键意图原子化、唯一编号、三联映射。**

每个 Intent 同时绑定：
- 代码入口（哪个文件/函数实现了它）
- 测试/评测（如何验证它）
- 运行探针（生产环境如何观测它）

无 Intent ID 的代码变更不可合并。无测试更新的 Intent 变更不可合并。

> 来源：暴论 v2 "Intent ID 体系 + 三联映射 + 双向闸门"

### P6. Design Decisions are Explicit

**代码中的 "why" 必须被显式记录，不依赖代码隐含。**

圆桌辩论的核心教训：代码不仅是 "what"，更是 "why"。
当代码可被 Agent 重新生成时，隐含在代码结构中的设计决策会丢失。

所有关键决策用 ADR（Architecture Decision Record）格式记录：
- 背景（什么情况下做的决策）
- 选项（考虑了哪些方案）
- 决策（选了哪个，为什么）
- 后果（接受了什么 trade-off）

> 来源：Brooks "代码不仅是 what，更是 why"
> 来源：OpenAI docs/design-docs/ 目录

---

## 第三类：执行纪律原则（Discipline > Speed）

### P7. Controlled Autonomy with Budget

**给 Agent 自主探索预算，不要每步打断。**

每个任务定义：
- 时间预算（如 20 分钟）
- 重试预算（同类失败最多 3 次）
- 权限阶梯（L1 只读 → L2 测试 → L3 修改 → L4 外部操作）

预算内自主执行，到阈值触发求助。无证据的重试被禁止。

> 来源：harness-engineering SKILL.md 4级权限阶梯
> 验证：Trellis ralph-loop 无上限 debug 循环 → 第12轮分析加入 ≤3 次上限

### P8. Evidence-Based Iteration

**每次迭代必须产出证据：做了什么、结果是什么、下一步假设是什么。**

禁止：
- 无证据重试（同一命令跑两遍期望不同结果）
- 静默绕过（用 fallback 隐藏真正的失败）
- 只报问题不报选项（把决策压力全部转移给人类）

> 来源：harness-engineering SKILL.md 反模式清单
> 验证：ANCHOR 补丁（"先观察再行动"）

### P9. Structured Escalation

**到阈值主动求助，用选项型提问，一次聚焦一个决策。**

触发条件（任一即可）：
- 同类失败连续 2-3 次
- 缺少关键上下文（需求、环境变量、数据权限）
- 需要跨越安全边界
- 多个方案的成本/风险差异显著

求助格式：当前阻塞 + 已验证事实 + 根因假设 + A/B/C 选项 + 一个决策问题。

> 来源：harness-engineering SKILL.md 求助模板
> 验证：DECODE 补丁（"破译反馈，二次验证"）

---

## 第四类：进化原则（Compound > Static）

### P10. Knowledge Compounding

**每次任务完成后，系统必须变得更好。**

闭环：


教训按 Agent 架构缺陷分类（不按人类行为规范）：
- **ANCHOR**：抗幻觉（先观察再行动）
- **SHAPE**：塑形输出（适配上下文/API约束）
- **DECODE**：破译反馈（工具静默失败时二次验证）
- **ESCAPE**：逃逸死锁（连续失败时换方向）

> 来源：第十三轮 compound 设计 + 第十六轮 ANCHOR/SHAPE/DECODE/ESCAPE 框架
> 验证：OpenAI "Each encoded capability compounds over time."

### P11. Automated Garbage Collection

**定期清理 AI 生成的熵，不靠人工。**

编码 golden principles → 定期扫描偏差 → 自动修复 PR。
规模化清理必须与代码生成速度成正比。

> 来源：OpenAI "Initially spent 20% of engineering time on Friday cleanup. Didn't scale."
> 验证：Trellis staleness tracking（F9）是第一步，但还不够自动化。

### P12. Human Gate at High-Leverage Points

**人的审核放在高杠杆点，不是每个步骤。**

高杠杆点：
- PRD/Spec 审批（决定做什么）
- 战略方向调整（决定系统往哪走）
- 高风险操作（安全/支付/权限/生产环境）

低杠杆点（Agent 自主）：
- 代码生成、测试执行、常规 lint/format
- 知识校准（calibrate/nightshift）
- 教训提取和沉淀（compound）
- Agent-to-Agent review

**人的带宽极其有限，自动化一切可以自动化的。**

> 来源：第十轮 "人审核批准 = 最可靠的 gate"
> 来源：OpenAI "Minimal blocking gates — corrections are cheap, waiting is expensive."
> 演化：从"人审核每条知识"→"人只看 morning brief"（元能力框架升级）

---

## 第五类：进化原则（Evolution > Static）

### P13. Living Knowledge

**知识必须流动，不能静止。世界是运动与变化的。**

AI coding 最佳实践每天都在变。静态知识库在几周内过时。
系统必须具备持续校准能力：

- **外循环**：从外部世界（X、博客、官方文档）获取新知识
- **内循环**：从自己的任务经验中提取教训
- **合并**：外部新知 + 内部经验 → 更新 patterns
- **清理**：过期/低质量知识定期衰减、归档

知识的三层腐化速度不同：
- Bedrock（原理）→ 几乎不变
- Patterns（模式）→ 季度级
- Practices（实践）→ 周级~日级

> 来源："世界是运动与变化的" — 元能力框架讨论
> 来源：OpenAI compound engineering "每次工作改善系统本身"

### P14. Self-Evolving System

**Harness 必须能改进自己。方法论固定，实现动态适配。**

底层的元问题是不变的（Agent 的 4 个架构缺陷、知识腐化、强制执行的必要性等）。
但具体解法必须根据项目特征和最新实践动态调整：

- **不教条主义**：每个 pattern 带多种实现变体，按项目选最优
- **阶段性适配**：项目不同阶段需要不同的 harness 配置
- **夜间自主学习**：Agent 可以挂机自主冲浪，第二天产出 morning brief
- **有界自迭代**：Harness 可以改进自己的知识获取和处理方式，但不改核心原则

> 来源："实践论，不教条主义" — 元能力框架讨论
> 来源：OpenAI "When the agent struggles, build the missing capability into the repo"

---

## 原则的使用方式

1. **每次设计决策前**：检查是否违反 14 条原则中的任何一条
2. **每次 PR 审查时**：验证变更是否符合相关原则
3. **每次系统改进时**：确认改进方向与原则一致
4. **每次辩论分歧时**：用原则作为裁决依据
5. **每次 nightshift 校准后**：检查新知识是否挑战现有原则

## 原则的演化

这 14 条原则不是永恒不变的。但修改原则本身需要：
- 明确的反例或新证据
- 至少 3 次实践验证
- 记录变更的 ADR
- 人工显式批准（原则修改是高杠杆决策）
