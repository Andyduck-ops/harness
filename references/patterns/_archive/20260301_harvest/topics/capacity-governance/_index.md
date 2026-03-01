# capacity-governance

- [queue-build-concurrency-environment-capacity-gate](./queue-build-concurrency-environment-capacity-gate.md) — 将 merge queue 构建并发与部署审批/等待处理能力做容量耦合门禁，阻断“队列提速但发布端过载”的隐性降级
- [deployment-reviewer-throughput-budget-gate](./deployment-reviewer-throughput-budget-gate.md) — 将 deployment required reviewers 的处理吞吐、批处理节流与旁路审计绑定成独立预算门禁，避免“验证通过但发布拥塞”失控
- [approval-batch-shock-absorber-gate](./approval-batch-shock-absorber-gate.md) — 将“approve all waiting jobs”纳入批次上限、冷却窗口与新鲜度重验闭环，吸收审批冲击并反向约束 queue 并发
