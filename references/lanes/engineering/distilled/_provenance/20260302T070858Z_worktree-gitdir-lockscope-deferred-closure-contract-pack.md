# Provenance: worktree-gitdir-lockscope-deferred-closure-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/worktree-gitdir-lockscope-deferred-closure-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: 运行态与可晋级态分离，stale/blocked 通道必须显式化
  - retained: 失败先分流，不允许“看似活着”直接闭环
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: 语义门禁只在执行通道健康后裁决，防止环境故障误路由
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: 提交收据失败时不得伪造 lineage 完整性
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like 闭环声明必须后置到真实提交完成
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: index 更新和 shortcut 仅在 commit 成功后发布，保障 recall 连续性

## Compression Decisions
- removed_repetition:
  - “每轮重复解释 index.lock 权限失败”的长叙述
  - 把写边界异常与语义证据异常混写的段落
- preserved_boundaries:
  - lockscope_probe 与 semantic/evidence gate 明确分通道
  - commit failure 命中 lockscope 指纹时强制 deferred
  - closure 语义后置到 commit + index 双收据

## Auditor Notes
- self_containment: candidate
- fidelity: candidate
- index_integrity: candidate
