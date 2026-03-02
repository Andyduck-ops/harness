# Provenance: verdict-first-evidence-ops-demux-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/verdict-first-evidence-ops-demux-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行连续性判断归属 ops 通道，不越权改写 gate 裁决。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 语义合同裁决先于诊断叙述发布，且保持可复核。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 证据层只接受 allowlist 输入，保留 lineage 与对账约束。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 闭环结论只在门禁层表达，不与运行噪声混写。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index 与 recall 路径保持可回链，同签名仅增量写入。

## Compression Decisions
- removed_repetition:
  - 同阻断签名的跨轮全量背景复述。
  - 运行诊断日志在知识层中的重复回灌。
- preserved_boundaries:
  - verdict-first 首屏固定。
  - ops/evidence 双通道隔离。
  - patterns 证据层只读，增量仅写 distilled。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
