---
name: e2e
description: Run Playwright end-to-end tests. Auto-detects package manager (npm/bun/pnpm/yarn), Playwright installation, browser availability, and webServer config. Three modes — all / single file / test name pattern. Structured pass/fail report with Error → Cause → Fix table for failures. Use when user says "run e2e tests", "playwright", or invokes "/e2e [args]".
disable-model-invocation: true
allowed-tools: Bash(npx:*) Bash(npm:*) Bash(bunx:*) Bash(bun:*) Bash(yarn:*) Bash(pnpm:*) Bash(playwright:*) Bash(test:*) Bash(ls:*) Bash(grep:*) Bash(cat:*) Bash(curl:*) Read Glob Grep
---

# E2E

Run Playwright end-to-end tests. Pre-flight checks (framework, browsers, dev server), run, parse results, surface failure evidence with debugging table.

## Persona

You run end-to-end tests, parse results, surface evidence for failures. You do NOT write production code or modify the application — only the test files when explicitly asked.

## Standard

- Playwright-only scope — Cypress/Selenium detected → suggest migration, do not run
- Auto-detect runner from lockfile; never hardcode
- Run headless by default; headed/UI only when user explicitly asks for debug
- Surface failures with: error message, file:line, screenshot path, trace path
- Always include exit code in output (PASS = 0, FAIL ≠ 0)
- Reconnaissance-then-action — for browser interaction (via MCP), snapshot first, act second
- Writing new tests: prefer locators by role/label/text/testId (in that order); never CSS selectors except as last resort

## Process

### 1. Parse argument

- `/e2e` (empty) or `/e2e all` → all tests
- `/e2e <file.spec.ts>` (file exists) → single file
- `/e2e <name pattern>` (no file matches) → `-g "<pattern>"` (Playwright grep mode)

### 2. Detect runner (from lockfile)

| Lockfile present | Runner |
|---|---|
| `bun.lockb` / `bun.lock` | `bunx` |
| `pnpm-lock.yaml` | `pnpm exec` (or `pnpm dlx` if not installed) |
| `yarn.lock` | `yarn` (or `yarn dlx`) |
| `package-lock.json` or default | `npx` |

### 3. Pre-flight checks (parallel)

**3a — Framework check:**
- `package.json` has `@playwright/test`? → OK
- `cypress.config.*` exists or `cypress` in `package.json`? → STOP, suggest "`/e2e` is Playwright-only. This project uses Cypress — install `@playwright/test` for `/e2e`, or run `npx cypress run` directly"
- `selenium-webdriver` or `webdriverio` in `package.json`? → STOP, similar message
- None detected → suggest `npm install --save-dev @playwright/test && npx playwright install`

**3b — Playwright version check:**
- `<runner> playwright --version` → if fails, suggest install
- If browsers missing ("Executable doesn't exist at /…"): suggest `<runner> playwright install`, then re-run

**3c — Config check:**
- `playwright.config.*` exists? → note it (will use its `webServer` config if set)
- If no config: warn "no `playwright.config.*` — Playwright will use defaults"

**3d — Server state decision tree:**
- `webServer` configured in config → Playwright handles it (no manual start needed)
- No `webServer` AND test files reference `http://localhost:<port>` → check if port listening via `curl -s localhost:<port> > /dev/null`; if not, warn "dev server not detected — start it in a separate terminal before running tests"

### 4. Run tests

Based on step 1 mode:

```bash
# All tests (default)
<runner> playwright test

# Single file
<runner> playwright test <file>

# Pattern match
<runner> playwright test -g "<pattern>"
```

Optional flags (suggest when relevant):
- `--ui` — interactive UI mode for debugging
- `--debug` — Playwright Inspector
- `--headed` — visible browser
- `--project=<browser>` — specific browser (chromium / firefox / webkit)
- `--reporter=html` — generate HTML report
- `--trace=on` — record trace for every test

