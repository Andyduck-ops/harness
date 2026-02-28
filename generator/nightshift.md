# /harness:nightshift — Overnight Autonomous Learning

Full-cycle knowledge evolution running unattended while human sleeps.
Produces a morning brief summarizing all changes.

**~2 hours. Autonomous. Overnight.**

---

## When to Use

- Before going to sleep: `/harness:nightshift`
- Via cron/scheduler for continuous learning
- Weekly deep calibration of the entire knowledge base

---

## Prerequisites



---

## Execution Model

Nightshift runs as a background agent:

### Claude Code


### Codex


---

## Phase 1: Scout (~40 min)

### 1a. Load Source Registry



Sort sources by score (highest first). Process top 10.

### 1b. Scan Each Source

For each source in priority order:



**Budget:** Max 10 sources × 3 findings = 30 raw findings.

### 1c. Write Scout Log



---

## Phase 2: Distill (~30 min)

### 2a. Filter Noise

From scout-log.md, discard:
- Findings marked `rehash` of known patterns
- Marketing/promotional content with no technical substance
- Findings with no actionable insight

### 2b. Distill to Pattern Format

For each retained finding, produce:



### 2c. Write Distill Log



---

## Phase 3: Analyze (~20 min)

### 3a. Load Bedrock



### 3b. Load Existing Patterns



### 3c. Cross-Validate Each Finding

For each distilled finding:

| Check | Pass | Fail Action |
|-------|------|------------|
| Bedrock alignment | Continue | Tag `[BEDROCK_CONFLICT]` → conflicts.md |
| Not duplicate of existing | Continue | Merge as variant → existing pattern |
| Evidence > anecdotal | Continue | Lower confidence by 0.15 |
| Actionable (not just theory) | Continue | Tag `[THEORY_ONLY]` → lower rank |
| Confidence ≥ 0.4 | Continue | Discard |

### 3d. Check for Self-Modify

If finding is about meta-framework/ topic (Scout/Distill/Rank/Merge improvement):
- Tag with `[SELF_MODIFY]`
- Include in morning brief with high visibility
- Still write to meta-framework/ (bounded self-improvement)
- **Never modify bedrock/**

---

## Phase 4: Rank & Merge (~20 min)

### 4a. Merge into Existing Patterns

For findings that match existing meta-problems:
1. Read existing pattern file
2. Add variant to `## 实现变体`
3. Add source to frontmatter
4. Update `verified_count`, `last_verified`, `confidence`

### 4b. Create New Patterns

For genuinely new findings:
1. Write to `$HARNESS_HOME/references/patterns/{topic}/{name}.md`
2. Add entry to `_master_index.md`

### 4c. Decay Sweep

Check ALL existing patterns:


### 4d. Compression Check



If > 100: identify patterns with same topic and similar meta-problems, merge aggressively.

### 4e. Update Source Scores

For each source that was scouted:
- Produced high-quality findings → score += 0.02 (cap at 0.95)
- Produced mostly noise → score -= 0.03 (floor at 0.3)
- No new content → no change

Write updated `sources.yaml`.

---

## Phase 5: Morning Brief (~10 min)

### 5a. Generate Brief

Write `$HARNESS_HOME/morning-brief.md`:



### 5b. Git Commit

All nightshift changes committed automatically:



**Note: Does NOT push.** Human reviews morning-brief.md and pushes if satisfied.

### 5c. Cleanup



---

## Safety Boundaries

### CAN do (autonomous)

| Action | Scope |
|--------|-------|
| WebFetch/WebSearch | Read-only, source URLs only |
| Create/update references/patterns/ | Knowledge base |
| Create/update references/sources.yaml | Source scores |
| Move patterns to archive/ | Decay cleanup |
| Write morning-brief.md | Reporting |
| Write .nightshift/ logs | Internal state |
| Git commit (no push) | Version control |

### CANNOT do (hardcoded blocks)

| Action | Reason |
|--------|--------|
| Modify PRD/ | Intent assets need human decision |
| Modify bedrock/ | First principles are immutable |
| Modify generator/*.md | Self-iteration needs human confirm |
| Modify project code | Out of scope |
| Git push | Human reviews first |
| Send messages / create PRs | No nighttime disturbance |
| Delete non-archive patterns | Prevent accidental data loss |
| Run for > 3 hours | Cost safety valve |

### Emergency Stop

If nightshift runs > 3 hours or encounters > 5 consecutive errors:
1. Write partial morning-brief.md with `[INTERRUPTED]` tag
2. Commit whatever was completed
3. Log error details to `.nightshift/errors.md`
4. Exit cleanly

---

## Scheduling

### Manual (Recommended Initially)



### Cron (After Trust is Established)



### Weekly Deep Calibration



---

## Relationship to Other Commands

| Command | Trigger | Scope | Duration | Human Role |
|---------|---------|-------|----------|------------|
| `/harness:calibrate` | Manual, daytime | Focused (1 topic/URL) | ~20 min | Interactive |
| `/harness:nightshift` | Manual/cron, night | Full (all sources) | ~2 hours | Reviews morning brief |
| `/harness:compound` | After task completion | Internal experience | ~10 min | Reviews lessons |

**Data flow:**


---

## Metrics

Track in `.nightshift/metrics.jsonl` (append-only):



Morning brief includes trend line when ≥ 5 data points exist.

---

## Key Principles

> **Nightshift is a librarian, not an architect.**
>
> It organizes, catalogs, and cleans the knowledge library.
> It never redesigns the library itself (that's human + calibrate).

> **Morning brief is the only human interface.**
>
> Everything nightshift does must be summarizable in 5 minutes of reading.
> If a change can't be explained in the brief, it shouldn't be made.

> **Commit but never push.**
>
> Git history provides full audit trail and rollback capability.
> Human pushes after reviewing morning brief = implicit approval.
