---
name: show-new-evidence-maturity-arbitration-gate
topic: discovery-governance
confidence: 0.80
verified_count: 11
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/16d6ff3826b2511df97f3dbdcc8dff44f06f5e03/hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:42:52Z)
  - OPML 2.0 Spec: outline required attributes and rss subscription conventions (https://2005.opml.org/spec2.html, checked 2026-02-28T22:42:25Z)
  - Hacker News API docs: top/new/show endpoints and item fields (deleted/dead) (https://github.com/HackerNews/API, checked 2026-02-28T22:41:40Z)
  - Hacker News news lane sample (2026-02-28): "MinIO Is Dead, Long Live MinIO"
  - Hacker News show lane sample (2026-02-28): item 47195123 "Show HN: Now I Get It – Translate scientific papers into interactive webpages"
  - Hacker News newest lane sample (2026-02-28): "How do HTTP servers figure out Content-Length?"
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows / merge_group (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
last_verified: 2026-02-28
rank: 3
---

## 元问题

`show` 与 `newest` 都是高价值早信号，但它们代表的是不同成熟度，而且都存在“采样后很快失效”的风险：

- `show` 更偏“可演示原型”，常包含可交互产物；
- `newest` 更偏“即时尝试与复盘”，常处于快速变化阶段；
- HN API 的 item 语义包含 `deleted/dead` 字段，说明条目可能在后续窗口变成不可执行对象；
- 若把两车道不加区分地直接晋级到同一候选池，会放大“早热度误判 + 失效条目污染”，导致白天执行队列反复返工。

本质问题：**缺少“车道意图识别 + 条目存活预检 + 成熟度冷却 + 可审计晋级”的仲裁合同。**

## 核心解法

建立 **Show-New Evidence Maturity Arbitration Gate（SNEMAG）**，将“发现”与“可执行晋级”分层：

1. **车道意图标签（lane intent tagging）**
   - `show` 默认标签：`prototype_executable`。
   - `newest` 默认标签：`fresh_signal`。
   - `news(top)` 作为共识锚点标签：`consensus_anchor`。
2. **条目存活预检（item liveness preflight）**
   - 对每个候选调用 `/v0/item/<id>.json`。
   - 若 `deleted=true` 或 `dead=true` 或缺失关键字段（`title/url`），直接 quarantine，不进入晋级包。
3. **双路径准入（dual-path admission）**
   - `prototype_executable` 可直接进入候选，但必须附最小可运行证据。
   - `fresh_signal` 先进入观察池，满足冷却窗口与复采样后才可晋级候选。
4. **成熟度冷却预算（maturity cooldown budget）**
   - 对 `fresh_signal` 强制 `cooldown_hours >= threshold` 且需二次采样仍成立。
   - 未通过冷却预算仅可沉淀，不可进入 merge queue 前置候选。
5. **required checks 硬门禁**
   - `lane_intent_classified_pass`
   - `item_liveness_preflight_pass`
   - `fresh_signal_cooldown_pass`
   - `prototype_evidence_minimum_pass`
   - `opml_outline_contract_pass`
   - `replay_artifact_complete_pass`

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `artifacts/lane_intent_manifest.json` | `window_id`, `item_id`, `lane`, `intent_label`, `classified_at` | 任何未分类条目不得晋级 |
| `artifacts/item_liveness_report.json` | `item_id`, `deleted`, `dead`, `title_present`, `url_present`, `pass` | `deleted/dead` 或关键字段缺失即 fail |
| `artifacts/fresh_signal_cooldown_report.json` | `item_id`, `first_seen_at`, `resampled_at`, `cooldown_hours`, `stable` | `stable=false` 或冷却不足即 fail |
| `artifacts/prototype_evidence_minimum.json` | `item_id`, `demo_ref`, `repro_steps`, `evidence_digest`, `pass` | 缺少可运行证据即 fail |
| `artifacts/opml_outline_contract_report.json` | `outline_text`, `outline_type`, `xml_url`, `html_url`, `pass` | `text/xmlUrl` 缺失或订阅体不合法即 fail |
| `artifacts/discovery_promotion_packet.json` | `required_checks`, `decision`, `blocked_reason`, `artifact_ref` | checks 不全不得晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前解析到 HN Popular Blogs OPML 原始订阅体；OPML 2.0 规范要求 `outline.text`，并约定 rss 订阅使用 `type="rss"` 与 `xmlUrl`，可作为入口结构契约。
2. HN API 文档定义 `topstories/newstories/showstories` 车道与 item 的 `deleted/dead` 字段，证明候选必须先做“存活预检”再晋级。
3. HN `news/show/newest` 同窗采样显示三车道内容成熟度不同：
   - `news`: `MinIO Is Dead, Long Live MinIO`（共识锚点）；
   - `show`: item `47195123`（可运行原型）；
   - `newest`: `How do HTTP servers figure out Content-Length?`（即时信号）。
4. GitHub Merge Queue 与 `merge_group` 事件提供“晋级前统一检查”的承载面，适合把 `item_liveness_preflight_pass` 等检查变成 required checks。
5. GitHub Protected Branches + workflow artifacts 让仲裁结果不可绕过且可回放，解决“夜间判定、次日无法复核”的断层。

## 反模式

- 把 `show` 与 `newest` 全部按同一优先级直接晋级。
- 只看车道热度，不检查 item `deleted/dead`。
- 只依赖 OPML 展示字段，不验证 `xmlUrl` 是否可用。
- 未经过冷却复采样就把 `fresh_signal` 升级为执行任务。
- 只有链接没有最小可运行证据，导致白天无法复现。
- checks 写在文档里但不设为 required status checks。
