# Provenance: gate-verdict-brief-budget-channel-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/gate-verdict-brief-budget-channel-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行态结论要先结构化，再进入恢复动作，避免单通道过载。
  - retained: stale/blocked 事件需要 receipt 化，不应依赖长文本叙述。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同判定与外围错误必须分离，避免归因串线。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 发布前需对账并形成可回链证据，拒绝“叙述替代证据”。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: 内容闭环结论不应被环境提交阻塞覆盖。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 检索入口命名稳定与 pointer-only 叙述可降低跨轮漂移与重复。

## Compression Decisions
- removed_repetition:
  - 相同 `index.lock permission denied` 错误签名的跨轮长句重放
  - 把 gate verdict 与 git blocked 合并为单一失败结论
- preserved_boundaries:
  - verdict/gitchannel/narrative 三通道隔离
  - narrative 改为 pointer-only，细节回链 provenance
  - dedup receipt 作为重复签名唯一增量载体

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
