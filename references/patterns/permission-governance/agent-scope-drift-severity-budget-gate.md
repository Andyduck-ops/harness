---
name: agent-scope-drift-severity-budget-gate
topic: permission-governance
confidence: 0.79
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:53:01Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Obsidian Sync now has a headless client")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Now I Get It – Translate scientific papers into interactive webpages")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Be Careful with LLM Agents")
  - OpenAI Docs: Background mode guide (https://developers.openai.com/topics/background-mode)
  - OpenAI Docs: Conversation state guide (https://developers.openai.com/docs/guides/conversation-state)
  - GitHub Docs: Controlling permissions for GITHUB_TOKEN (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/controlling-permissions-for-github_token)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - Hacker News API docs (https://github.com/HackerNews/API)
merge_upgrade_of:
  - references/patterns/permission-governance/agent-scope-manifest-escalation-gate.md
  - references/patterns/runtime-governance/browser-tool-scope-parity-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

即使已经引入最小权限清单与升级重放门禁，夜间无人执行仍会出现一种高频失效：**权限漂移被当作二元事件（通过/失败），导致高噪声告警和低价值冻结**。

1. 只读字段扩展与写权限升级被同等对待，门禁决策过粗；
2. 会话链连续且结果 `completed`，但实际 scope 已跨越风险等级；
3. 不同执行车道（采集/分析/晋级）没有独立漂移预算，导致误放行或误阻断并存。

本质问题：**缺少“权限漂移分级 + 车道预算 + 晋级硬门禁”的统一模型**。

## 核心解法

引入 **Agent Scope Drift Severity Budget Gate（ASDSBG）**，把权限漂移从“二元告警”升级为“分级预算门禁”：

1. **漂移分级（Severity Tier）**
   - `T1`：只读范围扩展（read-only drift）
   - `T2`：写能力变化（write-capable drift）
   - `T3`：外部系统/密钥面变化（external side-effect drift）
2. **分车道预算（Lane Budget）**
   - 每个车道定义 `max_drift_tier` 与 `max_drift_events_per_run`。
   - 超预算直接 `scope_drift_budget_pass=false`，禁止晋级。
3. **升级后重放强制（Replay After Escalation）**
   - 任何 `T2/T3` 漂移必须触发 `escalation_replay_pass`。
   - 未重放时，仅允许停留在探索层，不可 candidate->issue 或 PR 晋级。
4. **与 required checks 并列**
   - `scope_manifest_pass`
   - `scope_drift_budget_pass`
   - `escalation_replay_pass`
   任一失败即 quarantine。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `scope_drift_report.json` | `run_id`, `base_scope_digest`, `observed_scope_digest`, `drift_tier`, `drift_keys` | `drift_tier` 缺失即 fail |
| `lane_scope_budget.yaml` | `lane`, `max_drift_tier`, `max_drift_events_per_run` | 无车道预算即禁止晋级 |
| `promotion_packet.json` | `scope_manifest_pass`, `scope_drift_budget_pass`, `escalation_replay_pass`, `blocked_reason` | 任一 false 禁止晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前仍重定向到 HN Popular Blogs OPML Gist，入口稳定但内容持续变化，支持“连续采样 + 分级门禁”的必要性。
2. HN `news/show/newest` 同窗里同时出现 headless client、agent show 项目与 `Be Careful with LLM Agents`，说明“能力提升”与“权限风险”同步增长。
3. OpenAI Background mode 文档强调异步状态生命周期，证明 `completed` 只能表示流程结束，不能替代权限安全判断。
4. OpenAI Conversation state 文档提供 `previous_response_id` 与 conversation 链路，适合作为漂移事件绑定键。
5. GitHub `GITHUB_TOKEN` 权限文档要求显式最小权限配置，支撑 `T1/T2/T3` 分级治理落地。
6. GitHub protected branches 的 required checks 机制提供晋级硬门禁承载层。
7. HN API 提供 `topstories/showstories/newstories` 车道端点，支持分车道证据重放与异常归因。

## 反模式

- 只记录“是否漂移”，不区分漂移等级。
- 把 `completed` 当作可晋级证据，忽略 scope 变化。
- 所有车道复用同一权限预算，导致误报和漏报并存。
- 漂移超预算仍允许沿用旧 `promotion_packet`。
