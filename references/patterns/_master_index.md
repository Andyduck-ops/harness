# Pattern Master Index

> 合并收敛版索引（Harvest Consolidation）。
> 最后更新：2026-03-01

## Top Patterns

| Rank | Pattern | Topic | Confidence | Sources |
|------|---------|-------|-----------|----------|
| 1 | [progressive-disclosure](./context-injection/progressive-disclosure.md) | context-injection | 0.95 | 11 |
| 1 | [anchor-shape-decode-escape](./knowledge-evolution/anchor-shape-decode-escape.md) | knowledge-evolution | 0.90 | 10 |
| 1 | [compound-learning](./knowledge-evolution/compound-learning.md) | knowledge-evolution | 0.90 | 12 |
| 1 | [failure-budget](./agent-lifecycle/failure-budget.md) | agent-lifecycle | 0.90 | 12 |
| 1 | [hook-based-enforcement](./quality-enforcement/hook-based-enforcement.md) | quality-enforcement | 0.90 | 14 |
| 1 | [scout-distill-analyze-rank-merge](./meta-framework/scout-distill-analyze-rank-merge.md) | meta-framework | 0.75 | 17 |
| 2 | [custom-linter-messages](./quality-enforcement/custom-linter-messages.md) | quality-enforcement | 0.85 | 14 |
| 2 | [permission-ladder](./agent-lifecycle/permission-ladder.md) | agent-lifecycle | 0.85 | 10 |
| 2 | [staleness-detection](./knowledge-evolution/staleness-detection.md) | knowledge-evolution | 0.85 | 14 |
| 2 | [structured-escalation](./agent-lifecycle/structured-escalation.md) | agent-lifecycle | 0.85 | 13 |
| 2 | [contract-replay-verification-gate](./fullstack-engineering/contract-replay-verification-gate.md) | fullstack-engineering | 0.82 | 10 |
| 2 | [audit-gated-autonomy](./autonomous-ops/audit-gated-autonomy.md) | autonomous-ops | 0.81 | 15 |
| 2 | [observation-masking](./context-injection/observation-masking.md) | context-injection | 0.80 | 8 |
| 2 | [pipeline-gate-canonicalization](./pipeline-governance/pipeline-gate-canonicalization.md) | pipeline-governance | 0.80 | 9 |
| 2 | [token-storybook-readiness](./fullstack-engineering/token-storybook-readiness.md) | fullstack-engineering | 0.80 | 10 |
| 3 | [prd-epic-contract-replay-closure-gate](./product-delivery/prd-epic-contract-replay-closure-gate.md) | product-delivery | 0.80 | 23 |
| 3 | [agent-scope-identity-memory-governance](./runtime-governance/agent-scope-identity-memory-governance.md) | runtime-governance | 0.79 | 11 |
| 3 | [dual-gate-execution-card](./product-delivery/dual-gate-execution-card.md) | product-delivery | 0.79 | 24 |
| 3 | [evidence-provenance-freshness-trust-governance](./evidence-governance/evidence-provenance-freshness-trust-governance.md) | evidence-governance | 0.79 | 7 |
| 3 | [merge-queue-failure-surface-budget](./pipeline-governance/merge-queue-failure-surface-budget.md) | pipeline-governance | 0.79 | 8 |
| 3 | [required-checks-snapshot-closure-gate](./product-delivery/required-checks-snapshot-closure-gate.md) | product-delivery | 0.79 | 25 |
| 3 | [artifact-retention-reconciliation-governance](./evidence-governance/artifact-retention-reconciliation-governance.md) | evidence-governance | 0.78 | 10 |
| 3 | [context-compaction-replay-governance](./runtime-governance/context-compaction-replay-governance.md) | runtime-governance | 0.78 | 6 |
| 3 | [deployment-review-throughput-governance](./pipeline-governance/deployment-review-throughput-governance.md) | pipeline-governance | 0.78 | 6 |
| 3 | [multi-lane-discovery-arbitration](./discovery-governance/multi-lane-discovery-arbitration.md) | discovery-governance | 0.78 | 10 |
| 3 | [control-plane-conflict-governance](./runtime-governance/control-plane-conflict-governance.md) | runtime-governance | 0.77 | 9 |
| 3 | [opml-hn-priority-watchlist](./autonomous-ops/opml-hn-priority-watchlist.md) | autonomous-ops | 0.77 | 6 |
| 3 | [promotion-cooldown-latency-governance](./discovery-governance/promotion-cooldown-latency-governance.md) | discovery-governance | 0.77 | 6 |
| 3 | [24h-unattended-ai-loop](./autonomous-ops/24h-unattended-ai-loop.md) | autonomous-ops | 0.72 | 10 |
| 3 | [frontend-system-first](./fullstack-engineering/frontend-system-first.md) | fullstack-engineering | 0.68 | 9 |
| 3 | [backend-contract-first](./fullstack-engineering/backend-contract-first.md) | fullstack-engineering | 0.66 | 9 |

## Topics

| Topic | Patterns | 说明 |
|-------|----------|------|
| [context-injection/](./context-injection/) | 2 | 上下文注入与可读性策略 |
| [quality-enforcement/](./quality-enforcement/) | 2 | 质量规则强制执行 |
| [agent-lifecycle/](./agent-lifecycle/) | 3 | Agent 生命周期与故障预算 |
| [knowledge-evolution/](./knowledge-evolution/) | 3 | 知识进化与衰减治理 |
| [meta-framework/](./meta-framework/) | 1 | Scout→Distill→Analyze→Merge 元框架 |
| [autonomous-ops/](./autonomous-ops/) | 3 | 24h 无人推进与审计闭环 |
| [fullstack-engineering/](./fullstack-engineering/) | 4 | 前后端契约 + 设计系统执行 |
| [product-delivery/](./product-delivery/) | 3 | PRD→Issue→PR→Pattern 闭环交付 |
| [pipeline-governance/](./pipeline-governance/) | 3 | CI/Release/Queue 一体化门禁治理 |
| [discovery-governance/](./discovery-governance/) | 2 | 多信号车道发现与晋级治理 |
| [runtime-governance/](./runtime-governance/) | 3 | 运行时权限/状态/冲突控制治理 |
| [evidence-governance/](./evidence-governance/) | 2 | 证据来源、时效、信任与对账治理 |

## 统计

- 总计：31 patterns
- 平均 confidence：0.81
- 高置信度（≥0.90）：5 patterns
- 待验证（<0.80）：16 patterns

## 合并归档

- 归档路径：`references/patterns/_archive/20260301_harvest`
- 说明：非核心/重复的治理切片已归档，保留可追溯历史。
