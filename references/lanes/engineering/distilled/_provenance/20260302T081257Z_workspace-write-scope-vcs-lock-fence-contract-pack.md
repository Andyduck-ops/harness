# Provenance: workspace-write-scope-vcs-lock-fence-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/workspace-write-scope-vcs-lock-fence-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: runtime 新鲜度与 backpressure 仅归入 runtime 通道，不与 commit 边界混写。
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement/assertion 的语义门禁独立判定，不受提交锁冲突影响。
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: artifact lineage 与 digest 对账继续走 evidence 通道，不被 VCS 错误挪用。
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 闭环保持独立证据链，禁止被 commit 失败覆盖。
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: recall/rollback 一致性保留在 runtime/evidence 通道，避免通道污染。

## Compression Decisions
- removed_repetition:
  - 删除“每轮重复 index.lock 全背景”叙述，改为 blocker pointer。
  - 删除把 commit 失败写进 gate verdict 的重复文本。
- preserved_boundaries:
  - gate/evidence/runtime/commit 四通道硬隔离。
  - workspace 可写域与 gitdir 锁域分离建模。
  - 指标仅观测，不参与合同裁决。

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
