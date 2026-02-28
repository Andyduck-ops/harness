---
name: show-top-resonance-cooldown-gate
topic: discovery-governance
confidence: 0.79
verified_count: 8
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> HN Popular Blogs OPML raw (gist revision observed 2026-02-28)
  - HN news lane sample item 47195123 (Show HN: RubberUI...) from https://news.ycombinator.com/news (checked 2026-02-28T23:31Z)
  - HN show lane sample item 47180083 (Show HN: DeFAI...) from https://news.ycombinator.com/show (checked 2026-02-28T23:31Z)
  - HN newest lane sample item 47200719 (Show HN: Better Auth...) from https://news.ycombinator.com/newest (checked 2026-02-28T23:31Z)
  - HN API docs: topstories / showstories / newstories endpoints and item object fields (https://github.com/HackerNews/API, checked 2026-02-28T23:31Z)
  - HN Show guidelines entry (https://news.ycombinator.com/showhn.html, checked 2026-02-28T23:31Z)
  - GitHub Docs: managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: protected branches and required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
last_verified: 2026-02-28
rank: 3
---

## 元问题

当同一 Show 条目在短时间内同时命中 `news` 与 `show`，团队会把“传播热度”误判为“执行成熟度”，从而提前晋级 `candidate -> issue -> PR`。

这个失真来自一个结构性矛盾：

- HN 三车道（news/show/newest）衡量的是社区可见性；
- 工程执行链路（issue/PR/merge queue）需要的是可复现、可审计、可回放。

**如果缺少共振冷却（resonance cooldown），热度会抢跑证据。**

## 核心解法

建立 **Show-Top Resonance Cooldown Gate（STRCG）**，把“看见”与“执行”强制拆轨：

1. `resonance_capture`
   - 采样 `news/show/newest` 同窗命中，计算 `resonance_score`。
2. `cooldown_hold`
   - 达到共振阈值后，不立即晋级，进入最小冷却窗口（例如 6-24h）。
3. `evidence_refresh`
   - 冷却窗结束后重新抓取 lane 证据与可复现实验状态，生成新 digest。
4. `required_check_gate`
   - 只有 `resonance + cooldown + refresh` 三项都通过，才能进入 promotion。

## 最小执行协议

| Artifact | 必填字段 | Gate |
|---|---|---|
| `artifacts/show_resonance_window.json` | `item_id`, `window_id`, `seen_in_news`, `seen_in_show`, `seen_in_newest`, `resonance_score`, `captured_at` | 未形成同窗证据不得宣称“共振” |
| `artifacts/show_resonance_cooldown.json` | `item_id`, `cooldown_started_at`, `cooldown_minutes`, `cooldown_passed`, `reason` | 冷却未满直接阻断晋级 |
| `artifacts/show_resonance_reverify.json` | `item_id`, `recaptured_at`, `delta_from_first_capture`, `liveness_pass`, `repro_signal_pass`, `digest` | 无复采样证明不得 promotion |
| `artifacts/show_resonance_promotion.json` | `item_id`, `required_checks`, `decision`, `blocked_reason`, `evidence_refs` | required checks 不全不得进入 issue |

建议 required checks：

- `show_resonance_window_capture_pass`
- `show_resonance_cooldown_pass`
- `show_resonance_reverify_pass`
- `show_resonance_promotion_contract_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 仍是 OPML 聚合入口，它提供“发现面”而非“执行证据面”。
2. HN 页面采样显示 Show 类条目可在 `newest/show/news` 间快速迁移（示例 item：`47195123`, `47180083`, `47200719`），说明热度可在短窗形成共振。
3. HN API 把三车道分为不同 endpoint（`topstories/showstories/newstories`），也证明“车道命中”是分发信号而非执行验收信号。
4. GitHub merge queue + `merge_group` 说明晋级前检查需要队列场景一致性，不能靠一次性人工判断。
5. protected branches required checks 提供了把“冷却+复采样”落成硬门禁的执行面。

## 反模式

- `show` 上榜后立即建 Issue，不设冷却窗口。
- 只记录首次抓取，不做冷却后的二次复采样。
- 把“同窗共振”当作“可复现通过”。
- required checks 仅写文档、不接分支保护。
- 冷却失败仍以“紧急机会”为理由强行晋级。
