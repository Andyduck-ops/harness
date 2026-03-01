---
name: token-spec-pinning-attestation-gate
topic: token-governance
confidence: 0.78
verified_count: 6
sources:
  - https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect + OPML anchor, verified 2026-03-01)
  - HN top lane sample: https://news.ycombinator.com/item?id=47197267 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47180083 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201858 (sampled 2026-03-01)
  - Design Tokens draft: https://www.designtokens.org/tr/drafts/format/
  - Storybook tests: https://storybook.js.org/docs/writing-tests
  - GitHub required checks: https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches
  - GitHub artifact attestations (--provenance): https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/using-artifact-attestations-to-establish-provenance-for-builds
merge_upgrade_of:
  - references/patterns/fullstack-engineering/token-storybook-readiness.md
  - references/patterns/ui-governance/storybook-acceptance-attestation-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

前端设计系统在“次日可实战”阶段最常见的失真是：
**Storybook 三测通过了，但合并与发布的产物并非同一套 token 语义版本**。

根因不是“有没有测”，而是没有把 `token 规范版本钉住`、`测试执行`、`产物验签` 绑定为同一条晋级合同。

## 核心解法

建立 **Token Spec Pinning + Acceptance Attestation Gate（TSPA）**：

1. **Token 规范版本钉住门禁**
   - 在仓库显式记录 `token_spec_version`（禁止隐式跟随草案预览内容）。
   - 每次 token schema 变更都要生成 `token_schema_diff.json`。
2. **组件三测并联门禁**
   - Storybook 交互、a11y、视觉回归并联执行。
   - 输出统一 `storybook_tri_check_report.json`，不允许只看单测绿灯。
3. **交付产物同源验签门禁**
   - 构建 `acceptance_bundle.json`，绑定 `token_digest`、`storybook_report_digest`、`build_sha`。
   - 通过 artifact attestations 做 provenance 校验，保证“被测即被交付”。
4. **合并围栏门禁**
   - `token_schema_pin_pass`、`storybook_tri_check_pass`、`acceptance_attestation_pass` 设为 required checks。
   - 任一失败，禁止晋级主干/队列。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `token_schema_manifest.json` | `token_spec_version`, `schema_digest`, `generated_at_utc` | 未声明或版本漂移 |
| `token_schema_diff.json` | `base_sha`, `head_sha`, `breaking_paths`, `compat_decision` | 破坏变更未声明 |
| `storybook_tri_check_report.json` | `interaction_pass`, `a11y_pass`, `visual_pass`, `suite_sha` | 任一测试失败 |
| `acceptance_bundle.json` | `build_sha`, `token_digest`, `storybook_report_digest`, `artifact_uri` | 摘要不一致 |
| `provenance_verify_report.json` | `attestation_pass`, `signer`, `subject_digest` | `attestation_pass=false` |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前重定向至 OPML Gist，且页面有持续修订记录，说明入口稳定不代表内容静态，版本钉住是必需条件。
2. Design Tokens 草案页面明确提示“编辑中预览，不建议实现”，并给出已发布版本入口，证明必须显式区分“草案预览”与“可执行规范版本”。
3. Storybook 官方文档给出 `npm run test-storybook`，说明三测可以成为 CI 执行产物，而非仅用于本地展示。
4. GitHub 受保护分支可配置 required status checks，可把三测与验签变成不可绕过的合并闸门。
5. GitHub artifact attestations 文档提供 `--provenance` 产物签名路径，支持把“构建来源同一性”纳入可审计证据。
6. HN top/show/newest 同窗高频样本（`47197267 / 47180083 / 47201858`）显示探索与实现并行高速流动；没有统一门禁时，最容易出现“今天测过、明天不可复现”。

## 反模式

- 直接跟随 Design Tokens 草案预览内容，不记录 `token_spec_version`。
- Storybook 只做展示，不生成机器可判定报告。
- 测试报告和发布产物分离，未做摘要绑定与 provenance 校验。
- required checks 只挂单测，不挂 token 版本和验签门禁。
