---
name: pending-deadlock-taxonomy-version-drift-gate
topic: queue-governance
confidence: 0.80
verified_count: 6
sources:
  - Shortlink anchor: https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect verified 2026-03-01)
  - OPML source gist page: https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (last active Feb 28, 2026)
  - HN top lane sample: https://news.ycombinator.com/item?id=47200342 (sampled 2026-03-01)
  - HN show lane sample: https://news.ycombinator.com/item?id=47195123 (sampled 2026-03-01)
  - HN newest lane sample: https://news.ycombinator.com/item?id=47201808 (sampled 2026-03-01; ID captured from newest lane discuss link)
  - Hacker News API reference (topstories/showstories/newstories): https://github.com/HackerNews/API
  - GitHub Docs: managing merge queue (build concurrency, status check timeout, merge_group behavior): https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue
  - GitHub Docs: events that trigger workflows (`merge_group` is separate from pull_request/push): https://docs.github.com/en/actions/reference/events-that-trigger-workflows#merge_group
  - GitHub Docs: troubleshooting required status checks (skipped workflow can stay Pending and block merge): https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/collaborating-on-repositories-with-code-quality-features/troubleshooting-required-status-checks
  - GitHub Docs: re-running workflows and jobs (re-run uses original `GITHUB_SHA` and `GITHUB_REF`): https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs
merge_upgrade_of:
  - references/patterns/queue-governance/queue-pending-deadlock-self-heal-gate.md
  - references/patterns/queue-governance/queue-rerun-blackhole-isolation-gate.md
last_verified: 2026-03-01
rank: 3
---

## 元问题

夜间自治流水线即使有 Pending 僵局检测，也常在跨 cycle 演进中失效，因为“僵局类别”没有稳定词典：

- 本轮叫 `trigger_missing`，下轮改成 `missing_trigger`，动作映射不再可回放；
- 同一现象在 `pull_request` 与 `merge_group` 被分到不同类，导致一边隔离一边重试；
- 历史审计只看到“有过分类”，看不到“分类规则版本”，无法证明晋级决策一致性。

本质问题不是“有没有分类”，而是**分类词典是否版本化且可审计回放**。

## 核心解法

建立 **Pending Deadlock Taxonomy Version Drift Gate（PDTVDG）**：

1. 分类词典版本化
   - 维护 `deadlock_taxonomy_manifest.json`，固定 `class_id` 与语义，不允许同义替换隐式漂移。
   - 每次调整分类规则必须提升 `taxonomy_version`。
2. 动作映射显式化
   - `class_id -> allowed_actions` 固定白名单：
     - `trigger_missing` -> `quarantine + contract_fix_required`
     - `transient_failure` -> `bounded_rerun`
     - `queue_rebuild_overlap` -> `accept_latest_merge_group_only`
3. 纪元绑定
   - `classification_decision.json` 必填 `taxonomy_version` 与 `merge_group_sha`。
   - 若分类版本与当前策略版本不一致，禁止复用旧结论。
4. 并联门禁
   - `taxonomy_version_pass`
   - `class_action_mapping_pass`
   - `pending_deadlock_pass`
   - 任一失败即阻断晋级。

## 最小执行协议

| 文件 | 必填字段 | 阻断条件 |
|---|---|---|
| `deadlock_taxonomy_manifest.json` | `taxonomy_version`, `classes[]`, `allowed_actions[]`, `deprecations[]` | 分类定义无版本或类 ID 可变 |
| `classification_decision.json` | `check_name`, `class_id`, `taxonomy_version`, `evidence_refs[]`, `decision` | 分类未绑定版本或证据缺失 |
| `class_action_policy.json` | `class_id`, `allowed_actions`, `forbidden_actions` | `trigger_missing` 仍允许 re-run |
| `merge_group_alignment.json` | `merge_group_sha`, `decision_run_id`, `stale_runs[]` | 使用 stale run 结果做最终判定 |
| `promotion_decision.json` | `taxonomy_version_pass`, `class_action_mapping_pass`, `pending_deadlock_pass`, `decision` | gate fail 但 `decision=promote` |

## 证据链

1. `https://t.co/dwAiIjlXet` 持续重定向到 OPML Gist，且 Gist 仍在更新，说明输入源高时变，分类体系必须可版本追踪。
2. HN 三车道样本（top/show/newest）在同一窗口出现不同节奏信号（`47200342 / 47195123 / 47201808`），说明夜间治理需要跨车道一致的分类语义。
3. GitHub 文档明确 `merge_group` 是独立触发面；若词典未区分触发面，容易出现同一故障跨面误分类。
4. GitHub 文档明确 skipped workflow 可能使 required checks 长期 Pending 并阻塞 merge，证明 `trigger_missing` 必须映射到“隔离+修契约”而非重试。
5. GitHub 文档明确 re-run 继承原始 `GITHUB_SHA/GITHUB_REF`，说明“仅重跑”不是新证据面，必须由分类策略明确限制。
6. GitHub merge queue 文档给出 build concurrency 与 status check timeout，证明僵局处理是容量治理问题，分类漂移会直接污染吞吐预算。

## 反模式

- 分类字段只写自由文本，不维护 `taxonomy_version`。
- 同一类故障在不同 workflow 使用不同 class 名称，导致动作不一致。
- 发现 `trigger_missing` 后仍直接 re-run，并把“重跑成功过”当作治理证明。
- 允许旧版本分类结果跨 `merge_group` 复用。
- 不记录 `class_id -> action` 决策依据，导致次日无法审计为什么隔离/放行。
