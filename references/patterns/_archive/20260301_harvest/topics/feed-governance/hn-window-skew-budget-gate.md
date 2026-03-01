---
name: hn-window-skew-budget-gate
topic: feed-governance
confidence: 0.79
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T19:50:04Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, item 47196582)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, item 47195123)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, item 47199282)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: required status checks (https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks)
  - GitHub Docs: storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - OPML 2.0 spec (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/feed-governance/hn-lane-watermark-replay-contract.md
  - references/patterns/signal-governance/lane-debt-ratchet-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

`top/show/new` 三车道的价值不同，但刷新速度也不同。  
如果系统只要求“同窗采样”而不限制“采样偏斜”，会出现稳定失真：

- 采样时间差过大时，`new` 会被误判成“高增量方向”；
- 跨车道重复条目会被重复计数，放大伪新颖；
- 次日复盘能看到结果，但看不出为什么会偏。

本质上，缺的是“时间偏斜预算 + 重复率预算”的双预算合同。

## 核心解法

建立 **HN Window Skew Budget Gate（HWSBG）**，把三车道比较从“可比”升级成“可审计可解释”：

1. **偏斜预算（sampling skew budget）**
   - 为每个 `window_id` 记录 `sampling_skew_ms = max(sample_ts) - min(sample_ts)`。
   - 超过阈值（如 120000ms）直接 `hold`，不得进入 promotion。
2. **重复率预算（duplicate ratio budget）**
   - 统计 `cross_lane_duplicate_ratio = deduped_items / raw_items`。
   - 比率异常（过高或过低）触发 `needs_replay`，防止伪增量或清洗过度。
3. **车道配额（lane quorum）**
   - `top/show/new` 必须三车道齐全，缺一车道则 `quorum=false`。
   - `quorum=false` 时允许沉淀候选，但禁止晋级 issue/PR。
4. **闸门化执行**
   - 将 `skew_budget_pass && duplicate_ratio_pass && quorum=true` 写入 required checks。
   - 把 `lane_diff_report`、`sampling_window`、`promotion_packet` 上传为 artifact，确保次日回放。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `lane_sampling_window.json` | `window_id`, `top_ts`, `show_ts`, `new_ts`, `sampling_skew_ms` | `sampling_skew_ms <= budget_ms` |
| `lane_diff_report.json` | `raw_items`, `deduped_items`, `cross_lane_duplicate_ratio`, `replay_needed` | 比率越界则 `replay_needed=true` |
| `lane_quorum.json` | `top_ok`, `show_ok`, `new_ok`, `quorum` | `quorum=false` 则禁止 promotion |
| `promotion_packet.json` | `decision`, `blocked_reason`, `required_checks`, `artifact_ref` | 缺任一 check 则 `fail` |

## 证据链

- `https://t.co/dwAiIjlXet` 当前仍重定向到 OPML Gist，说明入口稳定但不提供时间对齐语义。
- HN `news` 采样显示头部样本可用（如 `item=47196582`），`show` 采样同样可用（`item=47195123`），`newest` 也持续滚动（`item=47199282`），三车道具备差速刷新特征。
- HN API 明确定义 `topstories`、`showstories`、`newstories` 三个独立列表，支持车道化采样与回放主键。
- GitHub required status checks 可将预算判定变为不可绕过的合并门。
- GitHub workflow artifacts 允许保存本轮窗口与差异报告，支持次日审计。
- OPML 2.0 只提供订阅目录格式，不提供车道时序预算，需要在流程层补合同。

## 反模式

- 只对齐 `window_id`，不记录 `sampling_skew_ms`。
- 只做去重，不监控 `cross_lane_duplicate_ratio` 是否异常。
- 缺某车道仍照常 promotion。
- checks 存在但不是 required，夜间可绕过。
