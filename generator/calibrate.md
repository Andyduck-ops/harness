# /harness:calibrate — Focused Knowledge Calibration

Manually triggered, focused calibration of the knowledge base.
Runs Scout→Distill→Analyze→Rank→Merge on a specific topic or source.

**~20 minutes. Human-initiated. Daytime use.**

---

## When to Use

- You read a great article about AI coding and want to absorb it
- A new tool/API released and you want patterns captured
- A specific topic in patterns/ feels stale
- After a major project milestone, to consolidate learnings
- After `/harness:compound` promotes lessons to pattern candidates

---

## Prerequisites

```bash
HARNESS_HOME="${HARNESS_HOME:-$HOME/harness}"
if [ ! -f "$HARNESS_HOME/references/sources.yaml" ]; then
  echo "[Harness] ERROR: Cannot find harness repo at $HARNESS_HOME"
  exit 1
fi
```

---

## Step 1: Determine Calibration Scope `[USER → AI]`

User provides one of:

| Input Type | Example | AI Action |
|-----------|---------|----------|
| **URL** | "calibrate this: https://openai.com/blog/..." | Scout that specific URL |
| **Topic** | "calibrate context-injection" | Scout all sources for that topic |
| **Source** | "calibrate @ryancarson" | Scout that specific source's recent output |
| **Broad** | "calibrate" (no args) | Scout top-ranked sources for recent activity |

---

## Step 2: Scout `[AI]`

### 2a. URL-based Scout

If user provided a specific URL:

```
WebFetch(url, prompt="Extract the key engineering insights, patterns,
  and actionable practices from this article. Focus on:
  1. What meta-problem does it address?
  2. What is the core solution?
  3. What evidence supports it?
  4. What are the implementation variants?
  Ignore marketing fluff. Be specific and technical.")
```

### 2b. Topic-based Scout

If user specified a topic:

```bash
# Read sources relevant to this topic
cat "$HARNESS_HOME/references/sources.yaml"
```

For each source with matching keywords:
```
WebFetch(source.url, prompt="Find recent content (last 30 days) about {topic}.
  Extract key insights, new patterns, or updated practices.")
```

Limit: top 5 sources by score. Max 3 articles per source.

### 2c. Source-based Scout

If user specified a source:
```
WebFetch(source.url, prompt="Find the 3 most recent and impactful articles or posts.
  Extract key engineering insights from each.")
```

### 2d. Broad Scout

No args — check top 5 sources by score for anything new:
```
For each top source:
  WebFetch(source.url, prompt="Any new articles in the last 7 days
    about AI coding, agent engineering, or developer tools?
    Extract key insights if found. Say 'nothing new' if none.")
```

---

## Step 3: Distill `[AI]`

For each finding from Scout, compress into pattern format:

```markdown
---
name: {slugified-name}
topic: {best-matching-topic}
confidence: {initial-estimate: 0.5-0.7 for new findings}
verified_count: 1
sources:
  - {source-name} ({date})
last_verified: {today}
rank: 3  # New findings start at rank 3
---

## 元问题
{What fundamental problem does this address?}

## 核心解法
{What is the core solution approach?}

## 证据
- {Source}: "{key quote or data point}"

## 实现变体
| 变体 | 机制 | 适用场景 |
|------|------|----------|
| ... | ... | ... |

## 反模式
- {What NOT to do}
```

**Key rule: Find the 元问题 (meta-problem).** If this finding addresses the same
meta-problem as an existing pattern, it's a variant, not a new pattern.

---

## Step 4: Analyze `[AI]`

For each distilled finding, run first-principles validation:

### 4a. Read Bedrock Principles

```bash
cat "$HARNESS_HOME/references/bedrock/first-principles.md"
```

### 4b. Cross-Validate

For each finding, check:

| Check | Question | Action if Fails |
|-------|----------|----------------|
| **Bedrock alignment** | Does this contradict any first principle? | Mark `[BEDROCK_CONFLICT]`, don't write |
| **Evidence strength** | Quantitative > Case study > Anecdotal? | Lower confidence accordingly |
| **Novelty check** | Is this already in patterns/? | If yes → merge as variant, not new pattern |
| **Noise filter** | Is this genuinely actionable or just buzzwords? | Mark `[NOISE]`, discard |

### 4c. Score Assignment

```
confidence = base_score × source_weight × evidence_multiplier

Where:
  base_score = 0.6 (new finding default)
  source_weight = from sources.yaml (0.5 - 0.95)
  evidence_multiplier:
    quantitative data = 1.3
    case study = 1.0
    anecdotal = 0.7
    opinion only = 0.4
```

