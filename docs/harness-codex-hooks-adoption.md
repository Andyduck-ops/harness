# Harness 在其他项目中的接入说明（元框架编译指南）

> **核心认知转变：Harness 不是一个静态脚手架（Boilerplate），它是一个元框架（Meta-Framework）。**
> 接入 Harness 的目的不是复制一堆 `.py` 脚本和文档，而是让 Agent 根据 Harness 主脑的“哲学与原则”，结合目标项目的真实情况，**现场编译（Compile）**出专属的运行环境与门禁。

---

## 1. 为什么不用传统“模板复制”？

在传统的脚手架思维中，你会有一个 `templates/` 目录，里面塞满了写死的 `quality-gate.py` 和 `inject-context.py`，然后用脚本把它们拷贝到新项目里。

**这种做法直接违背了 Harness 的核心理念：**
1. **知识腐化（Staleness）**：主仓库的 Nightshift（夜巡）每天都在进化，产出新的 Pattern 和门禁思路。静态复制过去的模板会在几周内彻底过时。
2. **削足适履**：一个 Python FastAPI 项目和一个 React 前端项目需要的质量门、测试截获逻辑完全不同。写死的模板要么过于庞大，要么无法运行。
3. **剥夺 Agent 的自主权**：Harness 的首要用户是 Agent。最佳实践应该由 Agent 在任务启动时动态检索、推导并实施。

因此，接入的过程必须是 **Agent-Driven 的编译过程**。

---

## 2. 什么是“环境编译”？（The Harness Bootstrap Skill）

我们提供了一个全局 Skill：`harness-bootstrap`。
它的底层逻辑极其轻量：提供一个“微内核（Micro-kernel）”，只负责建立目标项目与 Harness 主仓库（主脑）的连接，剩下的全交给 Agent 去完成。

### 执行流程解析

执行以下命令：
```bash
python3 "$HOME/.codex/skills/harness-bootstrap/scripts/bootstrap.py"
```

这不会生成任何模板文件！它只会做两件事：
1. 写入 `.harness/.harness-home` 指针，告诉 Agent 主脑在哪里。
2. 留下一份 `MANIFESTATION_INSTRUCTIONS.md`（降临指令）。

接下来，**你将要求大模型（Agent）接管**，Agent 会执行以下“编译”循环：

1. **装载灵魂（Load Bedrock）**：Agent 会顺着指针回到主脑，读取 `PRD/core-principles.md`，理解什么是 *Mechanical Enforcement > Documentation*，什么是 *Failure Budget*。
2. **靶场侦察（Reconnaissance）**：Agent 扫描当前目标项目，识别出语言、框架、现有的测试指令。
3. **模式检索（Query Patterns）**：Agent 去主脑的 Knowledge Lanes 里查阅相关的最佳实践。
4. **编译门禁（Compile Hooks）**：Agent 亲自为你手写 `.codex/config.toml` 和 `.harness/hooks/*.py`。如果你的项目用 `pytest`，它就会写一个基于 `pytest` 的强硬拦截器；如果你的项目没有测试，它甚至可能先帮你搭建测试框架再写拦截器。

---

## 3. 如何操作（实战指南）

### 3.1 准备工作

确保你的主机器上已经克隆了完整的 Harness 主仓库，并且环境变量存在：
```bash
export HARNESS_HOME="$HOME/harness"
```

同步全局 Skill：
```bash
cd "$HARNESS_HOME"
./codex-skill/scripts/sync-skills.sh --apply --skills harness-bootstrap
```

### 3.2 在目标项目中召唤“环境架构师”

进入你想接入 Harness 的目标项目（比如你新写的一个工具）：

**第一步：运行微内核**
```bash
python3 "$HOME/.codex/skills/harness-bootstrap/scripts/bootstrap.py"
```

**第二步：唤醒大模型**
唤醒你的命令行 Agent（使用具有 `harness-bootstrap` skill 的客户端），输入类似以下的 prompt：

> "请执行 `harness-bootstrap` skill。读取刚刚生成的 `.harness/MANIFESTATION_INSTRUCTIONS.md`，接管环境编译任务，为我这个项目生成质量门禁和执行环境。"

### 3.3 期待的结果

你会看到 Agent 开始“思考”并行动：
- 它会去读你的 `package.json` 或 `pyproject.toml`。
- 它可能会向你确认真实的构建命令。
- 它会自己创建 `quality-gate.py`，并将**“同类失败最多 3 次”**的硬性预算写在代码里。
- 它会自动配置好事件拦截机制。

一旦它完成，你的项目就已经被注入了 Harness 的“灵魂”。

---

## 4. 进化：从“静态库”到“流动的智慧”

这种接入方式最大的魅力在于：**下一次当你觉得现有门禁不好用了，或者主仓库 Nightshift 总结了新教训，你不需要去手动升级模板。**

你只需要重新对 Agent 说：
> "主库有了新的进展，请根据 `$HARNESS_HOME/references` 里的最新模式，重新审视并升级本项目的门禁和 hooks。"

**环境，在此刻，终于成为了流动的、可进化的代码。**
