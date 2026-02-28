---
name: hn-lane-identity-parity-gate
topic: feed-governance
confidence: 0.80
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T19:56:00Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, item 47196582)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, item 47195123)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, item 47199259)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - OPML 2.0 spec (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/feed-governance/hn-window-skew-budget-gate.md
  - references/patterns/feed-governance/hn-lane-watermark-replay-contract.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

即使有 `window_id`、`sampling_skew_ms` 和 `lane quorum`，仍会出现一种高频误判：
**页面车道身份与 API 车道身份混用**。

- 页面入口是 `news/show/newest`；
- API 入口是 `topstories/showstories/newstories`；
- 若采样脚本在某一层把 `newest` 写成 `latest`、或把页面头部与 API 头部跨窗拼接，系统会“看起来三车道齐全”，但实际上比的是不同集合。

结果是：预算门禁通过，结论仍然漂移，次日无法解释“为什么晋级”。

## 核心解法

建立 **HN Lane Identity Parity Gate（HLIPG）**，将“车道存在性”升级为“车道同一性”：

1. **车道身份清单（lane identity manifest）**
   - 固定映射：`news->topstories`、`show->showstories`、`newest->newstories`。
   - 任意别名（如 `latest`）进入 `alias_warning`，不得直接用于晋级计算。
2. **页面/API 同窗同头校验（head parity）**
   - 同一 `window_id` 下，页面首条 `item_id` 必须出现在对应 API 列表前 `N`（建议 `N=30`）内。
   - 若 `head_not_in_api_top_n=true`，标记 `identity_parity_fail`。
3. **跨层一致性预算（parity budget）**
   - 定义 `lane_parity_mismatch_ratio = mismatch_lanes / 3`。
   - 预算越界（如 >0）则 `hold`，只允许沉淀候选，不允许 promotion。
4. **晋级硬门禁（required checks）**
   - 仅当 `quorum=true && skew_budget_pass && identity_parity_pass` 才能晋级。
   - 将 `lane_identity_manifest`、`lane_parity_report` 落盘并上传 artifact，用于次日回放。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `lane_identity_manifest.json` | `window_id`, `page_lane`, `api_lane`, `mapping_version` | 映射缺失即 `fail` |
| `lane_parity_report.json` | `top_head_id`, `show_head_id`, `new_head_id`, `head_in_api_top_n` | 任一 false 即 `identity_parity_fail` |
| `lane_budget_report.json` | `sampling_skew_ms`, `duplicate_ratio`, `lane_parity_mismatch_ratio` | 任一预算越界即 `hold` |
| `promotion_packet.json` | `decision`, `blocked_reason`, `required_checks`, `artifact_ref` | checks 不全即 `fail` |

## 证据链

- `https://t.co/dwAiIjlXet` 在本轮仍重定向到 OPML Gist，入口稳定但不提供车道身份语义。
- HN 页面三车道采样均可得：`news=47196582`、`show=47195123`、`newest=47199259`，说明车道确实并行存在。
- HN API 明确提供 `topstories/showstories/newstories` 三个列表端点；页面车道与 API 车道并非同名，必须显式映射。
- GitHub required status checks 可以把 `identity_parity_pass` 变成不可绕过门禁。
- GitHub workflow artifacts 支持保留 `lane_parity_report` 供次日审计回放。
- OPML 2.0 只规定订阅目录交换，不覆盖车道身份一致性，因此该能力必须在执行层补齐。

## 反模式

- 只校验 `quorum`，不校验“页面车道是否与 API 车道同一”。
- 使用 `new/latest/newest` 混合别名且不写 `mapping_version`。
- 有预算门禁但不落盘 `lane_identity_manifest` 与 `lane_parity_report`。
- checks 存在但非 required，导致夜间绕过晋级。
