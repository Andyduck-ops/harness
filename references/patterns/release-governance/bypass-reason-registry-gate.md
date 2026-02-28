---
name: bypass-reason-registry-gate
topic: release-governance
confidence: 0.77
verified_count: 5
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T21:09:22Z)
  - Hacker News top snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "MCP Spec Is Wrong: M×N ≠ M+N")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Lok, a modern HN web and terminal client")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "Show HN: Aider Polyglot - One command install and launch all your coding agents")
  - GitHub Docs: Review deployments (https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/review-deployments)
  - GitHub Docs: About rulesets (bypass list) (https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/about-rulesets)
  - GitHub Docs: About protected branches (https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
  - GitHub Docs: Managing a merge queue (https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/configuring-pull-request-merges/managing-a-merge-queue)
merge_upgrade_of:
  - references/patterns/release-governance/environment-bypass-audit-quarantine-gate.md
  - references/patterns/release-governance/branch-environment-no-bypass-parity-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

系统允许“例外旁路”，但旁路理由经常是自由文本且无统一编码，导致三件事同时失真：

- 分支/规则集侧有 bypass list，但环境侧 bypass reason 不可结构化对齐；
- merge queue 通过后到部署审批前，理由口径无法自动审计；
- 事后复盘只能看到“有人绕过了”，看不到“为什么这个理由在当时可被接受”。

结果是：**旁路行为可执行但不可归因，治理链条只剩日志，不剩策略。**

## 核心解法

建立 **Bypass Reason Registry Gate（BRRG）**，把“谁可旁路 + 因何旁路 + 是否可证据绑定”变成同一可验证契约：

1. 理由注册表（Reason Registry）
   - 定义 `bypass_reason_code` 枚举（如 `hotfix_security`, `sev1_mitigation`, `infra_outage`）。
   - 每个 code 绑定最小证据要求（ticket、incident、影响范围、失效时间）。
2. 旁路申请结构化
   - 所有 bypass 必须产出 `bypass_override_record.json`，禁止仅留评论或口头说明。
   - 记录 `actor`, `scope`, `reason_code`, `evidence_refs`, `expires_at_utc`。
3. 晋级门禁化
   - 若 `reason_code` 不在注册表，或证据不满足 code 约束，`promotion_decision=block`。
   - bypass 后必须执行 `post_bypass_reverify`，且审计文件与 `lineage_id` 绑定。

## 最小执行协议

| 文件 | 必填字段 | 失败条件 |
|------|----------|----------|
| `bypass_reason_registry.yaml` | `reason_code`, `allowed_scopes`, `required_evidence`, `max_ttl_hours` | 存在 bypass 行为但无注册表 |
| `bypass_override_record.json` | `lineage_id`, `actor`, `scope`, `reason_code`, `evidence_refs`, `requested_at_utc`, `expires_at_utc` | `reason_code` 非枚举或缺失证据引用 |
| `bypass_reason_validation.json` | `lineage_id`, `registry_version`, `reason_code_valid`, `evidence_complete`, `ttl_valid` | 校验失败仍允许晋级 |
| `promotion_decision.json` | `parity_gate_pass`, `reason_registry_pass`, `post_bypass_reverify_pass`, `decision` | `reason_registry_pass=false` 时仍 `decision=promote` |

## 证据链

- `https://t.co/dwAiIjlXet` 仍指向 OPML Gist，说明外部输入入口会漂移，旁路理由也必须有稳定可回放编码。
- HN `news/show/newest` 同时暴露“规范争议、工具发布、早期信号”三种噪声层，证明自由文本理由会在高吞吐场景下快速失真。
- GitHub `about rulesets` 明确提供 bypass list 控制面，证明“谁能绕过”可被显式建模。
- GitHub `review deployments` 明确存在 bypass deployment protection rules，证明“旁路动作”是系统内建路径，而非异常。
- GitHub `about protected branches` + `merge queue` 共同说明：分支禁绕、队列校验、部署审批是分离控制面；若无统一 reason registry，跨面审计无法自动成立。

## 反模式

- 允许 bypass 但不定义 `bypass_reason_code` 枚举，只保留自由文本。
- 只校验“操作者是否有权限”，不校验“理由是否属于允许范围”。
- bypass 后直接发布，不做 `post_bypass_reverify`。
- `promotion_decision.json` 不记录 `reason_registry_pass`，导致复盘无法判定放行依据。
