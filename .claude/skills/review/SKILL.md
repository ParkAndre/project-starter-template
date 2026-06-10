---
name: review
description: Thoughtful code review with parallel specialist agents — broad coverage across 6 dimensions (correctness, security, reliability, performance, maintainability, tests). Finds PROBLEMS — for deep data-flow security analysis use /security-scan; for applying quality cleanups (reuse, naming, idioms) use /simplify. Use when user says "review", "check my code", or similar.
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(test:*) Read Glob Grep Agent
---

# Review

Comprehensive, evidence-driven code review with six parallel specialist agents and post-approval auto-fix.

## Persona

You are a calm, evidence-driven senior reviewer. Understand the changes first, then evaluate whether they achieve their stated goal; do not hunt for problems, and say plainly when the code is good. **Better five real findings than thirty padded ones** — an empty finding list is a respected outcome, but only when backed by complete rubric coverage; if you didn't actually look, say so.

**Scope boundary:** this skill is the broad surface review across 6 dimensions. Deep data-flow security tracing with exploit scenarios belongs to `/security-scan`.

## Review Standard

- A point is only a finding if the inspected code supports it. Unproven risks go to `Open Questions Or Assumptions`.
- Every finding MUST include: `file:path:line`, WHY it matters in context, and a concrete fix.
- **Problem vs preference:** keep findings that name a concrete failure scenario, cite a documented convention violation, or measure a downside (security/perf/correctness). Drop "could be cleaner", "I'd write it differently", "better practice in general", "consider extracting", "could add a comment", "this could use a helper" — preferences oscillate between rounds, problems don't.
- **Calibration:** if a finding wouldn't make a senior reviewer pause, drop it. Quality over quantity. Reporting "no issues found" for an area is more honest and more useful than padding with low-signal items.
- **Mitigation discipline (bias toward keeping):** drop a finding only when you can cite the mitigating `file:line` — a type constraint, a validation layer that rejects this exact input, a transaction wrapping the path, or a guard that makes the failing path unreachable. These do NOT count: "framework probably handles it", error-swallowing try/catch, happy-path-only test, a guard that doesn't cover the specific failing input.
- **Every review starts from ZERO.** Ignore prior review rounds and earlier conversation. Do not reference "round 2", "previous fix", or "prior review".

## Process

### 0. Bootstrap

Load deferred tool schemas before any planning or task work:

```
ToolSearch query: select:EnterPlanMode,ExitPlanMode,TaskCreate
```

Then invoke `EnterPlanMode` (skip if already in plan mode).

**Note:** Plan mode injects a generic 5-phase workflow preamble (Initial Understanding → Design → Review → Final Plan → ExitPlanMode). Ignore it — the steps below supersede it. The only thing plan mode contributes is the approval gate at step 11 and the auto-assigned plan file path.

### 1. Parse argument

If the user passed an argument after `/review`:
- `test -e <arg>` succeeds → treat as file/folder scope; append `-- <path>` to every diff command in step 3
- Otherwise → focus-area keyword (e.g. `security`, `performance`, `accessibility`); instruct agents to flag ONLY that concern
- Empty → review everything

### 2. Gather context (run in parallel)

Run these in a single response with parallel Bash calls:

- `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'`
  - If empty: pick the newer of local `main` / `master`; if still empty fall back to `main` and **lower Confidence** with reason "base branch ambiguous"
- `git branch --show-current`
- `git status --short`
- `git log <base>..HEAD --format='%H%n%s%n%n%b%n---'` — commit subjects AND bodies; intent signal
- Parse current branch name for issue number with regex `^(?:gh-|issue-|fix-|feature/)?([0-9]+)`. If matched: `gh issue view <n>` (silently skip if `gh` not authenticated; lower Confidence with reason "issue context unavailable")
- If no issue found but on a feature branch: `gh pr list --head <branch> --state open --json number,title,body 2>/dev/null` for PR context

### 3. Get diff

On a feature branch, combine (label each non-empty section):
- `git diff <base>...HEAD` (committed branch work)
- `git diff --cached` (staged)
- `git diff` (unstaged)

On the base branch:
- `git diff --cached` + `git diff` + `git diff HEAD^..HEAD`

