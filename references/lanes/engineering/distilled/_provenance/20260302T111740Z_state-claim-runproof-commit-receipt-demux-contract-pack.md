# Provenance: state-claim-runproof-commit-receipt-demux-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/state-claim-runproof-commit-receipt-demux-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 活性声明必须绑定 lease/heartbeat，`state=running` 不能替代 runproof。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 合同裁决理由域固定 contracts，不得混入提交错误。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: state/runproof/contracts/receipt 四域对账并保持可追溯映射。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 证据独立记录，不借由 state 声明推导通过。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 同签名异常仅做 delta 回放，历史下沉 pointer。

## Compression Decisions
- removed_repetition:
  - 同签名 `index.lock permission denied` 的背景解释不再跨轮全文复制。
  - state 运行声明不再与 gate/commit 混叙。
- preserved_boundaries:
  - state claim / runtime proof / contract verdict / commit receipt 通道隔离。
  - patterns 证据层保持只读，新增内容仅写 distilled。

## Auditor Notes
- self_containment: pass-candidate
- fidelity: pass-candidate
- index_integrity: pass-candidate
