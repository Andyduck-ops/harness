---
name: contract-replay-verification-gate
topic: fullstack-engineering
confidence: 0.85
verified_count: 18
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet (2026-03-01)
  - Hacker News top/show/new snapshot (2026-03-01)
  - OpenAPI Specification (official)
  - Pact official docs
  - Hypothesis docs (property-based testing) (2026-03-01)
  - Hypothesis stateful testing docs (rules/invariants) (2026-03-01)
  - Hypothesis API docs (settings.derandomize/database/replay) (2026-03-01)
  - fast-check docs (property-based testing) (2026-03-01)
  - fast-check model-based testing docs (replayPath/scheduledModelRun) (2026-03-01)
  - Stryker docs (thresholds + break/fail behavior) (2026-03-01)
  - Stryker docs (incremental testing baseline workflow) (2026-03-01)
  - StrykerJS Incremental docs（limitations + --force full run）(2026-03-01)
  - PIT docs (mutation testing guidance) (2026-03-01)
  - mutmut docs (mutation workflow) (2026-03-01)
  - Hypothesis docs (targeted property-based testing via target()) (2026-03-01)
  - Hypothesis replaying failures docs（@reproduce_failure stability caveat + @example workflow）(2026-03-01)
  - Hypothesis API docs（ExampleDatabase backends: file/redis/github artifact）(2026-03-01)
  - Hypothesis settings docs（CI profile defaults: `derandomize=True`, `print_blob=True`, `deadline=None`）(2026-03-01)
  - Hypothesis API docs（`fuzz_one_input` ignores `max_examples`/`derandomize`/`database`/`deadline` 等设置）(2026-03-01)
  - fast-check docs（外部 fake data 生成器需支持 seed + replay index 可重放）(2026-03-01)
  - StrykerJS configuration docs（`thresholds.break` 默认 `null`，未配置不会阻断构建）(2026-03-01)
  - StrykerJS configuration docs（mutant timeout 判定公式：`timeoutMS + timeoutFactor * test_time`）(2026-03-01)
  - Hypothesis stateful docs（`@initialize` 不可加 precondition；可用 `check_during_init` 控制初始化阶段是否执行 invariants）(2026-03-01)
  - fast-check scheduler docs（`waitIdle` 仅等待受控任务；外部异步源需显式纳入 scheduler）(2026-03-01)
  - HN lanes snapshot（news: id=47245871 "Show HN: SaaS builder...", show: id=47245760 "Show HN: Memctl...", newest: id=47245071 "Deep Learning Is Not So Mysterious or Different"）(2026-03-01)
  - HN lanes snapshot（news: MCP server context reduction, show: profile picture Chrome extension, newest: split context window）(2026-03-01)
  - OpenAI Harness engineering (observability + long-run loops) (2026-02-11)
last_verified: 2026-03-01
rank: 2
---

## 元问题

后端“契约优先”常见失败点是：
契约写了，但没有把变更验证和关键流量回放绑到同一闸门。

## 核心解法

采用 **Contract First + Replay Gate**：

1. **契约单一真相**：OpenAPI 作为接口权威定义。
2. **契约驱动验证**：Consumer/Provider 使用 Pact 类契约测试做兼容性校验。
3. **回放闸门**：每次后端变更必须通过关键交易流回放（Replay）。
4. **失败沉淀**：回放失败样本进入夜间回归资产。

## 证据链

- OpenAPI 规范提供稳定、机器可读的接口定义格式，适合作为变更基线。
- Pact 官方文档强调消费者驱动契约与提供方验证，可显著降低集成漂移。
- HN `top/new` 同日讨论中，基础设施项目对“明确边界 + 验证自动化”持续高频。

## 明日落地模板

1. `openapi.yaml` 变更即触发契约 diff。
2. PR 必须附 `breaking/non-breaking` 标记。
3. CI 分两段：`contract verify` -> `replay verify`。
4. 回放失败自动生成“复现最小输入”并写入回归集。

## 回放资产最小格式

| 字段 | 说明 |
|------|------|
| `case_id` | 用例唯一标识 |
| `contract_version` | 契约版本快照 |
| `request` | 输入请求体（可脱敏） |
| `expected` | 预期响应与状态码 |
| `actual` | 实际返回（失败时记录） |
| `repro` | 最小复现命令/脚本 |

## 反模式