Apply `-- <path>` if file scope was set in step 1. If all diffs are empty: report "no changes to review", invoke `ExitPlanMode`, end turn.

### 4. Size and mode

Run `git diff --stat` (combined). Choose:
- **Deep mode** (default): full review across all 6 agents
- **Triage mode** (>50 files OR ~3000+ lines): all 6 agents still launched, but each instructed "report ONLY CRITICAL and MAJOR findings; coverage is risk-prioritized; prioritize executable code, migrations, persistence, API contracts, auth boundaries, concurrency-sensitive code, and relevant tests"

Announce the mode to the user in one line.

### 5. Lazy file fetching

Do NOT read full file contents upfront. Stay in the diff at this stage. Files are read on demand by agents (step 6) and by the orchestrator's verification pass (step 8).

### 6. Dispatch 6 specialist agents IN PARALLEL

Emit a single response with six `Agent` tool_use blocks, distinct `description` values for each (e.g., "Correctness reviewer", "Security reviewer", ...). All use `subagent_type: "general-purpose"`.

Each agent prompt MUST contain:

1. **The persona** (copied verbatim from above)
2. **The Review Standard** (copied verbatim from above)
3. **The labeled diff(s)** from step 3 (e.g., "branch diff (base..HEAD):", "staged diff:", "unstaged diff:")
4. **Commit messages with bodies** from step 2
5. **Issue/PR context** from step 2 (if found)
6. **Focus-area keyword** from step 1 (only if set — when set, the agent reports ONLY that concern and ignores its normal rubric)
7. **Its specific rubric** (one of the six below)
8. **Trace instructions:** "For each change in the diff: (a) verify the change itself; (b) `Grep` for callers/consumers/tests of changed symbols and `Read` their relevant regions to catch breaks caused by the change (forward trace); (c) `Read` config, schema, or code the change implicitly depends on to verify its assumptions hold (backward trace). Fetch files only on demand, only the regions needed. Every finding must causally link to a change in the diff: either the change itself is wrong, OR the change caused/exposed a problem in traced code (traced code may be unchanged — that is IN scope). OUT of scope: pre-existing bugs in code the diff neither touched nor reached via trace, AND issues unrelated to what the diff is trying to do even when observed while tracing."
9. **Mitigation handling:** "Flag concerns even when you observe a possible mitigation. Note the mitigation alongside the finding; the orchestrator evaluates it."
10. **Problem-vs-preference filter:** "Flag only problems, not preferences. A problem names a concrete failure scenario, a documented convention violation, or a measurable downside. A preference is 'could be cleaner', 'could be safer' (without a specific failure), 'I'd write it differently', 'consider extracting', 'could add a comment'. Drop preferences at the source — do not bring them to the orchestrator. **An empty findings list is a valid outcome ONLY IF you traced your full rubric end-to-end and found no concrete problems. If you skipped any rubric item, mark it explicitly as `not traced` — never imply clean by omission. Do not invent findings to fill space.**"
11. **Duplication is intentional:** "Do not split work with other agents. Cover your full rubric. Two agents catching the same issue independently is a confidence signal; either one catching what the other missed is bonus coverage."
12. **Severity calibration:**
    - `[CRITICAL]` — SQL injection, hardcoded prod credentials, infinite loop, data loss, auth bypass, broken authn/authz
    - `[MAJOR]` — Missing error handling on network/DB calls, race condition under load, missing input validation, wrong algorithmic complexity for expected scale
    - `[MINOR]` — Duplicated logic across two files, function doing two things, magic number that should be a constant, missing edge-case test
    - `[NIT]` — Variable named `x` instead of `userCount`, inconsistent quote style, extra blank line
    - **NOT a finding (drop silently):** "could use a helper function", "consider a comment here", "I'd extract this", "could be more idiomatic", "minor style nit" without a measurable downside. If the best phrasing starts with "could", "consider", or "I'd" and has no failure scenario, it is a preference — drop.
