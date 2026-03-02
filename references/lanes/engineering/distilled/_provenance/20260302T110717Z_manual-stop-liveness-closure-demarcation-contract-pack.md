# Provenance: manual-stop-liveness-closure-demarcation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/manual-stop-liveness-closure-demarcation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行活性必须由 lease/heartbeat 证据独立证明，不得替代闭环证据。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同门裁决必须由约束断言与证据映射产生，不能受运行策略字段污染。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: runtime claim / closure proof / gate verdict / policy receipt 必须分层对账。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 闭环失败与运行策略分离归因，避免同层混写。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 同签名长跑态仅发布 delta，历史通过 pointer 回链。

## Compression Decisions
- removed_repetition:
  - 持续运行约束在多轮重复全文解释，导致首屏读负担扩张。
  - 手动停机策略字段被错误挪用为 gate 理由。
- preserved_boundaries:
  - liveness / closure / policy / contracts 四通道隔离。
  - patterns 证据层保持只读，本轮仅新增 distilled 与 provenance。

## Auditor Notes
- self_containment: pass-candidate
- fidelity: pass-candidate
- index_integrity: pass-candidate