- 先改实现，最后补契约。
- 只跑单元测试，不做跨服务契约验证。
- 回放脚本临时写、临时删，不沉淀为资产。

## Cycle 92 同化增量：Mutation + Property + Invariant 有效性闸门

把“测试通过”从数量指标升级为“语义有效性指标”，在原有 `contract verify -> replay verify` 之间插入两层硬门禁：

1. Property Gate（性质门禁）
   - 用 Hypothesis/fast-check 定义跨输入空间的业务性质，而非只写样例断言。
   - 每条核心性质必须支持失败最小化（shrinking）和可重放（固定 seed 或失败 seed 回灌）。
2. Mutation Gate（变异门禁）
   - 使用 Stryker/PIT/mutmut 注入细粒度代码变异，统计 mutation score。
   - 在 CI 上配置硬阈值（`threshold.break` 或等效机制），低于阈值直接阻断合并。
3. Invariant Replay Gate（不变量回放门禁）
   - 对真实/脱敏流量回放添加业务不变量断言（例如金额守恒、状态机单调、幂等键唯一）。
   - 要求“契约通过 + 性质通过 + 变异达标 + 不变量通过”四门同过，才允许进入部署。

## 四段式最小 CI 模板

1. `contract verify`：OpenAPI/Pact 兼容性检查。
2. `property verify`：性质测试（固定运行预算 + 失败 seed 持久化）。
3. `mutation verify`：mutation score 达到门槛并可解释剩余存活变异。
4. `replay invariant verify`：关键交易回放 + 不变量断言。

## 典型 AI 代码 bug 映射

| AI 常见失效模式 | 仅样例测试常见漏检 | 新门禁对应拦截点 |
|---|---|---|
| 表面正确、边界错误 | 示例覆盖不含极端输入 | Property Gate 自动生成边界与异常组合 |
| 隐式依赖/脆弱断言 | 改动后测试仍“全绿” | Mutation Gate 通过存活变异暴露弱断言 |
| 状态泄漏/跨请求污染 | 单次调用通过但序列失真 | Invariant Replay Gate 在回放序列中捕获违反不变量 |

## 检索锚点（L5）

- `mutation score threshold break contract replay`
- `property-based shrinking seed replay gate`
- `invariant replay 金额守恒 幂等键`

## Cycle 95 同化增量：Stateful 序列重放 + 可观测不变量门禁

目标：把“样例级 property”升级为“状态序列级 property”，并把失败从“日志可看见”升级为“PR 必阻断”。

1. Stateful Property 序列
   - Hypothesis `RuleBasedStateMachine` + `@invariant`：每一步后执行不变量断言。
   - fast-check `commands` + `modelRun/asyncModelRun/scheduledModelRun`：覆盖同步、异步与并发时序（race）路径。
2. 可复现失败清单（Replay Manifest）
   - fast-check：`seed + path + replayPath` 三元组必须落盘，否则失败不可稳定重放。
   - Hypothesis：保留最小失败程序片段（shrunk program）用于回归固定化。
3. Mutation Fail-Fast
   - Stryker：启用 `thresholds.break`，分数低于阈值直接 CI 失败。
   - PIT：`mutationThreshold` 与 `coverageThreshold` 双阈值并联，防止“覆盖率高但断言弱”。
4. Observability Invariant Gate
   - 参照 OpenAI Harness 的工作树隔离观测做法，将 LogQL/PromQL 预算作为验证输入：
     - 冷启动耗时上限
     - 关键路径 span 上限
     - 错误率预算
   - 规则：`contract + property + mutation + replay + observability` 五门同过才可晋级。

## Cycle 95 最小 CI 配置（5 Gate）

1. `contract verify`：OpenAPI/Pact 兼容性。
2. `stateful property verify`：Rule/Command 序列 + invariant。
3. `mutation verify`：Stryker/PIT fail-fast 阈值。
4. `replay verify`：seed/path/replayPath 回灌复现。
5. `observability invariant verify`：日志/指标/trace 预算。

## Cycle 95 检索锚点（L5）

- `stateful command replayPath scheduledModelRun race condition`
- `Hypothesis RuleBasedStateMachine invariant after every step`
- `Stryker thresholds break PIT mutationThreshold coverageThreshold`
- `observability invariant gate LogQL PromQL span budget`

## Cycle 100 同化增量：Deterministic Replay Contract（AI 代码有效测试）

