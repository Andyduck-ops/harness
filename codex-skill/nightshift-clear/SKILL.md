---
name: nightshift-clear
description: |
  Nightshift 运维收敛技能。提供 stop/status/collect/backfill 四步骨架，
  用 main 作为中转（inbox）来收纳多分支产出并回灌。
---

# Nightshift-Clear（最小骨架版）

> 目标：把“长期巡航中的分支产出”收束成可审计、可回放、可回灌的流程。

## 激活

```text
$nightshift-clear
```

或直接脚本：

```bash
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh status
```

## 四步骨架

1. `stop`：停止 nightshift 三套 tmux 会话（runner/watchdog/reporter）
2. `status`：生成状态报告（session、branch、head、dirty、state）
3. `collect`：以 `main` 为基，创建 `nightshift/inbox-*` 中转分支并收纳候选提交清单
4. `backfill`：从 inbox 回灌到目标分支（默认 dry-run，需 `--apply` 才执行）

## 安全默认值

- 默认 **dry-run**
- 只有显式 `--apply` 才执行改动
- 不做 `push`
- 冲突不中断信息输出（会返回失败码并保留现场）

## 典型命令

```bash
# 1) 看状态
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh status

# 2) 先停再对账
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh stop --apply
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh status

# 3) 创建 inbox 并收纳各分支“候选 head commit”（仅记录）
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh collect --apply

# 4) 把 inbox 回灌到某个分支（先 dry-run）
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh backfill --from nightshift/inbox-YYYYMMDDHHMM --to nightshift/engineering

# 5) 确认后执行
~/.codex/skills/nightshift-clear/scripts/nightshift-clear.sh backfill --from nightshift/inbox-YYYYMMDDHHMM --to nightshift/engineering --apply
```

