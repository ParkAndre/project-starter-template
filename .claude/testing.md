# Testing Requirements

## Mandatory Rules

1. Every feature/bugfix MUST have tests
2. All tests must pass before marking code as done
3. Coverage: 80% minimum for new code, 90%+ for critical paths (auth, payments)
4. **Exception:** Trivial changes (one-line fix, config change, typo) may skip full TDD ceremony

---

## Issue -> Test -> Code Flow

Every acceptance criteria (AC) in an issue becomes a test:

```
Issue #42: User can reset password
|- AC1: User receives reset email -> test_reset_email_sent()
|- AC2: Link expires after 1 hour -> test_reset_link_expiration()
|- AC3: Password must be 8+ chars -> test_password_validation()
```

Always write tests from acceptance criteria before implementation.

---

## TDD Workflow (Red-Green-Refactor)

1. **RED** — Write test from AC. Run it. It MUST fail (if it passes, the test is fake — rewrite it)
2. **GREEN** — Write minimal code to make the test pass
3. **REFACTOR** — Improve code quality while keeping tests green

---

## Test Validation

### The "Comment-Out Test"
Replace implementation with a broken stub. Test MUST fail. If test still passes, it tests nothing real.

### Assertion Quality
```typescript
// BAD - No real assertion
expect(true).toBe(true);

// BAD - Tests hardcoded value
const result = { success: true };
expect(result.success).toBe(true);

// GOOD - Tests actual behavior
const result = await login('user@test.com', 'ValidPass123');
expect(result.success).toBe(true);
expect(result.token).toBeDefined();
```

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
| Utility functions | 80%+ |
| UI components | 70%+ |

Coverage is not a goal in itself — 60% with real tests beats 100% with fake tests. Focus on testing **behavior**, not lines of code.

---

## Edge Cases (ALWAYS test)

- Empty/null/undefined inputs, invalid types, boundary values (min/max, 0, negative)
- SQL injection and XSS attempts in input
- Network failures, database errors, auth failures, rate limiting
- Race conditions in concurrent operations

---

## Database Testing

- Use transactions for cleanup (rollback after each test)
- Seed data consistently with fixtures or factories
- Test constraints (unique, foreign key, NOT NULL)
- Test migrations both up and down

---

## Definition of Done

1. Each AC has a corresponding test
2. Tests were written BEFORE implementation (TDD)
3. Tests failed initially (Red), then passed (Green)
4. Edge cases and error conditions covered
5. Tests are real (Comment-Out Test passes)
6. All tests pass
7. Coverage meets threshold (80%+ new code)
8. No regressions in existing tests

---

## Handling Failures

- Investigate root cause — is it code or test issue?
- Fix the root cause, re-run and verify
- If existing tests fail after your changes: fix the regression before merging
- Maintain test integrity — do not delete or weaken tests to force green status

---

## Related Skills

- **`/tdd <AC>`** — runtime TDD loop (RED → Verify RED → GREEN → REFACTOR), enforces Iron Law ("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST")
- **`/fix-issue <n>`** — end-to-end issue implementation with TDD per AC, status discipline, squash-merge or draft-PR
- **`/verify [mode]`** — pre-PR quality gate: tests + lint + typecheck + build + safety scans
- **`/e2e [args]`** — run Playwright end-to-end tests with failure debugging table

This document is the standards reference; skills above are the runtime implementations.