目标：把“测试发现问题”升级为“失败可重放 + 质量可阻断”，避免 AI 代码在边界和状态序列上“偶现绿灯”。

1. Property 随机性必须可重放
   - Hypothesis `settings` 明确 `derandomize`、`database` 与 replay 能力；CI 建议用确定性配置，且保留失败样本数据库以回灌复现。
   - fast-check model-based testing 明确 `commands` 场景复放需要 `{ seed, path, replayPath }` 三元组；缺 `replayPath` 会导致状态序列失败不可稳定重现。
2. Mutation 结果必须可阻断
   - Stryker `thresholds.break` 低于门槛会直接 `exit code 1`；默认 `break=0` 不会阻断构建，生产流水线必须显式改为非零阈值。
   - PIT 同时支持 `--mutationThreshold` 与 `--coverageThreshold` 失败闸门；两者并联可避免“覆盖率高但断言弱”假阳性。
3. Python 侧长跑策略要增量可持续
   - mutmut 支持增量记忆与恢复续跑（中断后可续），可与 nightly mutation 结合，控制 AI 代码回归成本。
4. Cycle 100 压缩结论（L4）
   - 与现有元问题完全同构：仍属于 `contract + property + mutation + replay + invariant` 验证闸门。
   - 判定：同化到当前 canonical pattern，不新建 topic/pattern。

## Cycle 100 检索锚点（L5）

- `Hypothesis derandomize database replay failed tests`
- `fast-check commands replayPath seed path`
- `Stryker thresholds.break exit code 1`
- `PIT mutationThreshold coverageThreshold`
- `mutmut restart where left off incremental`

## Cycle 105 同化增量：Targeted Property + Incremental Mutation（压缩窗口）

目标：在不牺牲覆盖面的前提下，把 AI 代码验证从“重跑全部”升级为“可持续长跑”。

1. Targeted Property（定向性质探索）
   - Hypothesis `target()` 允许把搜索导向高风险区域（例如长度、分支深度、状态跃迁幅度），用于更快命中“表面正确但边界错误”的 AI 代码缺陷。
   - 规则：核心性质必须同时保留 shrinking + seed/replay 能力，避免“只找到一次，无法复现”。
2. Incremental Mutation（增量变异基线）
   - Stryker incremental testing 支持以上一轮结果为基线，仅对受影响范围优先变异，降低长流水线成本。
   - 规则：增量模式用于提速，不替代门禁阈值；`thresholds.break` 仍是阻断开关。
3. Cycle 105 压缩结论（L4）
   - 新证据解决的问题仍是同一元问题：`contract + property + mutation + replay + invariant` 的可执行门禁。
   - 判定：同化到现有 canonical pattern，不新建 pattern/topic。

## Cycle 105 检索锚点（L5）

- `Hypothesis target() targeted property-based testing`
- `Stryker incremental testing baseline thresholds.break`

## Cycle 109 同化增量：失败重放保真 + 增量 mutation 可信度门禁

目标：解决 AI 代码测试里“本地能复现、CI 复现不了”和“增量提速后门禁悄悄失真”的同一元问题。

1. 失败重放要区分“临时救火”与“可持续资产”
   - Hypothesis 文档明确 `@reproduce_failure` 主要用于临时重放，升级 Hypothesis 版本后可能失效。
   - 生产治理动作：把最小失败输入沉淀为 `@example` 或失败样本库，不把 `@reproduce_failure` 当长期资产。
2. 失败样本库要跨运行单元共享
   - Hypothesis API 文档给出 `ExampleDatabase` 多后端（目录、Redis、GitHub Artifact）；
   - 生产治理动作：CI 与本地共用失败样本存储层，保证“CI 红灯 -> 本地一键重放”。
3. 增量 mutation 需要“定期全量校准”
   - Stryker Incremental 文档指出：未跟踪运行环境变化时可能误判为“无需重测”，并提供 `--force` 进行全量重跑。
   - 生产治理动作：增量模式常态运行，但每 N 轮或关键依赖变更后强制 `--force` 全量校准一次。

## Cycle 109 最小执行策略（增量 + 校准）

1. `contract verify`
2. `property verify`（失败样本入共享 ExampleDatabase）
3. `mutation verify --incremental`
4. `mutation verify --force`（周期性校准）
5. `replay invariant verify`

