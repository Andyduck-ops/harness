---
name: contradiction-sla-tombstone-gate
topic: control-plane-governance
confidence: 0.77
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-02-28T23:58:00Z)
  - HN news lane sample: https://news.ycombinator.com/item?id=47200342 (sampled 2026-02-28T23:58:00Z)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-02-28T23:58:00Z)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201816 (sampled 2026-02-28T23:58:00Z)
  - HN API lanes: https://hacker-news.firebaseio.com/v0/topstories.json + /showstories.json + /newstories.json (sampled heads 47196582/47195123/47201864 at 2026-02-28T23:58:00Z)
  - GitHub Docs: required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: merge_group event (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: workflow artifacts (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - GitHub Docs: issue forms syntax (https://docs.github.com/en/enterprise-cloud@latest/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
merge_upgrade_of:
  - references/patterns/control-plane-governance/contradiction-ledger-freeze-gate.md
  - references/patterns/feed-governance/hn-lane-identity-parity-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

`freeze` 本身不是终点。  
在夜间自治里，真正高风险的是“冲突长期未决”：

- 社区车道仍在持续产生新信号（top/show/newest）；
- 官方规则仍要求 required checks 与 queue 检查；
- 冲突若一直停留在 `open`，团队会被迫走 bypass 或临时人工放行。

核心矛盾是：  
**系统能识别冲突，但没有“超时处置”合同，最终会把冻结机制本身变成可绕过债务。**

## 核心解法

建立 **Contradiction SLA Tombstone Gate（CSTG）**，把冲突状态机扩展为“冻结 + 时限 + 墓碑 + 再资格化”四段治理：

1. **冲突开单即带 SLA（open-with-deadline）**
   - 每个冲突强制写 `opened_at_utc` 与 `sla_deadline_utc`。
   - 未设置 deadline 的冲突不得进入晋级流水线。
2. **超时自动墓碑（timeout-to-tombstone）**
   - 当 `now > sla_deadline_utc` 且未同时满足 `reverify_pass && reapprove_pass`，状态自动转 `tombstoned`。
   - `tombstoned` 不是软告警，而是晋级硬阻断。
3. **队列场景同构阻断（merge_group parity）**
   - PR 与 merge queue 都必须通过 `contradiction_sla_pass`、`contradiction_tombstone_clear`。
   - 防止“PR 过检但 queue 绕过”。
4. **再资格化合同（requalify-before-reopen）**
   - 仅允许通过新证据包重新开单：`new_evidence_digest`、`new_lane_snapshot`、`reapprove_ticket`。
   - 没有完整再资格化材料，`tombstoned` 不得复活。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `contradiction_ledger.json` | `claim_id`, `status`, `opened_at_utc`, `sla_deadline_utc`, `conflict_type` | 缺 deadline 或 status=open 且超时 |
| `contradiction_sla_report.json` | `claim_id`, `sla_pass`, `timeout_seconds`, `action` | `sla_pass=false` |
| `tombstone_registry.json` | `claim_id`, `tombstoned_at_utc`, `reason`, `requalify_required` | 命中 tombstone 仍请求晋级 |
| `requalify_packet.json` | `claim_id`, `new_evidence_digest`, `new_lane_snapshot`, `reapprove_ticket` | 任一字段缺失 |
| `promotion_decision.json` | `claim_id`, `contradiction_sla_pass`, `contradiction_tombstone_clear`, `decision` | checks 不全或不通过 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前稳定指向 OPML Gist，但 Gist 是可持续修订对象，意味着“冲突证据基线”会随时间漂移。
2. HN `news/show/newest` 与 API `top/show/new` 在同日采样可观察到头部并不同步，说明冲突不是一次性事件，而是持续流入事件。
3. GitHub required status checks 可以把 `SLA pass / tombstone clear` 固化为不可绕过条件。
4. GitHub `merge_group` 明确队列有独立触发路径，冲突门禁不接入队列就会被旁路。
5. GitHub workflow artifacts 可保存 `sla_report` 与 `tombstone_registry`，保证次日审计可回放。
6. Issue Forms 可把 `opened_at/sla_deadline/conflict_type` 结构化收口到入口，避免“临时文本描述”导致的执行歧义。

## 反模式

- 只做 `freeze`，不设 `sla_deadline`。
- 冲突超时后继续保持 `open`，不转墓碑。
- 仅在 PR 校验冲突，不在 merge queue 校验。
- 允许“口头补充证据”直接复活 tombstone。
- 没有 `tombstone_registry`，导致同一 claim 重复绕过。
