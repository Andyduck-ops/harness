# Provenance: probe-state-commit-trichotomy-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/probe-state-commit-trichotomy-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度决定 runtime 通道结论，避免状态声明越权。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: gate verdict 维持 requirement/assertion 语义闭环，不受提交失败覆写。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/digest 对账用于提交延后时的证据连续性声明。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like/replay 结论留在 gate 通道，不被 commit writability 问题回滚。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index/recall 连续性独立记录，确保 deferred commit 下检索层可回链。

## Compression Decisions
- removed_repetition:
  - 同一 `index.lock permission denied` 指纹的跨轮全量复述。
  - 把 runtime probe、gate verdict、commit 结论混写到单段状态描述。
- preserved_boundaries:
  - `runtime/state/commit` 三卡并列输出。
  - `runtime_verdict/gate_verdict/commit_verdict` 三元隔离。
  - patterns 证据层只读，新增仅写入 distilled 检索层。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
