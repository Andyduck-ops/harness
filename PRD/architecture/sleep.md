# Sleep — 知识压缩与重构守护进程

## 设计目标

将"读厚"的知识压缩为"读薄"的智慧，同时保持可追溯性。
定期扫描 patterns/，检测臃肿文件，执行同构检测、证据合并、边界条件提取。

**不是删除知识，是重构知识结构。**

---

## 核心理念

### 人类学习的本质

1. **读厚（Expansion）**：接触新信息 → 建立多个独立的知识点
2. **读薄（Compression）**：发现模式 → 提取元问题 → 合并同构知识
3. **成为专家**：能快速识别新问题属于哪个元问题

Nightshift 负责"读厚"，Sleep 负责"读薄"。

### 与 Nightshift 的关系

| 维度 | nightshift | sleep |
|------|-----------|-------|
| 触发 | 手动启动，持续运行 | 定期触发（如每周）或手动 |
| 输入 | 外部信源（X、博客、文档） | 内部 patterns/ 目录 |
| 输出 | 新 patterns（读厚） | 压缩 patterns（读薄） |
| 方向 | 扩张（Expansion） | 收缩（Compression） |
| 安全边界 | 不改 PRD/bedrock | 不改 PRD/bedrock |

---

## 执行模型

### 触发条件（任一即可）

1. **手动触发**：`/harness:sleep`
2. **定期触发**：每周日凌晨自动运行（cron job）
3. **阈值触发**：
   - 单个 pattern 文件 > 200 行
   - patterns/ 总文件数 > 50 个
   - 同一 topic 下文件数 > 8 个

### 执行模式

| 模式 | 触发 | 持续时间 | 输出 |
|------|------|----------|------|
| **前台模式** | 手动 `/harness:sleep` | ~30 min | 实时显示进度 |
| **后台模式** | 定期/阈值触发 | ~30 min | 写入 sleep-report.md |

**后台运行特性**：
- 可以像 nightshift 一样挂在后台
- 不阻塞其他操作
- 完成后产出 sleep-report.md
- 人随时可以查看报告

### 执行流程

```
1. Scan（扫描）
   ↓
2. Detect（检测臃肿）
   ↓
3. Analyze（同构分析）
   ↓
4. Split/Merge（拆分/合并）
   ↓
5. Verify（验证可生成性）
   ↓
6. Archive（归档旧版本）
   ↓
7. Report（生成报告）
```

---

## 每个阶段的详细设计

### Step 1: Scan（扫描）

扫描 `references/patterns/` 下所有非归档的 `.md` 文件：

```bash
find references/patterns -name "*.md" -type f ! -path "*/_archive/*"
```

统计每个文件的：
- 行数
- sources 数量
- 最后修改时间
- confidence 分数

### Step 2: Detect（检测臃肿）

标记需要处理的文件（满足任一条件）：

| 条件 | 阈值 | 原因 |
|------|------|------|
| 行数 > 200 | 臃肿 | 违反 Progressive Disclosure |
| sources > 15 | 可能混杂多个元问题 | 需要同构检测 |
| 同 topic 下文件数 > 8 | 可能有重复 | 需要合并检测 |

### Step 3: Analyze（同构分析）

对每个臃肿文件，执行同构检测：

**输入**：一个臃肿的 pattern 文件（如 390 行的 agent-scope-identity-memory-governance.md）

**分析维度**：
1. **元问题识别**：这些 sources 在说几个不同的元问题？
2. **证据聚类**：哪些 sources 在说同一件事？
3. **边界条件**：哪些是核心规律，哪些是特例？
4. **实现变体**：同一元问题有几种实现方式？

**输出**：
- 元问题列表（如：Session 管理、State 序列化、Handoff 机制、Memory budget）
- 每个元问题的 sources 分组
- 拆分建议

### Step 4: Split/Merge（拆分/合并）

#### 拆分策略

如果一个文件包含多个元问题（如 > 3 个），拆分为多个文件：

**原文件**：`agent-scope-identity-memory-governance.md`（390 行，29 sources）

**拆分后**：
- `agent-session-management.md`（元问题：如何管理 agent 会话）
- `agent-state-serialization.md`（元问题：如何序列化和恢复状态）
- `agent-handoff-protocol.md`（元问题：agent 间如何通信）
- `agent-memory-budget.md`（元问题：如何控制 token 使用）

每个文件：
- 只聚焦一个元问题
- 保留相关的 sources
- 更新 confidence 和 verified_count

#### 合并策略

如果同一 topic 下有多个文件在说同一个元问题，合并为一个文件：

**检测方法**：
- 读取同 topic 下所有文件的"元问题"字段
- 用 LLM 判断语义相似度
- 相似度 > 0.85 → 标记为候选合并

**合并规则**：
- 保留 confidence 最高的文件作为主文件
- 其他文件的 sources 合并到主文件
- 其他文件移动到 `_archive/`

### Step 5: Verify（验证可生成性）

对每个拆分/合并后的文件，验证：

**可生成性测试**：
- 给 LLM 看压缩后的 pattern
- 让它回答：如何在 OpenAI Agents SDK 中实现 session 管理？
- 如果能正确回答（包含关键 API、参数、边界条件）→ 通过
- 如果不能 → 压缩过度，需要补充细节

