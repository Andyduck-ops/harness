# Handoff TTL Drift and Attestation Lint Pack

## Target Meta-Problem
owner 交接结论被跨窗口复用、同一 incident 多次漂移切换、attestation 字段缺省却被误判通过，导致“已交接”成为不可追责黑盒。

## 60s Decision Path
1. TTL first: 先校验 `handoff_expires_at` 是否仍在有效窗口，过期结论一律作废。
2. Drift next: 同一 `incident_id` 统计 owner 切换序列，超过预算视为漂移异常。
3. Delta lint: 对比上一版 attestation 字段集，缺省关键字段直接阻断。
4. Promote last: 仅当 TTL、drift、delta 三门全部通过，才允许继续晋级。

## Minimal Evidence Bundle
- `owner_gate_decision_card.json`
- `handoff_attestation.json`
- `handoff_history_log.json`
- `attestation_delta_lint.json`
- `recall_manifest.json`

## Hard Gates
- `handoff_ttl_guard_pass`
- `owner_drift_audit_pass`
- `attestation_delta_lint_pass`
- `owner_handoff_integrity_pass`

任一失败，禁止交接复用与晋级。

## Guard Contracts
1. TTL guard:
`handoff_attestation.decided_at_utc + ttl_window` 必须覆盖当前裁决时间；过窗必须重做交接裁决。
2. Drift audit:
同一 `incident_id` 在一个窗口内 owner 切换次数不得超过 `max_handoff_switches`；超限触发 freeze。
3. Attestation delta lint:
当前 attestation 必须包含上一版全部必填键，且 `failed_preconditions` 与 `decision` 不得语义冲突。

## Anti-Patterns
- 把历史 pass 结论跨窗口复用，不重做前置校验。
- 先切 owner 再补 attestation，制造“先行为后证据”。
- 字段缺省但依旧标记 `handoff_allowed=true`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
