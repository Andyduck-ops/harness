# Preflight Fingerprint Quarantine Delta Pointer Contract Pack

## Target Meta-Problem
当恢复轮持续命中同一 `index.lock permission denied` 指纹时，如果仍按“全量叙述+末尾报错”输出，会稳定触发三类信号恶化：
- 阅读负担：首屏不给主阻断，执行者必须读完长段才能定位边界失败。
- 元问题混杂：commit 写路径失败被误并入 semantic/evidence/runtime 门禁。
- 重复叙述：同指纹跨轮重复全量历史，增量信息难检索。

## 60s Compression Path
1. 首屏只发布 `preflight_fingerprint_card`，先回答“主阻断在哪个通道”。
2. 同指纹复发时只发布 `delta_pointer_receipt`，历史说明统一下沉 `history_pointer`。
3. `runtime/gate/index/commit` 结论强制分通道，禁止跨通道覆写。
4. commit 通道失败立即写 `deferred_commit_receipt`，给出可恢复条件。
5. 仅在三门合同通过且 `commit_boundary_clear=true` 时发布 closed。

## Preflight-Fingerprint Quarantine Contract
1. Fingerprint preflight hard bind（强约束）
`preflight_fingerprint_card.json` 必含 `cycle_id,failure_fingerprint,writable_probe_pass,index_lock_path,first_seen_cycle,last_seen_cycle,observed_at_utc`。
2. Delta pointer hard bind（强约束）
`delta_pointer_receipt.json` 必含 `failure_fingerprint,new_information,unchanged_sections,history_pointer,next_retry_condition`。
3. Verdict partition hard bind（强约束）
`verdict_partition_card.json` 必含 `runtime_verdict,gate_verdict,index_verdict,commit_verdict,cross_lane_override=false`。
4. Deferred receipt hard bind（强约束）
`deferred_commit_receipt.json` 必含 `content_delta_present,commit_required,commit_attempted,commit_status,reason_if_no_commit,retry_condition`。
5. Publish barrier（强约束）
仅当 `self_containment_pass && fidelity_pass && index_integrity_pass && commit_boundary_clear=true` 才允许 `publish_decision=closed`。

## Minimal Evidence Bundle
- `preflight_fingerprint_card.json`
- `delta_pointer_receipt.json`
- `verdict_partition_card.json`
- `deferred_commit_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 即可回答“主阻断是否在 commit 边界、下一步恢复条件是什么”。
- `Fidelity`: commit 通道异常不覆写 runtime/gate/index 的既有结论。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern 证据源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 首屏不报主阻断，先写长叙述后补 `index.lock` 失败。
- 把 commit 边界失败写成语义或证据门禁失败。
- 同指纹无新增信息仍重复发布全量历史。
- 用观测指标或伪精度分数替代合同布尔裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