**反模式检测**：
- 是否丢失了关键的边界条件？
- 是否丢失了重要的反模式警告？
- 是否丢失了实现变体的对比？

**时效性验证（可选）**：
- 如果 pattern 中包含具体的 API 名称、参数、版本号
- 可选择联网查询最新文档，验证信息是否过时
- 如果发现过时 → 标记 `[STALE]`，写入 sleep-report.md
- 不自动修复（那是 calibrate/nightshift 的职责）

### Step 6: Archive（归档旧版本）

所有被拆分/合并的原文件移动到：

```
references/patterns/_archive/YYYYMMDD_sleep/
```

保留完整的历史记录，支持回滚。

### Step 7: Report（生成报告）

生成 `sleep-report.md`：

```markdown
# Sleep Report — YYYY-MM-DD

## Summary

- Scanned: 44 patterns
- Detected bloat: 6 files
- Split: 2 files → 8 files
- Merged: 4 files → 2 files
- Archived: 6 files
- Net change: +4 files, -1200 lines

## Details

### Split Operations

#### agent-scope-identity-memory-governance.md (390 lines → 4 files)

**元问题识别**：
1. Session 管理（12 sources）
2. State 序列化（8 sources）
3. Handoff 协议（5 sources）
4. Memory budget（4 sources）

**拆分结果**：
- agent-session-management.md (95 lines, confidence: 0.89)
- agent-state-serialization.md (78 lines, confidence: 0.87)
- agent-handoff-protocol.md (62 lines, confidence: 0.85)
- agent-memory-budget.md (58 lines, confidence: 0.83)

**可生成性验证**：✅ 通过

### Merge Operations

#### context-injection/progressive-disclosure.md + context-injection/lazy-loading.md

**元问题**：如何按需加载上下文

**合并理由**：语义相似度 0.92，说的是同一个元问题

**合并结果**：context-injection/progressive-disclosure.md (更新)

**可生成性验证**：✅ 通过

## Recommendations

1. 考虑将 `fullstack-engineering/contract-replay-verification-gate.md` (272 lines) 拆分
2. `product-delivery/` 下有 3 个文件都在说"闸门"，考虑合并
```

---

## 安全边界

### CAN do（自主执行）

| 操作 | 范围 |
|--------|-------|
| 读取 references/patterns/ | 分析 |
| 拆分/合并 patterns/ | 重构 |
| 移动到 _archive/ | 归档 |
| 更新 _master_index.md | 索引维护 |
| 写 sleep-report.md | 报告 |
| Git commit（不 push） | 版本控制 |

### CANNOT do（硬性禁止）

| 操作 | 原因 |
|--------|--------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/*.md | 自迭代需要人确认 |
| 删除 patterns（不归档） | 防止误删 |
| Git push | 人审核后才推 |

---

## 质量保障

### 防止过度压缩

1. **可生成性测试**：压缩后的知识必须能重建原始细节
2. **边界条件保留**：关键的边界条件、反模式、实现变体必须保留
3. **人工审核**：拆分/合并建议写入 sleep-report.md，人审核后才 push

### 防止误合并

1. **语义相似度阈值**：> 0.85 才考虑合并
2. **元问题一致性**：必须是同一个元问题
3. **Confidence 保护**：不合并 confidence < 0.6 的文件（可能是噪音）

### 防止知识丢失

1. **完整归档**：所有被修改的文件移动到 _archive/，不删除
2. **Git 历史**：每次 sleep 操作都 commit，可回滚
3. **可追溯性**：新文件的 sources 字段保留原始来源

---

## 与其他命令的关系

| 命令 | 触发 | 范围 | 持续 | 人的角色 |
|------|------|------|------|----------|
| `/harness:calibrate` | 手动，白天 | 聚焦（1 个 URL/topic） | ~20 min | 交互式 |
| `/harness:nightshift` | 手动启动 | 全部信源 + 探索 | **无上限** | 看 brief |
| `/harness:sleep` | 定期/手动 | patterns/ 压缩 | ~30 min | 审核报告 |
| `/harness:compound` | 任务完成后 | 内部经验 | ~10 min | 审核教训 |

**数据流：**

```
外部世界 → calibrate/nightshift → patterns/（读厚）
                                      ↓
                                   sleep（读薄）
                                      ↓
                                  压缩的 patterns/
                                      ↓
内部经验 → compound → 新教训 → patterns/
```

---

## 快速启动

```bash
# 手动触发
/harness:sleep

# 查看报告
cat $HARNESS_HOME/sleep-report.md

# 审核变更
git diff

# 批准变更
git push
```

---

## 核心原则

> **Sleep 是知识的重构师。**
>
> 它不删除知识——它重新组织知识结构。
> 它不改变元问题——它让元问题更清晰。

> **压缩不是丢弃，是提炼。**
>
> 从"这个 API 这样用"到"这类 API 的通用模式"。
> 从"29 个 sources 堆砌"到"4 个元问题清晰分类"。

> **可生成性是唯一标准。**
>
> 压缩后的知识必须能重建原始细节。
> 如果不能，说明压缩过度，需要补充。

> **人审核报告，不审核每个细节。**
>
> Sleep 产出 sleep-report.md，人看报告决定是否 push。
> 不需要人审核每个拆分/合并操作——那是 Agent 的工作。
