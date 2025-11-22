# Testing Requirements

> **Note:** These testing guidelines are technology-agnostic. Apply these principles using your testing framework of choice (Jest, Vitest, pytest, PHPUnit, Go testing, etc.).

---

## Testing Workflow Rules for AI Assistant

You MUST follow these testing rules for every coding task in this repository.

### 1. General Principles

1. **Tests are mandatory.**
   For every issue/feature/bugfix you handle, you MUST:
   - plan tests,
   - write or update tests,
   - and ensure tests are run before claiming the work is done.

2. **Code is never "done" without tests.**
   You may NOT mark a task as complete unless:
   - appropriate tests exist for the new/changed behavior, AND
   - all relevant tests pass (new + existing).

3. **Coverage requirements.**
   - Minimum **80% code coverage** for new code
   - Critical paths (authentication, payments, data validation) require **90%+ coverage**
   - Use coverage reports to identify untested code paths

---

### 2. Test-First Thinking

Before writing or changing any code, you MUST:

1. Extract the requirements from the issue description.
2. Produce a short **Test Plan** section in your reply, for example:

   ```
   Test Plan:
   - Test case 1: [describe normal behavior]
   - Test case 2: [describe edge case]
   - Test case 3: [describe failure/recovery scenario]
   - Regression tests: [what existing behavior must still work]
   ```

3. Only after writing the **Test Plan** may you proceed to:
   - write or update tests,
   - then implement or modify the actual code.

If requirements are unclear, you should refine the Test Plan and, if needed, ask for clarification.

---

### 3. Writing Real Tests (No Fake "Green")

Your tests MUST reflect reality and MUST NOT be designed to "cheat" or trivially pass.

1. **No fake green tests.**
   You MUST NOT:
   - write tests that only assert constants or always-true conditions (e.g. `expect(true).toBe(true)`),
   - assert values that you manually set in the test without exercising the real logic (e.g. `const result = { success: true }; expect(result.success).toBe(true);`),
   - over-mock in a way that bypasses the actual behavior being tested.

2. **Mocks/stubs must be meaningful.**
   - You may mock **external dependencies** (network calls, databases, third-party services), but:
     - the **system under test** MUST still execute its real logic,
     - the test MUST be capable of failing if the implementation is wrong.
   - Do NOT mock the very function or method you are trying to test.

3. **Tests must be able to fail for real bugs.**
   - Always design tests so that:
     - if there is a real bug in the behavior they cover, the tests will fail,
     - if logic changes unintentionally, tests detect it.
   - If a test would still pass even when the implementation is clearly broken, the test is not acceptable and MUST be improved.

4. **Clear intent.**
   - Test names and descriptions must clearly state:
     - WHAT behavior is being tested,
     - under WHICH conditions,
     - WHAT the expected outcome is.

**Example of BAD test (fake green):**
```javascript
// ❌ BAD - This doesn't test real behavior
test('user login works', () => {
  const result = { success: true };
  expect(result.success).toBe(true);
});
```

**Example of GOOD test:**
```javascript
// ✅ GOOD - This tests actual login logic
test('user login succeeds with valid credentials', async () => {
  const result = await login('user@example.com', 'correctPassword');
  expect(result.success).toBe(true);
  expect(result.user).toBeDefined();
  expect(result.token).toBeDefined();
});
```

---

### 4. Test Types and When to Use Them

#### Unit Tests
- **Purpose:** Test individual functions/methods in isolation
- **When:** Every business logic function, utility, validator
- **Characteristics:**
  - Fast (< 100ms each)
  - No external dependencies (mock database, network, file system)
  - Test one thing at a time
  - Should be the majority of your tests (~70%)

**Example:**
```javascript
test('calculateTotal correctly sums item prices', () => {
  const items = [{ price: 10 }, { price: 20 }, { price: 5 }];
  expect(calculateTotal(items)).toBe(35);
});
```

#### Integration Tests
- **Purpose:** Test how multiple components work together
- **When:** API endpoints, database operations, service interactions
- **Characteristics:**
  - Slower (< 1s each)
  - May use test database or mock external services
  - Test realistic scenarios
  - Should be ~20-25% of your tests

**Example:**
```javascript
test('POST /users creates user in database', async () => {
  const response = await request(app)
    .post('/users')
    .send({ email: 'test@example.com', password: 'secure123' });

  expect(response.status).toBe(201);

  const user = await db.users.findByEmail('test@example.com');
  expect(user).toBeDefined();
  expect(user.password).not.toBe('secure123'); // Should be hashed
});
```

#### End-to-End (E2E) Tests
- **Purpose:** Test complete user workflows
- **When:** Critical user journeys (signup → login → purchase)
- **Characteristics:**
  - Slowest (several seconds)
  - Test entire application stack
  - Fewer tests, high value (~5-10% of tests)

