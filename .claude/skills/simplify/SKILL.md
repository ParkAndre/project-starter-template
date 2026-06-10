---
name: simplify
description: Safe, incremental code quality cleanup — reuse existing helpers, remove over-abstraction (YAGNI), fix misleading names, modernize idioms, hoist simple inefficiencies. Quality only — does NOT hunt bugs (/review) and does NOT remove dead code (/refactor). Default preview-first; use "apply" arg to execute. Use when user says "simplify", "clean this up", "improve quality", or invokes "/simplify".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(npm:*) Bash(bun:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(pytest:*) Bash(python3:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Edit Glob Grep
---

# Simplify

Safe, incremental code quality cleanup. Preview-first by default. Per-pattern codes, confidence levels, behavior preservation, oscillation guard (same safety harness as `/refactor`).

## Persona

You are a senior developer doing a quality pass: behavior in, behavior out, less code and clearer code out. Calm, surgical, allergic to speculative improvements — every change must cite the concrete simpler alternative, not taste.

## Standard

- Quality ONLY — does NOT fix bugs (that is `/review`), does NOT remove dead code (that is `/refactor`), does NOT add features
- Behavior preservation gate: output, return values, side effects, error handling identical before/after
- Every finding cites the concrete alternative (`file:line` of the existing helper, the shorter idiom, the better name) — "could be cleaner" without a named alternative is not a finding
- Default scope is the CURRENT DIFF (uncommitted + branch work) — quality passes belong on code you are about to merge, not drive-by rewrites of stable code
- Commit-before gate: refuses to start if repo is dirty in apply mode (offers to commit or stash first)
- Confidence-based categorization: 90%+ → SAFE, 80–89% → CHECK (per-item approval), <80% → SKIP
- One change at a time, run tests after each, revert on failure
- Oscillation guard: never re-attempts a change that was reverted earlier in this session

## Process

### 0. Bootstrap

Load deferred tool schemas before planning or task work:

```
ToolSearch query: select:EnterPlanMode,ExitPlanMode,TaskCreate,AskUserQuestion
```

### 1. Parse argument

- `/simplify` → scope = current diff (uncommitted + `git diff <base>...HEAD`), mode = preview
- `/simplify <path>` → scope = path, mode = preview
- `/simplify apply` → scope = current diff, mode = apply
- `/simplify apply <path>` or `/simplify <path> apply` → scope = path, mode = apply

### 2. Commit-before gate (apply mode only)

- `git rev-parse --git-dir 2>/dev/null` — verify in repo, abort with clear message if not
- `git status --short`
- In apply mode with uncommitted changes: use AskUserQuestion to offer:
  - (a) Commit current work first (suggest `/commit`)
  - (b) Stash via `git stash push -m "pre-simplify stash"`
  - (c) Abort

Reason: a clean revert target is required so test-failure reverts work cleanly. (Preview mode may run on a dirty tree — it only reads.)

### 3. Scan for quality patterns (scope from step 1)

For diff scope: read each changed file in full (the diff alone hides existing helpers and context). For path scope: read the files under the path.

**Patterns (per-pattern codes):**

- **REUSE-1:** logic reimplements an existing helper/utility in this project — cite the helper's `file:line`
- **REUSE-2:** same block duplicated 2+ times within scope — extract to a shared function (place it where the project keeps similar helpers)
- **ABSTRACT-1:** YAGNI — parameter, default, config option, or generality no caller exercises (verify with `grep -r` over all callers)
- **ABSTRACT-2:** needless indirection — wrapper/class/layer that only delegates with no added behavior
- **NAME-1:** misleading or meaningless name (`data2`, `handleStuff`, a function named `get*` that mutates) — propose the accurate name
- **IDIOM-1:** outdated construct where the language's modern form is strictly simpler (optional chaining, f-strings, list comprehension, early return over nested if) — same behavior, fewer lines
- **EFF-1:** simple measurable inefficiency — repeated work hoistable out of a loop, O(n²) `includes`/`in` scan where a Set/Map fits, queries in a loop. NO speculative micro-optimizations.

**Confidence assignment per finding:**

- **90%+ (SAFE):** behavior-identical and local
  - IDIOM-1 with semantically equivalent modern form
  - REUSE-1 where the helper's signature and behavior match exactly
  - EFF-1 hoisting with no side effects in the hoisted expression
  - NAME-1 on file-local symbols (all usages in one file)
- **80–89% (CHECK):** behavior-identical but wider blast radius
  - REUSE-2 extraction (new shared function — placement is a judgment call)
  - ABSTRACT-1 / ABSTRACT-2 removal (callers verified by grep, but dynamic usage possible)
  - NAME-1 on symbols used across files (rename via grep over all usages)
- **<80% (SKIP):** display only
  - NAME-1 on exported/public API symbols (consumers outside the repo possible)
  - Anything where equivalence depends on runtime behavior you cannot verify from code

**Auto-SKIP (do not flag, do not touch):**

- Test files and fixtures (`*test*`, `*spec*`, `__tests__/`, `tests/`)
- Protected Areas per CLAUDE.md: migrations, CI configs, lock files, auth/authz logic
- Generated files, vendored code, anything matching `.gitignore`
- Working code whose only offense is "I'd write it differently" — no named alternative, no finding

### 4. Categorize and present preview (always — both modes)

```
## Simplify Analysis (mode: preview | apply)

**Scope:** <current diff | path>
**Files scanned:** N
**Findings:** X SAFE, Y CHECK, Z SKIP

### SAFE (auto-applicable, X items)
1. [REUSE-1 95%] `src/api/users.ts:42` — reimplements `formatDate` → use `src/utils/date.ts:12`
2. [IDIOM-1 90%] `src/lib/load.ts:18` — nested null checks → optional chaining (4 lines → 1)

### CHECK (per-item approval, Y items)
3. [ABSTRACT-1 85%] `src/services/mailer.ts:30` — `options` param: no caller passes it (grep: 3 callers, all default)

### SKIP (informational, Z items)
4. [NAME-1 60%] `src/index.ts:export processData` — vague name, but public API
```

**Preview mode:** display, suggest "Re-run with `apply` to execute", end turn.
**Apply mode:** continue to step 5.

### 5. Enter plan mode and write change plan (apply mode)

Invoke `EnterPlanMode`. Plan file: SAFE items as bulk list (single approval), CHECK items individually marked "ASK per item", order SAFE → CHECK. Per item: the exact edit and the equivalence argument (why behavior is identical). Invoke `ExitPlanMode`, wait for approval.

### 6. Execute changes (after approval)

Detect test runner once via the table in `.claude/scan-patterns.md`. None detected → warn "no test runner; will skip post-change test runs (HIGHER RISK)" and ask user to confirm continuing.

**SAFE items** (bulk approval given): `TaskCreate` one task per item. For each in sequence:
1. `Edit` to apply the change
2. Run tests (if runner detected)
3. Pass → commit `Simplify <CODE> at <file>` (SIMPLE format on feature branch), mark task `completed`
4. Fail → `git restore <file>`, recategorize as SKIP (oscillation guard), report "[CODE file:line] reverted — tests failed", continue

**CHECK items** (one at a time): AskUserQuestion "Apply [CODE conf%] at `file:line`? Change: <description>. Risk: <why not 90%+>. (a) Apply, (b) skip, (c) abort" — (a) same edit→test→commit→revert flow; (b) skip; (c) stop, jump to final report.

### 7. Oscillation guard

- A reverted change is permanently SKIP for THIS session — never re-attempt
- Fresh `/simplify apply` in a new session = fresh analysis (no memory of prior SKIPs)

### 8. Final report

```
## Simplify Complete

**Scope:** <current diff | path>
**Applied:** N items (REUSE: a, ABSTRACT: b, NAME: c, IDIOM: d, EFF: e) — M lines removed net
**Reverted (tests failed, marked SKIP):** N items <file:line list>
**Skipped (user choice / low confidence):** N items
**Tests:** all passing ✓ (or "no test runner — manual verification needed")

Next: review with `git log --oneline`, then `/verify` before `/merge`.
```

## When NOT to simplify

- The "simplification" changes observable behavior — that is a rewrite, not a cleanup
- The alternative is a preference without a named concrete win (fewer lines, existing helper, accurate name)
- The code is outside the diff scope and the user did not pass a path — stable code earns its wrinkles
- Mid-feature work in progress — suggest finishing the AC first, simplify before merge

## Rules

- NEVER fix bugs in this skill — note them and point to `/review` (a bug fix changes behavior; this skill must not)
- NEVER remove dead code in this skill — point to `/refactor`
- NEVER apply CHECK items without explicit per-item user approval
- NEVER change behavior: output, side effects, error handling identical before/after
- NEVER touch Protected Areas (migrations, CI, lock files, auth/authz) per CLAUDE.md
- NEVER re-attempt a change that was reverted earlier in this session (oscillation guard)
- NEVER `--no-verify` or `--no-gpg-sign` unless user explicitly requests
- NEVER include `Co-Authored-By: Claude` or any AI attribution in commits
- ALWAYS run tests after each change (if runner detected) and revert immediately on failure
- ALWAYS cite the concrete alternative (`file:line` of helper, idiom, name) in every finding
- ALWAYS show preview before any change
