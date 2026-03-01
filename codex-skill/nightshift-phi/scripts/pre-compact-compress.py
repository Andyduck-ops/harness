#!/usr/bin/env python3
"""L4 压缩周期 — compact 前注入压缩指令。

compact = 人工失忆。在失忆前强制执行一次压缩，
确保 compact 后的 agent 拿到的是干净的压缩状态。

不阻止 compact（exit 0），但通过 reason 注入行动指令。
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

    # 读取 state.json 获取当前 cycle 和上次压缩 cycle
    state_path = os.path.join(os.getcwd(), STATE_DIR, "state.json")
    current_cycle = 0
    last_compression = 0

    if os.path.exists(state_path):
        try:
            with open(state_path, "r", encoding="utf-8") as f:
                state = json.load(f)
            current_cycle = state.get("current_cycle", 0)
            last_compression = state.get("last_compression_cycle", 0)
        except (json.JSONDecodeError, IOError):
            pass

    cycles_since_compression = current_cycle - last_compression

    # 注入压缩提示（不阻止 compact）
    hint = (
        "[L4 压缩周期] 上下文即将被压缩（compact）。"
        "在继续之前：\n"
        f"1. 距上次压缩已过 {cycles_since_compression} cycles\n"
        "2. 检查所有 topics，merge 可合并的 patterns\n"
        "3. 更新 state.json 的 last_compression_cycle\n"
        "4. 确保 _master_index.md 是最新的（compact 后只能靠它恢复上下文）\n"
        "5. 在 morning-brief.md 记录压缩事件"
    )

    print(json.dumps({"decision": "allow", "reason": hint}))


if __name__ == "__main__":
    main()