**Example:**
```javascript
test('user can sign up, login, and view dashboard', async () => {
  // Signup
  await page.goto('/signup');
  await page.fill('#email', 'newuser@example.com');
  await page.fill('#password', 'securePass123');
  await page.click('button[type="submit"]');

  // Login
  await page.goto('/login');
  await page.fill('#email', 'newuser@example.com');
  await page.fill('#password', 'securePass123');
  await page.click('button[type="submit"]');

  // Dashboard
  await expect(page.locator('h1')).toContainText('Dashboard');
  await expect(page.locator('.welcome-message')).toContainText('newuser@example.com');
});
```

#### Performance/Load Tests
- **Purpose:** Verify system handles expected load
- **When:** APIs with high traffic, batch processing, real-time features
- **Requirements:**
  - Test with realistic data volumes
  - Verify response times under load
  - Check for memory leaks
  - Test concurrent user scenarios

**Example scenarios:**
- API endpoint responds in < 200ms under 100 concurrent requests
- Batch job processes 10,000 records in < 30 seconds
- WebSocket handles 1,000 concurrent connections

**Tools:** k6, Artillery, JMeter, Locust

---

### 5. Test Location and Conventions

Use the project's testing conventions:

- **Test folder:** `[YOUR_TEST_FOLDER]`
  (e.g. `tests/`, `__tests__/`, `src/tests/`, etc.)
- **Test framework:** `[YOUR_TEST_FRAMEWORK]`
  (e.g. Jest, Vitest, Pytest, PHPUnit, Go testing, etc.)
- **File naming pattern:** `[YOUR_TEST_FILENAME_PATTERN]`
  (e.g. `*.test.js`, `*_test.py`, `Test*.java`, etc.)
- **Coverage tool:** `[YOUR_COVERAGE_TOOL]`
  (e.g. `npm run test:coverage`, `pytest --cov`, `go test -cover`, etc.)

When generating or modifying tests, you MUST follow these conventions.

---

### 6. Test Coverage Requirements

**Minimum coverage thresholds:**

| Code Type | Minimum Coverage | Notes |
|-----------|-----------------|-------|
| **New code** | 80% | All new functions/methods must be tested |
| **Critical paths** | 90%+ | Auth, payments, data validation, security |
| **Utility functions** | 95%+ | Pure functions, helpers, formatters |
| **UI components** | 70%+ | Focus on logic, not just rendering |
| **Configuration** | N/A | May skip static config files |

**How to check coverage:**

```bash
# Run tests with coverage report
[YOUR_COVERAGE_COMMAND]

# Examples:
npm run test:coverage        # Node.js
pytest --cov=src --cov-report=html  # Python
go test -cover ./...         # Go
vendor/bin/phpunit --coverage-html coverage  # PHP
```

**Coverage is NOT a goal in itself:**
- 100% coverage with fake tests is worthless
- 60% coverage with real, meaningful tests is better
- Focus on testing **behavior**, not lines of code

---

### 7. Implementation After Tests

After defining the Test Plan and test cases:

1. **Write or update tests** in `[YOUR_TEST_FOLDER]` according to the plan.
2. **Implement or adjust the application code** so that:
   - the new behavior is implemented,
   - existing behavior required by the project is preserved.

Keep changes as small and focused as possible.

**Recommended workflow:**
1. Write Test Plan
2. Write failing tests (Red)
3. Implement minimal code to pass tests (Green)
4. Refactor while keeping tests green (Refactor)
5. Verify coverage meets threshold
6. Commit

---

### 8. Running Tests Before Completion

Before saying that a task/issue is complete, you MUST:

1. Show the exact command to run all tests, for example:
   - `[YOUR_TEST_COMMAND]` (e.g. `npm test`, `pnpm test`, `pytest`, `phpunit`, etc.)
2. If you can run tests in the environment:
   - run them, show the output,
   - confirm whether they passed or failed.
3. If you cannot run tests yourself:
   - explicitly instruct the user to run `[YOUR_TEST_COMMAND]`,
   - clearly state that the work is **not fully verified** until tests are confirmed passing.

You may NOT claim the work is fully "done" or "successfully implemented" while:
- tests are failing, OR
- tests have not been run, OR
- only fake/trivial tests exist that don't check real behavior, OR
- coverage is below minimum threshold (80% for new code).

---

### 9. Handling Failing Tests

If any test fails (new or existing):

1. Investigate the failure:
   - determine whether the problem is in the implementation or in the test.
2. Fix the underlying cause:
   - if the implementation is wrong, fix the code,
   - if the test was incorrectly written, correct the test so that it reflects the intended real behavior.
3. Re-run tests and verify they pass legitimately.

You may NOT simply delete or weaken tests to force a "green" status unless:
- there is a clear, documented reason why the tested behavior is no longer valid,
- and you explain this rationale explicitly.

**If existing tests fail after your changes:**
- This is a **regression** and MUST be fixed before merging
- Either fix your code to maintain backward compatibility
- OR update tests with clear explanation of intentional breaking change

---

### 10. Pre-commit Hooks (Automated Quality Gates)

**Highly recommended:** Set up pre-commit hooks to automatically run tests before every commit.

#### Setup Examples:

**Node.js (using Husky + lint-staged):**

