# Gitdir Writability Preflight Deferred Receipt Contract Pack

## Target Meta-Problem
恢复轮里若每次都在末尾才发现 `index.lock permission denied`，会持续放大三类信号：
- 阅读负担：执行者要先读完整段才知道本轮其实卡在 commit 边界。
- 元问题混杂：commit 写路径不可达被误混为 semantic/evidence/runtime 质量失败。
- 重复叙述：同一 lockscope 指纹被跨轮全量复述，增量信息稀薄。

## 60s Compression Path
1. 在写任何长叙述前先执行 `gitdir_writability_probe`，首屏发布 `preflight_boundary_card`。
2. probe 失败时立即进入 `deferred-commit`，只输出 `delta_receipt + retry_condition`，不重讲历史。
3. 把质量门 verdict 固定在 `runtime/gate/index` 通道，`commit` 通道单独隔离。
4. probe 通过才允许进入完整 publish 路径与 commit 尝试。
5. 同 fingerprint 仅追加 `new_information`，历史解释统一指向 `history_pointer`。

## Preflight-Deferred Contract
1. Preflight hard bind（强约束）
`preflight_boundary_card.json` 必含 `cycle_id,git_dir,index_lock_path,writable_probe_pass,failure_fingerprint,observed_at_utc`。
2. Deferred receipt hard bind（强约束）
`deferred_commit_receipt.json` 必含 `content_delta_present,commit_attempted,commit_status,reason_if_no_commit,retry_condition`。
3. Channel isolation hard bind（强约束）
`verdict_lane_card.json` 必含 `runtime_verdict,gate_verdict,index_verdict,commit_verdict,cross_lane_override=false`。
4. Repetition delta hard bind（强约束）
`repetition_delta_receipt.json` 必含 `failure_fingerprint,window_cycles,new_information,history_pointer`。
5. Publish barrier（强约束）
`self_containment_pass && fidelity_pass && index_integrity_pass && writable_probe_pass=true` 才允许 `publish_decision=closed`。

## Minimal Evidence Bundle
- `preflight_boundary_card.json`
- `deferred_commit_receipt.json`
- `verdict_lane_card.json`
- `repetition_delta_receipt.json`
- `heartbeat_status.json`
- `semantic_conformance_report.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单看 fragment 能直接回答“本轮卡点是否为 commit 可写性，下一步恢复条件是什么”。
- `Fidelity`: commit 通道失败不会覆写 runtime/gate/index verdict。
- `Index Integrity`: fragment/provenance/index 命名一致且可回链 5 个 pattern 源。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 未做 preflight 就进入长篇诊断，最后才抛出 lockscope 失败。
- 把 `index.lock permission denied` 写成语义门禁失败。
- 无新增信息仍重复全量历史而不写 delta receipt。
- 用指标值或伪精度分数替代合同布尔裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
