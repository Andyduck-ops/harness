#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Harness Bootstrap Micro-kernel — The bridge to the Motherbrain.

This script marks a paradigm shift: It does NOT copy templates. 
Harness is a meta-framework. This script only establishes the initial connection
and directory structure so the AI Agent can *dynamically compile* the specific runtime
based on the core principles and the target project's reality.
"""

import argparse
import json
import os
from pathlib import Path

DEFAULT_HARNESS_HOME = str(Path.home() / "harness")

def find_repo_root(start: Path) -> Path:
    cur = start.resolve()
    for p in [cur, *cur.parents]:
        if (p / ".git").exists():
            return p
    return cur

def _detect_profile(project_root: Path) -> dict:
    profile = {
        "language": "unknown",
        "framework": "none",
        "type": "app",
        "has_tests": False
    }

    # Language detection
    if (project_root / "package.json").is_file():
        profile["language"] = "javascript/typescript"
    elif (project_root / "pyproject.toml").is_file() or (project_root / "requirements.txt").is_file():
        profile["language"] = "python"
    elif (project_root / "go.mod").is_file():
        profile["language"] = "go"

    # Type detection
    if (project_root / "src" / "lib").is_dir() or (project_root / "lib").is_dir():
        profile["type"] = "library"
        
    # Simple test detection
    if (project_root / "tests").is_dir() or (project_root / "test").is_dir() or list(project_root.glob("**/*.test.*")) or list(project_root.glob("**/*_test.*")):
        profile["has_tests"] = True

    return profile

def main() -> None:
    p = argparse.ArgumentParser(description="Initialize Harness micro-kernel and awaken the Environment Compiler.")
    p.add_argument("--project", default=".", help="目标项目路径")
    p.add_argument("--harness-home", default=os.environ.get("HARNESS_HOME", DEFAULT_HARNESS_HOME))
    args = p.parse_args()

    project_root = find_repo_root(Path(args.project))
    harness_home = Path(args.harness_home).expanduser().resolve()

    if not (harness_home / "PRD" / "core-principles.md").exists():
        print(f"[!] 致命错误：无法在 {harness_home} 找到 Harness 主脑（缺少 PRD/core-principles.md）。")
        print("请确保 HARNESS_HOME 指向完整的主 Harness 仓库。")
        return

    # Create base directories
    harness_dir = project_root / ".harness"
    harness_dir.mkdir(parents=True, exist_ok=True)
    
    (harness_dir / "hooks").mkdir(parents=True, exist_ok=True)
    (harness_dir / "spec").mkdir(parents=True, exist_ok=True)
    
    # NEW: Intention Management Subsystem
    (project_root / "PRD" / "intent").mkdir(parents=True, exist_ok=True)
    (project_root / "PRD" / "architecture").mkdir(parents=True, exist_ok=True)

    # 1. Write the pointer to the Motherbrain
    pointer_path = harness_dir / ".harness-home"
    pointer_path.write_text(f"{harness_home}\n", encoding="utf-8")
    
    # Profile the project
    profile = _detect_profile(project_root)
    profile_path = harness_dir / "project-profile.json"
    profile_path.write_text(json.dumps(profile, indent=2), encoding="utf-8")

    # 2. Leave manifestation instructions for the Agent Compiler
    manifest_path = harness_dir / "MANIFESTATION_INSTRUCTIONS.md"
    manifest_path.write_text(
        "# Agent Manifestation Instructions\n\n"
        "**ROLE**: You are the Environment Compiler and Intent Architect for this project.\n\n"
        "**OBJECTIVE**: Dynamically compile the Harness runtime (hooks, specs, gates) tailored "
        "to this specific project, enforcing the meta-framework's strict principles. Focus heavily on Intent Management.\n\n"
        "**STEPS**:\n"
        f"1. **Load Soul**: Read `{harness_home}/PRD/core-principles.md`. Pay special attention to:\n"
        "   - `P4. Repo as Single Brain`\n"
        "   - `P5. Intent ID Traceability`\n"
        "   - `P6. Design Decisions are Explicit`\n"
        f"2. **Review Profile**: Read `.harness/project-profile.json` to understand the target environment.\n"
        f"3. **Query Patterns**: Search `{harness_home}/references/lanes/engineering/patterns/_master_index.md` for relevant architectural patterns based on your recon.\n"
        "4. **Establish Intent Management**: Harness believes Intent > Code. Do NOT write business code yet. You must first establish the PRD structure:\n"
        "   - Create `PRD/index.md` outlining the project's vision.\n"
        "   - Create `PRD/intent/registry.csv` (or md) to track Intent IDs.\n"
        "5. **Compile execution surface**: You must WRITE:\n"
        "   - `.codex/config.toml` to register your hooks.\n"
        "   - Custom Python scripts in `.harness/hooks/` to mechanically enforce tests, linting, and a strict debug budget (e.g., max 3 loops).\n"
        "   - **Crucially**: Ensure your Quality Gate (`quality-gate.py`) verifies that every code change is mapped to an Intent ID in the PRD.\n\n"
        "If you do your job right, this project will refuse to let an agent proceed if tests fail, if it gets stuck in an infinite debug loop, or if it writes code without a documented Intent.",
        encoding="utf-8"
    )

    print(f"\n[Harness Micro-kernel] 基础桥接与意图管理系统初始化完成于: {project_root}")
    print(f"-> 成功锁定主脑节点: {harness_home}")
    print("\n[给 Agent 的指令]:")
    print("微内核启动完毕。我已经留下了 .harness/MANIFESTATION_INSTRUCTIONS.md。")
    print("现在，请你接管工作。读取上述文件，成为环境架构师，重点建立 PRD 意图管理体系，并为这个项目现场编译出带有强制门禁的运行环境。")

if __name__ == "__main__":
    main()