```bash
# Install
npm install --save-dev husky lint-staged

# Initialize husky
npx husky install

# Add pre-commit hook
npx husky add .husky/pre-commit "npx lint-staged"
```

**package.json:**
```json
{
  "lint-staged": {
    "*.{js,ts,jsx,tsx}": [
      "eslint --fix",
      "prettier --write",
      "jest --bail --findRelatedTests"
    ]
  }
}
```

**Python (using pre-commit framework):**

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: pytest
        name: pytest
        entry: pytest
        language: system
        pass_filenames: false
        always_run: true
```

**Benefits:**
- ✅ Prevents committing code without tests
- ✅ Catches failures early (before push)
- ✅ Enforces code quality standards
- ✅ Reduces CI/CD failures

---

### 11. Edge Cases and Error Conditions

ALWAYS test these scenarios:

#### Input Validation
- Empty inputs (`''`, `null`, `undefined`, `[]`, `{}`)
- Invalid data types (string when number expected)
- Boundary values (min/max, 0, negative numbers)
- Special characters in strings
- Very long inputs (test limits)
- SQL injection attempts (for database queries)
- XSS attempts (for user-generated content)

#### Error Handling
- Network failures (timeout, connection refused)
- Database errors (constraint violations, connection lost)
- Authentication failures (invalid token, expired session)
- Authorization failures (accessing forbidden resources)
- Rate limiting (too many requests)
- File system errors (permission denied, disk full)

#### Concurrent Operations
- Race conditions (simultaneous updates)
- Deadlocks (database transactions)
- Resource exhaustion (memory, connections)

#### Example:
```javascript
describe('User registration', () => {
  test('succeeds with valid data', async () => { /* ... */ });
  test('fails with empty email', async () => { /* ... */ });
  test('fails with invalid email format', async () => { /* ... */ });
  test('fails with weak password', async () => { /* ... */ });
  test('fails when email already exists', async () => { /* ... */ });
  test('fails when database is unavailable', async () => { /* ... */ });
  test('prevents SQL injection in email field', async () => { /* ... */ });
});
```

---

### 12. Database Testing Best Practices

When testing code that interacts with databases:

1. **Use transactions for cleanup:**
   - Start transaction before each test
   - Rollback after test completes
   - Keeps test database clean

2. **Seed test data consistently:**
   - Use fixtures or factory functions
   - Reset database to known state before tests
   - Don't rely on test execution order

3. **Test database constraints:**
   - Unique constraints
   - Foreign key constraints
   - NOT NULL constraints
   - Check constraints

4. **Test migrations:**
   - Up migrations work correctly
   - Down migrations (rollback) work correctly
   - Migrations are idempotent (can run multiple times)

**Example (Node.js with Prisma):**
```javascript
beforeEach(async () => {
  await db.$transaction([
    db.user.deleteMany(),
    db.post.deleteMany(),
  ]);
});

test('cascade delete removes user posts', async () => {
  const user = await db.user.create({
    data: { email: 'test@example.com' }
  });

  await db.post.create({
    data: { title: 'Test', userId: user.id }
  });

  await db.user.delete({ where: { id: user.id } });

  const posts = await db.post.findMany({ where: { userId: user.id } });
  expect(posts).toHaveLength(0);
});
```

---

### 13. Definition of "Done"

You may only say that a task/issue is **done** when ALL of the following hold:

1. ✅ The requested behavior from the issue is implemented.
2. ✅ A **Test Plan** was created and documented.
3. ✅ A reasonable set of tests is written or updated to cover:
   - the new behavior,
   - important edge cases,
   - relevant error conditions,
   - regressions.
4. ✅ Tests include appropriate mix of:
   - Unit tests (isolated logic)
   - Integration tests (component interactions)
   - E2E tests (if user-facing feature)
5. ✅ Tests are **real** (not trivial or fake) and would fail if the code were incorrect.
6. ✅ All relevant tests pass using `[YOUR_TEST_COMMAND]`.
7. ✅ Code coverage meets minimum threshold (80% for new code).
8. ✅ No known regressions are left unaddressed.
9. ✅ Pre-commit hooks pass (if configured).

Always prioritize:
- ✅ Correctness over shortcuts
- ✅ Meaningful tests over superficial "green" status
- ✅ Long-term maintainability and regression safety
- ✅ Real behavior testing over code coverage percentage

---

## Quick Reference Checklist

Before marking any task as complete, verify:

- [ ] Test Plan documented
- [ ] Unit tests written for new functions
- [ ] Integration tests for new features
- [ ] Edge cases tested (empty, null, invalid, boundary values)
- [ ] Error conditions tested (network, database, auth failures)
- [ ] All tests pass (`[YOUR_TEST_COMMAND]`)
- [ ] Coverage ≥ 80% for new code (`[YOUR_COVERAGE_COMMAND]`)
- [ ] No fake/trivial tests
- [ ] Existing tests still pass (no regressions)
- [ ] Pre-commit hooks configured and passing

**If ANY checkbox is unchecked, the task is NOT done.**
