# queue-governance

- [merge-group-parity-freshness-gate](./merge-group-parity-freshness-gate.md) — 用 merge_group 同构校验与时效重检门禁阻断“排队后失真晋级”
- [merge-queue-tail-green-risk-gate](./merge-queue-tail-green-risk-gate.md) — 在容错队列模式下引入成员失败密度预算与模式验签，阻断“队尾绿灯掩蔽失败成员”
- [queue-reorder-rebuild-attestation-gate](./queue-reorder-rebuild-attestation-gate.md) — 把 jump 重排与 merge_group 重建提升为 epoch 失效信号，阻断“重排后复用旧证据”的隐式放行
- [queue-reorder-evidence-epoch-invalidation-gate](./queue-reorder-evidence-epoch-invalidation-gate.md) — 将 queue 重建与外部证据纪元强绑定，阻断“代码重建但证据未重采样”的跨纪元晋级
- [queue-jump-throughput-loss-budget-gate](./queue-jump-throughput-loss-budget-gate.md) — 将 jump 重排转为吞吐损耗预算门禁，阻断“以应急名义持续触发全量重建”的队列抖动
- [queue-fallback-recovery-threshold-gate](./queue-fallback-recovery-threshold-gate.md) — 将 fallback 容错模式切换转为恢复阈值门禁，阻断“只降级不恢复”的长期质量债务
- [queue-fallback-hysteresis-cooldown-gate](./queue-fallback-hysteresis-cooldown-gate.md) — 将 fallback 恢复升级为双阈值滞回+冷却门禁，阻断“恢复后立刻回退”的模式振荡
- [queue-pending-deadlock-self-heal-gate](./queue-pending-deadlock-self-heal-gate.md) — 将 Pending 僵局治理升级为分类自愈闭环，阻断“盲重试放大为长期吞吐黑洞”
- [queue-rerun-blackhole-isolation-gate](./queue-rerun-blackhole-isolation-gate.md) — 将“重试”升级为“有效重试证明+黑洞隔离”，阻断 trigger_missing 场景下的无限无效重跑
- [pending-deadlock-taxonomy-version-drift-gate](./pending-deadlock-taxonomy-version-drift-gate.md) — 将僵局分类从“命名习惯”升级为“版本化词典+动作映射门禁”，阻断跨 cycle 的分类漂移误治
