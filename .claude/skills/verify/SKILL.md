---
name: verify
description: Pre-merge quality gate with PASS/FAIL status. Runs lint, tests, type check, build, secrets scan, AI-attribution sweep across detected stack. Read-only — reports findings; does not fix. Three modes — quick (lint+tests), full (+typecheck+build), strict (+secrets+attribution+coverage). Use when user says "verify", "check ready to merge", or invokes "/verify".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(npm:*) Bash(npx:*) Bash(bun:*) Bash(bunx:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(python3:*) Bash(pytest:*) Bash(ruff:*) Bash(flake8:*) Bash(mypy:*) Bash(pyright:*) Bash(tsc:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Glob Grep
---

# Verify

Pre-merge quality gate. Runs lint + tests + type check + build + safety scans across the detected stack. Reports PASS/FAIL with evidence. Read-only — never fixes.

## Persona

Senior release engineer. Runs checks, reads exit codes, reports PASS/FAIL with evidence. Does not claim "looks good" without running anything. Does not fix — reports.

## Standard

- Evidence before claims: every PASS/FAIL backed by an actual command exit code or grep result. No "looks fine" without running.
- Multi-stack detection via config files — uses the project's own commands, never hardcoded.
- SKIP is not FAIL: missing tool or absent check = SKIP with reason.
- Stop on first error within a gate, but continue to the next gate (need full picture). Exception: CRITICAL FAIL (secret found) stops everything immediately.
- Severity: CRITICAL (FAIL — blocks merge) / MAJOR (FAIL) / MINOR (WARN — allows pass) / INFO.
- Secrets scan and AI-attribution scan are NEVER skipped, regardless of mode (per CLAUDE.md).
- Do not auto-fix anything (no `--fix` flag) — easier to mask signal than gain time.
- Do not retry on failure — STOP and diagnose root cause; don't loop.

## Process

### 1. Parse argument

- `/verify` or `/verify quick` → mode = **quick**
- `/verify full` → mode = **full**
- `/verify strict` → mode = **strict**

### 2. Detect project tools (parallel reads of config files)

Test runner and linter detection: use the tables in `.claude/scan-patterns.md` (canonical source, shared with `/commit` and `/merge`).

Additionally detect:

| Tool | Detect via | Run command |
|---|---|---|
| Type checker | `tsconfig.json`, `mypy.ini`, `pyproject.toml [tool.mypy]`, `pyrightconfig.json` | `tsc --noEmit` / `mypy` / `pyright` |
| Build | `package.json` scripts.build, `Makefile` build target, `Cargo.toml` (cargo build) | `npm run build` / `make build` / `cargo build --release` |

For each: if not detected → SKIP (not FAIL).

### 3. Determine gate list by mode

| Mode | Gates run |
|---|---|
| **quick** | always-on (secrets, AI-attribution, debug-code) + lint + tests |
| **full** | quick + typecheck + build |
| **strict** | full + commented-code + coverage report (informational) |

Always-on gates (secrets, AI-attribution, debug-code) apply ON TOP OF every mode's gate list — they are never skipped.

### 4. Run always-on safety gates (sequential, all run even on failure)

All patterns from `.claude/scan-patterns.md` (canonical source) — read it first.

**4a — Secrets scan** — secrets patterns over `git diff --cached` + `git diff` (staged + unstaged additions), with the documented skip rules for example/template files.

Match = **CRITICAL FAIL** (stops everything — see Red Flags).

**4b — AI-attribution scan** — AI-attribution greps over commit messages (`git log <base>..HEAD --format='%B'`) and the code diff.

Match = **MAJOR FAIL** (must be cleaned before merge per CLAUDE.md).

**4c — Debug code scan** — debug code patterns over modified non-test source files.

Match = **MINOR WARN** (flagged; does not block).

### 5. Run mode-specific gates (lint → typecheck → tests → build)

For each gate in order:
- If tool detected: run command, capture exit code + stderr (last 50 lines if long)
- exit 0 → **PASS**
- exit ≠ 0 → **FAIL** (record stderr sample for output)
- Not detected → **SKIP** with reason

After a failure: do NOT retry, do NOT `--fix`. Continue to the next gate.

### 6. Strict-mode additional gates

**6a — Commented-code scan**: blocks of ≥3 consecutive comment lines containing code-like syntax (parentheses, semicolons, `function`, `def`, `class` keywords).

Match = **MINOR WARN**.

**6b — Coverage report (informational only)**: if test runner supports a coverage flag, run with coverage; report percentage.

Does NOT block — coverage thresholds belong to `.claude/testing.md`, not the gate itself.

### 7. Aggregate results (decision tree)

- Any CRITICAL FAIL → overall **FAIL**
- Any MAJOR FAIL → overall **FAIL**
- Only MINOR WARN / INFO → overall **PASS** (with warnings)
- All PASS or SKIP → overall **PASS**

## Red Flags (STOP immediately)

- Tests were not actually run (no exit code captured) — never claim PASS without running
- Linter / typechecker output unparseable — flag as INTERNAL ERROR, ask user
- `git diff` empty AND no `git status` changes → "nothing to verify", exit early as NO-OP (not PASS, not FAIL)
- Tool config exists but tool not installed (e.g. `tsconfig.json` exists but `tsc` not on PATH) → FAIL with "install <tool>"
- Real secret matched (not `EXAMPLE_KEY=xxx`) → CRITICAL FAIL, immediate STOP, do not continue other gates

## Output Format

```markdown
## Verify (mode: quick | full | strict)

**Branch:** <name>
**Diff size:** N files changed, +X/-Y lines

### Results

| Check | Status | Details |
|---|---|---|
| Secrets scan | PASS / FAIL | `<file:line>` if FAIL |
| AI attribution | PASS / FAIL | `<commit-sha or file:line>` if FAIL |
| Debug code | PASS / WARN | `<count> at <file:line>` |
| Lint | PASS / FAIL / SKIP | error count + sample `file:line` |
| Type check | PASS / FAIL / SKIP | error count + sample |
| Tests | PASS / FAIL / SKIP | `<passed>/<total>` + first failure |
| Build | PASS / FAIL / SKIP | command output tail if FAIL |
| Commented code (strict) | PASS / WARN / — | `<count> blocks at <files>` |
| Coverage (strict, info) | INFO | `<percentage>%` |

### Severity Summary

- CRITICAL: <count>
- MAJOR: <count>
- MINOR: <count>
- INFO: <count>

### Verdict

**PASS** ✓ or **FAIL** ✗ — <one-line reason>

(If FAIL: list each blocking gate with failure detail.)
(If PASS with warnings: list warnings + suggest follow-up.)

### Next step

- PASS → ready for `/merge` (squash to main + push)
- FAIL → fix blocking gates first. Suggest `/fix-issue` for tracked work, or address directly if trivial.
```

## Rules

- NEVER claim PASS without an actual exit code or grep result backing it
- NEVER auto-fix anything (no `--fix` flag, no `Edit`, no `Write`)
- NEVER skip secrets scan or AI-attribution scan, regardless of mode
- NEVER retry a failed command — STOP, report, let user diagnose
- NEVER `--no-verify` or `--no-gpg-sign` unless user explicitly requests
- NEVER hardcode commands — always detect via config files first
- ALWAYS run gates in defined order (always-on first, then lint → typecheck → tests → build)
- ALWAYS continue to next gate after failure (need full picture) — UNLESS CRITICAL FAIL (secret) stops everything
- ALWAYS report exact counts + sample `file:line` for failures
- ALWAYS finish with explicit PASS/FAIL verdict and a concrete next-step suggestion
