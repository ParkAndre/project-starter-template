# Testing Requirements

## Why We Test

Tests ensure that:
1. **New behavior works** - Feature does what it should
2. **Behavior persists** - Future changes don't accidentally break it
3. **No regressions** - Changes elsewhere don't break existing functionality

---

## Mandatory Rules

1. **Tests are mandatory** - Every feature/bugfix MUST have tests
2. **Code is never "done" without tests** - All tests must pass before completion
3. **Coverage:** 80% minimum for new code, 90%+ for critical paths (auth, payments)

---

## Issue → Test → Code Flow

Every acceptance criteria (AC) in an issue becomes a test:

```
Issue #42: User can reset password
├── AC1: User receives reset email → test_reset_email_sent()
├── AC2: Link expires after 1 hour → test_reset_link_expiration()
└── AC3: Password must be 8+ chars → test_password_validation()
```

**NEVER write code without a corresponding test from an AC.**

---

## TDD Workflow (Red-Green-Refactor)

### Step 1: Write Test First

From the issue AC, write the test:

```typescript
// ❌ Test does not exist yet
// ✅ Write it BEFORE the implementation

test('reset link expires after 1 hour', async () => {
  const link = await createResetLink('user@test.com');

  // Simulate 61 minutes passing
  vi.advanceTimersByTime(61 * 60 * 1000);

  const result = await validateResetLink(link.token);
  expect(result.valid).toBe(false);
  expect(result.error).toBe('LINK_EXPIRED');
});
```

### Step 2: Run Test → Must Be RED

```bash
# Run with your project's test runner:
# npm test / bun test / pytest / vendor/bin/phpunit / go test / cargo test
[YOUR_TEST_COMMAND] reset-link.test.ts
```

**Expected:** Test FAILS because implementation doesn't exist.

**If test passes without implementation → TEST IS FAKE. Rewrite it.**

### Step 3: Write Minimal Code

Write just enough code to make the test pass:

```typescript
// Implementation in reset-link.ts
export async function validateResetLink(token: string) {
  const link = await db.resetLinks.findByToken(token);

  const hourAgo = Date.now() - (60 * 60 * 1000);
  if (link.createdAt < hourAgo) {
    return { valid: false, error: 'LINK_EXPIRED' };
  }

  return { valid: true };
}
```

### Step 4: Run Test → Must Be GREEN

```bash
[YOUR_TEST_COMMAND] reset-link.test.ts
```

**Expected:** Test PASSES.

### Step 5: Refactor (Optional)

Improve code quality while keeping tests green.

---

## Test Validation Checklist

Before marking tests as complete, verify:

### 1. The "Comment-Out Test"

Comment out the implementation → test MUST fail.

```typescript
// export async function validateResetLink(token) { ... }
export async function validateResetLink(token) {
  return { valid: true }; // Broken implementation
}
```

If test still passes → test is fake.

### 2. Assertion Quality

Each test must have **meaningful assertions**:

```typescript
// ❌ BAD - No real assertion
test('login works', () => {
  expect(true).toBe(true);
});

// ❌ BAD - Tests a hardcoded value
test('login works', () => {
  const result = { success: true };
  expect(result.success).toBe(true);
});

// ✅ GOOD - Tests actual behavior
test('login returns token for valid credentials', async () => {
  const result = await login('user@test.com', 'ValidPass123');
  expect(result.success).toBe(true);
  expect(result.token).toBeDefined();
  expect(result.token.length).toBeGreaterThan(20);
});
```

### 3. Edge Cases Covered

For each AC, also test:
- Invalid input
- Boundary values
- Error conditions

---

## Test Types

| Type | % | Use for | Speed |
|------|---|---------|-------|
| **Unit** | ~70% | Functions, utilities, validators | < 100ms |
| **Integration** | ~20% | API endpoints, DB operations | < 1s |
| **E2E** | ~10% | Critical user journeys | seconds |

---

## Coverage Thresholds

