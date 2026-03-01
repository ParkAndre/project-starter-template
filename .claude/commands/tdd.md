# TDD

Guided Test-Driven Development. Enforces RED-GREEN-REFACTOR cycle one acceptance criterion at a time.

## Usage

`/tdd <issue-number or description>` — start TDD for a feature or fix

## Process

1. **Get acceptance criteria (AC):**
   - If issue number given: read issue with `gh issue view <number>`
   - If description given: break it into testable acceptance criteria
   - List all ACs numbered. Ask user to confirm or adjust.

2. **For EACH AC, follow this strict cycle:**

   ### RED Phase
   - Write ONE test that captures the AC behavior
   - Test MUST assert real behavior (no `expect(true).toBe(true)`)
   - Run the test — it MUST FAIL
   - If it passes without implementation: the test is fake. Rewrite it.
   - Show the user: "RED: test fails as expected"

   ### GREEN Phase
   - Write the MINIMUM code to make the test pass
   - Do NOT write extra functionality
   - Do NOT handle edge cases not in this AC
   - Run the test — it MUST PASS
   - Run ALL tests — no regressions
   - Show the user: "GREEN: test passes"

   ### REFACTOR Phase
   - Ask: "Any refactoring needed before moving to next AC?"
   - If yes: refactor while keeping all tests green
   - If no: move to next AC

3. **After all ACs are done:**
   - Run full test suite
   - Report coverage if available
   - List what was implemented and tested

## Rules

- NEVER write implementation before the test
- NEVER skip the RED phase (test must fail first)
- NEVER write more code than needed to pass the current test
- ONE AC at a time — do not batch
- If user says "just implement it": explain why TDD order matters, but respect their choice
- Use project's actual test runner (detect from config files)
- Follow test patterns from `.claude/testing.md`
- Each test must fail if implementation is removed (the "comment-out test")