## Cycle 109 检索锚点（L5）

- `Hypothesis reproduce_failure not guaranteed across versions`
- `Hypothesis ExampleDatabase GitHubArtifactDatabase RedisExampleDatabase`
- `Stryker incremental may not detect environment changes --force`

## Cycle 122 同化增量：确定性测试合同（CI/本地一致性）

目标：解决 AI 代码测试里“同一失败在 CI 和本地语义不一致”的同一元问题，避免把偶然稳定误判为质量稳定。

1. Property 运行策略必须显式 profile 化
   - Hypothesis settings 文档给出 `ci` profile：`derandomize=True`、`print_blob=True`、`deadline=None`，并抑制 `too_slow` 健康检查噪声。
   - 治理动作：把 CI profile 固化为仓库标准，禁止开发者本地隐式 profile 漂移后直接作为门禁结果。
2. Fuzz Harness 与 Property Gate 不能混用配置语义
   - Hypothesis API 文档明确 `fuzz_one_input` 会忽略 `max_examples`、`derandomize`、`database`、`deadline`、`report_multiple_bugs` 等设置。
   - 治理动作：把 fuzz 模式定位为“补充探测通道”，主门禁仍使用可重放、可沉淀样本的 property 配置。
3. 外部随机数据源必须满足 replay 合同
   - fast-check 文档强调外部 fake data 生成器若不能基于 `seed` 与 `replay index` 重放，将破坏 shrinking 和失败复现。
   - 治理动作：把“可重放随机源”作为 property gate 前置验收项，不合格数据源禁止进入门禁。
4. Mutation 门禁默认不是阻断态，需显式拉闸
   - StrykerJS 配置文档给出 `thresholds.break` 默认 `null`；未设阈值时 mutation 分数不会自动阻断构建。
   - 治理动作：流水线强制声明 `thresholds.break`，并把阈值变更纳入 code review。
5. Mutant timeout 需按基线时间建模
   - StrykerJS 以 `timeoutMS + timeoutFactor * test_time` 判定超时；AI 代码引入慢测试后，阈值不当会导致“误杀/漏杀”。
   - 治理动作：按稳定基线更新 timeout 参数，避免把性能波动当成 mutation 质量结论。
6. Cycle 122 同化结论（L2）
   - 新证据仍属于同一元问题：`contract + property + mutation + replay + invariant` 的可执行门禁。
   - 判定：同化到当前 canonical pattern，不新建 topic/pattern。

## Cycle 122 检索锚点（L5）

- `Hypothesis ci profile derandomize print_blob deadline none`
- `Hypothesis fuzz_one_input ignores derandomize database deadline`
- `fast-check fake data seed replay index shrink reproducibility`
- `Stryker thresholds.break default null`
- `Stryker timeoutMS timeoutFactor mutant timeout formula`

## Cycle 126 同化增量：状态泄漏可测化（初始化路径 + 调度边界）

目标：解决 AI 代码常见“单步正确、序列失真”和“异步表面通过、后台泄漏未测到”的同一元问题。

1. 初始化路径必须进入不变量验收面
   - Hypothesis stateful 文档明确 `@initialize` 不支持 precondition，且可通过 `check_during_init` 控制初始化阶段是否执行 invariants。
   - 治理动作：对资金、权限、缓存等高风险状态机，强制启用初始化阶段不变量校验，避免“初始状态已污染”却在后续步骤才暴露。
2. 异步序列测试必须声明“受控任务边界”
   - fast-check scheduler 文档明确 `waitIdle` 只会等待由 scheduler 包装的任务，未纳入 scheduler 的外部异步工作不会被等待。
   - 治理动作：将外部队列、计时器、回调任务统一包装进 scheduler；否则禁止把 `waitIdle` 通过当作“无状态泄漏”证明。
3. 同化判定（L2/L7）
   - 新证据仍属于同一元问题：`contract + property + mutation + replay + invariant` 的执行门禁，只是补上“初始化不变量”和“受控异步边界”两块缺口。
   - 判定：同化到当前 canonical pattern，不新建 topic/pattern。

## Cycle 126 检索锚点（L5）

- `Hypothesis initialize cannot have precondition check_during_init`
- `fast-check scheduler waitIdle only scheduled tasks`
- `AI 状态泄漏 初始化不变量 异步回调 未纳入 scheduler`
