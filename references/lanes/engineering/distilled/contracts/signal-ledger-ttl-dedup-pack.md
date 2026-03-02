# Signal Ledger TTL Dedup Pack

## Target Meta-Problem
同一窗口内的门禁文档同时承担检测、叙述、裁决三重职责，导致信号卡跨窗口复制、读路径膨胀、结论错链复用。

## 60s Compression Path
1. 所有门禁只写 `signal_ledger_card`（结构化信号），禁止在门禁层写最终 verdict。
2. 每张卡必须绑定 `incident_window_id + lineage_id + owner_scope + evidence_ref`。
3. 由 `signal_digest_rollup` 生成窗口级摘要，router 仅消费摘要与证据指针。
4. 超过 TTL 的信号卡进入 `window_gc_manifest`，禁止被新窗口再次引用。

## Signal-Ledger Contract
1. Ledger-only write:
门禁层只允许写结构化卡片，不允许自由文本复述全量结论。
2. TTL and window binding:
每张卡必须带 `created_at_utc` 与 `ttl_until_utc`，且只在同一 `incident_window_id` 有效。
3. Lineage parity:
`lineage_id/head_sha/digest_set_id` 必须与证据账本一致。
4. Router isolation:
仅 `promotion_verdict_router` 可产出 `single_promotion_verdict`。

## Minimal Evidence Bundle
- `signal_ledger_cards.json`
- `signal_digest_rollup.json`
- `window_gc_manifest.json`
- `artifact_lineage_manifest.json`
- `recall_manifest.json`
- `single_promotion_verdict.json`

## Hard Gates
- `signal_card_schema_pass`
- `window_ttl_gc_pass`
- `lineage_digest_parity_pass`
- `router_isolation_pass`

任一失败，阻断 `promote/merge`，并冻结本窗口 verdict 复用。

## Anti-Patterns
- 门禁文档粘贴上轮 verdict 并改写措辞。
- 缺失 `evidence_ref` 仍输出晋级建议。
- TTL 过期卡片被继续用于新窗口裁决。
- 非 router 角色输出最终 `single_promotion_verdict`。

## Source Patterns
- `references/lanes/engineering/patterns/autonomous-ops/background-agent-runplane-lease-heartbeat-dlq-backpressure.md`
- `references/lanes/engineering/patterns/product-delivery/requirement-assertion-semantic-conformance-score-gate.md`
- `references/lanes/engineering/patterns/evidence-governance/artifact-retention-reconciliation-governance.md`
- `references/lanes/engineering/patterns/fullstack-engineering/ai-generated-code-prodlike-e2e-closure-gate.md`
- `references/lanes/engineering/patterns/runtime-governance/long-context-index-sharding-recall-rollback-contract.md`
