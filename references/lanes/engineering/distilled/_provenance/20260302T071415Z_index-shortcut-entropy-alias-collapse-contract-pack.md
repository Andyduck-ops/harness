# Provenance: index-shortcut-entropy-alias-collapse-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/index-shortcut-entropy-alias-collapse-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行态门禁必须先分流再裁决，避免噪声通道误晋级
  - retained: 长跑循环里失败应输出 delta 而非整段复写
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同裁决必须绑定可验证断言，不接受模糊同义结论
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 证据链需有唯一映射，避免 alias 扩散导致 lineage 断裂
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: 发布闭环必须后置到可验证收据，不以文本“看起来完整”为准
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index/recall 合同要求检索入口稳定、可回滚、可追溯

## Compression Decisions
- removed_repetition:
  - 每轮新增近义 retrieval shortcut 的重复叙述
  - 把 index 噪声与语义合同失败混写的描述
- preserved_boundaries:
  - canonical query 与 alias delta 分离
  - index 发布需绑定 fragment + provenance + canonical query
  - duplicate signature 命中时仅允许 alias_delta_only

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
