---
description: Safe, incremental dead code removal
argument-hint: [path]
allowed-tools: [Bash(git:*), Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(bun:*), Bash(bunx:*), Bash(composer:*), Bash(python3:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*), Bash(make:*), Read, Edit, Glob, Grep]
---

# Refactor

Systematic dead code removal and cleanup. Safe, incremental, test-verified.

## Usage

- `/refactor` — scan current project for dead code
- `/refactor <path>` — scan specific file or directory

## Process

1. **Scan for dead code** in target scope:
   - Unused imports and dependencies
   - Unused variables, functions, classes, types
   - Commented-out code blocks (> 3 lines)
   - Unreachable code paths
   - Unused exports (not imported elsewhere)
   - Leftover debug statements (`console.log`, `debugger`, `print`, `var_dump`)

2. **Categorize each finding:**

   - **SAFE** — Clearly unused, safe to remove (unused imports, unreferenced local variables, debug statements)
   - **CHECK** — Possibly unused but needs verification (exported functions, public methods, config values)
   - **SKIP** — Do not touch (test fixtures, intentional stubs, framework conventions)

3. **Present findings to user:**

```
## Dead Code Analysis

### SAFE (auto-removable)
1. `src/utils/helpers.ts:5` — unused import `lodash`
2. `src/api/users.ts:42` — unused variable `tempResult`
3. `src/lib/old.ts:10-25` — commented-out code block

### CHECK (needs your approval)
4. `src/utils/format.ts:export formatDate()` — no imports found, but is exported
5. `src/types/legacy.ts` — entire file, no imports found

### SKIP
6. `src/test/fixtures/mock.ts` — test fixture (intentional)
```

4. **Remove with user approval:**
   - SAFE items: "Remove all SAFE items? (y/n)"
   - CHECK items: ask one by one
   - After EACH removal: run tests immediately
   - If tests fail: revert that change, report which removal broke tests, recategorize as SKIP

5. **Final report:** lines removed, files removed, all tests passing.

## Rules

- NEVER remove CHECK items without explicit user approval
- NEVER remove code in one big batch — one change at a time, test after each
- ALWAYS revert immediately if tests fail after removal
- ALWAYS run tests after removals (use project's test runner)
- Do NOT refactor logic or rename things — this command is ONLY for dead code removal
- Do NOT touch protected areas (migrations, CI configs, lock files) per CLAUDE.md
- Respect `.gitignore` patterns — do not scan ignored files
