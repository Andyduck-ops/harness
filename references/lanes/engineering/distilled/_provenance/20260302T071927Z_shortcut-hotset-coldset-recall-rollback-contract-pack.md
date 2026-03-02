# Provenance: shortcut-hotset-coldset-recall-rollback-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/shortcut-hotset-coldset-recall-rollback-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行态信号必须先分层路由再裁决，避免热噪声直接晋级。
  - retained: 长跑回合应输出 delta，不应全量重放。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 查询入口必须绑定可执行断言，避免语义漂移。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 分层变更必须写入 receipt，保证证据链对账可追溯。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: 关闭发布前必须先拿到可复验收据，而非文本完整性。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 召回 fidelity 降级时先回滚到上一个稳定 shard，再做增量。

## Compression Decisions
- removed_repetition:
  - retrieval shortcuts 同义长串跨轮重复追加
  - 将索引容量信号与语义 gate 失败混写的叙述
- preserved_boundaries:
  - hotset 与 coldset 分层
  - recall 降级与 rollback 动作绑定
  - 发布闭环依赖 tier receipt + provenance

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
