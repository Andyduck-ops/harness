# control-plane-governance

- [contradiction-ledger-freeze-gate](./contradiction-ledger-freeze-gate.md) — 将社区信号与官方规则冲突建模为结构化账本，并用 freeze + reverify + reapprove 的双重门禁阻断错误晋级
- [contradiction-sla-tombstone-gate](./contradiction-sla-tombstone-gate.md) — 将冲突超时视为墓碑化阻断事件，要求 SLA 到期自动 tombstone 并通过再资格化合同才能恢复晋级
- [conflict-arbitration-dual-phase-contract-gate](./conflict-arbitration-dual-phase-contract-gate.md) — 将冲突恢复过程拆为“证据重验 + 治理复批”双相合同，并要求 pull_request 与 merge_group 同构执行
- [conflict-intake-required-form-gate](./conflict-intake-required-form-gate.md) — 将冲突治理前移到入口，使用 required 表单字段 + 同构 required checks 阻断“缺字段冲突”进入仲裁流
- [conflict-form-schema-drift-gate](./conflict-form-schema-drift-gate.md) — 将冲突入口从“字段存在校验”升级为“版本兼容校验”，以 schema 差分清单 + 兼容窗口阻断可提交但不可回放的仲裁债务
