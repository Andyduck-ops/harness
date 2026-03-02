# State Claim Runproof Commit Receipt Demux Contract Pack

## Target Meta-Problem
恢复轮若把 `state.json` 的运行声明、runtime 活性证据、三门合同裁决与 commit 回执写在同一叙述层，会同时触发：
- 阅读负担信号：首屏需要跨域比对才能判断“是否真的在跑”；
- 元问题混杂信号：合同失败理由被 commit 锁域错误污染；
- 重复叙述信号：同签名 `index.lock permission denied` 在每轮全文回放。

## 60s Compression Path
1. 固化 `state_claim_card`：只声明 `cycle,status,lane,updated_at`，不承担活性证明。
2. 固化 `runproof_card`：活性仅由 `pid + heartbeat + lease` 证明，禁止借用 state 声明。
3. 固化 `gate_verdict_card`：三门合同只写 `pass/fail + reason_scope=contracts`。
4. 固化 `commit_receipt_card`：提交边界异常只写 `repo_path,gitdir_path,lock_path,error_signature`。
5. 固化 `history_pointer_card`：同签名异常只发 delta，历史解释回链 pointer。

## Demux Contract
1. State claim isolation:
`state_claim_card.json` 必含 `cycle,status,lane,updated_at`，且不得含 gate verdict 字段。
2. Runtime proof orthogonality:
`runproof_card.json` 必含 `pid,heartbeat_at,lease_owner,stale_run`。
3. Gate reason purity:
`gate_verdict_card.json` 的 `reason_scope` 必须为 `contracts`。
4. Commit boundary quarantine:
`commit_receipt_card.json` 与 `gate_verdict_card.json` 禁止相互写回。
5. Delta-only replay:
同 `error_signature` 连续出现时，仅追加 `delta_fact_card.json`。

## Minimal Evidence Bundle
- `state_claim_card.json`
- `runproof_card.json`
- `gate_verdict_card.json`
- `commit_receipt_card.json`
- `delta_fact_card.json`
- `history_pointer_card.json`
- `runplane_lease_registry.json`
- `heartbeat_status.json`
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭 state_claim/runproof/gate_verdict/commit_receipt 可回答“是否在跑、合同是否通过、提交为何阻塞”。
- `Fidelity`: 保留 lease-heartbeat、requirement-assertion、artifact lineage、prod-like、recall rollback 的边界映射。
- `Index Integrity`: fragment/provenance/index/retrieval shortcut 四点可回链。

任一 gate fail：阻断晋级，只发布 `delta_fact_card` + `history_pointer_card`。

## Anti-Patterns
- 用 `status=running` 直接替代 runtime 活性证明。
- 将 commit 锁域错误写入合同门失败理由。
- 同签名失败每轮重放完整背景文本。
- 在同段混写 state 声明、gate 裁决和提交事务。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
