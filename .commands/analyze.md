---
description: Deep analysis and problem diagnosis for code, components, or systems
argument-hint: <file | component | problem description | "project">
allowed-tools: [Read, Glob, Grep, Bash, Task]
---

# /analyze - Structured Analysis Command

Analyze the following: $ARGUMENTS

If $ARGUMENTS is empty or unclear, ask clarifying questions before proceeding.

---

## Analysis Principles

- Never assume information not provided - mark gaps explicitly
- Distinguish **facts**, **assumptions**, and **opinions**
- Flow: problem → system → causes → solutions
- Focus on **diagnosis first**, not immediate fixes
- Output must be readable outside this conversation (standalone Markdown)

---

## Depth Selection

Determine depth based on request scope:

| Request Type | Depth | Phases |
|--------------|-------|--------|
| Single file/function | Quick | 1, 3, 5 |
| Component/feature | Standard | 1-4, 5 |
| System/architecture | Deep | All phases |
| Bug/error diagnosis | Diagnostic | 1, 3, 4, 5 |

---

## Phase 1: Problem or Goal Statement

Define the analysis subject:

- **What** is being analyzed? (file, component, system, error)
- **Expected** behavior or state?
- **Actual** behavior or state?
- **When/where** does the problem occur?

If information is missing:
- List what's missing
- State minimal assumptions clearly

---

## Phase 2: System Mapping (Standard/Deep only)

Describe the system before analyzing problems:

- Project type (web app, CLI, API, monorepo)
- Technologies and versions
- Key components and their roles
- Data flow (request → processing → storage → response)
- External dependencies (APIs, databases, services)

**Goal:** Establish shared understanding of how the system *should* work.

---

## Phase 3: Exploration

Use Claude Code tools to gather information:

```
Glob("**/*.ts")              - Find files by pattern
Grep("pattern", path="src/") - Search for code patterns
Read("path/to/file")         - Examine specific files
Bash("git log -10 --oneline") - Recent changes
Bash("git diff HEAD~5")      - What changed recently
```

For problem diagnosis, look for:
- Error patterns: `Grep("error|Error|ERROR|throw|catch")`
- TODOs/FIXMEs: `Grep("TODO|FIXME|HACK|XXX")`
- Recent changes: `Bash("git log --oneline -20")`
- Dependencies: `Read("package.json")` or equivalent

---

## Phase 4: Hypothesis Formation (Diagnostic/Deep)

For each potential cause:

| Hypothesis | Supporting Evidence | Counter Evidence | Likelihood |
|------------|---------------------|------------------|------------|
| [Cause 1] | [What supports this] | [What argues against] | High/Med/Low |
| [Cause 2] | ... | ... | ... |

Categories of problems:
- **Logic** - code does wrong thing
- **Configuration** - env vars, settings, paths
- **Dependencies** - version conflicts, missing packages
- **Infrastructure** - environment, permissions, resources
- **Data** - invalid state, corruption, race conditions

---

## Phase 5: Recommendations

### Immediate Actions
Concrete steps to verify or fix the issue:

1. [Action] - [Why this helps] - [Expected result]
2. ...

### Long-term Improvements
Architectural or process changes if applicable.

---

## Output Templates

### Quick Analysis (file/function)

```markdown
# Analysis: [Subject]

## Summary
[1-2 sentence overview]

## Findings
| Finding | Severity | Location |
|---------|----------|----------|
| [Issue] | High/Med/Low | [file:line] |

## Recommendations
1. [Action]
2. [Action]
```

### Diagnostic Analysis (bug/error)

```markdown
# Diagnosis: [Problem]

## Symptoms
- [What's happening]
- [When it happens]

## Investigation
[What was checked and found]

## Root Cause
[Most likely cause with evidence]

## Fix
[Recommended solution]

## Prevention
[How to avoid this in future]
```

### System Analysis (component/project)

```markdown
# Analysis: [System/Component]

## Overview
[What this system does]

## Architecture
[Key components and relationships]

## Findings

### Strengths
- [What works well]

### Issues
| Issue | Severity | Impact | Recommendation |
|-------|----------|--------|----------------|
| [Problem] | High/Med/Low | [Effect] | [Action] |

### Risks
- [Potential future problems]

## Recommendations

### Immediate
1. [Priority action]

### Long-term
1. [Strategic improvement]

## Open Questions
- [What needs clarification]
- [Decisions for team/stakeholders]
```

---

## Executive Summary

Always end with a brief summary for quick reading:

```markdown
## Executive Summary

**Subject:** [What was analyzed]
**Main finding:** [Key insight or problem]
**Recommendation:** [Primary action]
**Confidence:** High / Medium / Low
```

---

## Notes

- Adapt output format to match the analysis type
- Skip phases that don't apply to the request
- If analysis reveals scope is larger than expected, note this and ask if user wants to continue
- Save detailed analysis to a file if requested: `analyze-[subject]-[date].md`
