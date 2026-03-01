---
name: conflict-form-schema-drift-gate
topic: control-plane-governance
confidence: 0.79
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01T00:15:05Z)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (revisions observed on page, last active Feb 28, 2026)
  - HN top lane sample: https://news.ycombinator.com/item?id=47196582 (sampled 2026-03-01T00:16Z)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-03-01T00:16Z)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201858 (resolved from newest lane row, sampled 2026-03-01T00:16Z)
  - HN newest lane page: https://news.ycombinator.com/newest (sampled 2026-03-01T00:16Z)
  - GitHub Docs: syntax for issue forms (required fields and schema keys) (https://docs.github.com/en/enterprise-server@3.20/communities/using-templates-to-encourage-useful-issues-and-pull-requests/syntax-for-issue-forms)
  - GitHub Docs: common validation errors when creating issue forms (https://docs.github.com/en/enterprise-server@3.20/communities/using-templates-to-encourage-useful-issues-and-pull-requests/common-validation-errors-when-creating-issue-forms)
  - GitHub Docs: merge_group event (queue path parity) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
split_from:
  - references/patterns/control-plane-governance/conflict-intake-required-form-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

冲突治理把入口“结构化必填”做完后，下一批失败不再是“缺字段”，而是“字段语义漂移”。

典型表现：

- `conflict_type` 枚举扩展后，历史 claim 在重验阶段无法映射；
- `sla_deadline_utc` 从字符串改为对象后，老工件回放失败；
- 表单字段改名但未保留别名，`merge_group` 路径仍读取旧键导致 PR 与队列结果分叉。

元问题是：
**入口有 required，不等于入口 schema 稳定；没有版本兼容合同，冲突恢复会在“可提交但不可回放”处失效。**

## 核心解法

建立 **Conflict Form-Schema Drift Gate（CFSDG）**，把“字段存在性”升级为“字段版本兼容性”。

1. 引入 `form_schema_version` 与 `compat_window`（例如 N, N-1）。
2. 每次 schema 变更都生成 `schema_diff_manifest.json`，显式声明新增/废弃/别名映射。
3. 新增 `conflict_schema_compat_pass` required check。
4. `pull_request` 与 `merge_group` 必须同构执行 `conflict_schema_compat_pass`，避免队列旁路读取旧字段。
5. 冲突恢复（reverify/reapprove）仅接受“在兼容窗口内可解析”的证据包。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `conflict_intake_packet.json` | `claim_id`, `form_schema_version`, `required_fields_complete`, `generated_at_utc` | 无 schema 版本或 required 不完整 |
| `schema_diff_manifest.json` | `from_version`, `to_version`, `added`, `deprecated`, `aliases`, `breaking` | 发生 breaking 但未给兼容映射 |
| `schema_compat_report.json` | `claim_id`, `packet_version`, `parser_version`, `compat_pass`, `reason` | `compat_pass=false` 仍尝试晋级 |
| `arbitration_reverify_packet.json` | `claim_id`, `schema_compat_pass`, `lane_snapshot_digest`, `anchor_digest` | 未通过 schema 兼容检查 |

建议 required checks：

- `conflict_intake_pass`
- `conflict_schema_compat_pass`
- `arbitration_reverify_pass`
- `arbitration_reapprove_pass`

## 证据链

1. `t.co` 入口稳定重定向到 OPML Gist，但 Gist 页面可见修订历史，说明“入口稳定 != 内容稳定”，必须显式记录版本语义。
2. HN `news/show/newest` 同窗采样显示条目高速流动（`47196582 / 47195123 / 47201858`），冲突数据需要跨时间窗口回放，无法容忍隐式字段变更。
3. GitHub Issue Forms 文档给出结构化字段语法与 required 机制，且存在“常见校验错误”文档，说明 schema 演进是现实工程问题。
4. `merge_group` 是独立触发路径，若兼容检查只挂在 PR，会导致队列路径读取旧 schema 出现分叉。
5. required status checks 是将兼容合同落成硬门禁的执行面，避免“已知漂移但继续晋级”。

## 反模式

- 只做 `required: true`，不维护 `form_schema_version`。
- schema 改名后直接替换，不提供别名映射与兼容窗口。
- 只在 `pull_request` 路径跑兼容检查，`merge_group` 未接入。
- 在重验阶段临时脚本修补旧字段，不沉淀 `schema_diff_manifest`。
- 兼容失败仅告警不阻断，导致冲突恢复链条积累不可回放债务。
