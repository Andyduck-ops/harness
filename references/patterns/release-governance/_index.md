# release-governance

- [staged-promotion-gate](./staged-promotion-gate.md) — 把“夜间无人推进”与“白天受控发布”拆成两段式晋级闸门
- [queue-deploy-continuity-dual-gate](./queue-deploy-continuity-dual-gate.md) — 把 merge queue 校验与 environment 审批绑定到同一 lineage，阻断“可合并但不可安全发布”
- [approval-freshness-budget-gate](./approval-freshness-budget-gate.md) — 把 queue 绿灯到 deploy 审批之间的时滞纳入预算，超窗强制重验再审批
- [environment-wait-timer-reverify-gate](./environment-wait-timer-reverify-gate.md) — 把 environment wait timer 建模为强制重验触发器，阻断“等待导致证据过窗”后直接晋级
- [environment-bypass-audit-quarantine-gate](./environment-bypass-audit-quarantine-gate.md) — 把 deployment bypass 从“手工例外”升级为“身份约束 + 审计隔离 + 重验恢复”的强制双轨门禁
- [branch-environment-no-bypass-parity-gate](./branch-environment-no-bypass-parity-gate.md) — 把分支禁绕与环境旁路策略做同一性闸门，阻断“规则禁绕但流程可旁路”的策略反转
- [bypass-reason-registry-gate](./bypass-reason-registry-gate.md) — 把旁路理由从自由文本升级为枚举注册表与证据绑定门禁，阻断“可绕过但不可归因”的灰放行
- [ruleset-bypass-list-drift-gate](./ruleset-bypass-list-drift-gate.md) — 把 ruleset bypass 名单漂移从“配置变更”升级为“队列重验 + 晋级阻断”的硬门禁
