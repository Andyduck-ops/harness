---
name: trusted-root-freshness-quarantine-gate
topic: trust-governance
confidence: 0.79
verified_count: 8
sources:
  - HN Popular Blogs OPML via https://t.co/dwAiIjlXet -> https://gist.github.com/emschwartz/e6d2bf860ccc367fe37ff953ba6de66b (redirect checked 2026-02-28T20:12:13Z)
  - Hacker News news snapshot (https://news.ycombinator.com/news, sampled 2026-02-28, top title: "A New Law of Thermodynamics: The Law of Disorder")
  - Hacker News show snapshot (https://news.ycombinator.com/show, sampled 2026-02-28, top title: "Show HN: Milestone, a desktop app to mark student work with AI")
  - Hacker News newest snapshot (https://news.ycombinator.com/newest, sampled 2026-02-28, top title: "GitHub Issues Search now supports nested queries and boolean operators")
  - Hacker News API (https://github.com/HackerNews/API)
  - GitHub Docs: Verify attestations offline (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/verify-attestations-offline)
  - GitHub Docs: Use artifact attestations (https://docs.github.com/en/actions/how-tos/secure-your-work/use-artifact-attestations/use-artifact-attestations)
  - OPML 2.0 Specification (https://2005.opml.org/spec2.html)
merge_upgrade_of:
  - references/patterns/artifact-governance/artifact-retention-verification-window-gate.md
  - references/patterns/evidence-governance/attested-evidence-provenance-gate.md
last_verified: 2026-02-28
rank: 3
---

## 元问题

夜间无人流程里，离线验签最容易出现的伪安全是：
**attestation 校验通过，但 trusted root 已过期或未轮换，导致“可验签结果”本身失去时效可信度。**

这会形成双重错觉：流水线看起来合规，次日追溯却无法证明“当时信任根是否仍有效”。

## 核心解法

建立 **Trusted Root Freshness Quarantine Gate（TRFQ-G）**，把“验签通过”升级为“验签根新鲜且可追责”：

1. **根信任时效合同**
   - 定义 `trusted_root_max_age_hours`（例如 24h）。
   - promotion 前必须校验 `now - trusted_root_fetched_at <= max_age`。
2. **轮换与指纹双记录**
   - 每轮生成 `trusted_root_snapshot.json`，记录 `fetched_at`, `root_digest`, `source`。
   - 验签报告必须回填 `root_digest`，禁止只记录 pass/fail。
3. **失效即隔离**
   - `root_fresh_pass=false` 或 `root_digest_mismatch=true` 时，直接 `quarantine`。
   - 禁止“先晋级后补拉根信任”。
4. **晋级并联闸门**
   - 仅当 `attestation_verify_pass && root_fresh_pass && digest_parity_pass` 才能晋级。
   - 所有结果写入 `promotion_decision.json` 并纳入 required checks。

## 最小执行协议

| 文件 | 必填字段 | 闸门 |
|------|----------|------|
| `trusted_root_snapshot.json` | `fetched_at_utc`, `root_digest`, `source_url` | 缺字段即失败 |
| `attestation_verify_report.json` | `subject_digest`, `verified`, `trusted_root_fetched_at`, `root_digest` | `verified=false` 即阻断 |
| `root_freshness_report.json` | `max_age_hours`, `age_hours`, `root_fresh_pass`, `root_digest_mismatch` | 任一失败即隔离 |
| `promotion_decision.json` | `attestation_verify_pass`, `root_fresh_pass`, `digest_parity_pass`, `decision` | 非全绿不得晋级 |

## 证据链

- `https://t.co/dwAiIjlXet` 持续重定向到 OPML Gist，适合作为稳定入口，但入口稳定不代表信任根新鲜。
- HN `news/show/newest` 同日高频变化，说明夜间发现与次日复验存在天然时差，根信任时效必须显式门禁。
- HN API 明确 `topstories/showstories/newstories` 是独立端点，支持把多车道采样时间写入统一验证上下文。
- GitHub 官方离线验签文档明确要求使用 `trusted_root.jsonl`，并给出更新信任根命令；这说明“根信任轮换”是验签正确性的前置条件。
- GitHub attestations 文档提供 `gh attestation verify` 路径，可把 `root_fresh_pass` 绑定为机器可审计事实。
- OPML 2.0 规范强调 outline 的 `text/xmlUrl/htmlUrl` 语义分离，支持对“入口身份”做可机审记录，避免根信任来源混淆。

## 反模式

- 只看 `gh attestation verify` 结果，不记录 trusted root 拉取时间。
- 多轮长期复用同一 trusted root 文件，不做 age 检查。
- root 失效仅报警不隔离，允许继续 promotion。
- 把 root 更新当人工操作，不纳入 required checks 与审计产物。
