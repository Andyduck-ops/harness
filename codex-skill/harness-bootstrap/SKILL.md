---
name: harness-bootstrap
description: |
  Harness 全局引导器（元框架 → 运行面编译协议）。
  将 Harness 的“灵魂”（PRD 原则与 Knowledge Lanes）动态编译为目标项目可执行的 Runtime（Hooks + Spec）。
  注意：它不是静态脚手架！它是一个 Agent-Driven 的环境生成过程。
---

# Harness Bootstrap（环境编译器协议）

> **Harness 是元框架，你的任务是担任“环境架构师”，为当前项目“编译”出它的运行面。**

作为执行此 Skill 的 Agent，你绝不能去“复制文件”或依赖写死的静态模板。你必须深刻理解 Harness 的核心不可违反原则（尤其是 `P1. Harness First` 和 `P2. Mechanical Enforcement > Documentation`），主动侦察当前目标项目的特征，然后**为其量身定制**专属的强制门禁（Hooks）和规范（Spec）。

---

## 执行协议（强制执行顺序）

### Step 1: 建立主脑连接（执行微内核）

在目标项目的根目录运行微内核引导脚本：

```bash
python3 "$HOME/.codex/skills/harness-bootstrap/scripts/bootstrap.py"
```

该脚本极其轻量，它**没有任何模板**，它只会：
1. 建立 `.harness` 目录基建。
2. 写入指针文件告诉你主脑 (`HARNESS_HOME`) 在哪。
3. 退出。**剩下的环境“编译”工作全部由你（Agent）接管并完成。**

### Step 2: 注入“灵魂”（加载 Bedrock）

通过第一步得到的主脑路径，**你必须首先**读取并理解以下资产：
- `PRD/core-principles.md` (重点理解什么是“强制执行”与“失败预算”)
- `PRD/vision.md` (理解环境为什么比代码更重要)
- `PRD/architecture/knowledge-lanes.md` (理解多主题命名空间)

*提示：不要把它们复制到目标项目里。你只需要把这些原则“装载”到你的大脑中，作为你接下来生成代码的绝对准则。*

### Step 3: 靶场侦察（Profile the Target）

运用你的能力检查当前目标项目的真实环境：
- 它用什么语言/框架？（如检测 `package.json`, `pyproject.toml`, `go.mod` 等）
- 它的核心验证命令应该是什么？（真实的测试怎么跑？Lint 怎么跑？能否跑通？）
- 项目的目录结构和现有约定是怎样的？

### Step 4: 检索模式（Query Patterns）

不要无脑全量克隆知识库。根据 Step 3 的侦察结果，去 `$HARNESS_HOME/references/lanes/engineering/patterns/_master_index.md` 中寻找**与当前项目真实情况最相关的 Pattern**。

例如：如果是 Python 项目，去查找 Harness 中关于 Python 测试和代码检查的强制模式；如果是前端，去寻找相关的打包与质量门模式。

### Step 5: 编译运行面（Compile the Runtime）

这是最关键的一步，也是展现你能力的地方。基于你吸收的原则和项目真实情况，在目标项目中**自己思考并编写**以下内容：

1. **`.codex/config.toml` (Hooks 注册表)**
   - 编写配置以拦截关键事件（如 `session_start`、`subagent_start`、`subagent_stop`）。确保它是为 Codex Hook 契约设计的。

2. **动态生成 Hooks 脚本 (存放在 `.harness/hooks/`)**
   - **不要从任何地方抄袭模板！** 根据你理解的 `Mechanical Enforcement`，编写**适合当前环境**的 Python 拦截脚本。
   - **例子 1 (质量门)**：生成一个 `quality-gate.py`，它拦截 `subagent_stop`，强制执行你在 Step 3 侦察到的项目特有的真实测试命令。如果测试失败，它必须通过返回非零状态或特定的 JSON payload 来阻断 Agent 的下一步行动。
   - **例子 2 (失败预算)**：生成拦截脚本，确保 Agent 在特定阶段（如 `debug`）连续失败不超过 3 次。超出时自动阻断并输出结构化的升级求助报告。
   - **例子 3 (意图/状态注入)**：生成脚本在 `subagent_start` 时读取局部教训库和对应的 jsonl 以向子 Agent 注入必要的上下文。

3. **生成局部教训库和工作流 (存放在 `.harness/spec/` 和 `.harness/workflow.md`)**
   - 编写适合该项目的 `workflow.md`，明确流水线阶段（例如：plan -> implement -> check -> debug -> finish）。
   - 初始化局部教训索引 `lessons/index.md`。

---

## 验收标准

当你完成编译后，项目必须达到以下目标：
1. **彻底的机械化**：环境必须通过 Hook 自动且强硬地运行真实测试，Agent 试图用“口头报告测试通过”来蒙混过关时会被系统阻断。
2. **防死循环**：Agent 遇到困难进入修复循环时，如果在预算内（如 3 次）未解决，环境会自动触发死锁阻断，强制交由人类裁决。
3. **因地制宜**：所有生成的脚本和命令都完美契合目标项目当下的语言、框架和状态。

**牢记你的身份：你生成的不是参考文档，而是强制机器执行的“纪律门禁”。世界是运动的，你的编译产物必须是最适合它当下的！**