If `confidence < 0.4` → discard (too noisy).

---

## Step 5: Rank & Merge `[AI]`

### 5a. Check for Existing Patterns

```bash
cat "$HARNESS_HOME/references/patterns/_master_index.md"
```

For each new finding:
- **Same meta-problem exists?** → Merge as implementation variant into existing pattern
- **New meta-problem?** → Create new pattern file in appropriate topic/
- **Contradicts existing?** → Create `conflicts.md` entry, don't auto-resolve

### 5b. Merge into Existing Pattern

If merging:
1. Read existing pattern file
2. Add new variant to `## 实现变体` table
3. Add new source to YAML frontmatter `sources:`
4. Increment `verified_count` if independent source confirms
5. Update `last_verified` date
6. Recalculate `confidence` (more sources = higher confidence)

### 5c. Create New Pattern

If new:
1. Write file to `$HARNESS_HOME/references/patterns/{topic}/{name}.md`
2. Update `_master_index.md` with new entry

### 5d. Update Source Scores

If a source produced high-quality findings → bump score in sources.yaml.
If a source produced mostly noise → lower score.

---

## Step 6: Report `[AI → USER]`

Present calibration results:

```markdown
## Calibration Complete

**Scope**: {url/topic/source/broad}
**Sources checked**: {N}
**Findings**: {N total} → {N kept} / {N noise} / {N conflicts}

### New Patterns
| Pattern | Topic | Confidence | Source |
|---------|-------|-----------|--------|
| {name} | {topic} | {conf} | {source} |

### Updated Patterns
| Pattern | Change | New Confidence |
|---------|--------|---------------|
| {name} | +1 variant from {source} | {old} → {new} |

### Discarded
- {finding}: {reason} (noise / low confidence / bedrock conflict)

### Conflicts (need human resolution)
- {pattern A} vs {new finding}: {description}

### Source Score Changes
| Source | Old Score | New Score | Reason |
|--------|-----------|-----------|--------|
| {name} | {old} | {new} | {reason} |
```

---

## Step 7: Commit (optional) `[USER]`

If satisfied with results:
```bash
cd $HARNESS_HOME && git add references/ && git commit -m "calibrate: {scope} — {N} findings"
```

---

## Examples

### Example 1: Calibrate a specific article
```
User: /harness:calibrate https://openai.com/index/harness-engineering/
AI: Scouts URL → Distills 3 findings → 2 merge into existing patterns, 1 new
```

### Example 2: Calibrate a topic
```
User: /harness:calibrate context-injection
AI: Checks 5 sources → Finds 2 new articles → Distills → 1 new variant for progressive-disclosure
```

### Example 3: Broad calibration
```
User: /harness:calibrate
AI: Scans top 5 sources (last 7 days) → 1 new finding from Anthropic blog → Merges
```

---

## Decay Check (Piggyback)

Every calibrate run also checks for staleness:

```bash
# Check all patterns for 90-day decay
for pattern in $HARNESS_HOME/references/patterns/**/*.md; do
  last_verified=$(grep 'last_verified' "$pattern" | head -1)
  # If > 90 days since last_verified → flag for review
done
```

Stale patterns are included in the report under "### Stale Patterns (consider re-verifying)".

---

## Safety Boundaries

| Rule | Enforcement |
|------|------------|
| Never modify bedrock/ | Hardcoded path check |
| Never modify PRD/ | Hardcoded path check |
| Never modify generator/ core logic | Hardcoded path check |
| Confidence < 0.4 → discard | Automatic |
| Contradictions → conflicts.md, not auto-resolve | Automatic |
| Max 5 sources per calibration | Prevent runaway costs |
| Max 500 words per distilled pattern | Prevent bloat |
| patterns/ > 100 → trigger merge warning | Automatic |

---

## Key Principles

> **Find the meta-problem, not the surface solution.**
>
> Different articles often describe the same underlying problem.
> Calibrate's job is to recognize "this is progressive-disclosure again"
> rather than creating a new pattern for every article.

> **Evidence strength determines confidence, not source fame.**
>
> A quantitative study from an unknown blog outranks an opinion piece
> from a famous practitioner.

> **Calibrate is additive, never destructive.**
>
> It can add variants, update scores, create new patterns.
> It cannot delete patterns, modify bedrock, or resolve conflicts.
