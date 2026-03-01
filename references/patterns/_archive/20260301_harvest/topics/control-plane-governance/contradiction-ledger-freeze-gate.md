---
name: contradiction-ledger-freeze-gate
topic: control-plane-governance
confidence: 0.76
verified_count: 5
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-02-28T23:51:29Z)
  - OPML source gist API: https://api.github.com/gists/e6d2bf860ccc367fe37ff953ba6de66b (updated_at=2026-02-28T19:33:01Z, history_count=6)
  - HN news lane sample: https://news.ycombinator.com/news (item 47200342, sampled 2026-02-28T23:51:29Z)
  - HN show lane sample: https://news.ycombinator.com/show (item 47195123, sampled 2026-02-28T23:51:29Z)
  - HN newest lane sample: https://news.ycombinator.com/newest (item 47201858, sampled 2026-02-28T23:51:29Z)
  - HN API lanes: https://hacker-news.firebaseio.com/v0/topstories.json + /showstories.json + /newstories.json (cross-check sampled 2026-02-28T23:51:29Z)
  - GitHub Docs: protected branches and required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: storing and sharing workflow data/artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - GitHub Docs: syntax for issue forms (https://docs.github.com/en/enterprise-cloud@latest/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: merge_group event trigger (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
merge_upgrade_of:
  - references/patterns/source-governance/triangulated-evidence-ratification-gate.md
  - references/patterns/evidence-governance/attested-evidence-provenance-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

在 AGGRESSIVE_DYNAMIC 里，探索侧（OPML/HN）与执行侧（官方文档/门禁）经常出现“同轮矛盾”：

- 社区信号提示“应当晋级”；
- 官方规范提示“当前不能晋级或需要额外检查”；
- 系统若不冻结，下一轮会直接改写方向或继续 promotion，造成可审计链断裂。

核心矛盾是：
**发现系统允许快速演化，但执行系统需要稳定约束；缺少显式冲突账本时，自动化会在两者之间来回振荡。**

## 核心解法

建立 **Contradiction Ledger Freeze Gate（CLFG）**，把“冲突”从日志噪声升级为阻断性状态：

1. **冲突显式建模（ledger-first）**
   - 每条候选 claim 必须记录 `community_signal`、`official_rule`、`conflict_type`。
   - 冲突类型最少区分：`freshness_conflict`、`provenance_conflict`、`executability_conflict`。
2. **冻结晋级（freeze-before-promote）**
   - 任一冲突进入 `open` 状态时，`candidate -> issue` 与 `issue -> pr` 自动冻结。
   - 仅允许更新证据，不允许推进状态。
3. **双重解锁（reverify + reapprove）**
   - 先做复采样/重验签（`reverify_pass`），再做人审批准（`reapprove_pass`）。
   - 两者都通过才可将冲突状态改为 `resolved` 并恢复晋级。
4. **分支硬门禁（required checks）**
   - 把 `conflict_freeze_pass`、`conflict_resolution_pass` 设为 required checks。
   - 在 merge queue / `merge_group` 场景下同样强制执行，防止队列绕过。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `contradiction_ledger.json` | `claim_id`, `community_signal`, `official_rule`, `conflict_type`, `status` | `status=open` 时禁止晋级 |
| `conflict_freeze_report.json` | `claim_id`, `freeze_applied`, `frozen_stage`, `reason` | `freeze_applied=false` 且存在冲突 |
| `conflict_resolution_report.json` | `claim_id`, `reverify_pass`, `reapprove_pass`, `resolved_at` | 任一为 false 不可解锁 |
| `promotion_decision.json` | `claim_id`, `conflict_freeze_pass`, `conflict_resolution_pass`, `decision` | checks 不全或不通过 |

## 证据链

1. `https://t.co/dwAiIjlXet` 已稳定重定向到 OPML Gist，且 Gist API 显示存在 revision 历史，说明“入口可变更”是常态，不是异常分支。
2. 同一采样窗口里 HN `news/show/newest` 与 API `topstories/showstories/newstories` 返回的是不同分发车道，社区信号天生是并行且可能冲突的。
3. GitHub protected branches 的 required checks 能把“冲突未解不得晋级”从约定变成硬约束。
4. GitHub workflow artifact 能固化冲突账本和处置报告，保证次日审计可回放。
5. GitHub issue form 支持结构化必填项，可在 candidate 晋级入口提前收集冲突语义，减少后置返工。
6. `merge_group` 文档明确队列场景需要单独工作流触发，冲突门禁若不接入队列会被绕过。

## 反模式

- 发现冲突只写日志，不进入结构化 `ledger` 状态机。
- 允许“冲突 open 但继续 promotion”。
- 只做自动复验，不做人审复批，导致风险继续漂移。
- required checks 只挂在 PR，不挂在 merge queue / `merge_group`。
- 冲突解决后不写 `resolved_at` 和处置证据，次日无法追责。
