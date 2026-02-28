# /harness:init — Project Environment Generator

Scan a project, read patterns/, and generate a project-specific `.harness/` execution environment.

---

## Prerequisites

- The `harness` repo must be cloned locally (contains PRD + references/patterns/)
- HARNESS_HOME environment variable points to the harness repo root
  - Default: `~/harness`

---

## Step 0: Locate Harness Knowledge Base

```bash
HARNESS_HOME="${HARNESS_HOME:-$HOME/harness}"
if [ ! -f "$HARNESS_HOME/references/patterns/_master_index.md" ]; then
  echo "[Harness] ERROR: Cannot find harness repo at $HARNESS_HOME"
  echo "[Harness] Clone it: git clone https://github.com/Andyduck-ops/harness ~/harness"
  exit 1
fi
echo "[Harness] Knowledge base found at $HARNESS_HOME"
```

---

## Step 1: Detect Platform `[AI]`

Detect which AI coding platform is being used:

| Signal | Platform |
|--------|----------|
| Running inside Claude Code CLI | **claude-code** |
| `.agents/` exists + no `.claude/` | **codex** |
| `.cursor/` exists + no `.claude/` | **cursor** |
| Default | **claude-code** |

Store result:
```
PLATFORM=claude-code  # or codex / cursor
```

**Phase 1 (MVP): Only claude-code is fully supported.** Other platforms get degraded output with warnings.

---

## Step 2: Scan Project Characteristics `[AI]`

Analyze the current project to understand its shape. Run these checks:

### 2a. Language & Framework Detection

```bash
# Detect by config files
ls package.json 2>/dev/null && echo "LANG: javascript/typescript"
ls tsconfig.json 2>/dev/null && echo "FRAMEWORK: typescript"
ls requirements.txt setup.py pyproject.toml 2>/dev/null && echo "LANG: python"
ls go.mod 2>/dev/null && echo "LANG: go"
ls Cargo.toml 2>/dev/null && echo "LANG: rust"
ls Gemfile 2>/dev/null && echo "LANG: ruby"
```

### 2b. Project Structure Analysis

Use Glob to understand the directory shape:
- `src/` or `app/` → application code location
- `tests/` or `__tests__/` or `*_test.go` → test convention
- `docs/` → existing documentation
- `.github/` → CI/CD presence
- Monorepo signals: `packages/`, `apps/`, `workspace` in package.json

### 2c. Existing Tooling Detection

```bash
# Build/test commands
grep -q '"test"' package.json 2>/dev/null && echo "CMD_TEST: npm test"
grep -q '"lint"' package.json 2>/dev/null && echo "CMD_LINT: npm run lint"
grep -q '"build"' package.json 2>/dev/null && echo "CMD_BUILD: npm run build"
ls Makefile 2>/dev/null && echo "CMD_BUILD: make"
ls pytest.ini setup.cfg pyproject.toml 2>/dev/null && echo "CMD_TEST: pytest"
```

### 2d. Compile Project Profile

Summarize findings into a structured profile:

```markdown
## Project Profile

- **Language**: TypeScript
- **Framework**: Next.js
- **Structure**: monorepo (apps/ + packages/)
- **Test command**: npm test
- **Lint command**: npm run lint
- **Build command**: npm run build
- **CI**: GitHub Actions
- **Existing docs**: docs/ (sparse)
- **Complexity**: medium (15k LOC, 3 packages)
```

---

## Step 3: Select Applicable Patterns `[AI]`

Read the pattern index and select patterns based on project profile:

```bash
cat "$HARNESS_HOME/references/patterns/_master_index.md"
```

### Pattern Selection Matrix

| Pattern | Applies When | Always |
|---------|-------------|--------|
| progressive-disclosure | Always | ✅ |
| hook-based-enforcement | Platform has hooks (claude-code) | ✅ |
| failure-budget | Always | ✅ |
| compound-learning | Always | ✅ |
| anchor-shape-decode-escape | Always | ✅ |
| permission-ladder | Team/production projects | ⚠️ |
| structured-escalation | Always | ✅ |
| staleness-detection | Project has specs/docs | ⚠️ |
| observation-masking | Projects with verbose test output | ⚠️ |
| custom-linter-messages | Projects with linters | ⚠️ |
| scout-distill-analyze-rank-merge | Meta-capability desired | ⚠️ |

