# Provenance: runner-liveness-receipt-channel-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/runner-liveness-receipt-channel-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 活性声明必须绑定 heartbeat/lease/pulse 证据，缺证只能 deferred。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: gate 裁决先行，不能被运行噪声或提交回执覆盖。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: receipt 与 verdict 都需可回放映射，避免“已处理但不可对账”。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 结果不得反向证明 runner liveness。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 历史回放下沉 pointer，首屏只保留本轮 delta 与动作。

## Compression Decisions
- removed_repetition:
  - 同签名轮次反复全量解释 channel closed 与 index.lock 历史报错。
  - 在 gate 结论段重复粘贴提交失败尾日志。
- preserved_boundaries:
  - runtime liveness 与 commit receipt 双通道隔离。
  - state claim 与 witness proof 硬绑定。
  - patterns 证据层只读，增量仅写 distilled。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
