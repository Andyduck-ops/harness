#!/usr/bin/env python3
"""Nightshift-Sleep Meta-Logic Guard (formerly saturation-guard).

职责：
1) lane 命名空间与双存储(Dual-Store)边界保护。
2) 全息芯片（Holographic Fragment）质量审计：写入 distilled/ 的文件必须包含
   The Logic, Adaptation Matrix, Invariant Solution 等必要骨架。
"""
from __future__ import annotations

import json
import os
import sys
from pathlib import Path

STATE_PREFIX = ".nightshift-sleep"
DEFAULT_LANE = "engineering"

WRITE_TOOL_NAMES = {
    "write",
    "write_file",
    "edit",
    "multi_edit",
}

REQUIRED_CHIP_SECTIONS = [
    "Meta-Problem ID",
    "The Logic",
    "Adaptation Matrix",
    "Invariant Solution"
]

def _load_payload() -> dict:
    try:
        return json.load(sys.stdin)
    except (json.JSONDecodeError, EOFError):
        return {}

def _resolve_rel_path(file_path: str) -> Path | None:
    if not file_path:
        return None
    path = Path(file_path)
    if not path.is_absolute():
        path = (Path.cwd() / path).resolve()
    else:
        path = path.resolve()
    try:
        return path.relative_to(Path.cwd().resolve())
    except ValueError:
        return None

def _block(reason: str) -> None:
    print(json.dumps({"decision": "block", "reason": reason}))
    sys.exit(2)

def _allow(reason: str | None = None) -> None:
    if reason:
        print(json.dumps({"decision": "allow", "reason": reason}))
    else:
        print("{}")

def _load_lane_id() -> str | None:
    env_lane = (os.environ.get("NIGHTSHIFT_SLEEP_LANE") or "").strip()
    if env_lane: return env_lane
    candidates = []
    default_ctx = Path.cwd() / STATE_PREFIX / "context.json"
    if default_ctx.is_file(): candidates.append(default_ctx)
    for p in Path.cwd().glob(f"{STATE_PREFIX}-*/context.json"):
        if p.is_file(): candidates.append(p)
    if not candidates: return None
    latest = max(candidates, key=lambda p: p.stat().st_mtime)
    try:
        data = json.loads(latest.read_text(encoding="utf-8"))
        return (data.get("lane_id") or "").strip() or None
    except Exception:
        return None

def _extract_target_paths_and_content(tool_input: dict) -> list[tuple[str, str]]:
    results = []
    content = tool_input.get("content") or tool_input.get("new_string") or ""
    
    # Single file
    for k in ["file_path", "path", "destination"]:
        if tool_input.get(k):
            results.append((tool_input[k], content))
            break
            
    # Multiple files
    files = tool_input.get("files")
    if isinstance(files, list):
        for item in files:
            if isinstance(item, dict):
                p = item.get("path") or item.get("file_path")
                c = item.get("content") or ""
                if p: results.append((p, c))
    return results

def _is_allowed_sleep_state(parts: tuple[str, ...]) -> bool:
    if not parts: return False
    return parts[0] == STATE_PREFIX or parts[0].startswith(f"{STATE_PREFIX}-")

def _audit_holographic_chip(content: str) -> str | None:
    """If the file is a distilled fragment, ensure it has the required structure."""
    if not content:
        return None # Can't check empty content (e.g. rename/move)
        
    missing = []
    content_lower = content.lower()
    for sec in REQUIRED_CHIP_SECTIONS:
        if sec.lower() not in content_lower:
            missing.append(sec)
            
    if missing:
        return f"芯片格式缺失必填要素: {', '.join(missing)}。你必须编译出包含这些要素的全息芯片 (Adaptation Matrix, The Logic 等)。"
    return None

def _validate_target(rel: Path, content: str, lane_id: str | None) -> None:
    parts = rel.parts
    if not parts: return

    if _is_allowed_sleep_state(parts): return
    if rel.name in {"sleep-report.md", "research-back-signals.md"}: return

    if parts[0] in {"PRD", "generator", "codex-skill", "docs"}:
        _block(f"[Meta-Logic Guard] 禁止写入 {parts[0]}/。Sleep 的身份是环境编译器，不能越权修改系统元资产。")

    if parts[0] != "references":
        _block("[Meta-Logic Guard] 非 references 目录写入已阻断。")

    if len(parts) >= 2 and parts[1] in {"patterns", "sources", "bedrock"}:
        _block("[Meta-Logic Guard] 禁止写旧路径。请使用 references/lanes/{lane_id}/...")

    if len(parts) >= 2 and parts[1] == "bridges": return

    if len(parts) < 3 or parts[1] != "lanes":
        _block("[Meta-Logic Guard] 仅允许写 references/lanes/{lane_id}/... 或 bridges/。")

    target_lane = parts[2]
    if lane_id and target_lane != lane_id:
        _block(f"[Meta-Logic Guard] 当前 lane={lane_id}，禁止跨界写入 lane={target_lane}。")

    if len(parts) >= 4 and parts[3] == "bedrock":
        _block("[Meta-Logic Guard] 禁止修改 bedrock。第一性原理不可自动改写。")

    if len(parts) >= 4 and parts[3] == "patterns":
        if "/_archive/" in "/".join(parts) or rel.name in {"_master_index.md", "_index.md"}:
            return
        _block("[Meta-Logic Guard] 禁止修改 patterns 证据层主文件！请将重构结果写入 distilled/，原文件归档至 _archive/。")

    if len(parts) >= 4 and parts[3] == "distilled" and rel.suffix == ".md":
        if not rel.name.startswith("_"):
            # This is a distilled chip, audit it!
            err = _audit_holographic_chip(content)
            if err:
                _block(f"[Meta-Logic Guard] 逻辑审计失败！\n{err}")

def main() -> None:
    payload = _load_payload()
    if not payload:
        _allow(); return

    tool_name = (payload.get("tool_name") or "").lower()
    if tool_name not in WRITE_TOOL_NAMES:
        _allow(); return

    tool_input = payload.get("tool_input") or {}
    lane_id = _load_lane_id() or DEFAULT_LANE

    targets = _extract_target_paths_and_content(tool_input)
    if not targets:
        _allow(); return

    for path_str, content in targets:
        rel = _resolve_rel_path(path_str)
        if rel is None:
            _block("[Meta-Logic Guard] 越界访问。")
        _validate_target(rel, content, lane_id)

    _allow()

if __name__ == "__main__":
    main()
