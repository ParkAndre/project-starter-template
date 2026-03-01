---
description: Run Playwright end-to-end tests
argument-hint: [test-file, test-name, or "all"]
allowed-tools: [Bash(npx:*), Bash(npm:*), Bash(bunx:*), Bash(bun:*), Bash(yarn:*), Bash(pnpm:*), Read, Glob]
---

# Run E2E Tests (Playwright)

Run end-to-end tests using Playwright: $ARGUMENTS

## Detect Package Runner

Determine the package runner by checking for lock files:
- `bun.lockb` / `bun.lock` → `bunx`
- `pnpm-lock.yaml` → `pnpm exec` or `pnpm dlx`
- `yarn.lock` → `yarn` or `yarn dlx`
- `package-lock.json` or default → `npx`

Use the detected runner (`<runner>`) for all commands below.

## Determine What to Run

1. **If $ARGUMENTS is empty or "all"**:
   ```bash
   <runner> playwright test
   ```

2. **If $ARGUMENTS is a file path**:
   ```bash
   <runner> playwright test $ARGUMENTS
   ```

3. **If $ARGUMENTS is a test name pattern**:
   ```bash
   <runner> playwright test -g "$ARGUMENTS"
   ```

## Before Running

1. **Check Playwright is installed**:
   ```bash
   <runner> playwright --version
   ```
   If not installed, suggest installing `@playwright/test` with the project's package manager.

2. **Check if dev server needed**:
   - Look for `playwright.config.ts` webServer config
   - If configured, Playwright handles it
   - If not, may need dev server running in background

## Running Tests

### Default (headless):
```bash
<runner> playwright test
```

### With UI (debugging):
```bash
<runner> playwright test --ui
```

### Specific browser:
```bash
<runner> playwright test --project=chromium
```

### Show report after:
```bash
<runner> playwright show-report
```

## On Failure

1. **Show the error message clearly**

2. **Check common issues**:
   - Selector not found → element may have changed
   - Timeout → page slow or element never appears
   - Navigation error → URL may be wrong

3. **Suggest debugging**:
   ```bash
   <runner> playwright test --debug
   ```

4. **Offer to show trace**:
   ```bash
   <runner> playwright show-trace trace.zip
   ```

## Output Format

```
## E2E Test Results

**Command**: `<runner> playwright test [args]`
**Status**: ✅ Passed / ❌ Failed

### Summary
- Total: X tests
- Passed: X
- Failed: X
- Skipped: X

### Failed Tests (if any)
1. `test name` - Error message
   - File: path/to/test.ts:line
   - Suggestion: [how to fix]
```

## Writing New E2E Tests

If user asks to create e2e test:

1. **Follow Playwright patterns**:
   ```typescript
   import { test, expect } from '@playwright/test';

   test.describe('Feature Name', () => {
     test('should do something', async ({ page }) => {
       await page.goto('/path');
       await expect(page.getByRole('heading')).toContainText('Expected');
     });
   });
   ```

2. **Use recommended selectors** (priority order):
   - `getByRole()` - accessibility roles
   - `getByLabel()` - form labels
   - `getByText()` - visible text
   - `getByTestId()` - data-testid attribute
   - Avoid: CSS selectors, XPath

3. **Keep tests independent** - each test should work alone