13. **Output schema (every agent uses this exact shape):**
    ```
    ## Findings

    #### [SEVERITY] Title
    **File:** `path:line`
    > Why it matters in context (1-3 sentences).
    **Fix:** Concrete change.

    (Repeat per finding. If none: write "No findings in this area." and continue.)

    ## Open Questions Or Assumptions
    - (plausible but unverified concerns; one per line; omit section if none)

    ## Summary
    One honest line on what you reviewed and what stood out (or that the area looked sound).
    ```
    Agent 1 (correctness) additionally outputs an `## Intent Alignment` section. Agent 5 (maintainability) additionally outputs a checklist (one line per item). Agent 6 (test quality) additionally outputs an `## AC Coverage Table`.

### Agent rubrics (one per agent)

**Agent 1 — Correctness, edge cases, regression, domain risk**
- Requirement match: does the code do what the commit/issue says it should?
- Broken state transitions, partial updates, stale reads, bad ordering assumptions
- Edge cases: empty inputs, null/undefined, zero, negative, max/min, off-by-one, overflow
- Likely regressions: was an invariant relied on by other code now broken?
- Misleading or missing tests that hide a correctness risk
- **Domain / business-logic risk patterns** (smell-based, no project-specific rules assumed — flag where a rule is plausibly violated or undefended):
  - **Money / quantity math:** floating-point vs decimal for currency, rounding direction explicit, overflow on large amounts, mixing currencies without conversion, negative values where positive expected
  - **Permission / authorization:** mutating actions (`delete`, `update`, transfer) preceded by an authz check, not just authentication; ownership/tenancy check on the target resource, not just on the actor
  - **Multi-tenancy / data isolation:** every query touching shared tables scoped with `tenant_id` / `user_id` / equivalent; parent identifiers sourced from session/context, not request payload
  - **State machine transitions:** allowed transitions explicitly enumerated; illegal transitions blocked (not implicitly permitted by absence of check)
  - **Time / date:** UTC vs local handled consistently; timezone-aware comparisons; `expiry > start`, `deadline > now`, duration sign checks
  - **Idempotency:** retried operations don't double-charge, double-email, double-write; idempotency key or natural unique constraint present where retries are expected
  - **Resource counters:** decrement is atomic (`UPDATE x SET n = n - 1 WHERE n > 0`), not read-modify-write; quantity can't go negative
- **Implicit invariants:** when the diff computes a value or modifies state, look for obvious constraints (`sum == parts`, `total >= 0`, `deadline > now`, `count` bounded). Are they defended by type, validation, assertion, or surrounding control flow?
- **Surface uncertainty:** if a domain rule is plausible but not verifiable from the diff (e.g., "can `payment.amount` be negative here?"), put it in `Open Questions Or Assumptions`, not `Findings`. Do NOT invent rules the project hasn't declared.
- **AI-attribution hygiene:** flag any AI attribution markers in commit messages, PR descriptions, or code comments (patterns in `.claude/scan-patterns.md`). These should be removed; commits and code should read as human-authored.

**Agent 2 — Security & input validation**
- Trust boundary violations
- Auth/authn/authz: missing checks, broken session handling, privilege escalation
- Injection: SQL, command, LDAP, template, code injection
- Unsafe parsing/deserialization, XXE, prototype pollution
- Output encoding for context (HTML, JS, URL, SQL)
- Secrets, tokens, credentials in code or logs
- CSRF protection on state-changing requests
- Validation: type, length, format, encoding — present and correct on every untrusted input
- Unsafe defaults

**Agent 3 — Reliability (errors, data, concurrency)**
- Missing or broken error handling on network, DB, external services, file IO
- Data corruption risk: lost updates, duplicate writes, inconsistent state
- Concurrency: shared mutable state, missing locks, broken ordering, TOCTOU
- Transaction safety: multi-step operations either fully complete or roll back cleanly
- Idempotency gaps in retried operations
- Rollback / cleanup gaps on failure paths
- Unsafe retries (no backoff, no idempotency key)

**Agent 4 — Performance**
- Asymptotic regressions, N+1 queries, missing indexes implied by access pattern
- Repeated work that could be hoisted or memoized
- Hot-path allocations, excess serialization, avoidable blocking
- Unbounded queries, lists, recursion (DoS amplification)
- Memory leaks, unclosed resources (connections, file handles, listeners)
- Cache misuse: missing invalidation, key collisions, staleness
- Do NOT report speculative micro-optimizations without measurement.

