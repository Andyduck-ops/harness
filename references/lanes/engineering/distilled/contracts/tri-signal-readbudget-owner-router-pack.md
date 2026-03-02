# Tri-Signal Read Budget and Owner Router Pack

## Target Meta-Problem
当阅读负担、元问题混杂、重复叙述同时出现时，incident 会在多门禁文本间来回漂移，最终形成“读得更多但裁决更慢”的失控路径。

## 60s Decision Route
1. 先定义单一 owner：`continuity > semantic > lineage > runtime-boundary`。
2. 再绑定读预算：同一裁决窗口最多读取 3 份主证据，超限即回退到 owner 重选。
3. 仅输出一份 `owner_router_verdict_card.json` 作为 canonical verdict。
4. 非 owner 门禁全部转为 pointer，不再生成并行叙述。

## Read Budget Contract
1. Gate hop cap:
同一 `incident_id` 在一个窗口内最多允许一次 owner 切换，超过即触发 `route_fanout_guard_pass=false`。
2. Evidence cap:
每次裁决最多绑定 3 个主 artifact，其他证据只能挂在 pointer map。
3. Narrative cap:
同义裁决文本只能有一个 canonical 段落，其余位置仅引用 verdict id。
4. Window replay guard:
跨窗口复用历史 verdict 前，必须重新验证 freshness/head 一致性。

## Minimal Evidence Bundle
- `owner_router_verdict_card.json`
- `read_budget_guard.json`
- `evidence_pointer_map.json`
- `route_fanout_lint.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`

## Hard Gates
- `route_fanout_guard_pass`
- `read_budget_guard_pass`
- `canonical_narrative_pass`
- `window_replay_guard_pass`

任一失败，禁止继续晋级与跨门禁交接。

## Anti-Patterns
- 先并行写多门禁裁决，再事后补 owner。
- 用“更多解释文本”替代“更小证据束”。
- 把跨窗口旧结论直接复制为当前 verdict。
- 让同一 incident 在多文档出现语义不等价的重复叙述。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
