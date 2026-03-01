---
name: temporal-evidence-freshness-gate
topic: evidence-governance
confidence: 0.75
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (active 2026-02-28)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28)
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28)
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28)
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/signal-governance/exploit-explore-evidence-router.md
  - references/patterns/recovery-governance/workspace-recovery-envelope.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

24h 无人推进里，外部证据（HN top/show/new、OPML、官方文档）会在几个小时内变化。
如果只保存链接，不保存“当时看到的快照”，次日无法回答两个关键问题：
- 这条结论在当时是否成立？
- 现在复盘时为什么和昨晚看到的不一样？

本质问题是：**发现链路缺少“时序锁 + 回放锚点”，证据会随时间漂移**。

## 核心解法

建立 **Temporal Evidence Freshness Gate（TEFG）**，把“证据是否新鲜、是否可回放”变成可机审闸门：

1. **采样锁定（Snapshot Pinning）**
   - 每轮固定采样 `OPML + HN news/show/newest`。
   - 为每条候选记录 `sampled_at_utc + source_url + content_digest`。
2. **时效闸门（Freshness SLA）**
   - 候选晋级 Issue 前必须满足时效阈值（例如 `<= 24h`）。
   - 超时自动打回 `stale`，要求重采样。
3. **回放信封（Replay Envelope）**
   - Actions artifact 必须保存 `raw_snapshot + normalized_summary + digest_manifest`。
   - PR required checks 校验 artifact 是否存在且字段完整。
4. **冲突再验证（Drift Re-verify）**
   - 若当前页面与快照摘要冲突，保留原快照结论并追加 `drift_note`。
   - 不允许“静默覆盖”旧证据。

## 最小执行协议

| 组件 | 必填字段 | 通过条件 |
|------|----------|----------|
| `evidence_snapshot.json` | `cycle`, `sampled_at_utc`, `source_url`, `digest` | 每条证据都有时间戳和摘要哈希 |
| `freshness_gate.json` | `candidate_id`, `max_age_hours`, `age_hours`, `result` | `age_hours <= max_age_hours` |
| `replay_manifest.json` | `artifact_ref`, `snapshot_refs`, `drift_notes` | 可定位并重放本轮证据 |
| `promotion_report.json` | `freshness_passed`, `replay_passed`, `required_checks` | 两闸门全绿才允许晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 持续重定向到 HN Popular Blogs OPML，适合作为稳定信号基座，但仍需要采样时刻锁定。
- HN `news/show/newest` 每次采样内容明显不同，说明外部证据天然时变，不能只存 URL。
- Hacker News 官方 API 提供 `topstories/newstories/showstories` 及 item 时间字段，可作为快照与漂移比对的主键来源。
- GitHub Actions artifact 机制可持久化快照与摘要清单，支撑次日回放与审计。
- GitHub required checks 可把 freshness/replay 变成不可绕过的合并门禁。

## 反模式

- 只在 pattern 里贴 URL，不记录采样时间与摘要哈希。
- 发现后隔天直接晋级 Issue，不做时效复检。
- 页面漂移后直接改写结论，不保留 drift_note。
- 有 artifact 但不纳入 required checks，导致门禁失效。
