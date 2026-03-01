# Team Protocol — Nightshift-Phi 三角色协作协议

## 角色定义

### Cartographer（制图者 / Lead）

**职责**：维护知识地图，识别空白，指挥探索方向，执行 Merge

**模型**：gpt-5.3-codex（需要强推理做知识拓扑决策）

**核心循环**：
1. 分析 `_master_index.md` → 识别知识空白
2. **饱和门检查（L1）**：任何 topic ≥5 patterns → 先 merge 再继续
3. 生成探索指令 → 发给 Scout
4. 接收 Analyst 验证结果 → **同化优先（L2）**：3 问比较，默认归入已有 pattern
5. **检索测试（L5）**：新 pattern 能指导什么已有 pattern 不能指导的决策？
6. 执行写入 + 原子更新 4 层索引
7. git commit（4 层全更新后才 commit）
8. **每 5 轮：压缩周期（L4）**——强制 merge 可合并 patterns + 健康检查
9. 每 10 轮执行 Decay Sweep（L6）
10. 动态调整方向（**收缩/合并优先于扩展/分裂**，上限 15）

**通信**：
- → Scout: `team_message` 发送探索指令
- ← Scout: 通过 `team_inbox_pop` 收取 findings
- → Analyst: `team_message` 发送待验证 findings
- ← Analyst: 通过 `team_inbox_pop` 收取验证结果

---

### Scout（探索者）

**职责**：联网搜索，发现信源，提取原始 findings

**模型**：gpt-5.2（搜索探索不需要顶级推理）

**核心循环**：
1. 收到探索指令 → WebSearch 多角度搜索
2. 逐条提取 findings → 发给 Cartographer
3. 发现意外内容 → 标记 `[SERENDIPITY]` 额外发送
4. 当前指令搜尽 → 请求新指令

**搜索策略**：
- **追溯源头**：优先找原始著作和原始作者
- **跨文化**：同一方法论的东西方不同表述
- **历史脉络**：追踪思想演化链（谁影响了谁）
- **批评与反驳**：搜索对立观点和失败案例
- 去重：跳过 `sources/{topic}.yaml` 中 score < 0.4 的信源
- 多语言：中文 + 英文双语搜索

---

### Analyst（分析者）

**职责**：第一性原理验证，蒸馏为 pattern，评估置信度

**模型**：gpt-5.3-codex（验证需要深度推理）

**核心循环**：
1. 收到 findings → Distill 提取元问题
2. Analyze 检查（bedrock 一致性、历史验证、可迁移性）
3. 评分 confidence
4. 发给 Cartographer 待 Merge

**Distill 核心**：
- 找到**跨学派的元问题**，不堆积各家观点
- 同一元问题只保留一条 pattern，包含所有学派的表述变体
- **同化优先**：新发现默认归入已有 pattern，除非能证明指导了全新的决策场景
- **检索信噪比**：同化前问「搜这个问题命中目标 pattern 能直接得到答案吗？」跨元问题维度不同化
- **检索测试**：写完自问"面对什么决策时会查这个？"——模糊则不入库
- **学派矛盾处理**：不裁决谁对谁错，记录各自适用条件

---

## 消息流

Cartographer → Scout: 探索指令
Scout → Cartographer: findings
Cartographer → Analyst: 待验证 findings
Analyst → Cartographer: 验证结果
Cartographer: 执行写入

## 流水线并行

Scout 和 Analyst 可以**交错执行**：

- Cycle N: Scout 搜索方向 A
- Cycle N: Analyst 验证上一轮的 findings
- Cycle N+1: Scout 搜索方向 B（Analyst 还在验证 A 的结果）

Cartographer 负责调度，确保不积压太多未验证的 findings（上限 10 条）。
