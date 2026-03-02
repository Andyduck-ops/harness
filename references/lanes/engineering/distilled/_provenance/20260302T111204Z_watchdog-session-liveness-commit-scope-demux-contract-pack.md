# Provenance: watchdog-session-liveness-commit-scope-demux-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/watchdog-session-liveness-commit-scope-demux-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 会话活性声明必须绑定 heartbeat/lease 证据，不得替代闭环结论。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同裁决必须绑定断言证据，禁止借道运行或提交边界错误。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: runtime/runpair/contracts/receipt 四域需分层对账并可回放。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 结果与会话活性、提交边界隔离归因。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 同签名异常只发布 delta，历史通过 pointer 回链。

## Compression Decisions
- removed_repetition:
  - watchdog/session 存活与 cycle 闭环在多轮重复混写。
  - 相同 `index.lock permission denied` 在 gate 区域反复回放。
- preserved_boundaries:
  - session liveness / cycle closure / contract verdict / commit receipt 四通道隔离。
  - patterns 证据层只读，本轮新增仅写 distilled。

## Auditor Notes
- self_containment: pass-candidate
- fidelity: pass-candidate
- index_integrity: pass-candidate
