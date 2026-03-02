# Provenance: runtime-drift-observation-verdict-isolation-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/runtime-drift-observation-verdict-isolation-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 运行观测保持 runtime 通道独立，不被状态声明直接覆写
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 语义裁决保持 gate 通道独立
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest 对账语义保留在 evidence 通道
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 与 replay 结论保持 gate 通道，不被漂移观测覆写
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index shard/recall 连续性独立记录，可在 commit 延后时先发布检索层

## Compression Decisions
- removed_repetition:
  - 同签名 runtime drift 的跨轮全量复述
  - 把观察信号直接写成 gate fail 的混写叙述
- preserved_boundaries:
  - `runtime_probe/state_claim/partition` 三卡分层
  - runtime/gate/index/commit 四通道 verdict 隔离
  - patterns 证据层只读，新增仅写入 distilled 检索层

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
