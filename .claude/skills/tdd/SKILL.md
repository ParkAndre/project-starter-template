---
name: tdd
description: Standalone Test-Driven Development loop with RED-GREEN-REFACTOR enforcement and verify-RED gate. Takes AC description (or issue number), produces test+implementation pairs. Use /fix-issue for end-to-end (issue→branch→TDD→merge); use /tdd for standalone TDD work without issue/branch orchestration. Use when user says "tdd", "test first", or invokes "/tdd <AC>".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(npm:*) Bash(npx:*) Bash(bun:*) Bash(bunx:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(pytest:*) Bash(python3:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Write Edit Glob Grep
---

# TDD

Standalone Test-Driven Development loop. Takes an AC description (or issue number), produces test + implementation pairs via strict RED → Verify RED → GREEN → REFACTOR cycle. One AC at a time.

## Iron Law

**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

## Persona

Senior developer who writes tests first, every time. Calm, disciplined, allergic to "I'll test it after". Refuses to write production code until a failing test demands it.

## Standard

- Iron Law: production code is written only to make a failing test pass.
- One AC at a time — no batching, no parallel ACs.
- RED-gate: the test must fail for the **right reason** (intended behavior gap), not syntax error or missing import.
- GREEN: minimal code to pass — no edge cases beyond current AC, no anticipatory abstractions.
- "Delete means delete" — if pre-test code exists for the current AC, delete it and restart from RED.
- All tests pass after every phase (no regressions).
- Real assertions only (Comment-Out Test per `.claude/testing.md` — test must fail if production code is removed).
- Optional checkpoint commits per phase — `test:` (RED), `fix:`/`feat:` (GREEN), `refactor:` (REFACTOR).

**Scope distinction:**
- `/tdd <AC>` — standalone TDD loop. Does NOT create branches or commits (except opt-in checkpoints). Does NOT merge.
- `/fix-issue <n>` — end-to-end: issue → branch → TDD → verify → merge/PR.

Use `/tdd` for proof-of-concept, experiments, non-issue work. Use `/fix-issue` for tracked work.

## Process

### 1. Parse argument

- `<integer>` → issue number → `gh issue view <n> --json title,body` (extract ACs in step 3)
- `<description string>` → use directly as AC source
- Empty → ask user: "What feature or fix are we TDD'ing?"

### 2. Detect test runner (parallel reads of config files)

- `package.json` scripts.test → `npm test` / `bun test` / `pnpm test` / `yarn test` (detect package manager from lockfile)
- `pytest.ini`, `pyproject.toml`, `setup.cfg` → `pytest`
- `phpunit.xml` → `vendor/bin/phpunit`
- `go.mod` → `go test ./...`
- `Cargo.toml` → `cargo test`
- `Makefile` test target → `make test`
- None detected → ask user: "What test command should I run? Or abort."

### 3. Parse ACs from source

Recognise patterns:
- **Checklist:** `- [ ] <criterion>` or `- [x] <criterion>`
- **Heading:** `## Acceptance Criteria`, `## AC`, `## Definition of Done`
- **Inline:** `AC1:`, `AC2:`, `AC3:`
- **Gherkin:** `Given ... When ... Then ...`
- **User Journey:** `As a <role>, I want <action>, so that <benefit>` (treat as one AC unless decomposable)

If unable to parse: ask user to confirm or edit the candidate AC list.

List ACs numbered. Present to user for confirmation before proceeding.

### 4. Plan sequence

- Order: foundation first (e.g. AC1 schema → AC2 API → AC3 UI)
- Note dependencies (AC2 depends on AC1)
- `TaskCreate` one task per AC: subject = "AC N: <short desc>"

### 5. Begin TDD loop

For each AC in sequence, run the 5-phase loop below. Mark task `in_progress` at RED start, `completed` after GREEN passes.

---

## TDD Loop (per AC)

### Phase RED — Write failing test

1. Identify test file (existing → append; new feature → create alongside source per project convention)
2. Write ONE test asserting the AC behavior
3. The test must:
   - Make a real assertion (no `expect(true).toBe(true)`)
   - Test observable behavior, not implementation detail
   - Be the smallest test that captures the AC

### Phase Verify RED — gate before GREEN

1. Run the test → capture exit code + stderr
2. The test **must FAIL** with one of:
   - **Runtime RED** (dynamic languages / runtime failure): assertion fails, function returns wrong value, exception thrown matching expectation
   - **Compile-time RED** (typed languages — TS, mypy, Go): type/compile error indicating a missing function/method/type the test expects to exist
3. The test **must NOT fail** with:
   - Syntax error in test code → fix the test
   - Missing test framework import → fix the test
   - Test file not found by runner → fix path/config
4. If the test PASSES (false negative): **the test is fake** — rewrite with a more specific assertion or different input
5. Announce: `RED ✓ — test fails for the right reason: <error message>`
6. (Optional) checkpoint commit: `test: add failing test for <AC>`

### Phase GREEN — Minimal implementation

1. Write the SMALLEST production code that makes this test pass
2. Don't:
   - Add edge cases not in this AC
   - Anticipate future ACs
   - Add abstractions or helpers without 2+ call sites
   - Refactor while implementing
3. Run target test → must PASS
4. Run **full test suite** → no regressions
5. If a regression appears: STOP, fix the regression first (new code must not break old behavior)
6. Announce: `GREEN ✓ — N/M tests passing`
7. (Optional) checkpoint commit: `fix: implement <AC>` or `feat: add <AC>` (use `feat:` for new behavior, `fix:` for bug)

### Phase REFACTOR — Optional cleanup

1. If code is non-trivial (≥10 lines new), ask: "Refactor this AC's code? (a) yes, (b) skip"
2. If yes, clean up while keeping all tests GREEN. Common refactors:
   - Extract function (only with 2+ call sites)
   - Rename for clarity
   - Inline single-use helper
   - Remove duplication
3. Run all tests after each refactor → must remain GREEN
4. (Optional) checkpoint commit: `refactor: <AC area>`
5. If no refactoring needed: skip to next AC

### Phase Repeat — Next AC

- Mark current AC task `completed`
- Move to next AC in sequence
- Continue until all ACs done → final verification (below)

---

## When Stuck (decision table)

| Symptom | Likely cause | Action |
|---|---|---|
| Test passes immediately (no RED) | Test is fake (no real assertion, or testing already-implemented behavior) | Rewrite — assert specific output value, not "exists" |
| Test fails with import/syntax error | Test setup wrong | Fix imports, framework setup, file path |
| GREEN seems impossible without huge code | AC too broad | Split AC into smaller pieces; restart from RED with smaller test |
| Test passes but feels meaningless | Testing implementation, not behavior | Rewrite — assert observable output, not internal state |
| Refactor breaks tests | Refactor changed behavior (not pure cleanup) | Revert refactor — pure cleanup must preserve behavior |
| Adding new test breaks old tests | Coupled tests (shared mutable state) | Isolate — fresh setup per test, no shared state |

## Rationalizations to Reject

| Rationalization | Why it's wrong | Required action |
|---|---|---|
| "I'll just write the implementation, then test it" | You'll write code that fits your test, not behavior; misses edge cases test would force you to consider | Stop. Delete implementation. Write test first. |
| "I already tested this manually" | Manual tests aren't repeatable, aren't in CI, vanish on next change | Convert manual test into automated test |
| "This AC is too simple for TDD" | No AC is too simple. Skipping for "simple" trains you to skip more. | One small test, one small implementation. Cycle completes in <2 minutes. |
| "I'll add a test later" | "Later" never comes. Tests written after pass without exercising real failure modes (they would pass even against a broken stub). | Add it now or admit the AC is not done. |
| "Just this once" | Every "just this once" is the start of a rotting habit | Stop. Restart from RED. |
| "The test is too hard to write" | Code is too coupled / does too much / depends on too many things | The test difficulty is the signal — simplify the design before testing it |

## Red Flags (STOP and reset)

- Production code written before a test exists for the current AC → delete the production code, restart from RED
- Test passes without implementation (RED skipped) → test is fake, rewrite
- Test fails with syntax/import error (Verify RED failed) → fix the test before claiming RED
- "I'll run tests later" → STOP, run them now
- All tests passing but AC behavior not explicitly asserted → add an assertion for the AC, not just "function exists"
- Multiple ACs in progress simultaneously → finish current AC's GREEN before starting next AC's RED

## Final Verification Checklist (after all ACs done)

- [ ] Every AC has at least one passing test
- [ ] Full test suite passes (no regressions)
- [ ] No vacuous assertions (`expect(true).toBe(true)`, `assert True`, etc.)
- [ ] Each test would FAIL if production code for that AC were removed (Comment-Out Test per `.claude/testing.md`)
- [ ] No `// TODO test this later`, `xit(...)`, `it.skip(...)`, `@unittest.skip`, `t.Skip()` left in (unless tracked by issue)
- [ ] Code follows project conventions (run `/verify` if available)

## Rules

- NEVER write production code without a failing test for that exact behavior
- NEVER skip the Verify RED phase (test must fail for the right reason)
- NEVER write more production code than needed to pass the current test
- NEVER batch ACs — one at a time
- NEVER add anticipatory features ("might need this later")
- NEVER skip running the full test suite after GREEN
- NEVER commit `xit(...)`, `it.skip(...)`, `@unittest.skip`, `t.Skip()` without a tracked follow-up issue
- ALWAYS announce phase transitions: `RED ✓ — <reason>`, `GREEN ✓ — N/M passing`
- ALWAYS check Comment-Out Test compliance per `.claude/testing.md`
- ALWAYS follow the project's detected test runner (never hardcode)
- ALWAYS refer to `.claude/testing.md` for coverage thresholds, test type ratios, and edge case checklists — this skill is the RUNTIME loop; `testing.md` is the standards reference
