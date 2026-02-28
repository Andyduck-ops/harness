---
name: show-new-evidence-maturity-arbitration-gate
topic: discovery-governance
confidence: 0.77
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/ba6f71137be093a55057f19f34578f3f5f4f97e0/hn-popular-blogs-2025.opml (redirect checked 2026-02-28T22:28:30Z)
  - Hacker News news item 47203527 (sampled 2026-02-28, title: "drafts by murat")
  - Hacker News show item 47200167 (sampled 2026-02-28, title: "Show HN: A promptless way to create editable SVGs")
  - Hacker News newest item 47203487 (sampled 2026-02-28, title: "What happened when I built a daily coding challenge platform with AI")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows / merge_group (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
last_verified: 2026-02-28
rank: 3
---

## 元问题

`show` 与 `newest` 都是高价值早信号，但它们代表的是不同成熟度：

- `show` 更偏“可演示原型”，常包含可交互产物；
- `newest` 更偏“即时尝试与复盘”，常处于快速变化阶段；
- 若把两车道不加区分地直接晋级到同一候选池，会放大“早热度误判”，导致白天执行队列反复返工。

本质问题：**缺少“车道意图识别 + 成熟度冷却 + 可审计晋级”的仲裁合同。**

## 核心解法

建立 **Show-New Evidence Maturity Arbitration Gate（SNEMAG）**，将“发现”与“可执行晋级”分层：

1. **车道意图标签（lane intent tagging）**
   - `show` 默认标签：`prototype_executable`。
   - `newest` 默认标签：`fresh_signal`。
   - `news(top)` 作为共识锚点标签：`consensus_anchor`。
2. **双路径准入（dual-path admission）**
   - `prototype_executable` 可直接进入候选，但必须附最小可运行证据。
   - `fresh_signal` 先进入观察池，满足冷却窗口与复采样后才可晋级候选。
3. **成熟度冷却预算（maturity cooldown budget）**
   - 对 `fresh_signal` 强制 `cooldown_hours >= threshold` 且需二次采样仍成立。
   - 未通过冷却预算仅可沉淀，不可进入 merge queue 前置候选。
4. **required checks 硬门禁**
   - `lane_intent_classified_pass`
   - `fresh_signal_cooldown_pass`
   - `prototype_evidence_minimum_pass`
   - `replay_artifact_complete_pass`

## 最小执行协议

| 文件 | 必填字段 | 门禁规则 |
|------|----------|----------|
| `artifacts/lane_intent_manifest.json` | `window_id`, `item_id`, `lane`, `intent_label`, `classified_at` | 任何未分类条目不得晋级 |
| `artifacts/fresh_signal_cooldown_report.json` | `item_id`, `first_seen_at`, `resampled_at`, `cooldown_hours`, `stable` | `stable=false` 或冷却不足即 fail |
| `artifacts/prototype_evidence_minimum.json` | `item_id`, `demo_ref`, `repro_steps`, `evidence_digest`, `pass` | 缺少可运行证据即 fail |
| `artifacts/discovery_promotion_packet.json` | `required_checks`, `decision`, `blocked_reason`, `artifact_ref` | checks 不全不得晋级 |

## 证据链

1. `https://t.co/dwAiIjlXet` 当前解析到 HN Popular Blogs OPML 原始订阅体，保证探索入口稳定可复用。
2. HN `news/show/newest` 同窗采样显示三车道同时活跃且内容成熟度不同：
   - `news`: `47203527` (`drafts by murat`) 偏长期观点锚点；
   - `show`: `47200167` (`Show HN: A promptless way to create editable SVGs`) 偏可演示原型；
   - `newest`: `47203487` (`...daily coding challenge platform with AI`) 偏即时构建复盘。
3. GitHub Merge Queue 与 `merge_group` 事件提供“晋级前统一检查”的技术落点，适合承载仲裁后的 required checks。
4. GitHub Protected Branches 可把仲裁检查转成不可绕过门禁，避免夜间信号直接冲进白天主干。
5. GitHub workflow artifacts 支持固化 `cooldown_report` 与 `promotion_packet`，确保次日可回放审计。

## 反模式

- 把 `show` 与 `newest` 全部按同一优先级直接晋级。
- 未经过冷却复采样就把 `fresh_signal` 升级为执行任务。
- 只有链接没有最小可运行证据，导致白天无法复现。
- checks 写在文档里但不设为 required status checks。
