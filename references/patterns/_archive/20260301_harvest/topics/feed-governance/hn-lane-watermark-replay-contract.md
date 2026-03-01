---
name: hn-lane-watermark-replay-contract
topic: feed-governance
confidence: 0.78
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T19:42:28Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, item 47197677)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, item 47197466)
  - Hacker News new snapshot (https://news.ycombinator.com/latest, sampled 2026-02-28, item 47141119)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - OPML 2.0 spec (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/feed-governance/canonical-feed-drift-gate.md
  - references/patterns/evidence-governance/temporal-evidence-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

同一轮夜间探索同时读取 `top/show/new` 三条车道时，最常见的错误不是“没有信号”，而是“错把时间差当增量”：

- `top` 代表共识沉淀，更新慢；
- `show` 代表原型发布，更新中速；
- `new` 代表早信号，更新快。

如果三条车道不在同一采样窗口对齐，系统会把跨窗口差异误判为“新发现”，重复产出同构 pattern。

## 核心解法

建立 **HN Lane Watermark Replay Contract（HLWRC）**，把“跨车道可比性”升级为晋级前硬门禁：

1. **同窗采样（Window-Aligned Sampling）**
   - 每轮生成唯一 `window_id`，`top/show/new` 必须共享该窗口。
   - 任何跨窗口拼接结果直接标记 `invalid_comparison`。
2. **车道水位线（Lane Watermark）**
   - 为每条车道记录 `head_item_id`、`head_age_min`、`sampled_at_utc`。
   - 仅在 `window_id` 一致时允许做跨车道排序和去重。
3. **跨车道去重键（Cross-Lane Dedupe Key）**
   - 使用 `item_id + source_revision + window_id` 作为唯一主键。
   - 避免同一条内容在不同车道被重复记为多个发现。
4. **回放仲裁（Replay Arbitration Gate）**
   - promotion 前必须提交 `lane_diff_report` 与 `replay_manifest`。
   - required checks 校验 `window_aligned=true && dedupe_applied=true`，否则禁止晋级。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `lane_sampling_window.json` | `window_id`, `started_at_utc`, `ended_at_utc`, `sources` | 缺任一车道 => `hold` |
| `lane_watermarks.json` | `top_head_id`, `show_head_id`, `new_head_id`, `sampled_at_utc` | 不同窗比较 => `invalid` |
| `lane_diff_report.json` | `window_id`, `new_vs_top_delta`, `show_vs_top_delta`, `dedupe_count` | `window_id` 不一致 => `fail` |
| `replay_manifest.json` | `window_id`, `artifact_ref`, `digest`, `source_revision` | 无回放锚点 => `fail` |
| `promotion_packet.json` | `decision`, `required_checks`, `blocked_reason` | checks 不全不得晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 在本轮仍重定向到 OPML Gist，说明入口可复用但仍需窗口与修订锁。
- HN `news` 与 `show` 页面在同日采样中均出现新头部条目，证实三车道节奏差异显著，不能直接拼接比较。
- HN API 提供 `topstories/showstories/newstories` 规范化入口，可作为车道水位线主键来源。
- GitHub required status checks 可把“窗口对齐 + 去重已执行”变为不可绕过的合并闸门。
- GitHub workflow artifacts 可持久化 `lane_diff_report` 和 `replay_manifest`，保证次日审计可回放。
- OPML 2.0 是目录交换规范，不提供时序对齐语义，因此需要外加 `window_id` 合同层。

## 反模式

- 每条车道独立采样但没有共享 `window_id`。
- 把 `top/show/new` 的差异直接当成“新增洞察”而不做去重。
- 只留链接，不落盘 `lane_diff_report` 与 `replay_manifest`。
- 检查存在但未设为 required checks，夜间可被临时绕过。
