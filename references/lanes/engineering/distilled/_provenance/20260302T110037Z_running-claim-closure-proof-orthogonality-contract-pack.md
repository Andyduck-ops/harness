# Provenance: running-claim-closure-proof-orthogonality-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/running-claim-closure-proof-orthogonality-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行活性必须由 lease/heartbeat 新鲜度独立证明，不得替代闭环证明。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同裁决必须绑定语义断言，不得被提交回执错误替代。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: runtime claim、closure proof、gate verdict、receipt 需要分层对账。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 闭环与执行环境报错需隔离归因。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 同指纹失败态只发布 delta，历史通过 pointer 回链。

## Compression Decisions
- removed_repetition:
  - `running` 声明与 `closure` 结论在冻结轮被重复绑定叙述。
  - `index.lock permission denied` 在多个段落重复解释并污染 gate 原因。
- preserved_boundaries:
  - runtime claim / closure proof / contract verdict / commit receipt 四通道隔离。
  - patterns 证据层只读，本轮新增仅写 distilled。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