**Core patterns (always applied):** progressive-disclosure, hook-based-enforcement, failure-budget, compound-learning, anchor-shape-decode-escape, structured-escalation.

**Conditional patterns:** Read the pattern file, check if the project matches the "适用场景".

---

## Step 4: Generate `.harness/` Directory `[AI]`

### 4a. Copy Base Template

```bash
if [ -d .harness ]; then
  echo "[Harness] .harness/ already exists. Skipping generation."
  echo "[Harness] To regenerate, remove .harness/ first."
  exit 0
fi

cp -r "$HARNESS_HOME/generator/templates/base/" .harness/
echo "[Harness] Created .harness/ from base template"
```

### 4b. Customize Based on Project Profile

**workflow.md** — Inject detected commands:
```markdown
## Verification Commands

- **Test**: `{detected_test_cmd}`
- **Lint**: `{detected_lint_cmd}`
- **Build**: `{detected_build_cmd}`
```

**spec/ directory** — Create domain-specific index files:

| Project Type | Spec Directories |
|-------------|------------------|
| Frontend (React/Vue/Svelte) | `spec/frontend/`, `spec/components/`, `spec/styling/` |
| Backend (Express/FastAPI/Go) | `spec/backend/`, `spec/api/`, `spec/database/` |
| Fullstack | Both above |
| Library/SDK | `spec/api-surface/`, `spec/compatibility/` |
| CLI tool | `spec/commands/`, `spec/output-format/` |

Each `spec/{domain}/index.md` starts with:
```markdown
# {Domain} Specifications

> This file is auto-generated by /harness:init. Customize as you develop.
> Specs are injected into agents via hooks — they are enforced, not suggested.

## Conventions

<!-- Add project-specific conventions here -->

## Patterns in Use

<!-- Auto-populated from selected patterns -->
```

**lessons/ directory** — Always create ANCHOR/SHAPE/DECODE/ESCAPE:
```
.harness/spec/lessons/
├── index.md       # Summary + framework explanation
├── ANCHOR.md      # Anti-hallucination patches
├── SHAPE.md       # Context/output adaptation
├── DECODE.md      # Signal verification
└── ESCAPE.md      # Loop breaking strategies
```

### 4c. Generate JSONL Injection Files

Create default JSONL files for each pipeline stage:

**implement.jsonl:**
```jsonl
{"file": "spec/lessons/index.md", "reason": "Project lessons and patterns"}
{"file": "spec/{primary_domain}/index.md", "reason": "{primary_domain} conventions"}
```

**check.jsonl:**
```jsonl
{"file": "spec/lessons/index.md", "reason": "Verify against known lessons"}
```

**debug.jsonl:**
```jsonl
{"file": "spec/lessons/ESCAPE.md", "reason": "Loop-breaking strategies"}
{"file": "spec/lessons/DECODE.md", "reason": "Signal verification for debugging"}
```

---

## Step 5: Generate Platform-Specific Config `[AI]`

### Claude Code (Primary)

Generate `.claude/` directory with:

**settings.json** — Register hooks:
```json
{
  "hooks": {
    "SessionStart": [{
      "command": "python3 .harness/hooks/session-start.py",
      "guard": "[ -d .harness ]"
    }],
    "PreToolUse": [{
      "matcher": "Task",
      "command": "python3 .harness/hooks/inject-context.py",
      "guard": "[ -d .harness ]"
    }],
    "PostToolUse": [{
      "matcher": "Edit|Write",
      "command": "python3 .harness/hooks/track-staleness.py",
      "guard": "[ -d .harness ]"
    }],
    "SubagentStop": [{
      "command": "python3 .harness/hooks/quality-gate.py",
      "guard": "[ -d .harness ]"
    }]
  }
}
```

**CLAUDE.md** — Progressive disclosure entry point (~100 lines):
```markdown
# {Project Name}

> Auto-generated by Harness. This is your agent's entry point.

## Project
{one-line description from package.json/README}

## Commands
- Test: `{test_cmd}`
- Lint: `{lint_cmd}`
- Build: `{build_cmd}`

## Specs (auto-injected by hooks)
Do NOT manually read spec files — they are injected into your context automatically
when you work on tasks. See `.harness/spec/` for the full knowledge base.

## Lessons
See `.harness/spec/lessons/index.md` for project-specific lessons.

## Workflow
Use `/harness:start` to begin a development session.
```

