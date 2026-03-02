# PID Proof / State Claim Fence Contract Pack

## Target Meta-Problem
恢复轮把 `state.json.status=running` 当作已验证事实，而不校验 pid 与最近心跳证据，会同时触发三类信号：
- 阅读负担信号：读者必须反查 pid 文件、进程表、state 时间戳才能确认是否真的在跑。
- 元问题混杂信号：把“进程活性缺证”误写成语义门禁或证据门禁失败。
- 重复叙述信号：同一 `running-claim-without-pid-proof` 指纹跨轮重复解释，增量事实被淹没。

## 60s Compression Path
1. 首屏固定 `state_claim_router_card`，先给本轮合同裁决与下一动作。
2. `running` 声明必须绑定 `pid_witness_card` 与 `heartbeat_freshness_card`，缺一即降级 `deferred`。
3. pid 不存在或心跳过窗时，只发布 `claim_mismatch_delta`，禁止重放历史全文。
4. `meta_scope_router` 强制分离 `runtime_claim` 与 `semantic/evidence` 问题面。
5. commit 边界异常仅写 `commit_receipt`，不得反向改写三门合同结论。

## Claim Fence Contract
1. State claim hard bind:
`state_claim_router_card.json` 必含 `cycle_id,state_status_claim,claim_updated_at,primary_verdict,next_action`。
2. PID witness hard bind:
`pid_witness_card.json` 必含 `pid_source,pid_value,pid_exists,process_signature,observed_at_utc`。
3. Heartbeat freshness hard bind:
`heartbeat_freshness_card.json` 必含 `heartbeat_at,cursor_lag_seconds,freshness_window_seconds,freshness_pass`。
4. Mismatch decision fence:
当 `state_status_claim=running` 且 (`pid_exists=false` 或 `freshness_pass=false`) 时，`publish_decision` 必须是 `deferred`。
5. Scope isolation fence:
`meta_scope_router.json` 必含 `runtime_claim_scope,semantic_scope,evidence_scope,cross_scope_write=false`。

## Minimal Evidence Bundle
- `state_claim_router_card.json`
- `pid_witness_card.json`
- `heartbeat_freshness_card.json`
- `claim_mismatch_delta.json`
- `meta_scope_router.json`
- `commit_receipt.json`
- `artifact_lineage_manifest.json`
- `semantic_conformance_report.json`
- `prodlike_e2e_manifest.json`
- `recall_manifest.json`

## Hard Gates
- `Self-Containment`: 仅凭本碎片即可回答“running 声明是否可信、阻断点在哪、下一轮怎么恢复”。
- `Fidelity`: 保留 runtime/semantic/evidence 边界与反模式映射，不用观测指标替代合同裁决。
- `Index Integrity`: fragment/provenance/index 行与 shortcut 命名一致，可回链到 5 个 pattern 主证据路径。

任一 gate fail：进入 `deferred-reconcile`，禁止标记 `publish_decision=closed`。

## Anti-Patterns
- 仅凭 `state.json.status=running` 发布“系统持续运行”结论。
- pid 不存在但仍把失败归因为 semantic/evidence gate。
- 把 commit 锁域错误写成合同门禁失败。
- 同签名重试时重复整段历史而不发布 `claim_mismatch_delta`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
