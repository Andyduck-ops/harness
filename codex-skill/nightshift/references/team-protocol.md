# Team Protocol — Nightshift 三角色协作协议

## 角色定义

### Cartographer（制图者 / Lead）

**职责**：维护知识地图，识别空白，指挥探索方向，执行 Merge

**模型**：gpt-5.3-codex（需要强推理做知识拓扑决策）

**核心循环**：
1. 分析 `_master_index.md` → 识别知识空白
2. 生成探索指令 → 发给 Scout
3. 接收 Analyst 验证结果 → Rank & Merge
4. **原子更新 4 层索引**：L3(pattern) → L2(_index.md) → L1(_master_index) → L0(brief)
5. git commit（4 层全更新后才 commit）
6. 每 5 轮执行文件健康检查（膨胀控制）
7. 每 10 轮执行 Decay Sweep
8. 动态调整方向（扩展/收缩/分裂/合并/Serendipity）

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
- 广度优先：每个指令搜索 3-5 个不同角度
- 二级探索：从已有 patterns 关键词出发做关联搜索
- 去重：跳过 `sources/{topic}.yaml` 中 score < 0.4 的信源
- 多语言：中文 + 英文双语搜索

**Finding 格式**：


---

### Analyst（分析者）

**职责**：第一性原理验证，蒸馏为 pattern，评估置信度

**模型**：gpt-5.3-codex（验证需要深度推理）

**核心循环**：
1. 收到 findings → Distill 提取元问题
2. Analyze 检查（bedrock 一致性、证据、可操作性）
3. 评分 confidence
4. 发给 Cartographer 待 Merge

**Distill 核心**：
- 找到元问题，不堆积方案
- 同一元问题只保留一条 pattern
- 保留所有实现变体

**输出格式**：


---

## 消息流



## 流水线并行

关键：Scout 和 Analyst 可以**交错执行**：

- Cycle N: Scout 搜索方向 A
- Cycle N: Analyst 验证上一轮的 findings
- Cycle N+1: Scout 搜索方向 B（Analyst 还在验证 A 的结果）

Cartographer 负责调度，确保不积压太多未验证的 findings（上限 10 条）。
