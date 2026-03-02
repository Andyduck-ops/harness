# Provenance: gate-reason-purity-receipt-attribution-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/gate-reason-purity-receipt-attribution-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行活性与阻断面需要独立证据通道，不能被旁路错误覆盖。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 门禁裁决必须绑定语义断言证据，不得借道非语义错误。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: receipt 与 gate reason 都需可对账映射，防止“有报错但无归因”。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 失败或通过都不能直接篡改 gate reason attribution。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 同指纹错误回放采用 delta + history pointer，禁止全文复读。

## Compression Decisions
- removed_repetition:
  - 同一 `index.lock permission denied` 报错在每轮 gate 结论段重复粘贴。
  - 在三门合同段重复解释 commit 边界失败细节。
- preserved_boundaries:
  - contract gate reason 与 commit receipt 分通道。
  - gate fail 理由必须绑定 gate 语义证据。
  - patterns 证据层只读，新增仅写 distilled。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
