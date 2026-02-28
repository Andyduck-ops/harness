# Generator — Project Environment Generator

## What It Does

The Generator scans a project and produces a tailored `.harness/` execution environment
based on the project's language, framework, structure, and applicable patterns.

## Commands

| Command | Description | Status |
|---------|-------------|--------|
| [init.md](./init.md) | `/harness:init` — Scan project, generate `.harness/` | ✅ Designed |
| [calibrate.md](./calibrate.md) | `/harness:calibrate` — Focused knowledge calibration | ✅ Designed |
| [nightshift.md](./nightshift.md) | `/harness:nightshift` — Overnight autonomous learning | ✅ Designed |

## Hook Templates (Production-Quality)

Derived from Trellis hooks (battle-tested through 18 rounds of iteration):

| Hook | Trigger | Key Features |
|------|---------|--------------|
| `session-start.py` | SessionStart | UTF-8 safe, CLAUDE_PROJECT_DIR aware, lessons + staleness injection |
| `inject-context.py` | PreToolUse(Task) | JSONL parsing, prd.md auto-extraction (F5), spec.jsonl fallback |
| `track-staleness.py` | PostToolUse(Edit/Write) | Zero-LLM detection, atomic writes, repo root walking |
| `quality-gate.py` | SubagentStop | Verify command execution (not just mention), 3-Failure Protocol, per-task state, timeout |

## Base Templates



## Design Principles

1. **Method is fixed, implementation adapts** — Every project gets the same patterns,
   but spec directories, JSONL content, and agent prompts are tailored.

2. **Start minimal, grow through compound** — Init generates a skeleton.
   Real value accumulates through `/harness:compound` after each task.

3. **Specs are injected, not remembered** — Hooks enforce context injection.
   More reliable than hoping the AI "remembers" conventions.
