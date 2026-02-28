---
name: opml-outline-tri-key-drift-gate
topic: source-governance
confidence: 0.78
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:16:32Z)
  - OPML 2.0 Specification (https://2005.opml.org/spec2.html)
  - Hacker News news snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Building software products in the age of AI [video]")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Better Auth - Authentication and authorization framework for TypeScript")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Build your own SQLite, Part 1: Listing tables")
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub REST API docs: Gists (https://docs.github.com/en/rest/gists/gists)
  - GitHub Docs: Verify attestations offline (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline)
merge_upgrade_of:
  - references/patterns/source-governance/triangulated-evidence-ratification-gate.md
  - references/patterns/feed-governance/canonical-feed-drift-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间发现流里，OPML 订阅源最常见的隐性失真是把 `outline.text` 当成唯一身份。
但 `text` 是可编辑显示名，不是稳定主键；一旦改名，就会把同一订阅误判成“新信源”，进而污染 HN 车道去重、证据链回放和晋级审计。

核心矛盾是：
**订阅入口可变（text）与执行证据需稳定可追溯之间缺少身份合同。**

## 核心解法

建立 **OPML Outline Tri-Key Drift Gate（OOTD-G）**，把订阅身份从“单字段猜测”升级为“可审计三元主键 + 漂移分级”：

1. **三元主键落盘**
   - `outline_key = normalize(xmlUrl) + normalize(htmlUrl) + normalize(text)`
   - 同时记录 `identity_tier`：`strict(xmlUrl+htmlUrl)`、`fallback(xmlUrl)`。
2. **可编辑字段隔离**
   - `text` 变化默认不创建新订阅，只记为 `display_drift`。
   - 仅当 `xmlUrl` 变化时认定为 `source_break`，触发重验签与降级。
3. **跨车道引用约束**
   - 所有 HN claim 必须携带 `outline_key` 与 `hn_item_id`。
   - 未绑定 key 的 claim 不能晋级 Issue/PR。
4. **晋级并联闸门**
   - `identity_parity_pass && freshness_pass && provenance_pass` 才允许 promotion。
   - 任何 `source_break` 直接进入 quarantine。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `outline_identity_manifest.json` | `outline_key`, `xmlUrl`, `htmlUrl`, `text`, `identity_tier` | 缺字段即失败 |
| `outline_drift_report.json` | `outline_key`, `drift_type`, `changed_fields`, `decision` | `source_break` 必须 quarantine |
| `claim_source_index.json` | `claim_id`, `hn_item_id`, `outline_key`, `sampled_at_utc` | 缺 `outline_key` 不可晋级 |
| `promotion_decision.json` | `identity_parity_pass`, `freshness_pass`, `provenance_pass`, `decision` | 非全绿不得晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 持续跳转到 OPML Gist，且页面含 revision 记录；说明入口稳定但订阅体会演化，需要身份合同。
- OPML 2.0 把 `text/xmlUrl/htmlUrl` 定义为不同语义字段，并说明 `type="rss"` 时 `xmlUrl`/`text` 有约束，支持三元建模而非单字段。
- HN `news/show/newest` 同时段头条不同，证明同一 cycle 内信号高波动，若订阅身份不稳，去重与回放会失真。
- HN API 提供 `topstories/showstories/newstories` 三个稳定端点，可把 `hn_item_id` 绑定到订阅主键做可回放证据索引。
- GitHub Gists API 可提供订阅入口 revision 轨迹，支持 drift 证据留痕。
- GitHub 离线验签文档要求管理 `trusted_root.jsonl` 时效，说明“可追溯身份 + 可复验来源”应并联治理。

## 反模式

- 仅用 `outline.text` 去重，改名即当新来源。
- 只做链接收集，不给 claim 绑定 `outline_key`。
- `xmlUrl` 变化只报警不隔离，继续晋级。
- 发现层与晋级层使用不同主键，导致次日无法回放同一证据对象。
