#!/usr/bin/env python3
"""Nightshift-phi stop guard — 阻止 agent 在无合法理由时自行退出。

合法停止条件：
1. 人主动停止（检测到 user interrupt 信号）
2. 连续 5 次 Scout 错误
3. 所有方向穷尽
4. 系统错误（git 冲突 / 磁盘满）

其他情况一律阻止退出，注入继续工作的指令。
"""
import json
import os
import sys

STATE_DIR = ".nightshift-phi"


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        print("{}")
        return

    event = payload.get("hook_event_name", "")
    last_msg = payload.get("last_assistant_message", "") or ""

    # 检查是否有合法停止理由
    legitimate_stops = [
        "[INTERRUPTED]",
        "[EXHAUSTED]",
        "[DISK_FULL]",
        "[GIT_CONFLICT]",
        "[SYSTEM_ERROR]",
        "[USER_STOP]",
    ]

    for marker in legitimate_stops:
        if marker in last_msg:
            print(json.dumps({"decision": "allow"}))
            return

    # 检查 state.json 的连续错误计数
    state_path = os.path.join(os.getcwd(), STATE_DIR, "state.json")
    if os.path.exists(state_path):
        try:
            with open(state_path, "r", encoding="utf-8") as f:
                state = json.load(f)
            if state.get("consecutive_errors", 0) >= 5:
                print(json.dumps({"decision": "allow"}))
                return
            if state.get("status") == "exhausted":
                print(json.dumps({"decision": "allow"}))
                return

            # L4 压缩检查：退出前确保已执行压缩
            current_cycle = state.get("current_cycle", 0)
            last_compression = state.get("last_compression_cycle", 0)
            if current_cycle - last_compression >= 5:
                compress_reason = (
                    "[L4 压缩周期] 距上次压缩已超 5 cycles，退出前必须先执行压缩。"
                    "检查所有 topics，merge 可合并的 patterns，"
                    "更新 state.json 的 last_compression_cycle 后再退出。"
                )
                print(json.dumps({"decision": "block", "reason": compress_reason}))
                sys.exit(2)
        except (json.JSONDecodeError, IOError):
            pass

    # 无合法理由 → 阻止退出，注入继续指令
    reason = (
        "Nightshift-phi 没有合法停止理由。继续探索。"
        "如果你觉得当前方向穷尽了，分析知识地图找新的空白区域。"
        "如果连续遇到错误，检查网络状态并切换搜索策略。"
    )

    if event in ("Stop", "stop"):
        print(json.dumps({"decision": "block", "reason": reason}))
        sys.exit(2)
    elif event in ("SubagentStop", "subagent_stop"):
        agent_type = payload.get("agent_type", "")
        if agent_type in ("scout", "analyst", "cartographer"):
            print(json.dumps({"decision": "block", "reason": reason}))
            sys.exit(2)

    print("{}")


if __name__ == "__main__":
    main()