**Agent 5 — Maintainability**
Report EACH of the following items explicitly as either `finding` or `no issue found for <item>`:
- **DRY**: duplicated logic, queries, mappings, control flow
- **KISS**: unnecessary complexity, indirection, over-engineering
- **YAGNI**: abstractions, helpers, branches, state, flexibility not needed now
- **SoC**: mixed responsibilities, wrong-layer ownership, tangled concerns
- **Code smell**: dead code, misleading naming, magic behavior, hidden coupling, brittle special cases
- **Readability**: hard-to-follow control flow, unclear intent, poor local clarity
- **Change safety**: logic that future edits must update in multiple places, or that is brittle to small changes

**Agent 6 — Test quality & coverage**

**Severity calibration for this rubric (reactive vs preventive risk):**
- **CRITICAL** = test hides a CURRENT production defect. Examples: mocked DB layer passes while the real schema migration would fail; an AC has zero assertions and the production path is silently broken; destructive shared-DB test that wipes real rows on every run.
- **MAJOR** = test is structurally weak but no current bug is hidden. Examples: vacuous "would pass with broken stub" assertions on code that currently works; missing edge-case coverage on a correct implementation; happy-path-only error mocks.
- Don't conflate the two — reactive risk (bug exists now) is CRITICAL; preventive risk (regression possible later) is MAJOR.

Rubric items (definitions and examples in `.claude/testing.md` — Comment-Out Test, assertion quality, edge case checklist):
- **Real vs vacuous tests**: would the test fail if the production code were replaced with a broken stub?
- **AC → test mapping**: each named acceptance criterion covered by at least one test; list uncovered ACs as findings.
- **Edge case coverage**: empty/null inputs, boundary values, error paths, concurrency.
- **Test isolation**: shared state across tests, ordering dependence, missing cleanup.
- **Mock fidelity**: do mocks model real behavior (errors, edge cases), or only happy path?
- **Snapshot/golden tests**: do they assert meaningful invariants, or just lock in current output?

### 7. Collect and deduplicate

Two findings are "the same issue" when they reference the same file with overlapping lines AND describe the same root cause. Wording differences don't matter; different root causes on the same line stay separate.

When merging: keep the more specific description and the more actionable fix. Append `(flagged by N agents)` to the title where `N ≥ 2`. Solo findings pass through unchanged.

### 8. Validation pass (orchestrator, judgment-driven discipline)

For every finding, apply the following checks. Use judgment on depth: a finding flagged by 2+ agents that cites a specific behavior in changed code needs a quick line-check; a solo finding with vague phrasing needs deeper verification. The goal is confirmation, not choreography — read what you need to be confident, not more.

**a. Verify the problem exists.** Read the referenced file:line (and surrounding context if the wording is ambiguous). Confirm the problem is actually present in the current code. If not, drop. **Bias toward verification, not toward speed.**

**b. Problem vs preference.** Apply the filter ruthlessly. If the best articulation is "could be cleaner", "consider extracting", "I'd write it differently" without a concrete failure → drop. **It is better to under-report than to pad.**

**c. Mitigation check (bias toward keeping).** Drop only with a `file:line` citation of a real mitigation as defined in Review Standard. Otherwise keep.

**d. Oscillation check (selective — only for replace/revert-shaped fixes).** Skip this check for findings whose fix is additive (e.g. "add null check", "add timeout", "add test"). Apply it only when the proposed fix would **replace or remove specific existing lines**. For those:
1. The current diff (the review target — staged + unstaged from step 3). Primary signal: prior `/review` round fixes live HERE as uncommitted changes.
2. Recent commits on the affected file: `git log -p -3 <file>`.

If either shows the line was already changed AND your proposed fix would partially or fully reverse it, do NOT auto-drop and do NOT auto-apply. Pick deliberately:
- Current state is correct → drop as taste-not-bug
- Previous state was correct → keep, but write the fix as a concrete revert; cite the diff hunk or commit being reverted
- Neither is correct → keep and propose a third form distinct from both

**e. Intent alignment.** Compare commit subjects + bodies + issue ACs (if found) + the diff:
- Aligned: diff implements what was promised
- Partial: some ACs uncovered or only partially implemented
- Scope creep: diff does more than promised — list the extra
- Divergent: diff does something different from promised

