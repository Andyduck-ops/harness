---
name: show-lane-executability-gate
topic: discovery-governance
confidence: 0.79
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b/raw/16d6ff3826b2511df97f3dbdcc8dff44f06f5e03/hn-popular-blogs-2025.opml (checked 2026-02-28T23:26Z)
  - Hacker News top lane snapshot (https://news.ycombinator.com/news, checked 2026-02-28T23:26Z)
  - Hacker News show lane snapshot (https://news.ycombinator.com/show, checked 2026-02-28T23:26Z)
  - Hacker News newest lane snapshot (https://news.ycombinator.com/newest, checked 2026-02-28T23:26Z)
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows / merge_group (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (required status checks) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Storing and sharing data from a workflow (https://docs.github.com/en/actions/how-tos/writing-workflows/choosing-what-your-workflow-does/storing-and-sharing-data-from-a-workflow)
last_verified: 2026-02-28
rank: 3
---

## 元问题

`show` 车道的发现价值很高，但“可演示”不等于“可执行”。

同一时间窗内，HN 已出现以下迁移路径：

- `news` 车道出现 `Show HN: Mowgli - Figma for the agent era...`（item `47218423`）；
- `show` 车道也出现同一条目（item `47218423`）以及 `PydanticAI-Bandit`、`A2A Coder`；
- `newest` 车道继续涌入新 Show（如 `Solcoder`，item `47219335`）。

这意味着：**一个 Show 条目可能在很短窗口从“新鲜样例”升级为“团队想立刻执行的候选”**。如果没有“可执行预检”，白天会把大量“能看不能跑”的 demo 推进到 Issue/PR 队列，制造执行债务与返工。

## 核心解法

建立 **Show Lane Executability Gate（SLEG）**，把 Show 晋级拆成可审计四步：

1. `lane_capture`
   - 记录 `news/show/newest` 三车道同窗快照与 item 轨迹。
2. `executability_preflight`
   - 检查 demo URL 可达性、是否登录墙、是否有最小复现实验步骤。
3. `promotion_contract`
   - 只有通过预检的 Show 条目才允许进入 candidate->issue。
4. `required_checks_enforcement`
   - 把门禁结果接入 GitHub required checks，阻断“文档通过但流水线不强制”。

## 最小执行协议

| Artifact | 必填字段 | Gate |
|---|---|---|
| `artifacts/show_lane_capture.json` | `window_id`, `item_id`, `lane`, `first_seen_at`, `seen_in_news`, `seen_in_show`, `seen_in_newest` | 缺少跨车道轨迹则不可晋级 |
| `artifacts/show_executability_preflight.json` | `item_id`, `url_reachable`, `auth_wall`, `repro_steps_present`, `repo_or_demo_ref`, `pass` | `pass=false` 直接 quarantine |
| `artifacts/show_promotion_contract.json` | `item_id`, `contract_version`, `required_checks`, `decision`, `blocked_reason` | required checks 不全不得进入 Issue |
| `artifacts/show_replay_bundle.json` | `item_id`, `capture_digest`, `preflight_digest`, `workflow_run_id`, `artifact_ref` | 无回放包不得归档为“可执行发现” |

建议 required checks：

- `show_lane_capture_pass`
- `show_executability_preflight_pass`
- `show_promotion_contract_pass`
- `show_replay_bundle_complete_pass`

## 证据链

1. `https://t.co/dwAiIjlXet` 指向 HN Popular Blogs OPML，说明入口是“订阅体聚合”，不是可执行性交付合同。
2. HN 三车道同窗快照（2026-02-28）显示 Show 条目在 `newest -> show -> news` 之间快速迁移，证明“发现热度”与“可执行性”不是同一维度。
3. GitHub Merge Queue 文档要求把状态检查作为晋级约束；`merge_group` 事件用于队列场景检查一致性。
4. Protected Branches 的 required status checks 能把门禁从“约定”变为“不可绕过”。
5. workflow artifact 文档提供回放落点，可把“可执行结论”变成可审计证据包。

## 反模式

- 看到 Show 热度就直接建 Issue，不做可执行预检。
- 只存链接，不存复现步骤与运行证据。
- 在 PR 描述声明“已验证”，但没有 required checks 绑定。
- `merge_group` 未纳入检查触发，导致入队后语义漂移。
- 把 OPML/聚合入口当成可执行性证明。
