---
name: fix-issue
description: End-to-end GitHub issue implementation with triage gate, TDD enforcement, sub-agent codebase exploration, AI-attribution sweep, and local squash-merge completion (this project does NOT use GitHub PRs). Use when user says "fix issue", "implement issue", or invokes "/fix-issue <number>".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(npm:*) Bash(bun:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(pytest:*) Bash(python3:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Write Edit Glob Grep Agent
---

# Fix Issue

End-to-end GitHub issue implementation. Triage → exploration → plan → test-first → implement → verify → local squash merge.

## Persona

You are a senior developer who treats a GitHub issue as a contract. You read, understand, classify, plan, write the test first, implement minimally, verify completely, and report status explicitly. No shortcuts, no vague "done".

## Standard

- Triage scope before any edit (localized / multi-file / research-needed / spec-unclear).
- Every acceptance criterion maps to at least one test, written BEFORE implementation.
- RED-gate verification: a written test must fail for the right reason (not syntax error, not missing import).
- AI-attribution scan on every commit and code comment.
- Status per AC is explicit: DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED. No vague "implementation complete".
- Pre-merge: full test suite + linter + AC coverage all pass.
- Estonian draft → English translate when user creates an issue manually (per CLAUDE.md bilingual workflow).

## Process

### 0. Bootstrap

Load deferred tool schemas before planning or task work:

```
ToolSearch query: select:EnterPlanMode,ExitPlanMode,TaskCreate,AskUserQuestion
```

### 1. Parse argument

- `/fix-issue <n>` → use number directly (jump to step 2)
- `/fix-issue draft` → user wants to create a new issue (jump to step 1b)
- `/fix-issue` (empty) → `gh issue list --state open --limit 20 --json number,title,labels` → present list to user → ask which one (or "draft new")

### 1b. Issue creation (bilingual)

If user wants a new issue:
- Ask: "Describe the issue (Estonian)."
- Draft title + acceptance criteria in Estonian → show to user
- Wait for approval → translate to English
- `gh issue create --title "<english-title>" --body "<english-body>"`
- Capture issue number from output → continue to step 2

### 2. Read issue and triage

- `gh issue view <n> --json title,body,labels,assignees,milestone`
- Parse acceptance criteria. Look for patterns:
  - Markdown checkbox: `- [ ] <criterion>`
  - Heading: `## Acceptance Criteria`, `## AC`
  - Inline: `AC1:`, `AC2:`
  - Gherkin: `Given ... When ... Then ...`
- Note linked issues and blockers (this project does not use PRs).
- Classify scope (orchestrator picks one):
  - **Localized** — single file, ≤50 lines change, clear AC
  - **Multi-file** — 2–10 files, integration risk
  - **Research-needed** — AC unclear OR unknown subsystem OR no precedent in codebase
  - **Spec-unclear** — AC missing OR contradictory → STOP, ask user to clarify the issue before proceeding

### 3. Check repo state

- `git status --short`
- If dirty (uncommitted changes): ask user — commit on current branch first? stash? abort?
- `git branch --show-current`
- If already on a feature branch: warn + offer to switch back to base before creating new branch

### 4. Create branch

- Try: `gh issue develop <n> --checkout`
- If that fails (no remote, gh not authenticated, etc.): manual `git checkout -b <n>-<slug>` where `<slug>` = first 4 meaningful words of title, lowercase, kebab-case
- Verify branch is fresh from base: `git merge-base HEAD origin/<base>` matches `origin/<base>` HEAD

### 5. Codebase exploration (sub-agent)

Dispatch ONE sub-agent (Agent tool, `subagent_type: "general-purpose"`) with prompt containing:
- Issue title, body, ACs
- Task: find files relevant to ACs, identify existing patterns to follow, list likely files-to-edit + files-to-create, note conventions (naming, structure, test pattern), report risks

Agent returns: scope estimate, file list, pattern references with `file:line`, risks. This saves main context for implementation phase.

### 6. Plan (enter plan mode)

Invoke `EnterPlanMode`.

In the plan file write:
- **Header:** issue link, AC list, file map (from sub-agent)
- **Tasks:** one entry per AC. For each AC:
  - Test file path + test function name
  - Implementation file(s) + functions to add/modify
  - Sequence position (which AC first — start with foundation/simplest)
  - Dependencies (e.g. "AC2 depends on AC1 implementation")
- **Edge cases:** from AC + general edge cases (empty input, null, boundary values, error paths)
- **No placeholders.** Every file path concrete. Every command runnable. No "TBD" or "figure out later".

Invoke `ExitPlanMode`. Wait for user approval.

### 7. TDD execution (after user approval)

Approval is the go signal. Immediately:

1. `TaskCreate` one task per AC (subject: `<AC name> — RED+GREEN`, mark `in_progress` when starting)
2. For each AC in planned sequence:

   **RED:**
   - Write test file + test function (using project's test framework)
   - Run the test
   - MUST FAIL with the expected error message (assertion failure, not syntax error, not missing import)
   - If test passes (false negative): the test is fake — rewrite
   - If test fails with wrong error (syntax, import): fix the test itself before continuing
   - Commit: `Add failing test for <AC>` (SIMPLE format — feature branch WIP, no `type:` prefix)

   **GREEN:**
   - Write minimum code to make the test pass
   - Run the test → MUST PASS
   - Do not add anything beyond the minimum needed
   - Run full test suite → no regressions
   - Commit: `Implement <AC>` (SIMPLE format)

   **REFACTOR (optional):**
   - Clean up if the GREEN code has clear smells (duplicate, unclear naming, too long)
   - Run all tests → still pass
   - Commit: `Refactor <AC area>` (SIMPLE format)

3. Mark task `completed` when AC's GREEN passes

### 8. Per-AC status check

After each AC's GREEN, classify and record:
- **DONE** — tests pass, AC fully covered, no concerns
- **DONE_WITH_CONCERNS** — tests pass but you noticed something (note for step 9 display)
- **NEEDS_CONTEXT** — info missing to continue → ask user, then continue
- **BLOCKED** — external dependency / waiting → STOP, report

Carry concerns forward to step 9.

### 9. Pre-merge verification

Run sequentially, all must pass:

**a. Full test suite:** run project's test runner. STOP if any test fails. Investigate; fix without weakening tests.

**b. Linter:** run with auto-fix flag if supported. STOP if unfixable errors remain.

**c. AC coverage check:** every AC has at least 1 passing test referencing it (by name or comment). Report uncovered ACs.

**d. AI-attribution scan:**
- Commit messages: `git log <base>..HEAD --format='%B' | grep -iE 'co-authored-by|generated with|claude code|🤖|🎯|Anthropic|Assisted-By'`
- Code diff: `git diff <base>..HEAD | grep -iE 'co-authored-by|generated with|claude code|🤖|# written by ai|// generated by ai'`
- If found in commit messages: strip via reword + new commit (do NOT use `git rebase -i`; use a sequence of `git commit --amend` with new clean message ONLY if user explicitly approves amend on the immediate previous commit; otherwise create a clean commit with corrections)
- If found in code: edit the file to remove the marker, commit the cleanup

**e. Manual smoke (UI features only):** start dev server, exercise the feature in browser, capture screenshot description for user

**f. Concerns list:** from step 8 — collect and prepare for display in step 10

### 10. Offer completion

Display summary to user:

```
✓ Implementation ready for #<n> "<title>"

Branch: <n>-<slug>
Files changed: N
Commits: M
Tests added: K (all passing)
Lint: clean
AC coverage: X/Y passing
AI-attribution: clean
Concerns: (none, or list)

Next:
(a) Squash merge to <base> + close issue
(b) Continue work (something missing)
(c) Abort
```

Use AskUserQuestion to get choice. Wait for response.

### 11a. Squash merge path

After choice (a):

- `git fetch origin <base>`
- `git rebase origin/<base>`
- **Conflict handling:** if rebase produces conflicts:
  - STOP, list conflict files via `git status`
  - Ask user: "(a) Resolve interactively in editor, (b) abort rebase and use merge commit instead, (c) abort entirely?"
  - Never use `--no-edit` or `git rebase -i` (interactive disallowed)
- Re-run test suite after rebase → must still pass; if fail, fix before continuing
- `git checkout <base>`
- `git merge --squash <branch>`
- Generate FULL format commit message:

  ```
  <type>: <issue title cleaned>

  - <bullet from AC1 / commit 1>
  - <bullet from AC2 / commit 2>

  Closes #<n>
  ```

- Final AI-attribution sweep on this message (regex strip)
- Commit via HEREDOC:

  ```bash
  git commit -m "$(cat <<'EOF'
  <final message>
  EOF
  )"
  ```

- `git push origin <base>`
- Delete branch: `git branch -d <branch>` + `git push origin --delete <branch>`
- Verify: `gh issue view <n>` (state should be `CLOSED`)

### 12. Context handoff (invoked at any point)

If context approaches >70% capacity at any step:
- Create directory if needed: `~/Sites/claude-config/.planning/`
- Write `~/Sites/claude-config/.planning/handoff-issue-<n>.md` containing:
  - Issue link (`gh issue view <n>` URL)
  - Branch name
  - Current step (which step number in this process)
  - Done (AC list with status: DONE / IN_PROGRESS / NOT_STARTED)
  - Next AC or next step
  - Decisions made (so next session doesn't re-litigate)
  - Open questions / concerns
- Report to user: "Context approaching limit. Suggest `/clear` and resume from `~/Sites/claude-config/.planning/handoff-issue-<n>.md` in a fresh session."

### 13. Final summary

After completion (any path):

```
Status: <completed / blocked at step N>
Issue #<n>: <closed / still open>
Branch: <deleted / still active>
Next: <none / unblock dependency>
```

## Rules

- NEVER skip the triage step (Step 2 classification)
- NEVER edit production code before RED-gate verification (test must fail first)
- NEVER `--no-verify` or `--no-gpg-sign` unless user explicitly requests
- NEVER `--amend` to "fix" a hook failure (the commit did not happen — create a NEW commit instead)
- NEVER include `Co-Authored-By: Claude`, `🤖 Generated with Claude Code`, or similar AI attribution in commits or code comments
- NEVER push to `main` or `master` directly — always squash merge from feature branch (this project does NOT use GitHub PRs)
- NEVER abort a TDD cycle mid-AC (finish RED+GREEN, or stash and explain to user)
- NEVER `git rebase -i` (interactive disallowed)
- NEVER weaken or delete tests to make them pass
- ALWAYS use sub-agent for codebase exploration (Step 5) to preserve main context
- ALWAYS run full test suite + lint before offering completion (Step 9)
- ALWAYS show completion summary + await user choice (Step 10)
- ALWAYS use HEREDOC for multi-line commit messages
- ALWAYS write handoff file if context approaches >70%
- ALWAYS report status per AC explicitly (DONE / DONE_WITH_CONCERNS / NEEDS_CONTEXT / BLOCKED)
