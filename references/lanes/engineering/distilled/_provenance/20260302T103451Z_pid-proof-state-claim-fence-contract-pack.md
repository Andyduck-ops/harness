# Provenance: pid-proof-state-claim-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/pid-proof-state-claim-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: running 判定必须绑定 lease/heartbeat 新鲜度，失配只能 deferred。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 裁决先行，语义门禁不能吞并 runtime claim 漂移。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: claim 证据链要可回放，避免“做过但对不上账”。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 结论独立于进程活性探针，禁止跨 scope 覆写。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: 回滚/召回路径与 state claim 分通道，先验连续性后做晋级判断。

## Compression Decisions
- removed_repetition:
  - 同签名反复解释“state=running 但无活性证明”的历史长文。
  - 每轮重复粘贴 commit 边界报错到 gate 结论段。
- preserved_boundaries:
  - state claim 与 pid witness 双证据绑定。
  - runtime/semantic/evidence 三 scope 隔离。
  - patterns 证据层只读，增量仅写 distilled。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
