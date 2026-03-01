---
name: conflict-intake-required-form-gate
topic: control-plane-governance
confidence: 0.78
verified_count: 5
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01T00:10:23Z)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (last active Feb 28, 2026; revisions observed)
  - HN news lane sample: https://news.ycombinator.com/item?id=47200904 (sampled 2026-03-01T00:10:23Z)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-03-01T00:10:23Z)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201782 (sampled 2026-03-01T00:10:23Z)
  - GitHub Docs: syntax for issue forms (`required: true`) (https://docs.github.com/en/enterprise-cloud@latest/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: merge_group event parity requirement for queue path (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
split_from:
  - references/patterns/control-plane-governance/conflict-arbitration-dual-phase-contract-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

很多“冲突恢复失败”不是失败在恢复阶段，而是失败在入口阶段。

当冲突入口使用自由文本时，后续双相合同（reverify + reapprove）最常出现三类不可修复问题：

- 缺 `claim_id`，导致证据包与审批票据无法绑定；
- 缺 `opened_at_utc` 与 `sla_deadline_utc`，导致超时处置不可计算；
- 缺 `conflict_type`，导致仲裁策略与门禁条件无法路由。

元问题是：
**冲突治理把约束放在“恢复出口”，却没有在“冲突入口”先做结构化必填收口。**

## 核心解法

建立 **Conflict Intake Required-Form Gate（CIRFG）**，把冲突入口从“文本提交”改为“结构化合同提交”。

1. 冲突入口统一采用 Issue Form，关键字段 `required: true`。
2. 新增 `conflict_intake_pass` 作为 required status check。
3. `pull_request` 与 `merge_group` 必须同构执行 `conflict_intake_pass`，避免队列路径旁路。
4. 只有 `conflict_intake_pass=true` 的 claim 才允许进入后续 `arbitration_reverify_pass` 与 `arbitration_reapprove_pass`。

## 最小执行协议

| 对象 | 必填字段 | 阻断规则 |
|---|---|---|
| `conflict-intake.yml` | `claim_id`, `conflict_type`, `opened_at_utc`, `sla_deadline_utc`, `source_lane` | 任一缺失即拒绝受理 |
| `conflict_intake_packet.json` | `claim_id`, `form_schema_version`, `required_fields_complete`, `generated_at_utc` | `required_fields_complete=false` 即阻断 |
| `conflict_decision_router.json` | `claim_id`, `intake_pass`, `route`, `reason` | `intake_pass=false` 仍进入仲裁流程 |

## 证据链

1. `t.co` 入口稳定重定向到 OPML Gist，但 Gist 有持续修订，说明入口证据本身会漂移，必须从 intake 时就记录结构化元数据。
2. HN `news/show/newest` 在同窗样本中对应不同 item id（`47200904 / 47195123 / 47201782`），冲突来源必须显式记录 `source_lane`，否则重验不可复现。
3. GitHub Issue Form 支持 `required: true`，可把冲突关键字段转为机器可验证输入，而非人工补票。
4. GitHub `merge_group` 是独立触发路径；如果 intake check 只在 PR 触发，会在队列阶段出现检查不一致。
5. required status checks 可作为硬门禁承载 `conflict_intake_pass`，避免“入口不完整但仍可晋级”。

## 反模式

- 冲突入口采用自由文本模板，仅在仲裁阶段补填字段。
- 只在 `pull_request` 路径校验 `conflict_intake_pass`，忽略 `merge_group`。
- 允许没有 `claim_id` 的冲突进入账本，后续无法追踪和回放。
- 把缺字段视为“告警”而不是“阻断”，最终在夜间无人模式累积治理债务。
