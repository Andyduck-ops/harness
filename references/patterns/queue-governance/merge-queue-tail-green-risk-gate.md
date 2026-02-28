---
name: merge-queue-tail-green-risk-gate
topic: queue-governance
confidence: 0.77
verified_count: 9
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:39:15Z, revisions observed: 29)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "Obsidian Sync and local-first software")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Now I Get It: Visuals on how AI translators work")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "The Making of Anthropic CEO Dario Amodei (2025)")
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: Events that trigger workflows (`merge_group`) (https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group)
  - GitHub Docs: About protected branches (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Troubleshooting required status checks (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules#troubleshooting-required-status-checks)
  - OPML 2.0 Spec (`text/xmlUrl/htmlUrl` attributes) (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
  - references/patterns/feed-governance/hn-lane-identity-parity-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

Merge queue 的“队尾通过即可合并”容错模式，会把一个高风险事实隐藏掉：

- GitHub 允许关闭 `Only merge non-failing pull requests`，此时队列里允许包含失败 PR，只要最终组合头部通过就可推进；
- queue 会在 `merge_group` 上下文运行，而很多团队仍只盯 `pull_request` 结果；
- required checks 还要求基于最新 commit SHA 且在 7 天有效窗口内。

本质是：**当队列从“逐 PR 绿灯”切到“组合尾绿灯”时，失败责任会被掩蔽，导致可审计链条断裂。**

## 核心解法

建立 **Merge Queue Tail-Green Risk Gate（MQTRG）**，把“可合并”拆成三层硬门禁：

1. 队列模式验签（Mode Attestation）
   - 每次晋级都固化 `only_merge_non_failing_pull_requests` 当前值。
   - 若仓库策略与本次 run 读取值不一致，直接阻断。
2. 组内成员失败密度预算（Failure Density Budget）
   - 记录 merge_group 中每个 PR 的 required checks 映射，不允许“成员失败但队尾通过”无痕晋级。
   - 允许容错模式时，也必须满足 `failing_member_ratio <= budget`。
3. 双时点新鲜度重验（Entry + Exit Freshness）
   - 入队前校验 `queue_entry_fresh_pass`；
   - 出队前在 `merge_group` 再校验 `queue_exit_fresh_pass`，并验证 checks 绑定最新 SHA 和有效期。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `queue_mode_attestation.json` | `repo`, `branch`, `only_merge_non_failing_pull_requests`, `captured_at_utc` | 与仓库策略不一致 |
| `merge_group_member_matrix.json` | `merge_group_sha`, `pr_members[]`, `required_check_status[]`, `failing_member_count` | 成员映射缺失或计数不一致 |
| `queue_failure_budget.json` | `failing_member_ratio`, `max_failing_member_ratio`, `queue_mode` | 比例超预算 |
| `promotion_decision.json` | `queue_entry_fresh_pass`, `queue_exit_fresh_pass`, `mode_attested`, `decision` | 任一门禁失败仍标记 promote |

## 证据链

- `https://t.co/dwAiIjlXet` 当前重定向到 OPML Gist，且 Gist 存在多次修订，说明夜间输入面会持续漂移，晋级门禁不能只信一次性采样。
- HN `top/show/newest` 同时段头条高度异构，佐证夜间信号与工程负载都具高时变性，队列中的“延迟 + 合并”会放大掩蔽风险。
- GitHub merge queue 文档给出两种模式：可仅合并全通过 PR，或允许失败 PR 混入队列（只要尾部通过），这正是“责任掩蔽”的机制来源。
- GitHub Actions 文档要求关键检查监听 `merge_group`，否则队列阶段校验会缺失。
- GitHub required checks 文档要求检查必须针对最新 commit SHA 且超过 7 天会失效，支持双时点 freshness gate。
- OPML 2.0 规范中的 `text/xmlUrl/htmlUrl` 可编辑属性说明订阅输入可变，进一步要求晋级时保留模式与证据快照。

## 反模式

- 只看队尾 `merge_group` 结果，不记录组内 PR 失败分布。
- 开启容错模式但未定义 `failing_member_ratio` 预算。
- 只在 `pull_request` 事件保留证据，不在 `merge_group` 做复验。
- required checks 用旧 SHA 或超 7 天历史结果直接复用。

