---
name: conflict-arbitration-dual-phase-contract-gate
topic: control-plane-governance
confidence: 0.80
verified_count: 7
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01T00:03:22Z)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (last active Jan 26, 2026; revisions observed on page)
  - HN top lane sample: https://news.ycombinator.com/item?id=47222207 (sampled 2026-03-01T00:03:22Z)
  - HN show lane sample: https://news.ycombinator.com/item?id=47219143 (sampled 2026-03-01T00:03:22Z)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47222463 (sampled 2026-03-01T00:03:22Z)
  - GitHub Docs: merge_group event requires separate trigger path for required checks parity (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: syntax for issue forms (`required: true`) (https://docs.github.com/en/enterprise-cloud@latest/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: workflow artifacts for auditable evidence packets (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
merge_upgrade_of:
  - references/patterns/control-plane-governance/contradiction-ledger-freeze-gate.md
  - references/patterns/control-plane-governance/contradiction-sla-tombstone-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

`freeze` 与 `tombstone` 解决了“先停下”，但没有解决“何时、凭什么恢复推进”。

在 24h 无人推进里，常见故障是：

- 复验通过但没有复批票据，仍被快速恢复；
- 人工同意恢复但证据包未刷新，恢复基于过期上下文；
- PR 流水线做了冲突仲裁，merge queue（`merge_group`）没做，出现旁路。

核心矛盾是：  
**冲突生命周期有状态机，但没有双相合同约束“证据重验”和“治理复批”的先后与同构执行。**

## 核心解法

建立 **Conflict Arbitration Dual-Phase Contract Gate（CADPCG）**，把冲突恢复改为必须串行通过的双相门禁：

1. **Phase A: Reverify（证据相）**
   - 强制刷新 `top/show/newest` 三车道快照 + OPML anchor digest。
   - 输出 `arbitration_reverify_packet.json`，包含 `claim_id`, `lane_snapshot_digest`, `anchor_digest`, `reverify_pass`。
2. **Phase B: Reapprove（治理相）**
   - 只有当 `reverify_pass=true` 才允许进入复批。
   - 复批票据必须绑定 `claim_id + packet_digest + approver_set`，防止“票据挪用”。
3. **Queue 同构（PR 与 merge_group 一致）**
   - `pull_request` 与 `merge_group` 都必须通过 `arbitration_reverify_pass` 与 `arbitration_reapprove_pass`。
   - 任一路径缺失检查即阻断晋级。
4. **入口结构化（Issue Form 必填）**
   - 在冲突入口表单强制 `required: true` 字段：`conflict_type`, `opened_at_utc`, `sla_deadline_utc`, `claim_id`。
   - 防止“自由文本入口”造成后续合同字段缺失。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `contradiction_ledger.json` | `claim_id`, `status`, `conflict_type`, `opened_at_utc`, `sla_deadline_utc` | 入口缺字段或冲突状态非法流转 |
| `arbitration_reverify_packet.json` | `claim_id`, `lane_snapshot_digest`, `anchor_digest`, `reverify_pass`, `generated_at_utc` | `reverify_pass=false` 或 digest 缺失 |
| `arbitration_reapprove_ticket.json` | `claim_id`, `packet_digest`, `approver_set`, `approved_at_utc`, `reapprove_pass` | 未绑定 packet 或审批人集合为空 |
| `arbitration_decision.json` | `claim_id`, `arbitration_reverify_pass`, `arbitration_reapprove_pass`, `decision` | 两相任一失败仍尝试 promotion |
| `workflow_artifact_manifest.json` | `claim_id`, `artifact_names`, `artifact_sha256`, `retention_days` | 缺工件映射，审计不可回放 |

## 证据链

1. `t.co` 短链仍稳定重定向至 OPML Gist，但 Gist 页面可见 revision 历史，说明 anchor 本身具备时间漂移属性。
2. 同窗采样显示 HN `top/show/newest` 是并行车道：`47222207 / 47219143 / 47222463`，不能用单车道替代冲突重验。
3. GitHub 文档明确 `merge_group` 是独立触发路径；若不接同一组 checks，会出现 PR 与 queue 行为不一致。
4. required status checks 文档给出了分支硬门禁落点，可将双相合同从“流程约定”升级为“不可绕过”。
5. issue form 文档支持 `required: true`，可以在冲突入口把合同字段结构化收口。
6. workflow artifacts 文档可承载双相包与票据，支持次日审计回放。

## 反模式

- 只做重验不做复批，或只做复批不绑定重验包。
- PR 流水线校验双相合同，但 `merge_group` 未接同构检查。
- 冲突入口依赖自由文本，不做必填字段约束。
- 审批票据不绑定 `packet_digest`，导致跨 claim 复用。
- 双相决策不落工件，第二天无法追踪“凭什么恢复”。
