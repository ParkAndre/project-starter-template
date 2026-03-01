# Verify

Pre-PR quality gate. Run all project checks and report PASS/FAIL status.

## Usage

- `/verify` or `/verify quick` — lint + tests only
- `/verify full` — all checks including coverage and build

## Process

1. **Detect project tools** by checking config files:
   - Test runner: `package.json` scripts, `pytest.ini`, `phpunit.xml`, `go.mod`, etc.
   - Linter: `.eslintrc*`, `ruff.toml`, `.phpcs.xml`, etc.
   - Type checker: `tsconfig.json`, `mypy.ini`, `pyright`, etc.
   - Build: `package.json` build script, `Makefile`, `build.gradle`, etc.
   - If a tool is not found, mark as SKIP (not FAIL)

2. **Check for common issues** (no tools needed):
   - Scan staged/changed files for hardcoded secrets (API keys, passwords, tokens)
   - Scan for leftover debug code (`console.log`, `debugger`, `print(`, `var_dump`)
   - Scan for commented-out code blocks (> 3 lines)
   - Report findings as warnings

3. **Run checks in order** (stop category on first failure):
   - **Quick mode:** Lint → Tests
   - **Full mode:** Lint → Type check → Tests (with coverage) → Build

4. **Display results table:**

```
## Verify Results

| Check        | Status | Details          |
|--------------|--------|------------------|
| Secrets scan | PASS   | No issues found  |
| Debug code   | WARN   | 2 console.log    |
| Lint         | PASS   | 0 errors         |
| Type check   | PASS   | No errors        |
| Tests        | PASS   | 42 passed, 0 failed |
| Build        | SKIP   | No build script  |

**Result: PASS** (1 warning)
```

## Rules

- NEVER skip the secrets scan — always run it
- Report exact error counts and locations for failures
- If ANY check is FAIL, overall result is FAIL
- Warnings (debug code, commented code) do NOT cause FAIL
- List specific files and lines for all issues found
- Do NOT fix issues — only report them
- Use the project's actual commands (read from config), never hardcode
