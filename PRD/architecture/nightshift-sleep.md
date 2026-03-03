# Sleep — 方法论编译器与元逻辑合成器

## 第一性原理：从“文档压缩”到“方法论编译”

### 元问题
传统的知识积累模式（Nightshift）产出的是“带血的证据”和“散乱的经验”。如果直接把这些原始信息推给 Agent，会导致：
1. **语义过载**：Agent 被细节淹没，无法抓取本质。
2. **缺乏鲁棒性**：经验往往带有特定框架/语言的偏置，换个环境就失效。
3. **决策漂移**：没有统一的元逻辑锚点，Agent 会在矛盾的建议中反复横跳。

**Harness 的解法**：Sleep 不仅仅是压缩，它是 **Harness 元框架的后端编译器**。

---

## 核心设计理念：编译器思维

### 1. 知识的降层（Knowledge Lowering）
类似于编译器将高级语言源码降层为 IR（中间表示），Sleep 的任务是将 `Patterns`（高级经验）降层为 **`Meta-Logic IR`（元逻辑芯片）**。
- **源码**：`patterns/` 中的原始文档（包含特定 API、报错信息、长篇叙述）。
- **IR（全息碎片）**：不带偏置的元逻辑骨架。它解释了“为什么（Why）”和“决策点（Decision Points）”。
- **目标**：这种 IR 应该具备**深刻的鲁棒性**，能被解压（Lowered）到任何具体项目（Python/Go/JS）中。

### 2. 元问题锚定（Meta-Problem Anchoring）
知识不按“文件名”组织，而按“元问题”锚定。每一个 `distilled` 碎片必须是一个 **元问题的解空间模型**。
- **锚点示例**：*“如何治理长序列任务中的意图腐化？”*
- **逻辑**：只要元问题不变量（Invariant）存在，该碎片就永不过时。

### 3. 方法论的弹性适配（Target Adaptation）
作为编译器，Sleep 必须产出带有 **“环境适配参数”** 的智慧。
- 它不给出死板的数值，而是给出 **“风险/成本/效率”的折中函数**。
- **示例**：*“当项目 Risk 级别从 Medium 升至 High 时，意图验证门禁必须从‘采样审计’自动升级为‘全量阻塞审计’。”*

---

## 运作机制：元能力重构循环

### 1. 神经剪枝：提炼不变量（Invariants）
Sleep 扫描所有 patterns，寻找跨领域的高频共鸣点。
- **动作**：将碎片化的经验合并为**“髓鞘化”的方法论路径**。
- **输出**：Bedrock 层的更新建议或 `distilled/` 中的核心碎片。

### 2. 对抗性模拟（Generative Dreaming）
Sleep 在合成新方法论后，必须进行 **“离线压力测试”**。
- **测试**：模拟一个极端、陌生的靶场环境，让 Agent 仅凭该方法论碎片进行决策推理。
- **判据**：如果 Agent 能推导出“环境补偿策略（Compensation Strategy）”，则该方法论具备深刻鲁棒性。

### 3. 反向反馈：给 Nightshift 的“研究令”
Sleep 发现的逻辑断层（无法自洽的矛盾、证据不足的推论）必须转化为 **`research-back-signals.md`**。
- **联动**：Nightshift 收到信号后，下一轮搜索将从“泛搜”转为“攻坚”，寻找缺失的逻辑拼图。

---

## 全息碎片（Holographic Fragment）新规范

每个碎片不再是“摘要”，而是一枚 **“Harness 逻辑芯片”**：

1. **Meta-Problem ID**：唯一锚定的元问题 ID。
2. **The Logic (The Why)**：底层的逻辑推导，解释矛盾的本质。
3. **Invariant Solution (Abstract How)**：框架无关的方法论骨架。
4. **Adaptation Matrix (Target Rules)**：基于项目 Profile（Risk, Lang, Type）的适配规则。
5. **Recovery/Failure Contract**：极端情况下的鲁棒性保障路径。
6. **Provenance**：指向 `patterns/` 证据层的溯源指针。

---

## 运作规则与安全边界

### 1. 镜像一致性（The Mirror Principle）
- `distilled/`（逻辑层）的变化必须在 `_distilled_index.md` 中同步。
- 每一个 `distilled` 碎片必须能在 `patterns/` 中找到至少两个互证的证据来源。

### 2. 深度审计门（The Deep Audit Gate）
- **Self-Containment**：单卡片逻辑自洽。
- **Inference Robustness**：在模拟环境下的推理成功率（新加入）。
- **Traceability**：审计指针未断裂。

### 3. 禁止操作
- 禁止修改 `PRD/`（除通过人工审批的本补丁）。
- 禁止在没有证据支撑的情况下空转生成方法论。
- 禁止删除 `patterns/` 中的原始证据（必须移入 `_archive/`）。

---

## 总结：智慧的味道

**Sleep 的成功标准不是“压缩率”，而是“编译成功率”。**
当一个从主仓库导出的 `distilled` 芯片，插入到一个全新的、陌生的目标项目中，能够通过 `harness-bootstrap` 指导 Agent 自动生成一套**完美适配、逻辑自洽且能拦截真实风险**的 Hook 时，我们就得到了真正的“智慧”。
