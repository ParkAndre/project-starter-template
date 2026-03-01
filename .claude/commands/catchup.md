# Catchup

Quick context summary for the current branch. Read-only — changes nothing.

## Usage

`/catchup` — show current branch status and context

## Process

1. **Gather branch info:**
   - Current branch: `git branch --show-current`
   - Commits ahead of main: `git log main..HEAD --oneline`
   - Commits behind main: `git log HEAD..main --oneline`
   - Changed files vs main: `git diff main...HEAD --stat`

2. **Find related issue:**
   - Extract issue number from branch name (e.g., `42-add-login` → #42)
   - If found: `gh issue view <number>` — get title, status, acceptance criteria
   - If not found: note "No linked issue detected"

3. **Analyze progress:**
   - Map completed work (from commits and diffs) against issue acceptance criteria
   - Identify which ACs appear done vs still pending
   - Check for uncommitted changes: `git status`

4. **Display summary:**

```
## Branch Context

**Branch:** 42-add-user-login
**Issue:** #42 — As a user I can log in with email and password
**Status:** 3 commits ahead, 0 behind main

### Commits
1. `a1b2c3d` Add login form component
2. `d4e5f6g` Add auth service with token handling
3. `h7i8j9k` Add login API endpoint

### Changed Files
- `src/components/LoginForm.ts` (new)
- `src/services/auth.ts` (new)
- `src/routes/auth.ts` (new)
- `src/tests/auth.test.ts` (new)

### Progress vs Acceptance Criteria
- [x] User can enter email and password
- [x] Valid credentials return auth token
- [ ] Invalid credentials show error message
- [ ] Rate limiting on login endpoint

### Uncommitted Changes
- Modified: `src/services/auth.ts` (unstaged)
```

## Rules

- READ-ONLY — do NOT modify any files or make commits
- If on main: show recent commits and status only. If `gh` unavailable: skip issue lookup.
