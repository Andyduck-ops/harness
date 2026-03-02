# Provenance: watchdog-restart-cycle-drift-channel-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/watchdog-restart-cycle-drift-channel-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat/backpressure 连续性信号必须独立判定，不得被门禁结论覆盖。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 语义符合性失败必须保持独立 verdict，不能被运行漂移替代。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 证据链和 digest 对账通道必须保留，不并入 commit 错误解释。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 边界保留，避免被 watchdog 重启叙述污染。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 索引连续性仍需独立证据回链，不因重启而降级为文本描述。

## Compression Decisions
- removed_repetition:
  - 同一轮反复解释 `state running + runtime stopped` 的长叙述
  - `index.lock permission denied` 的跨门重复扩写
- preserved_boundaries:
  - 连续性通道、语义通道、证据通道、提交边界通道分离
  - 同签名只通过 `restart_delta_receipt` 递增
  - 发布前必须通过 `closure_gate_matrix` 的通道一致性检查

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
