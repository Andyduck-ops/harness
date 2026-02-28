---
name: claim-anchor-retrievability-gate
topic: evidence-governance
confidence: 0.77
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:22:12Z)
  - OPML 2.0 Specification (https://2005.opml.org/spec2.html)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top item id: 45871445, title: "ChatGPT’s confidence can mislead users, study finds")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top item id: 45871193, title: "Show HN: Open-Source Cursor Alternative")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top item id: 45871883, title: "Version 4.2.0")
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub REST API docs: Gist revisions (https://docs.github.com/en/rest/gists/gists#get-a-gist-revision)
merge_upgrade_of:
  - references/patterns/evidence-governance/temporal-evidence-freshness-gate.md
  - references/patterns/source-governance/opml-outline-tri-key-drift-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间发现流程里，最常见的失效不是“没有证据”，而是**证据存在但第二天找不回同一对象**：

- claim 只记录标题或 URL，不绑定稳定 item id；
- OPML 入口发生重定向或改名后，旧 claim 无法回放；
- 结果是晋级记录可读但不可复验。

核心矛盾是：
**执行闭环要求可回放证据，而发现链路默认只保存“可读线索”。**

## 核心解法

建立 **Claim Anchor Retrievability Gate（CARG）**，把“可读线索”升级为“可回放锚点”：

1. claim 三元锚定
   - `claim_id` 必须绑定 `hn_item_id` + `outline_key`。
   - 任何缺失绑定的 claim 一律不得晋级。
2. 锚点存活预算
   - 为每条 claim 维护 `retrievability_sla_hours` 与 `last_replay_at_utc`。
   - 超预算未复验直接降级为 `stale_claim`。
3. 入口修订对账
   - OPML 来源记录 `gist_revision`。
   - 当 revision 变化时，批量触发 claim 重放，避免“入口漂移后静默失效”。
4. 墓碑状态处置
   - 回放时检测 HN item 的 `deleted/dead` 状态。
   - 进入 `tombstone` 队列，禁止继续作为晋级证据。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `claim_anchor_index.json` | `claim_id`, `hn_item_id`, `outline_key`, `captured_at_utc` | 缺任一锚点字段 |
| `claim_replay_report.json` | `claim_id`, `replay_status`, `last_replay_at_utc`, `stale_hours` | `replay_status != ok` 且未隔离 |
| `source_revision_lock.json` | `source_url`, `gist_revision`, `checked_at_utc` | revision 变更后未触发重放 |
| `promotion_decision.json` | `retrievable_pass`, `freshness_pass`, `provenance_pass`, `decision` | 任一 gate 非 pass 仍晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 仍指向 OPML Gist，且 Gist 页面存在 revision 历史，说明“入口可演化”是常态，不是异常。
- OPML 2.0 明确 `text` 可作为显示文本而 `xmlUrl/htmlUrl`承载结构语义，支持 claim 绑定 `outline_key` 而非仅绑定标题。
- HN 页面在同一时段 `top/show/newest` 的首条 item 各不相同，说明夜间采样如果不记录稳定 id，会在次日失去定位一致性。
- HN API 给出 `topstories/showstories/newstories` 列表和 `item` 结构，可提供稳定 `hn_item_id`，并支持 `deleted/dead` 失效判定。
- GitHub Gists API 支持按 revision 获取内容，可把“入口版本”纳入回放对账条件。

## 反模式

- claim 只存标题或摘要，不存 `hn_item_id`。
- 回放失败只记录日志，不把 claim 降级或隔离。
- OPML revision 变化后不触发重放，只继续累积新 claim。
- 证据链可读但不可检索，导致晋级审计无法复现同一对象。