**agents/ directory** — Generate agent definitions based on selected patterns:
- `plan.md` — Requirements clarification + PRD generation
- `implement.md` — Code implementation with spec injection
- `check.md` — Quality verification with quality gate
- `debug.md` — Bug fixing with failure budget awareness

### Codex (Phase 2 — Degraded)

Generate `.agents/` with:
- `AGENTS.md` — Entry point with instructions (replaces hooks with strong directives)
- `skills/{name}/SKILL.md` — Each Trellis command as a Codex skill

### Cursor (Phase 2 — Degraded)

Generate `.cursor/` with:
- `rules/harness.md` — All conventions as rules (no enforcement, just guidance)

---

## Step 6: Generate Hook Scripts `[AI]`

Copy hook scripts from templates, customizing based on selected patterns:

```bash
cp "$HARNESS_HOME/generator/templates/hooks/"*.py .harness/hooks/
```

**Hook customization based on patterns:**

| Pattern Selected | Hook Impact |
|-----------------|-------------|
| failure-budget | quality-gate.py tracks debug_count, enforces ≤3 limit |
| permission-ladder | inject-context.py checks permission level before allowing tools |
| staleness-detection | track-staleness.py enabled |
| observation-masking | quality-gate.py truncates verbose output before injection |
| custom-linter-messages | quality-gate.py enhances lint error messages with fix instructions |

---

## Step 7: Present Summary & Confirm `[USER]`

Present the generated configuration to the user:

```markdown
## Harness Initialized ✓

**Project**: {project_name}
**Platform**: {platform}
**Language**: {language} / {framework}

### Generated Structure

```
.harness/
├── workflow.md              # Development workflow guide
├── hooks/                   # 4 Python hook scripts
│   ├── session-start.py
│   ├── inject-context.py
│   ├── track-staleness.py
│   └── quality-gate.py
├── scripts/                 # Task management utilities
│   ├── task.py
│   └── get_context.py
├── tasks/                   # Task directories (created per-task)
├── spec/
│   ├── {domain}/index.md    # Domain conventions
│   └── lessons/             # ANCHOR/SHAPE/DECODE/ESCAPE
└── index/
    └── knowledge.jsonl      # Semantic index

.claude/                     # Platform-specific (auto-generated)
├── settings.json            # Hook registration
├── CLAUDE.md                # Agent entry point (~100 lines)
└── agents/                  # Agent definitions
    ├── plan.md
    ├── implement.md
    ├── check.md
    └── debug.md
```

### Patterns Applied
- ✅ progressive-disclosure (context injection)
- ✅ hook-based-enforcement (quality enforcement)
- ✅ failure-budget (agent lifecycle)
- ✅ compound-learning (knowledge evolution)
- ✅ anchor-shape-decode-escape (lesson classification)
- ✅ structured-escalation (agent lifecycle)
- {conditional patterns if selected}

### Verification Commands
- Test: `{test_cmd}`
- Lint: `{lint_cmd}`
- Build: `{build_cmd}`

### Next Steps
1. Customize `.harness/spec/{domain}/index.md` with your project conventions
2. Run `/harness:start` to begin your first development session
3. After your first task, run `/harness:compound` to extract lessons
```

---

## Idempotency

- If `.harness/` already exists, **do not overwrite**. Report and exit.
- If `.claude/settings.json` already exists, **merge** hook entries (don't overwrite existing hooks).
- If `CLAUDE.md` already exists, **append** harness section (don't overwrite user content).

---

## Key Principles

> **Method is fixed, implementation adapts to the project.**
>
> Every project gets the same patterns (progressive disclosure, failure budget, compound learning),
> but the specific spec directories, JSONL content, verification commands, and agent prompts
> are tailored to the project's language, framework, and structure.

> **Specs are injected, not remembered.**
>
> The generated hooks ensure agents receive relevant specs automatically.
> This is more reliable than hoping the AI "remembers" conventions.

> **Start minimal, grow through compound.**
>
> Init generates a skeleton. Real value accumulates through `/harness:compound`
> after each task — lessons, specs, and patterns build up over time.
