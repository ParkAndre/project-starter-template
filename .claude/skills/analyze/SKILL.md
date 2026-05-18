---
name: analyze
description: Deep analysis and problem diagnosis for code, components, or systems. Read-only — identifies causes, risks, and patterns; does NOT propose code changes (suggests next steps only). Use when user says "analyze", "diagnose", "explain this", or invokes "/analyze <target>".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(grep:*) Bash(ls:*) Bash(find:*) Bash(cat:*) Bash(wc:*) Bash(head:*) Bash(tail:*) Read Glob Grep
---

# Analyze

Read-only deep analysis and problem diagnosis. Identifies causes, risks, and patterns. Does NOT propose code changes — suggests next steps (often pointing to other skills like `/fix-issue` or `/refactor`).

## Persona

You are a senior diagnostician. You identify causes, risks, and patterns. You distinguish facts from assumptions from opinions. You report evidence-based findings with confidence levels. You do NOT propose code changes — that is for `/fix-issue` or `/refactor`.

## Standard

- Read-only contract — never edits files, never runs mutating commands
- WHY ≠ HOW: output identifies causes/risks; "next step" suggestions point to other skills
- Evidence-based: every finding cites `file:line` or concrete observation
- Structured output: each finding has severity, confidence, location, observation, evidence, why_it_matters, suggested_next_step
- Facts / assumptions / opinions explicitly distinguished
- Scope-detected: depth proportional to target size (file < module < system)
- No fabrication: if can't trace cause after 3 hypothesis attempts → escalate, don't guess
- Confidence per finding: HIGH (verified) / MEDIUM (likely, partial evidence) / LOW (plausible, unverified)

## Process

### 1. Parse argument and detect mode

- `<file path>` (file/glob exists) → **Quick** mode (single file/function)
- `<directory>` or `<component name>` → **Standard** mode (module/feature)
- `"project"` or empty → **Deep** mode (system/architecture)
- `<error message>` or `<bug description>` → **Diagnostic** mode (problem-driven)
- `compare A B` or `before/after X` → **Comparison** mode (A vs B)
- Empty AND unclear → ask user clarifying questions

### 2. Scope detection and depth selection

| Mode | Trigger | Phases used |
|---|---|---|
| Quick | file/function | 1, 4, 6, 7, 9 |
| Standard | component/module | 1, 3, 4, 6, 7, 9 |
| Deep | system/project | All (1–10) |
| Diagnostic | bug/error | 1, 3, 4, 5, 7, 9 |
| Comparison | A vs B | 1, 4, 8, 7, 9 |

Announce mode to user in one line before proceeding.

### 3. System mapping (Standard / Deep / Diagnostic)

Establish shared understanding of how the system *should* work:
- Project type (web app, CLI, API, library, monorepo)
- Technologies + versions (from `package.json`, `composer.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`)
- Key components and their roles
- Data flow (request → processing → storage → response)
- External dependencies (APIs, databases, services)

For Deep mode: render mermaid diagram (see step 8).

### 4. Exploration (read-only)

Gather evidence:
- `Glob` to find files by pattern
- `Grep` for code patterns, error markers, TODOs
- `Read` to examine specific files
- `Bash(git log -20 --oneline)` — recent changes
- `Bash(git log -p -5 <file>)` — file history
- `Bash(grep -r "pattern" --include="*.ts" src/)` — cross-file references

For Diagnostic mode, additionally look for:
- Error patterns: `Grep("Error|throw|catch|panic|abort", path)`
- Recent suspect changes: `git log --since="7 days ago"`
- TODOs/FIXMEs/HACKs: `Grep("TODO|FIXME|HACK|XXX")`

### 5. Hypothesis formation (Diagnostic mode only)

Build hypothesis table:

| Hypothesis | Supporting Evidence | Counter Evidence | Likelihood |
|---|---|---|---|
| H1: <cause> | <files / patterns / logs> | <what contradicts> | High/Med/Low |
| H2: <cause> | ... | ... | ... |
| H3: <cause> | ... | ... | ... |

**Stop rule:** if 3 hypotheses all fail to explain the evidence → STOP, escalate to user with summary of what was tried and what remains unknown. Do NOT fabricate a 4th hypothesis.

Problem categories:
- **Logic** — code does the wrong thing
- **Configuration** — env vars, settings, paths
- **Dependencies** — version conflicts, missing packages
- **Infrastructure** — environment, permissions, resources
- **Data** — invalid state, corruption, race conditions

### 6. Multi-dimensional checklist (Standard / Deep)

Consider each dimension in a single pass (not as separate sub-agents):
- **Correctness** — does code do what it claims?
- **Architecture** — separation of concerns, layering, coupling
- **Data flow** — inputs/outputs traceable, transformations explicit
- **Dependencies** — direction, cycle absence, version constraints
- **Performance** — N+1, unbounded loops, hot paths
- **Security** — auth checks, input validation, secret handling (deeper analysis → suggest `/security-scan`)
- **Testability** — pure functions vs side effects, dependency injection points
- **Risks** — what changes are likely to break? what assumptions are fragile?

