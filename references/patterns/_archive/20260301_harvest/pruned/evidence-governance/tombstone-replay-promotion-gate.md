---
name: tombstone-replay-promotion-gate
topic: evidence-governance
confidence: 0.79
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:28:31Z)
  - OPML 2.0 Specification (https://2005.opml.org/spec2.html)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Deep learning is akin to a nuclear first strike")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: The Mad 2025 Chart of Fortune 500 Revenue, Earnings and Stock")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Show HN: Build and host react apps, no config")
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules#troubleshooting-required-status-checks)
merge_upgrade_of:
  - references/patterns/evidence-governance/claim-anchor-retrievability-gate.md
  - references/patterns/evidence-governance/temporal-evidence-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间发现到白天晋级之间存在一个高频断层：
**证据在采集时可回放，但在晋级前变成 HN `deleted/dead`（墓碑）后仍被当作有效证据继续流转。**

这会导致一种“幽灵晋级”：
- required checks 仍然是绿的（因为只校验了旧快照）；
- 但当前证据对象已经失效，无法再证明同一个 claim。

## 核心解法

建立 **Tombstone Replay Promotion Gate（TRPG）**，把“采集成功”与“晋级可用”拆成两个独立闸门并强制串联：

1. 双时点回放
   - `capture_replay_pass`：采集当下可检索。
   - `promotion_replay_pass`：晋级前窗口内再次回放。
2. 墓碑状态机
   - `active -> soft_invalid -> hard_invalid(tombstone)`。
   - 一旦 `deleted/dead=true`，直接写入 `tombstone_reason`，禁止晋级。
3. 晋级冻结门禁
   - 分支保护必须包含 `promotion_replay_pass` 为 required status check。
   - 超过 7 天未更新状态检查视为失败，强制重放后再晋级。
4. 来源入口联动
   - OPML revision 变化触发受影响 claim 批量预晋级重放。
   - 避免“入口已漂移但旧证据仍被放行”。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `claim_replay_report.json` | `claim_id`, `hn_item_id`, `captured_at_utc`, `promotion_checked_at_utc`, `promotion_replay_pass` | 缺晋级前重放字段 |
| `tombstone_quarantine.json` | `claim_id`, `hn_item_id`, `deleted`, `dead`, `tombstone_reason`, `quarantined_at_utc` | tombstone 后未隔离 |
| `promotion_decision.json` | `capture_replay_pass`, `promotion_replay_pass`, `freshness_pass`, `decision` | 任一 gate fail 仍晋级 |
| `source_revision_lock.json` | `source_url`, `revision`, `checked_at_utc`, `replay_triggered` | 入口修订后未触发重放 |

## 证据链

- `https://t.co/dwAiIjlXet` 指向 OPML Gist 且可修订，说明来源入口会变化，晋级前必须重放而不是只依赖历史快照。
- OPML 2.0 定义 `text/xmlUrl/htmlUrl` 为不同语义字段，支持把“来源身份”与“显示文本”分离，避免入口漂移误判。
- HN `news/show/newest` 同时段头条不同，证明外部信号高波动；若没有晋级前复核，旧结论会快速过期。
- HN API `item` 支持 `deleted/dead` 字段，这是墓碑判定的官方语义依据。
- GitHub 分支保护要求 required status checks 成功，且状态检查超过 7 天需重新通过，适合作为晋级前重放门禁。

## 反模式

- 只在采集时回放一次，晋级前不复核。
- 把 `deleted/dead` 当作普通告警而非硬阻断。
- required checks 只校验 lint/test，不校验证据可回放。
- OPML revision 变化后继续使用旧 claim 直接晋级。
