# Watchdog Session Liveness / Commit Scope Demux Contract Pack

## Target Meta-Problem
恢复轮中若把 tmux/session 存活声明、cycle 闭环状态、以及 git 提交锁域失败写在同一层，会持续触发三类信号：
- 阅读负担信号：首屏无法区分“会话仍在重启”与“本轮已闭环”。
- 元问题混杂信号：VCS 锁域错误被误归因为 Self-Containment/Fidelity 失败。
- 重复叙述信号：同一 `index.lock permission denied` 在每轮全文回放，增量事实被稀释。

## 60s Compression Path
1. 首屏固定 `session_liveness_card`，只回答“runner/watchdog 是否存活”。
2. `cycle_closure_card` 独立声明 run pair 是否闭环，缺失 `run_end` 直接 `deferred`。
3. 三门合同只读取 `contract_gate_card`，理由域限定 `contracts`。
4. `commit_scope_receipt_card` 独立记录 `workspace-write` 与 `gitdir-lockscope` 的写域差异。
5. 同签名失败仅发布 `delta_fact_card`，历史下沉 `history_pointer_card`。

## Demux Contract
1. Session liveness isolation（强约束）
`session_liveness_card.json` 必含 `session_name,tmux_alive,codex_process_seen,scope=runtime`。
2. Cycle closure isolation（强约束）
`cycle_closure_card.json` 必含 `cycle_id,run_start_seen,run_end_seen,closure_verdict,scope=runpair`。
3. Gate reason purity（强约束）
`contract_gate_card.json` 必含 `self_containment,fidelity,index_integrity,reason_scope=contracts`。
4. Commit scope demux（强约束）
`commit_scope_receipt_card.json` 必含 `workspace_write,gitdir_write,receipt_status,error_class,lock_scope`。
5. Delta-only replay（强约束）
`delta_fact_card.json` 必含 `fingerprint,new_fact,unchanged_context`，禁止内联历史全文。

## Minimal Evidence Bundle
- `session_liveness_card.json`
- `cycle_closure_card.json`
- `contract_gate_card.json`
- `commit_scope_receipt_card.json`
- `delta_fact_card.json`
- `history_pointer_card.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 单碎片可独立回答“会话是否存活、cycle 是否闭环、阻塞域在哪里”。
- `Fidelity`: 保留 runtime / runpair / contracts / receipt 四通道边界，不跨通道推导。
- `Index Integrity`: fragment/provenance/index 命名一致，且可回链 5 个 pattern 主证据。

任一 gate fail：进入 `deferred-reconcile`，禁止 `publish_decision=closed`。

## Anti-Patterns
- 用 `tmux_alive=true` 直接推导 `cycle_closure=closed`。
- 把 `index.lock permission denied` 写成 Fidelity 失败理由。
- 在 gate 段重复粘贴提交失败堆栈。
- 用观测指标分数替代合同裁决。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
