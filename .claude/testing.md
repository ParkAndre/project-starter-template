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

## Test-First Workflow

Before writing code, you MUST:

1. Extract requirements from issue
2. Write **Test Plan** in your reply:
   ```
   Test Plan:
   - Normal behavior: [what should work]
   - Edge case: [boundary conditions]
   - Error scenario: [failure handling]
   - Regression tests: [existing behavior that must still work]
   ```
3. Write tests BEFORE implementation
4. Follow Red-Green-Refactor:
   - Write failing test (Red)
   - Implement minimal code to pass (Green)
   - Refactor while keeping tests green

---

## Writing Real Tests (No Fake Green)

**You MUST NOT:**
- Write tests that assert constants: `expect(true).toBe(true)`
- Assert manually set values without real logic
- Over-mock to bypass actual behavior

**Example of BAD test:**
```javascript
// ❌ BAD - Doesn't test real behavior
test('user login works', () => {
  const result = { success: true };
  expect(result.success).toBe(true);
});
```

**Example of GOOD test:**
```javascript
// ✅ GOOD - Tests actual login logic
test('user login succeeds with valid credentials', async () => {
  const result = await login('user@example.com', 'correctPassword');
  expect(result.success).toBe(true);
  expect(result.user).toBeDefined();
  expect(result.token).toBeDefined();
});
```

**Mocks must be meaningful:**
- Mock external dependencies (network, database, third-party)
- System under test MUST execute real logic
- Test MUST fail if implementation is wrong
- NEVER mock the function you're testing

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

1. ✅ Requested behavior implemented
2. ✅ Test Plan documented (including regression tests)
3. ✅ Tests cover: new behavior, edge cases, error conditions, regressions
4. ✅ Appropriate test mix (unit, integration, E2E)
5. ✅ Tests are real (would fail if code broken)
6. ✅ All tests pass: `[YOUR_TEST_COMMAND]`
7. ✅ Coverage meets threshold (80%+ new code)
8. ✅ No regressions

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
# Replace with your project commands
[YOUR_TEST_COMMAND]        # Run tests
[YOUR_COVERAGE_COMMAND]    # Run with coverage
```

---

## Pre-commit Hooks (Recommended)

Set up hooks to run tests before every commit:

**Node.js (Husky):**
```bash
npm install --save-dev husky lint-staged
npx husky install
npx husky add .husky/pre-commit "npx lint-staged"
```

**Benefits:**
- Prevents committing without tests
- Catches failures before push
- Enforces quality standards
