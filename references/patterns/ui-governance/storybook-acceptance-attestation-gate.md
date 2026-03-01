---
name: storybook-acceptance-attestation-gate
topic: ui-governance
confidence: 0.78
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - HN top lane sample: https://news.ycombinator.com/item?id=47197267 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47180083 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201629 (sampled 2026-03-01)
  - Design Tokens Format Module (https://www.designtokens.org/tr/drafts/format/)
  - Storybook docs: stories as test cases; run UI tests in CI (https://storybook.js.org/docs/writing-tests)
  - GitHub Docs: required status checks on protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: use artifact attestations to establish provenance for builds (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds)
merge_upgrade_of:
  - references/patterns/fullstack-engineering/token-storybook-readiness.md
  - references/patterns/artifact-governance/artifact-digest-mismatch-escalation-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

前端设计系统常见的失效面不是“没有测试”，而是**被测试的组件产物与最终交付产物不是同一个对象**：

- Storybook 测试通过的是一次构建快照；
- 合并前后又发生 token/组件再生成；
- 次日回看只看到“CI 绿了”，却无法证明“交付物就是被验收过的那份”。

这会把“可次日实战”的前端能力退化成“可演示、不可追责”。

## 核心解法

建立 **Storybook Acceptance Attestation Gate（SAAG）**，把“组件验收”与“产物验签”强绑定：

1. `token_snapshot`
   - 每次候选晋级先冻结 `token_digest` 与 `token_schema_version`。
2. `storybook_tri_check`
   - 强制执行 interaction + accessibility + visual 三测，并输出统一验收报告。
3. `acceptance_bundle`
   - 把 `token_digest + storybook_report_digest + component_bundle_digest` 打成验收包。
4. `attestation_sign_and_verify`
   - 对验收包做 provenance attestation 并立即验证，失败即隔离。
5. `required_check_lock`
   - 将 `storybook_acceptance_attestation_pass` 设为 required status check，未通过不得晋级。

## 最小执行协议

| Artifact | 必填字段 | 阻断条件 |
|---|---|---|
| `token_snapshot.json` | `token_digest`, `token_schema_version`, `generated_at_utc` | token 未冻结就执行验收 |
| `storybook_tri_report.json` | `interaction_pass`, `a11y_pass`, `visual_pass`, `storybook_build_digest` | 任一测试未通过 |
| `acceptance_bundle.json` | `component_bundle_digest`, `storybook_report_digest`, `token_digest`, `lineage_id` | digest 链不完整 |
| `acceptance_attestation.json` | `subject_digest`, `attestation_ref`, `verified`, `verified_at_utc` | `verified=false` |
| `promotion_decision.json` | `storybook_acceptance_attestation_pass`, `required_checks`, `decision` | gate fail 仍晋级 |

建议 required checks：

- `storybook_tri_check_pass`
- `acceptance_bundle_integrity_pass`
- `storybook_acceptance_attestation_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 持续指向 HN Popular Blogs OPML，说明信号入口稳定但内容持续变化，要求交付链可重放、可归因。
2. HN 三车道同窗样本（`47197267 / 47180083 / 47201629`）显示“原型展示与新发布”节奏很快，前端产物在无人时窗内更易发生二次生成漂移。
3. Design Tokens 规范将设计决策结构化，提供 `token_digest` 的稳定锚点。
4. Storybook 明确 stories 可直接作为测试用例并在 CI 运行，提供组件验收执行面。
5. GitHub protected branches 的 required checks 提供“未通过不可合并”的官方阻断面。
6. GitHub artifact attestations 可建立并验证构建来源，适合作为“验收产物同一性”的签名层。

## 反模式

- 只保留 Storybook 截图，不保留 `storybook_build_digest`。
- 测试通过后重新生成组件包，却继续复用旧验收结论。
- 把 token 更新和组件发布拆成两条无关联流水线。
- required checks 只锁测试结果，不锁验收包验签结果。

