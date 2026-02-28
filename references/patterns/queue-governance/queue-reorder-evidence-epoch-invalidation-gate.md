---
name: queue-reorder-evidence-epoch-invalidation-gate
topic: queue-governance
confidence: 0.80
verified_count: 7
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> raw/426957f4.../hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:43:33Z)
  - OPML 2.0 Spec: `outline` requires `text`; RSS subscription outlines use `type=\"rss\"` + `xmlUrl` (https://2005.opml.org/spec2.html, checked 2026-02-28T22:48:40Z)
  - Hacker News API: `topstories/newstories/showstories` endpoints and item fields `deleted/dead` (https://github.com/HackerNews/API, checked 2026-02-28T22:50:20Z)
  - Hacker News news sample (2026-02-28): item 47205076 "Stop Burning your tokens. Do this instead."
  - Hacker News show sample (2026-02-28): item 47200167 "Show HN: A promptless way to create editable SVGs"
  - Hacker News newest sample (2026-02-28): "Wouldn't It Be Nice if Apps Could Tell Us How They Use Our Data?"
  - GitHub Docs: Managing a merge queue (`jump` to top triggers full rebuild) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue, checked 2026-02-28T22:49:32Z)
  - GitHub Docs: Events that trigger workflows (`merge_group` required for merge queue checks) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group, checked 2026-02-28T22:48:05Z)
merge_upgrade_of:
  - references/patterns/queue-governance/queue-reorder-rebuild-attestation-gate.md
  - references/patterns/evidence-governance/tombstone-replay-promotion-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

队列重排（例如 `jump` 到队首）会触发 merge queue 重建；重建后验证对象已经变化，但很多系统只重跑 CI，不重置外部证据纪元：

- 旧 `HN item` 在重排窗口内可能变成 `deleted/dead`；
- 旧 OPML outline 可能已修订，`xmlUrl/text` 契约变化；
- 旧晋级包仍绑定重排前证据，导致“代码是新判定面，证据却是旧快照”。

本质问题：**queue 重建只触发“代码重放”，未触发“证据纪元失效 + 重采样”，产生跨纪元错配晋级。**

## 核心解法

建立 **Queue Reorder Evidence-Epoch Invalidation Gate（QREEIG）**：

1. 双纪元绑定
   - `queue_epoch_id`：merge queue 重建纪元。
   - `evidence_epoch_id`：外部证据采样纪元。
   - `promotion_packet` 必须声明二者同窗绑定，禁止跨纪元复用。
2. 重排即证据失效
   - 一旦检测 `jump/rebuild_triggered=true`，标记 `previous_evidence_epoch_invalidated=true`。
   - 强制重采样 HN `top/show/new` 与 OPML outline 契约。
3. 证据重放硬门禁
   - `item_liveness_recheck_pass`：关键 item 需再次确认非 `deleted/dead`。
   - `opml_outline_contract_recheck_pass`：`text/type/xmlUrl` 合法且可检索。
   - `merge_group_rebuild_replay_pass`：重建后的 merge_group 检查通过。
4. required checks 一体化
   - `queue_rebuild_attested_pass`
   - `evidence_epoch_rebound_pass`
   - `item_liveness_recheck_pass`
   - `opml_outline_contract_recheck_pass`
   - 任一失败即 quarantine。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_reorder_event.json` | `queue_epoch_id`, `jump_requested`, `rebuild_triggered`, `triggered_at_utc` | 重排发生但无纪元记录 |
| `evidence_epoch_manifest.json` | `evidence_epoch_id`, `bound_queue_epoch_id`, `sample_window_utc`, `sources_digest` | `bound_queue_epoch_id` 不匹配 |
| `item_liveness_recheck.json` | `hn_item_id`, `deleted`, `dead`, `title_present`, `url_present`, `pass` | 任一 item `deleted/dead` 或字段缺失 |
| `opml_outline_contract_recheck.json` | `outline_text`, `outline_type`, `xml_url`, `contract_pass` | `text/xmlUrl` 不合法或不可检索 |
| `promotion_packet.json` | `queue_epoch_id`, `evidence_epoch_id`, `previous_evidence_epoch_invalidated`, `decision` | 跨纪元晋级或失效标记缺失 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前仍重定向到 OPML Gist，说明入口可持续修订，证据必须带纪元而非一次性快照。
2. OPML 2.0 规范要求 `outline.text`，并约定订阅体 `type=\"rss\"` 与 `xmlUrl`，可作为重采样契约校验基线。
3. HN API 官方文档给出 `topstories/newstories/showstories` 端点，且 item 含 `deleted/dead` 字段，证明“采样时有效”不等于“晋级时仍有效”。
4. 本轮三车道样本显示信号时变：news（item `47205076`）、show（item `47200167`）、newest（隐私透明主题），重排窗口内需二次确认。
5. GitHub merge queue 文档明确 `jump` 会触发 in-progress pull request 全量重建；GitHub Actions 文档要求 merge queue 检查监听 `merge_group`，支持把“重建后重采样”升级为 required checks。

## 反模式

- 重排后只重跑 CI，不重置证据纪元。
- 复用重排前 `promotion_packet`，仅替换 head SHA。
- 只看 HN 热度，不校验 `deleted/dead`。
- 把 OPML 当静态清单，不做 `text/xmlUrl` 契约重检。
- merge queue 开启后仍只监听 `pull_request`，忽略 `merge_group`。