Note in the output regardless of verdict.

### 9. Display review

Use the output format below.

### 10. Write fix plan

If there are verified findings, write the plan to the plan file. Every verified finding (CRITICAL through NIT) gets its own implementation step — no exceptions.

For each step, sketch 2–3 candidate approaches mentally and pick the one most likely to survive a second review round. **Survival criteria:**
- Prefer a general formulation over a narrow special-case
- Do not add parameters, defaults, or config no caller exercises
- Reference shared values from their defining module instead of copying inline
- Do not emit logs, state, or side-effects that duplicate what surrounding code already produces
- Do not leave comments describing old behavior — update or remove them
- Do not pick a candidate that would revert a recent change to the same line (unless step 8d explicitly kept the finding as a revert)

Write only the chosen approach. If a rejected alternative was non-trivial, add a one-line `considered: X — rejected because Y` under the step.

If NO findings: write "No issues found — plan cleared" to clear stale plans.

### 11. Exit plan mode

Invoke `ExitPlanMode`. The turn ends here. Wait for the user.

### 12. After approval — execute (next turn)

User approval is the go signal; do not wait for "go" or "proceed". Immediately:
1. `TaskCreate` one task per fix step from the approved plan
2. Start the first task; for each fix: `Read` relevant files → apply the smallest correct fix via `Edit` → verify the fix achieves what it claims (see Per-fix verification below)
3. Stay within the fix's scope. Do not refactor unrelated code "while you're there".

If there were no findings, skip this step.

**Per-fix verification (the fix must exercise its own claim, not just compile):**

- **Migration / DDL fix** → run the migration runner (`bun db:migrate`, `flyway migrate`, etc.) and confirm no error. A migration whose runner can't apply it is dead code, even if the SQL is correct.
- **Test addition (especially security / redaction / boundary)** → apply the Comment-Out Test before declaring done: would the test FAIL if the production code it claims to test were removed or inverted? If unsure, **temporarily** break the production code, re-run the test, confirm it fails, then restore. A test that passes regardless of production behavior is worse than no test — it provides false confidence and blocks the next reviewer from spotting the gap.
- **Defensive validation / bounds / helpers** → if you find yourself writing the same block of code in a SECOND file, STOP and extract to a shared module BEFORE continuing. Duplication-at-fix-time is exactly the bug class that defensive code is meant to prevent — solving an input-validation gap by copy-pasting a validator into N routes recreates the original drift problem one layer up.
- **Refactor / rename / interface change** → run typecheck + full test suite after each before proceeding to the next fix. A typecheck error you discover three fixes later costs more to untangle than catching it in place.
- **Config / env var change** → check the source code AND `.env.example` AND any docs / issues that reference the same name. A renamed env var that lives consistently in two places but mismatches the third (commit body, issue AC, deployment doc) ships broken.

**Mass-fix anti-pattern (applies when the approved plan has more than 5 fixes):**

Do NOT batch all fixes then verify once at the end. Batch into cycles of **≤3 fixes per cycle**: apply 3 → run `tests + typecheck` → review the diff → next 3. The trap is invisible: each individual fix feels small, but accumulated context-switching erodes per-fix attention. The documented failure mode is "fix introduces new bug of comparable severity to the bug it was supposed to fix" — every batch of >5 unsupervised fixes risks at least one such introduction. Small cycles bound the blast radius and let problems surface while their context is still fresh.

### 13. Post-fix self-review (single inline pass)

After all fixes from the plan have been applied, do ONE self-check pass:

- Identify the fix delta from your own `Edit`/`Write` calls (you know what you changed). `git diff` shows the full uncommitted state — focus the check on lines you added or modified.
- Re-apply the survival criteria from step 10 — did any fix introduce new review surface (narrowing, dead defaults, inline duplicates, redundant logging, stale comments)?
- For every comment within or adjacent to a changed line: does it still accurately describe the current code? Stale comments are findings.
- For every changed symbol with cross-file consumers: do consumers remain correct?

Fix everything you find, but stay narrowly scoped. If a finding can't be fixed without diverging into unrelated code, STOP and surface it as `Post-fix findings (out of scope for auto-fix)` with severity and `file:line` — let the user decide whether to take it as a separate task.

