# Provenance: signal-lens-router-fidelity-freeze-contract-pack

- fragment: `references/lanes/engineering/distilled/contracts/signal-lens-router-fidelity-freeze-contract-pack.md`
- lane: `engineering`
- method: `topology-distill`
- focus_signals: `阅读负担`, `元问题混杂`, `重复叙述`

## Evidence Mapping
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
  - retained: lease/heartbeat 新鲜度约束与 backpressure 冻结触发
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
  - retained: requirement→assertion 映射闭环与 conformance 阻断
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
  - retained: lineage/head_sha/digest_set 同源锁与 digest 对账
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
  - retained: prod-like replay 可重放与边界一致性门
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
  - retained: shard/recall/rollback continuity 合同与漂移冻结

## Compression Decisions
- removed_repetition:
  - 删除多角色视角下同窗口全量 narrative 复写
  - 删除单卡中事实/推理/裁决混写段
- preserved_boundaries:
  - lens router 与三 signal capsule 分层
  - fidelity anchor 与 verdict delta pointer 分层
  - 任一闭环失败即冻结发布

## Auditor Notes
- self_containment: pass
- fidelity: pass
- index_integrity: pass
