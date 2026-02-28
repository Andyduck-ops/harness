# queue-governance

- [merge-group-parity-freshness-gate](./merge-group-parity-freshness-gate.md) — 用 merge_group 同构校验与时效重检门禁阻断“排队后失真晋级”
- [merge-queue-tail-green-risk-gate](./merge-queue-tail-green-risk-gate.md) — 在容错队列模式下引入成员失败密度预算与模式验签，阻断“队尾绿灯掩蔽失败成员”
- [queue-reorder-rebuild-attestation-gate](./queue-reorder-rebuild-attestation-gate.md) — 把 jump 重排与 merge_group 重建提升为 epoch 失效信号，阻断“重排后复用旧证据”的隐式放行
- [queue-reorder-evidence-epoch-invalidation-gate](./queue-reorder-evidence-epoch-invalidation-gate.md) — 将 queue 重建与外部证据纪元强绑定，阻断“代码重建但证据未重采样”的跨纪元晋级