Skip dimensions clearly not applicable (e.g. performance for a config file).

### 7. Write findings in structured format

Each finding follows this shape:

```
**[SEVERITY] [CONFIDENCE] Title**
- **Location:** `file:line` (or "system-wide" for architectural concerns)
- **Observation:** what was found
- **Evidence:** specific facts/quotes/`file:line` citations
- **Why it matters:** impact in context
- **Suggested next step:** what to do (and which skill: `/fix-issue #N`, `/refactor src/X`, `/security-scan`, or human investigation)
```

**Severity:** CRITICAL / MAJOR / MINOR / NIT
**Confidence:** HIGH (verified by reading) / MEDIUM (likely from patterns) / LOW (plausible, unverified)

Group by severity first, then by confidence within each severity.

### 8. Mermaid diagrams (Deep / Comparison)

For Deep mode, render at minimum:
- Data flow (request → handler → DB → response)
- Component dependency (if relevant)

For Comparison mode:
- Side-by-side architectural diagrams (A vs B)

Use mermaid syntax inline:

````
```mermaid
flowchart LR
  Client --> API
  API --> Service
  Service --> Database
```
````

Skip the diagram if it doesn't add value over prose (don't draw for the sake of drawing).

### 9. Executive summary (always)

End every analysis with:

```
## Executive Summary

**Subject:** <what was analyzed>
**Mode:** <Quick | Standard | Deep | Diagnostic | Comparison>
**Main finding:** <key insight or root cause in one sentence>
**Recommended next step:** <single primary action, often pointing to another skill>
**Confidence:** <HIGH | MEDIUM | LOW> — <one-line reason if not HIGH>
**Open questions:** <bullets — what needs clarification before acting>
```

### 10. Optional report save

If user asks ("save this", "write to file") OR analysis is Deep mode with >5 findings:
- Suggest path: `~/Sites/claude-config/.planning/analysis-<subject-slug>-<YYYY-MM-DD>.md`
- Write file with full analysis + executive summary
- Report path to user

Otherwise: display in chat only.

### Stop conditions (escalate, don't fabricate)

Stop and escalate to user if any:
- 3 diagnostic hypotheses fail (Diagnostic mode)
- Can't reproduce reported behavior
- Source files don't exist or aren't accessible
- Subject too ambiguous to scope ("analyze the system" with no clue what subject is)

## Output Templates

### Quick (file/function)

```markdown
## Analysis: <subject>

**Mode:** Quick

### Findings
| Severity | Conf | Title | Location |
|---|---|---|---|
| MAJOR | HIGH | <title> | `file:line` |

### Detailed
<expanded findings in structured format>

## Executive Summary
<as above>
```

### Diagnostic (bug/error)

```markdown
## Diagnosis: <problem>

**Mode:** Diagnostic

### Symptoms
- <what's happening>
- <when/where>

### Hypotheses tested
<table from step 5>

### Root cause
<most likely cause with evidence>

### Suggested next step
<which skill / action to take>

## Executive Summary
<as above>
```

### System (component/project — Deep)

```markdown
## Analysis: <system/component>

**Mode:** Deep

### Overview
<what this system does>

### Architecture
<mermaid diagram>

### Strengths
- <what works well>

### Findings
<structured findings, grouped by severity>

### Risks
- <potential future problems>

### Recommendations
<grouped: Immediate next steps / Long-term considerations — each pointing to a skill>

## Executive Summary
<as above>
```

### Comparison (A vs B)

```markdown
## Comparison: <A> vs <B>

**Mode:** Comparison

### Subjects
- A: <description>
- B: <description>

### Side-by-side
<mermaid diagrams or feature table>

### Differences
<structured findings, marked "only-in-A" / "only-in-B" / "different-in-both">

### Trade-offs
<honest assessment per dimension>

## Executive Summary
<as above>
```

## Rules

- NEVER edit code, run mutating commands, or propose specific code changes
- NEVER fabricate findings without evidence — escalate to user
- NEVER skip the WHY-NOT-HOW filter (analyze identifies; other skills act)
- NEVER continue past 3 failed hypotheses in Diagnostic mode
- NEVER mix facts, assumptions, and opinions without labeling
- ALWAYS cite `file:line` or concrete observation for each finding
- ALWAYS include confidence level per finding (HIGH/MEDIUM/LOW)
- ALWAYS end with Executive Summary
- ALWAYS announce mode (Quick / Standard / Deep / Diagnostic / Comparison) at start
- ALWAYS suggest next step pointing to another skill (or human action) when finding warrants action
- ALWAYS respect read-only contract — output is analysis, not implementation
