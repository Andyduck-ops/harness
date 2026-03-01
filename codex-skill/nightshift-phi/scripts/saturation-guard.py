#!/usr/bin/env python3
"""L1 饱和门 — per-topic pattern 上限 = 5。

拦截 Write 到 references/patterns/{topic}/ 的操作，
如果该 topic 已有 ≥5 个 pattern 文件，阻止写入。

只在创建新文件时触发。更新已有文件不阻止。
"""
import json
import os
import sys
from pathlib import Path

PATTERN_LIMIT = 5
PATTERNS_DIR = "references/patterns"


def main():
    try:
        payload = json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        print("{}")
        return

    tool_name = payload.get("tool_name", "") or ""
    if tool_name.lower() not in ("write", "write_file"):
        print("{}")
        return

    # 获取写入目标路径
    tool_input = payload.get("tool_input", {}) or {}
    file_path = tool_input.get("file_path", "") or tool_input.get("path", "")
    if not file_path:
        print("{}")
        return

    # 只关心 references/patterns/{topic}/*.md
    try:
        rel = Path(file_path).resolve().relative_to(Path.cwd().resolve())
    except ValueError:
        print("{}")
        return

    parts = rel.parts
    if len(parts) < 4 or parts[0] != "references" or parts[1] != "patterns":
        print("{}")
        return

    topic = parts[2]
    target_file = parts[3]

    # 跳过 _index.md、_master_index.md、_archive
    if topic.startswith("_") or target_file.startswith("_"):
        print("{}")
        return

    # 如果文件已存在 → 是更新，不阻止
    if os.path.exists(file_path):
        print("{}")
        return

    # 新文件 → 检查该 topic 下已有多少 pattern
    topic_dir = Path.cwd() / PATTERNS_DIR / topic
    if not topic_dir.is_dir():
        print("{}")
        return

    existing = [
        f for f in topic_dir.glob("*.md")
        if f.name != "_index.md" and not f.name.startswith("_")
    ]

    if len(existing) >= PATTERN_LIMIT:
        reason = (
            f"[L1 饱和门] topic '{topic}' 已有 {len(existing)} patterns（上限 {PATTERN_LIMIT}）。"
            f"必须先 merge 已有 patterns 再添加新的。"
            f"执行压缩：检查 {topic}/ 下哪些 patterns 可以合并，合并后再创建新 pattern。"
        )
        print(json.dumps({"decision": "block", "reason": reason}))
        sys.exit(2)

    print("{}")


if __name__ == "__main__":
    main()
