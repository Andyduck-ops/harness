---
name: canonical-feed-drift-gate
topic: feed-governance
confidence: 0.76
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub REST API: gists (https://docs.github.com/en/rest/gists/gists)
  - OPML 2.0 spec (https://2005.opml.org/spec2.html)
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间知识巡航把 `https://t.co/dwAiIjlXet` 当成“稳定作者池入口”时，常忽略一个关键事实：
**短链目标可变、Gist 内容可更新、HN 三榜实时波动**。

如果没有“入口锁定 + 修订锁定 + 榜单水位线锁定”，系统会把“源漂移”误判为“新增洞察”，造成重复 pattern 和错误晋级。

## 核心解法

建立 **Canonical Feed Drift Gate（CFDG）**，把“源是否稳定”作为晋级前硬门禁：

1. **短链锚定（Redirect Pin）**
   - 每个 cycle 记录 `short_url`, `resolved_url`, `redirect_chain`, `checked_at_utc`。
   - 若解析目标变化，直接进入 `drift_review`，不允许自动晋级。
2. **修订锚定（Revision Pin）**
   - 对 Gist 记录 `gist_id`, `latest_commit_sha`, `raw_digest`。
   - 任何 claim 必须绑定具体 `gist_revision`，禁止仅引用“当前页面”。
3. **三榜水位线（Lane Watermark）**
   - 分别记录 `top/show/newest` 的 `head_item_id` 与 `sampled_at_utc`。
   - 仅在同一 OPML revision + 同一采样窗口内做跨源比较。
4. **漂移决策（Drift Decision）**
   - 若 OPML 修订变更且榜单水位线同时跃迁，决策必须 `hold` 并触发重采样。
   - 只有 `redirect_stable && revision_stable && watermark_aligned` 才能晋级。

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `canonical_feed_pin.json` | `short_url`, `resolved_url`, `redirect_chain`, `checked_at_utc` | 目标变化 => `drift_review` |
| `opml_revision_lock.json` | `gist_id`, `latest_commit_sha`, `raw_digest`, `outline_count` | 无 revision 不可晋级 |
| `lane_watermark.json` | `top_head_id`, `show_head_id`, `new_head_id`, `sampled_at_utc` | 跨窗口比较判定无效 |
| `drift_gate_report.json` | `redirect_stable`, `revision_stable`, `watermark_aligned`, `decision` | 任一 false => `decision=hold` |

## 证据链

- `https://t.co/dwAiIjlXet` 当前确实重定向到 HN Popular Blogs OPML Gist，但短链只提供“入口”，不提供修订不可变性。
- HN `news/show/newest` 同时活跃且头部条目持续变化，说明采样窗口不对齐时，结论会被“时间差”污染。
- HN 官方 API 提供 `topstories/newstories/showstories` 列表，适合沉淀 lane watermark 主键。
- GitHub Gists REST API 提供 `List gist commits` 与 `Get a gist revision`，可将 claim 锁定到具体 revision。
- OPML 2.0 规范强调订阅列表交换语义，说明 OPML 更像“目录快照”，需要额外版本锁来保证回放一致性。

## 反模式

- 只记录 `t.co` 短链，不记录重定向链和最终目标。
- 只引用 Gist 页面 URL，不落盘 `commit_sha` 与 digest。
- 把 `top/show/newest` 不同时间采样结果直接拼接比较。
- OPML 变更后沿用旧结论直接晋级，未触发重采样。
