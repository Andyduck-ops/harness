---
name: comprehension-debt-ratchet-freeze-gate
topic: comprehension-governance
confidence: 0.79
verified_count: 10
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News topstories API (https://hacker-news.firebaseio.com/v0/topstories.json, sampled 2026-02-28)
  - Hacker News showstories API (https://hacker-news.firebaseio.com/v0/showstories.json, sampled 2026-02-28)
  - Hacker News newstories API (https://hacker-news.firebaseio.com/v0/newstories.json, sampled 2026-02-28)
  - Hacker News API docs (https://github.com/HackerNews/API)
  - OpenAI Background mode guide (https://platform.openai.com/docs/guides/background)
  - OpenAI Conversation state guide (https://platform.openai.com/docs/guides/conversation-state)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/actions/using-workflows/storing-workflow-data-as-artifacts)
merge_upgrade_of:
  - references/patterns/comprehension-governance/comprehension-budget-gate.md
  - references/patterns/signal-governance/lane-debt-ratchet-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间自治常见失败不是“没发现信号”，而是“发现太多后，人类接管时无法快速判定哪些结果可执行”。
当 `show/new` 信号吞吐高、后台任务并发高时，会出现两个债务同时膨胀：

- `evidence debt`：待仲裁 claim 堆积，`oldest_age_hours` 上升；
- `comprehension debt`：待接管解释包堆积，次日 reviewer 只能看结论，无法快速复核推理路径。

本质矛盾：**路由系统只管“抓到什么”，没有把“人能否在时间预算内理解并接管”纳入硬门禁**。

## 核心解法

引入 **Comprehension Debt Ratchet Freeze Gate（CDRFG）**，把“吞吐优先”升级为“可接管优先”：

1. **双债务账本（Dual Ledger）**
   - `lane_ledger`: `due_items`, `oldest_age_hours`, `carry_over_debt`
   - `handoff_ledger`: `pending_explain_packets`, `median_review_minutes`, `unverified_claims`
2. **冻结闸门（Freeze Gate）**
   - 当 `comprehension_debt_ratio > threshold` 时，自动冻结 `candidate -> issue/pr` 晋级；
   - 仅允许继续收集证据，不允许推进执行闭环。
3. **棘轮恢复（Ratchet Recovery）**
   - 冻结后按固定比例把预算从 `discovery lane` 转移到 `ratification + handoff lane`；
   - 直到 `comprehension_debt_ratio` 回落到解除阈值以下。
4. **异步可审计（Background + Audit）**
   - 后台运行仅负责生产草案与证据，不直接产生“已晋级决策”；
   - 每次冻结/解冻都必须落盘 `ratchet_decision.json` 与 `freeze_reason`.
5. **分支强制（Required Checks）**
   - 把 `comprehension-freeze-check` 设为 required status check；
   - 未解冻或解释包缺失时，受保护分支禁止合并。

## 最小执行协议

| 文件 | 必填字段 | 闸门规则 |
|------|----------|----------|
| `lane_ledger.json` | `cycle`, `lane`, `due_items`, `oldest_age_hours`, `carry_over_debt` | 任一 lane 债务超阈值触发配额调整 |
| `handoff_ledger.json` | `pending_explain_packets`, `median_review_minutes`, `unverified_claims` | 计算 `comprehension_debt_ratio` |
| `ratchet_decision.json` | `from_quota`, `to_quota`, `trigger_metric`, `reason` | 配额调整必须可解释 |
| `freeze_gate_report.json` | `frozen`, `frozen_since`, `unfreeze_condition`, `required_checks` | `frozen=true` 时禁止晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 重定向到 HN Popular Blogs OPML，可作为稳定作者池；
- HN API 同时提供 `topstories/showstories/newstories`，证明信号进入速度与成熟度分层天然不同；
- OpenAI Background mode 文档给出后台运行与轮询状态机，适合承担“采集/草案”而非“直接晋级”；
- OpenAI Conversation state 文档强调用 `previous_response_id`/`conversation` 维持状态链，支持把“会话状态”和“审计证据”分层；
- GitHub protected branches 的 required checks 能把 freeze gate 从软约束变为硬约束；
- GitHub Actions artifacts 可持久化账本与解释包，保证次日接管可回放。

## 反模式

- 只做 evidence 路由，不追踪 handoff 负债，导致“发现繁荣、接管瘫痪”。
- 后台任务直接触发晋级，跳过解冻条件与 explain packet。
- 冻结决策不落盘 reason，次日无法解释为何阻断。
- 把“状态连续”误当“证据连续”，仅靠会话上下文而不保存可审计 artifact。
