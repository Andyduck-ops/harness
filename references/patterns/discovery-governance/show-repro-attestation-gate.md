---
name: show-repro-attestation-gate
topic: discovery-governance
confidence: 0.80
verified_count: 8
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/16d6ff3826b2511df97f3dbdcc8dff44f06f5e03/hn-popular-blogs-2025.opml (checked 2026-02-28T23:31Z)
  - HN API docs: topstories/newstories/showstories endpoints and item fields (deleted/dead) (https://github.com/HackerNews/API, checked 2026-02-28T23:31Z)
  - HN top lane API sample item 47220686 (Show HN: BrowserOS...) (checked 2026-02-28T23:31Z)
  - HN show lane API sample item 47219451 (Show HN: Escape from Los Angeles 1996...) (checked 2026-02-28T23:31Z)
  - HN new lane API sample item 47220825 (Show HN: Text containers in tool docs...) (checked 2026-02-28T23:31Z)
  - HN Show FAQ: shownew 4-point/2-comment threshold and no-show mode (https://news.ycombinator.com/showhn.html, checked 2026-02-28T23:31Z)
  - GitHub Docs: About protected branches (required status checks must pass) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: About artifact attestations (cryptographic provenance) (https://docs.github.com/en/actions/security-for-github-actions/using-artifact-attestations/about-artifact-attestations)
last_verified: 2026-02-28
rank: 3
---

## 元问题

Show 车道能快速提供高价值样例，但“上榜”并不等于“可复现可交付”。

同一时间窗内，`Show HN: BrowserOS...`（item `47220686`）已在 `topstories` 与 `showstories` 同时出现；而 `newstories` 又持续出现新的 Show 条目（如 item `47220825`）。再叠加 Show 官方机制（先进入 shownew，满足阈值后才进入 show），我们会遇到一个系统性问题：

**发现速度高于复现证据生成速度，导致 candidate->issue 晋级被“热度”而非“证据”驱动。**

## 核心解法

建立 **Show Repro Attestation Gate（SRAG）**，把 Show 晋级分成“热度采样”和“复现验签”两条独立流水线，并强制在晋级前汇合：

1. `lane_capture`
   - 记录 `top/show/new` 三车道命中与时间窗，识别“热度共振”。
2. `repro_bundle_build`
   - 产出最小复现包（最短步骤、输入、期望结果、环境指纹）。
3. `attestation_sign`
   - 对复现包做 artifact attestation，保存 provenance。
4. `required_check_enforce`
   - 将复现验签结果绑定为 protected branch 的 required status checks；未通过直接阻断晋级。

## 最小执行协议

| Artifact | 必填字段 | Gate |
|---|---|---|
| `artifacts/show_lane_resonance.json` | `window_id`, `item_id`, `seen_in_top`, `seen_in_show`, `seen_in_new`, `captured_at` | 缺少三车道采样记录不得晋级 |
| `artifacts/show_repro_bundle.json` | `item_id`, `repo_or_demo_ref`, `repro_steps`, `expected_outcome`, `runtime_fingerprint`, `bundle_digest` | 缺少最小复现要素直接 fail |
| `artifacts/show_repro_attestation.json` | `bundle_digest`, `attestation_ref`, `signer`, `verified`, `verified_at` | `verified=false` 直接 quarantine |
| `artifacts/show_promotion_decision.json` | `item_id`, `required_checks`, `decision`, `blocked_reason`, `evidence_refs` | required checks 不全不得 candidate->issue |

建议 required checks：

- `show_lane_resonance_capture_pass`
- `show_repro_bundle_complete_pass`
- `show_repro_attestation_verified_pass`
- `show_promotion_decision_contract_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 仍指向 HN Popular Blogs OPML，说明入口是“发现订阅体”，不是复现证明本身。
2. HN API 明确区分 `topstories/newstories/showstories`，且 item 语义包含 `deleted/dead`；因此仅凭车道热度不能作为长期可执行证据。
3. HN Show 官方说明展示了 `shownew -> show` 的阈值晋级机制（4 points / 2 comments），这属于社区可见性规则，不是工程可复现规则。
4. GitHub protected branches 规定 required status checks 必须通过才能合并，提供了晋级硬门禁承载点。
5. GitHub artifact attestations 提供了可加密验证的 provenance，适合把“可复现”从口头声明变成可核验证据。

## 反模式

- 看到 Show 进入 top 就直接建 Issue，不附复现包。
- 把“shownew/show 阈值通过”误当成“工程可交付”证明。
- 只存链接与截图，不存可验证的 bundle digest/attestation。
- required checks 只写在文档，不接入分支保护。
- 证据无签名，次日无法判定复现包是否被替换。
