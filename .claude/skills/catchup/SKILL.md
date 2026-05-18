---
name: catchup
description: Read-only branch context summary. Shows branch, issue, recent commits, changed files, AC progress, uncommitted + stashed changes, last-commit age, and suggested next steps. Reads any handoff file created by /fix-issue. Use when user returns to work after a break, switches branches, or says "catch me up", "what was I doing", "where am I", or invokes "/catchup".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(ls:*) Bash(grep:*) Read Glob Grep
---

# Catchup

Read-only branch context summary. Orients you after a break — surfaces what you were doing, what changed, and what to do next.

## Persona

You orient the user after a context break. Read-only. Surface what they were doing, what changed, and what they should do next. No editing.

## Standard

- Read-only: this skill never modifies files, never commits, never pushes, never installs
- Output is inline (chat) — no file persistence (handoff files are written by `/fix-issue`, not here)
- Structured template (predictable sections in fixed order) — fast to skim
- Surface stash + handoff files (commonly missed)
- Always end with concrete "Suggested next steps" (actionable commands)
- Honest about gaps: if `gh` unauthenticated, if no issue linked, if branch not feature-branch — say so

## Process

### 1. Parse argument

- `/catchup` (empty) → current branch
- `/catchup <branch-name>` → summary for that branch (run `git fetch` first; show context for branch even if not checked out)

### 2. Gather git context (parallel reads)

Run these in a single response with parallel Bash calls:

- `git rev-parse --git-dir 2>/dev/null` — verify in a repo (else "not in a git repo", exit)
- `git branch --show-current`
- `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` — base branch (fallback `main`)
- `git status --short` — staged, unstaged, untracked
- `git stash list` — stashed work (commonly missed)
- `git log <base>..HEAD --format='%h %s'` — commits ahead of base
- `git log HEAD..<base> --format='%h %s'` — commits behind base (rare, but useful)
- `git diff <base>...HEAD --stat` — changed files vs base
- `git log -1 --format='%cr'` — last commit relative time ("3 days ago")
- `git log -1 --format='%H %s'` — last commit hash + subject

### 3. Find linked issue or PR

- Parse current branch name with regex: `^(?:gh-|issue-|fix-|feature/)?([0-9]+)`
- If matched: `gh issue view <n> --json title,state,body,labels 2>/dev/null` (silently skip if `gh` unauthenticated; note gap in output)
- If no issue or `gh` failed: `gh pr list --head <branch> --state open --json number,title,body 2>/dev/null` for PR context
- If both empty: note "No linked issue or PR" — do NOT fabricate

### 4. Handoff file check

- `ls .planning/handoff-*.md 2>/dev/null`
- If issue number known: prefer `.planning/handoff-issue-<n>.md`
- If a handoff file exists: `Read` its content
- Surface its "Next" section prominently at the TOP of output (most actionable input)

### 5. Parse AC progress (if issue body has ACs)

Patterns to recognise in issue body:
- Checklist: `- [ ] / - [x]`
- Heading: `## Acceptance Criteria`, `## AC`
- Inline: `AC1:`, `AC2:`
- Gherkin: `Given ... When ... Then ...`

Cross-reference commit messages and changed files to guess which ACs are done:
- Mark as `[x] (probable)` if commit/diff evidence supports it
- Mark as `[ ]` if no detection
- Be honest — "probable" not "done"

### 6. Suggest next steps

Based on collected state, propose 2-4 concrete commands:

| State | Suggestion |
|---|---|
| Tests not run recently / no test record | `/verify quick` |
| Uncommitted changes present | `/commit` |
| Issue ACs incomplete | Continue work, mention which AC next |
| Branch ahead + tests pass + ACs done | `/merge <n>` (squash + push) |
| Stash present | `git stash show stash@{0}` to inspect, `git stash pop` to restore |
| Handoff file present | Quote its "Next" section verbatim |
| On main with uncommitted | `gh issue create` then `gh issue develop <n> --checkout` |
| No linked issue/PR on feature branch | `gh issue create` and link, or note as untracked work |

## Output Format

```markdown
## Catchup: <branch-name>

**Last commit:** <hash> "<subject>" (<relative time>)
**Status:** N ahead, M behind <base>
**Issue:** #<n> "<title>" (<state>) — or "No linked issue/PR"

### Handoff (if exists)

> Read from `.planning/handoff-issue-<n>.md`:
> <handoff "Next" section verbatim>

### Recent commits

1. `<hash>` <subject>
2. `<hash>` <subject>
...

### Changed files vs <base>

- `src/components/LoginForm.ts` (new, +120/-0)
- `src/services/auth.ts` (modified, +45/-12)
- ...

### AC Progress (if issue has ACs)

- [x] AC1 — probable (commit "Add login form")
- [x] AC2 — probable (commit "Add auth service")
- [ ] AC3 — not detected
- [ ] AC4 — not detected

### Uncommitted Changes

- Modified: `src/services/auth.ts` (unstaged, +3/-1)
- Staged: `src/routes/auth.ts` (new file)
- Untracked: `notes.txt`

### Stashed Changes

(Show only if `git stash list` returned anything.)
- `stash@{0}`: "WIP: experimenting with refresh tokens"
- `stash@{1}`: "broken — debugging session timeouts"

### Suggested Next Steps

1. Run `/verify quick` — confirm current state passes lint+tests
2. Address AC3 (invalid credentials error message) — see issue #<n>
3. After AC3 + AC4 done: `/merge <n>` to squash + close
```

## Rules

- NEVER modify files (no `Edit`, no `Write`)
- NEVER commit, push, stash, pop, or perform any mutating git operation
- NEVER `gh issue create`, `gh pr create`, `gh issue close`, or any mutating `gh` command
- NEVER install dependencies or run tests (suggest the command — let the user decide)
- ALWAYS announce "No linked issue/PR" if neither found (do NOT fabricate)
- ALWAYS read the handoff file if it exists (it's the most actionable input)
- ALWAYS end output with "Suggested Next Steps" (≥1 concrete action)
- ALWAYS show stash list if non-empty (commonly missed)
- ALWAYS include time-since-last-commit ("how stale am I" signal)
- ALWAYS be honest about coverage gaps (`gh` unauth, no issue body, etc.)