| Code Type | Minimum |
|-----------|---------|
| New code | 80% |
| Critical paths (auth, payments, security) | 90%+ |
| Utility functions | 95%+ |
| UI components | 70%+ |

**Coverage is NOT a goal in itself:**
- 100% coverage with fake tests is worthless
- 60% coverage with real tests is better
- Focus on testing **behavior**, not lines of code

---

## Edge Cases (ALWAYS test)

**Input validation:**
- Empty/null/undefined inputs
- Invalid data types
- Boundary values (min/max, 0, negative)
- Very long inputs
- SQL injection attempts
- XSS attempts

**Error handling:**
- Network failures (timeout, connection refused)
- Database errors (constraints, connection lost)
- Auth failures (invalid token, expired session)
- Rate limiting

**Concurrent operations:**
- Race conditions
- Resource exhaustion

---

## Database Testing

1. **Use transactions for cleanup** - Rollback after each test
2. **Seed data consistently** - Use fixtures or factories
3. **Test constraints** - Unique, foreign key, NOT NULL
4. **Test migrations** - Both up and down

---

## Definition of Done

Task is complete ONLY when ALL true:

1. ✅ Each AC has a corresponding test
2. ✅ Tests were written BEFORE implementation
3. ✅ Tests failed initially (Red), then passed (Green)
4. ✅ Tests cover edge cases and error conditions
5. ✅ Tests are real (would fail if code broken)
6. ✅ All tests pass: `[YOUR_TEST_COMMAND]`
7. ✅ Coverage meets threshold (80%+ new code)
8. ✅ No regressions in existing tests

---

## Handling Failures

If tests fail:
1. Investigate - is it code or test issue?
2. Fix the root cause
3. Re-run and verify pass

**If existing tests fail after your changes:**
- This is a **regression** - MUST be fixed before merging
- Either fix code to maintain compatibility
- OR update tests with clear explanation of intentional breaking change

NEVER delete/weaken tests to force green status.

---

## Commands

```bash
# [YOUR_TEST_COMMAND] - Replace with your actual test commands

# Node.js (Bun):
# bun test                          # Run all tests
# bun test path/to/file.test.ts    # Run specific file
# bun test --coverage               # With coverage
# bunx playwright test              # E2E tests

# Node.js (npm/Vitest/Jest):
# npm test                          # Run all tests
# npx vitest path/to/file.test.ts  # Run specific file
# npx vitest --coverage             # With coverage
# npx playwright test               # E2E tests

# Python:
# pytest                            # Run all tests
# pytest path/to/test_file.py      # Run specific file
# pytest --cov=src                  # With coverage
# pytest -x                         # Stop on first failure

# PHP:
# vendor/bin/phpunit                # Run all tests
# vendor/bin/phpunit tests/Feature  # Run specific directory
# vendor/bin/phpunit --coverage-text # With coverage

# Go:
# go test ./...                     # Run all tests
# go test ./pkg/...                 # Run specific package
# go test -cover ./...              # With coverage
# go test -race ./...               # With race detector

# Rust:
# cargo test                        # Run all tests
# cargo test test_name              # Run specific test
# cargo tarpaulin                   # With coverage (requires tarpaulin)
```

---

## Pre-commit Hooks

Tests run automatically before every commit using git hooks:

**Node.js (Husky):**
```bash
# Install and initialize
npm install -D husky    # or: bun add -d husky
npx husky init          # or: bunx husky init

# Add pre-commit hook
cp .husky/pre-commit.example .husky/pre-commit
chmod +x .husky/pre-commit
```

**Python (pre-commit):**
```bash
pip install pre-commit
pre-commit install
# Configure in .pre-commit-config.yaml
```

**General (git hooks):**
```bash
# Create hook directly
echo '#!/bin/sh\n[YOUR_TEST_COMMAND] --bail' > .git/hooks/pre-commit
chmod +x .git/hooks/pre-commit
```

**Benefits:**
- Prevents committing without tests
- Catches failures before push
- Enforces quality standards

See `.husky/pre-commit.example` for full example.
