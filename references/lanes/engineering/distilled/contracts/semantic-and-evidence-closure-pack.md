# Semantic and Evidence Closure Pack

## Target Meta-Problem
如何避免“检查项都绿了，但需求语义未兑现、证据链不一致、prod-like 仍失败”的伪闭环。

## One-Page Contract
1. Semantic closure:
每个 `requirement_id` 至少映射一个 `assertion_id`，且 `conformance_score` 过阈值。
2. Lineage closure:
所有关键工件必须共享 `lineage_id + head_sha + digest_set_id`，防止跨链拼接。
3. Runtime closure:
AI 生成代码必须通过 prod-like 场景回放，记录 `seed/path/replay_path` 可复现。
4. Promotion closure:
`contract_replay_pass + prodlike_e2e_pass + runtime_boundary_parity_pass + mutation_threshold_pass` 同时为真。

## Minimal Evidence Bundle
- `requirement_assertion_map.json`
- `semantic_conformance_report.json`
- `artifact_lineage_manifest.json`
- `artifact_digest_set.json`
- `artifact_promotion_attestation.json`
- `prodlike_e2e_manifest.json`
- `replay_repro_bundle.json`
- `promotion_closure.json`

## Blocking Gates (Hard)
- `requirement_conformance_pass`
- `artifact_lineage_lock_pass`
- `prodlike_e2e_pass`
- `runtime_boundary_parity_pass`

任一失败，禁止晋级。

## Fast Triage Playbook
1. 查 unmet semantics：`unmapped_requirements[]`、`stale_assertions[]`。
2. 查 evidence parity：digest 与 `head_sha` 是否一致。
3. 查 prod-like replay：失败是否可重放，边界档案是否同构。

## Anti-Patterns
- 只验证 required checks，不验证需求语义断言。
- 工件来自不同 head 仍允许合并。
- E2E 绿但不保留 replay 证据。
- 生产边界漂移未阻断。

## Source Patterns
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
