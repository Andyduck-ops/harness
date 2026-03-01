---
name: contract-epoch-replay-gate
topic: contract-governance
confidence: 0.78
verified_count: 8
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (revisions observed on page, last active Feb 28, 2026)
  - HN top lane sample: https://news.ycombinator.com/item?id=47200904 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201826 (sampled 2026-03-01)
  - OpenAPI Specification v3.1.2 (https://spec.openapis.org/oas/v3.1.2.html)
  - Pact docs: provider verification (https://docs.pact.io/provider)
  - GitHub Docs: merge_group event (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: troubleshooting required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
merge_upgrade_of:
  - references/patterns/fullstack-engineering/backend-contract-first.md
  - references/patterns/fullstack-engineering/contract-replay-verification-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

后端“契约优先”在 24h 无人推进里经常失败于同一个断点：
**PR 路径通过了契约校验，但 merge queue 路径或消费者回放样本已经跨 epoch，最终把“可合并”变成“不可回放”。**

根因不是缺少契约，而是没有把“契约版本纪元（epoch）”和“回放样本纪元”绑定为同一条晋级合同。

## 核心解法

建立 **Contract Epoch Replay Gate（CERG）**，把契约语义和回放可执行性做同构门禁：

1. 为每次接口语义快照生成 `contract_epoch`（例如 OpenAPI 规范摘要）。
2. 为消费者回放集生成 `replay_fixture_epoch`（样本生成时间 + 用例版本）。
3. 生成 `epoch_compat_report.json`，明确 `contract_epoch` 与 `replay_fixture_epoch` 是否兼容。
4. 将 `contract_diff_pass`、`provider_verify_pass`、`replay_freshness_pass`、`epoch_parity_pass` 设为 required checks。
5. `pull_request` 与 `merge_group` 双路径必须跑同一组 checks，避免“PR 通过、队列失配”。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `contract_epoch_manifest.json` | `base_sha`, `head_sha`, `contract_epoch`, `semantic_diff` | 无法计算语义差异 |
| `replay_fixture_manifest.json` | `suite_id`, `replay_fixture_epoch`, `cases_total`, `generated_at_utc` | 回放样本过期或来源不明 |
| `epoch_compat_report.json` | `contract_epoch`, `replay_fixture_epoch`, `compat_pass`, `incompatible_paths` | `compat_pass=false` 仍尝试晋级 |
| `promotion_packet.json` | `lane`, `required_checks`, `decision`, `blocked_reason` | checks 不完整或非同构 |

建议 required checks：

- `contract_diff_pass`
- `provider_verify_pass`
- `replay_freshness_pass`
- `epoch_parity_pass`

## 证据链

1. `t.co` 入口稳定重定向到 OPML Gist，但 Gist 页面显示有多次修订，说明上游内容会持续演化，契约与样本必须带版本纪元。
2. HN `news/show/newest` 在同窗内并行高频刷新（本轮样本 `47200904 / 47195123 / 47201826`），证明夜间自动链路中的信号状态会快速漂移。
3. OpenAPI 提供机器可读契约基线，Pact 的 provider verification 提供消费者视角验证；两者结合才能覆盖“定义正确 + 消费可回放”。
4. GitHub `merge_group` 是独立事件路径，若只校验 PR 路径，会出现队列路径纪元失配。
5. required status checks 能把纪元同构要求变成硬门禁，阻断“先并后补”的回放债务。

## 反模式

- 只维护 `openapi.yaml`，不维护 `replay_fixture_epoch`。
- 回放样本长期复用，不记录生成时间和来源摘要。
- 仅在 `pull_request` 跑契约检查，`merge_group` 未接入。
- provider verification 与 replay coverage 仅告警不阻断。
- 晋级包不记录 epoch 对齐状态，导致故障后不可审计回放。