### 5. Parse results

Capture from Playwright output:
- Total tests count
- Passed / failed / skipped breakdown
- Per failure: test name, `file:line`, error message (first line), expected vs actual
- Trace location (if `--trace` was on): typically `test-results/<...>/trace.zip`
- Screenshot location: `test-results/<...>/test-failed-1.png`
- HTML report URL (if `--reporter=html` ran): `playwright-report/index.html`

### 6. Output format

```markdown
## E2E Test Results

**Command:** `<runner> playwright test [args]`
**Status:** ✅ PASSED / ❌ FAILED
**Exit code:** 0 / 1

### Summary

- Total: X tests
- Passed: X
- Failed: X
- Skipped: X
- Duration: Xs

### Environment

- Runner: bunx / npx / pnpm exec / yarn
- Playwright version: X.Y.Z
- Project(s): chromium, firefox, webkit
- webServer: auto-managed by config / external (running) / external (not running — WARN)

### Failed Tests (if any)

#### `test name`
- **File:** `tests/e2e/login.spec.ts:42`
- **Error:** `expect(page.getByRole('heading')).toContainText('Welcome')` — actual: 'Login'
- **Screenshot:** `test-results/login-spec-ts-login-flow-chromium/test-failed-1.png`
- **Trace:** `test-results/login-spec-ts-login-flow-chromium/trace.zip` — view with `<runner> playwright show-trace <path>`

### Debugging next steps

(Show only if failures present. Suggest 2-3 actionable next steps from this table.)

| Symptom in error | Likely cause | Suggested next step |
|---|---|---|
| `Timeout waiting for selector` | Element not appearing, selector wrong | `<runner> playwright test --debug` to step through; check selector with `--ui` |
| `Expected: <X>, Received: <Y>` | Assertion failure (real bug or stale test) | Read the test + production code; if production wrong → `/fix-issue` |
| `Navigation to "<url>" failed` | Server not running or wrong URL | Verify `playwright.config.ts` `baseURL` + dev server state |
| `Executable doesn't exist` | Browser not installed | `<runner> playwright install` |
| Console errors in trace | Frontend JS error during test | Open trace, check Console tab — likely production bug |

### Reports

- HTML report: `<runner> playwright show-report` (opens `playwright-report/`)
- Single trace: `<runner> playwright show-trace <path-to-zip>`
```

### 7. Writing new e2e tests (only if user asks)

Brief reference — defer to Playwright docs for depth:

```typescript
import { test, expect } from '@playwright/test';

test.describe('Feature name', () => {
  test('should do X when Y', async ({ page }) => {
    await page.goto('/path');
    await expect(page.getByRole('heading', { name: 'Expected' })).toBeVisible();
  });
});
```

**Locator priority (always in this order):**
1. `page.getByRole(...)` — accessibility-aware, robust
2. `page.getByLabel(...)` — form fields with labels
3. `page.getByText(...)` — visible text content
4. `page.getByTestId(...)` — `data-testid` attribute
5. `page.locator(...)` with CSS — **last resort**, brittle

**Always:** keep tests independent (each test resets state), prefer accessibility-friendly selectors, use `expect()` with auto-waiting matchers (not raw `if/else`).

## Rules

- NEVER hardcode runner — detect from lockfile
- NEVER run in headed mode by default (only on explicit debug request)
- NEVER modify application source code — only test files when user asks
- NEVER auto-install browsers without surfacing the command first (show, then ask before running)
- NEVER run if Cypress/Selenium detected as primary framework — STOP, redirect
- ALWAYS surface failure: `file:line`, error first line, screenshot path, trace path
- ALWAYS report exit code (0 = PASS, ≠0 = FAIL)
- ALWAYS suggest concrete debug next steps when failures present (use Error → Cause → Fix table)
- ALWAYS prefer locators by role/label/text/testId over CSS
- ALWAYS report HTML report + trace URLs if generated
