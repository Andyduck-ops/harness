# Nightshift — 夜间自主学习协议

## 设计目标

Agent 在人睡觉时自主进化知识库。
人第二天早上 5 分钟读完 morning brief，了解全部变化。

---

## 工作流



---

## Morning Brief 格式



---

## 执行环境

### Claude Code



### Codex



---

## 安全边界

### Nightshift 可以做

| 操作 | 说明 |
|------|------|
| 搜索网页 | 读取信源内容 |
| 创建/更新 references/ 下的文件 | 知识库更新 |
| 创建/更新 patterns/ 下的文件 | 模式更新 |
| 移动文件到 archive/ | 过期清理 |
| 写 morning-brief.md | 简报 |
| 写 changelog.md | 变更记录 |

### Nightshift 不可以做

| 操作 | 原因 |
|------|------|
| 修改 PRD/ | 意图资产需要人工决策 |
| 修改 bedrock/ | 第一性原理不可自动修改 |
| 修改 generator/ 核心逻辑 | 自迭代需要人确认 |
| 修改项目代码 | 超出知识管理范围 |
| 发送消息/创建 PR | 夜间不打扰 |
| 删除非 archive 文件 | 防止误删 |

---

## 质量保障

### 防止知识污染

1. **Noise Filter**: Distill 阶段标记 [NOISE] 的发现直接丢弃
2. **Confidence Threshold**: 低于 0.4 的 pattern 不写入 patterns/
3. **Conflict Detection**: 矛盾写入 conflicts.md，不自动解决
4. **Bedrock Guard**: 与核心原理冲突的发现标记 [BEDROCK_CONFLICT]，需人工处理

### 防止膨胀

1. **Merge 压缩**: 同构知识强制合并
2. **Decay 机制**: 90 天无引用 → 分数衰减 → 归档
3. **总量控制**: patterns/ 超过 100 条时触发强制合并
4. **articles/ 限制**: 只保留摘要（~500字），详情按需重新获取

### 防止自迭代失控

1. **Bounded Self-Improvement**: 只改知识获取/处理方式，不改核心原则
2. **meta-framework/ 变更需标记**: [SELF_MODIFY] 标签，morning brief 高亮显示
3. **回滚能力**: 所有变更通过 git commit，可随时回退

---

## 与 calibrate 的关系

| 命令 | 触发 | 范围 | 耗时 |
|------|------|------|------|
| `/harness:nightshift` | 定时/手动（夜间） | 全量 Scout + 全流程 | ~2h |
| `/harness:calibrate` | 手动（白天按需） | 聚焦特定 topic/信源 | ~20min |
| `/harness:init` 内置 | 新项目初始化时 | 轻量检查最近 7 天 | ~10min |

nightshift 是完整循环，calibrate 是快速定向校准。
