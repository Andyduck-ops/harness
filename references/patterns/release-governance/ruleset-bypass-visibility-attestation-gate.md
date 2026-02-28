---
name: ruleset-bypass-visibility-attestation-gate
topic: release-governance
confidence: 0.79
verified_count: 6
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:19:40Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "How to build a coding agent")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Self-hosting all your coding agents with a single script")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Nvidia's net margin in AI peaks amid shrinking cloud rents")
  - GitHub REST API Rulesets (`bypass_actors` visibility requires write access) (https://docs.github.com/en/rest/repos/rules?apiVersion=2022-11-28#get-a-repository-ruleset)
  - GitHub Docs: Managing a merge queue (`Only merge non-failing pull requests`) (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
  - GitHub Docs: About protected branches (`Require status checks before merging`) (https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
merge_upgrade_of:
  - references/patterns/release-governance/ruleset-bypass-list-drift-gate.md
  - references/patterns/queue-governance/merge-group-parity-freshness-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

很多团队在做 ruleset bypass 审计时，用的是低权限 token 拉取 ruleset 配置。  
GitHub Rulesets API 明确说明：`bypass_actors` 只在调用者有仓库写权限时返回。

这会产生一个高危假象：**“字段不可见”被误读成“旁路名单为空”，进而把未知权限面当成安全态继续晋级。**

## 核心解法

建立 **Ruleset Bypass Visibility Attestation Gate（RBVAG）**，把“可见性”本身纳入晋级门禁：

1. 可见性先验验签
   - 每轮采样先记录 token 能力：`token_scope`, `repo_role`, `can_read_bypass_actors`。
   - `bypass_actors` 缺失时一律标记 `visibility_unknown`，禁止默认等价 `[]`。
2. 双快照一致性
   - 同轮生成 `write_scope_snapshot` 与 `runtime_scope_snapshot`。
   - 对比 `bypass_actor_count` 与 `bypass_mode`，任一不可见或差异即阻断晋级。
3. 队列联动止血
   - 当 `visibility_unknown=true` 时，merge queue 必须启用最严模式（仅允许 non-failing PR）并强制 `merge_group` 重验。
   - 未恢复可见性前，禁止“容错队列 + 自动晋级”组合。
4. 审计封账
   - `promotion_decision.json` 必须写入 `bypass_visibility_attested` 与 `attestation_scope_hash`。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `ruleset_visibility_attestation.json` | `token_scope`, `repo_role`, `can_read_bypass_actors`, `captured_at_utc` | 字段缺失仍放行 |
| `ruleset_bypass_dual_snapshot.json` | `write_scope_bypass_actors`, `runtime_scope_bypass_actors`, `visibility_unknown` | 缺失字段被映射为空数组 |
| `queue_safety_override.json` | `only_merge_non_failing_pull_requests`, `merge_group_reverify_required` | `visibility_unknown=true` 时仍允许容错队列 |
| `promotion_decision.json` | `bypass_visibility_attested`, `attestation_scope_hash`, `decision` | 未验签仍 `decision=promote` |

## 证据链

- `https://t.co/dwAiIjlXet` 仍重定向到同一 OPML 入口，说明外部输入入口稳定，但内容持续变化，不能把“看不到”当“没有”。
- HN `news/show/newest` 同时出现 agent 工程化、部署脚本化、AI 基础设施波动等信号，意味着夜间自动化密度高，权限误判的放大效应更强。
- GitHub Rulesets API 文档明确：`bypass_actors` 仅在写权限上下文返回，这是可见性盲区的直接依据。
- GitHub merge queue 文档显示可选择“只合并非失败 PR”；在可见性未知时必须切回该保守模式。
- GitHub protected branches 文档要求状态检查基于最新 commit 且在有效窗口内，支持“可见性异常即重验”的硬门禁。

## 反模式

- 用 read-only token 拉取 ruleset 后把缺失 `bypass_actors` 当空列表。
- 在 `visibility_unknown` 状态下继续启用容错 merge queue。
- 只记录 ruleset 结果，不记录 token 作用域与权限上下文。
- `promotion_decision.json` 缺少 `bypass_visibility_attested` 字段，导致次日不可追责。
