# Generator — Project Environment Generator

## What It Does

The Generator scans a project and produces a tailored `.harness/` execution environment
based on the project's language, framework, structure, and applicable patterns.

## Commands

| Command | Description | Status |
|---------|-------------|--------|
| [init.md](./init.md) | `/harness:init` — Scan project, generate `.harness/` | ✅ Designed |
| calibrate.md | `/harness:calibrate` — External knowledge calibration | 🔲 Planned |
| nightshift.md | `/harness:nightshift` — Overnight autonomous learning | 🔲 Planned |

## Templates



## Design Principles

1. **Method is fixed, implementation adapts** — Every project gets the same patterns,
   but spec directories, JSONL content, and agent prompts are tailored.

2. **Start minimal, grow through compound** — Init generates a skeleton.
   Real value accumulates through `/harness:compound` after each task.

3. **Specs are injected, not remembered** — Hooks enforce context injection.
   More reliable than hoping the AI "remembers" conventions.