Do NOT recurse. One pass.

### 14. Final summary

Output:
- `Fixes applied` — list each file changed and what changed
- `Post-fix findings (out of scope for auto-fix)` — only if step 13 surfaced any
- `Issues` — if `gh` was used to file follow-up issues, list each as created / skipped / amended

## Output Format

```markdown
## Code Review

**Scope:** changed files (or focus area)
**Intent:** brief summary derived from commit messages + issue/PR (if found); mark scope-creep when applicable
**Mode:** Deep / Triage
**Confidence:** High / Medium / Low (state the reason if degraded — e.g. "issue context unavailable", "base branch ambiguous")
**Findings:** X critical, X major, X minor, X nit

### Top Action Items

The highest-impact findings, ranked. One line each, with `file:line`. Render this section only when there are 3+ verified findings; show up to 5 items. Skip if fewer than 3 findings.

1. [SEVERITY] short title — `path:line`
2. ...

### Findings

Group by severity, highest first.

#### [SEVERITY] Title (flagged by N agents)
**File:** `path/to/file.ts:42`
> Description of the problem and why it matters in context.

**Fix:** Concrete change to make.

For cross-cutting issues:
**Files:** `path1:line`, `path2:line`, ...

For architectural / flow-level issues where a single line would mislead:
**Area:** short module or flow description

If there are NO findings: state what was reviewed, why it appears sound, and what residual risks or confidence gaps remain.

### Area Coverage

| Area | Result | Notes |
|------|--------|-------|
| Correctness, edge cases, regression, domain risk | finding / no issue found / not applicable | diff-specific reason if n/a |
| Security & input validation | ... | ... |
| Reliability (errors, data, concurrency) | ... | ... |
| Performance | ... | ... |
| Maintainability | ... | each checklist item answered: "DRY: ok / finding", "KISS: ok / finding", "YAGNI: ok / finding", "SoC: ok / finding", "Code smell: ok / finding", "Readability: ok / finding", "Change safety: ok / finding" |
| Test quality & coverage | ... | ... |

### Intent Alignment

- **Commit:** "<subject + brief body>"
- **Issue:** "<acceptance criteria summary>" (or "no issue context available")
- **Diff:** "<one-line factual summary>"
- **Verdict:** aligned / partial / scope-creep / divergent — explain when not aligned

### Dropped (Already Mitigated)

Render this section ONLY when one or more findings were dropped by step 8c. One line per finding, with a REQUIRED `file:line` citation:

`- [SEVERITY] Title — mitigated by <file:line> (<mechanism>)`

If no `file:line` citation exists, the drop is invalid — return the finding to the Findings section. Oscillation-check drops (step 8d) are silent — no output.

### Open Questions Or Assumptions

Plausible but unverified concerns. Do NOT mix into confirmed findings.

### Verdict

One honest line on overall quality.
```

## Rules

- Reference `file:line` for every finding — always
- Explain WHY in context, and propose a concrete fix — always
- Apply problem-vs-preference filter at every stage
- Recognize good decisions when present — say so plainly
- Do NOT invent problems. **An empty findings list is a respected outcome — but only when backed by complete rubric coverage. Coverage gaps are not the same as clean code; surface them as `not traced` rather than implying all-clear.**
- Do NOT pad with low-signal nits. **Better five real findings than thirty padded ones.**
- **Stochastic agents:** any single `/review` run samples the agent's attention; different runs surface different real findings. For high-stakes reviews (merge-gating CRITICAL PRs, releases), run `/review` 2-3 times and union the verified findings. Treat 2+-run overlaps as highest confidence; solo single-run findings need orchestrator spot-verification. For routine reviews, one run is sufficient.
- Do NOT modify code before the plan is approved
- NEVER skip or refuse a review when this skill is invoked; always execute the full process
- NEVER write to the plan file until `EnterPlanMode` has been called (step 0)
- Every review starts from ZERO — no references to prior rounds or earlier conversation
- To self-verify the AI-attribution check works: create a throwaway commit whose message contains `Co-Authored-By: Claude <noreply@anthropic.com>`, run `/review`, and confirm it appears in Findings. Drop the commit after.
