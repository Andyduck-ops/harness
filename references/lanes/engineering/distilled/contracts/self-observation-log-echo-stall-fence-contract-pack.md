# Self-Observation Log Echo Stall Fence Contract Pack

## Target Meta-Problem
当恢复轮把 `ops/tool` 诊断输出误当作 `domain evidence` 回写到 run log，并在同轮继续把这些日志当压缩输入时，会同时触发三类噪声：
- 阅读负担：首屏先看到工具调用与排查噪声，真实合同结论被后置。
- 元问题混杂：运行面（runner/watchdog/reporter）与知识面（gate/index/provenance）被写进同一裁决通道。
- 重复叙述：同一“自观察”片段跨轮重复扩写，新增证据与增量结论被淹没。

## 60s Compression Path
1. 强制双通道拆分：`ops_trace_channel`（运行诊断）与 `distill_evidence_channel`（可检索知识）禁止混写。
2. 先写 `verdict_summary_card`，只允许引用 fragment/provenance/index 三类产物路径。
3. 启用 `runlog_source_filter`：屏蔽 `thinking/exec/succeeded` 等工具执行回声，不纳入知识证据。
4. 同签名重试只写 `delta_observation_card`，历史解释统一走 `history_pointer`。
5. `events` 若仅有 `run_start` 且超窗口未闭环，发布 `stalled_cycle_receipt`，不覆写既有 gate/index verdict。

## Stall Fence Contract
1. Channel isolation（强约束）
`channel_map.json` 必含 `ops_trace_channel,distill_evidence_channel,cross_write=false`。
2. Source allowlist（强约束）
`runlog_source_filter.json` 必含 `allow_paths=[distilled/contracts,distilled/_provenance,distilled/_distilled_index.md]`。
3. Verdict-first publication（强约束）
`verdict_summary_card.json` 必含 `self_containment,fidelity,index_integrity,next_action`。
4. Delta-only repetition（强约束）
`delta_observation_card.json` 必含 `fingerprint,new_information,unchanged_sections,history_pointer`。
5. Stall receipt fence（强约束）
`stalled_cycle_receipt.json` 必含 `cycle,run_start_at_utc,timeout_window,escalation_route,gate_verdict_unchanged=true`。

## Minimal Evidence Bundle
- `verdict_summary_card.json`
- `channel_map.json`
- `runlog_source_filter.json`
- `delta_observation_card.json`
- `stalled_cycle_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 可独立回答“为何出现卡住、哪些内容可作为证据、下一步如何恢复”。
- `Fidelity`: 运行面与知识面边界清晰，保留反模式与证据映射，不用伪精度指标裁决。
- `Index Integrity`: fragment/provenance/index 命名一致，可回链 5 个 pattern 主证据。

任一 gate fail：进入 `deferred-reconcile`，禁止发布 `publish_decision=closed`。

## Anti-Patterns
- 把工具执行日志当作领域证据写入 distilled contract。
- 用“日志很多/分数很高”替代三门合同裁决。
- 运行诊断失败直接覆写 gate/index 已通过结论。
- 同一自观察片段跨轮全量复述而不产出增量。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
