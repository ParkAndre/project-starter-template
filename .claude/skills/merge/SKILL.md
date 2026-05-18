---
name: merge
description: Squash merge current feature branch to base (main/master) and close linked issue. Pre-merge verify gate (tests + lint + secrets + AI-attribution), rebase with interactive conflict prompt, re-run tests after rebase, FULL conventional commit (bullets + Closes #XX), AI-attribution sweep on final message, branch cleanup (local + remote), verify issue closed. Use when user says "merge", "squash merge", "finish branch", or invokes "/merge".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(npm:*) Bash(npx:*) Bash(bun:*) Bash(bunx:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(pytest:*) Bash(python3:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Glob Grep
---

# Merge

Squash merge current feature branch to base (main/master) and close linked issue. Pre-merge gates, interactive conflict handling, FULL conventional commit, AI-attribution sweep, branch cleanup, verify issue closed.

## Persona

Senior release engineer. Treats main as sacred. Verifies everything before merging, preserves history clarity (squash + bullets), refuses to merge with failing tests or AI attribution. Reports each step explicitly.

## Standard

- Pre-merge gates are HARD: tests fail → STOP; lint fail → STOP; on main → STOP; dirty repo → STOP
- Rebase before squash (clean linear history)
- Interactive conflict handling — never `--no-edit`, never `rebase -i`, never auto-resolve
- Re-run tests AFTER rebase (incoming changes may break)
- FULL conventional commit format on squash: `<type>: <title>` + per-commit bullets + `Closes #XX`
- AI-attribution sweep on final commit message (regex strip)
- Branch cleanup: delete local AND remote after successful push
- Verify issue closed via `gh issue view` — close-by-commit-message must have worked

## Process

### 1. Parse argument

- `<integer>` → use as issue number
- Empty → try to extract from branch name (regex `^(?:gh-|issue-|fix-|feature/)?([0-9]+)`)
- No issue number extractable → ask user: "Which issue does this branch close, or `none`?"

### 2. Pre-merge safety checks (parallel reads)

- `git rev-parse --git-dir 2>/dev/null` — verify in a repo
- `git branch --show-current` → must NOT be `main` or `master` (else STOP)
- `git status --short` → must be clean (else STOP — commit or stash first via `/commit`)
- `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` → base branch detection (fallback `main`)
- `git rev-parse --git-dir` vs `git rev-parse --git-common-dir` → worktree detection
- `git symbolic-ref HEAD` fails → detached HEAD → STOP, ask user

### 3. Worktree provenance check (if worktree)

If `git rev-parse --git-dir` differs from `git rev-parse --git-common-dir`, you're in a worktree.

- Compare worktree path against known harness-owned prefixes: `.worktrees/`, `worktrees/`, `~/.config/superpowers/worktrees/`
- If harness-owned: do NOT cleanup worktree after merge — let harness manage it
- If user-owned: cleanup as usual (step 12)

### 4. Pre-merge verify gate

Run gates sequentially, all must PASS:

**4a — Tests** (detected per stack — see `/verify` skill):
- `npm test` / `bun test` / `pnpm test` / `pytest` / `vendor/bin/phpunit` / `go test ./...` / `cargo test` / `make test`
- exit ≠ 0 → STOP

**4b — Linter** (detected per stack):
- `npm run lint` / `ruff check` / `flake8` / `phpcs` / `golangci-lint run` / `cargo clippy`
- exit ≠ 0 → STOP

**4c — Secrets scan** on `git diff <base>..HEAD`:
- Patterns from `/commit` skill (BEGIN .* PRIVATE KEY, AKIA, sk_*, ghp_, xox*, generic password/key/secret/token)
- Match → CRITICAL STOP

**4d — AI-attribution in branch commits:**
- `git log <base>..HEAD --format='%B' 2>/dev/null | grep -iE 'co-authored-by|generated with|claude code|🤖|🎯|Anthropic|Assisted-By'`
- If found: STOP, instruct user to clean up commits before merge. Suggestions:
  - `git commit --amend` to fix the most recent commit (if it's the only one)
  - Replace commits with clean ones (manual `git reset --soft` + new commits)
  - Do NOT auto-`filter-branch` — too risky

Any FAIL → STOP, report what blocks. Do not proceed.

### 5. Fetch and rebase

- `git fetch origin <base>`
- `git rebase origin/<base>`

**Conflict handling** if rebase produces conflicts:
- STOP, list conflict files via `git status`
- Ask user: "(a) Resolve interactively in editor (I'll wait), (b) abort rebase and use merge-from-base instead, (c) abort entirely"
- **(a)**: wait for user signal "resolved"; then `git rebase --continue`. If more conflicts, repeat.
- **(b)**: `git rebase --abort`, then `git merge origin/<base>` (a merge commit is OK in this case — better than blocking)
- **(c)**: `git rebase --abort`, end turn

NEVER `--no-edit`. NEVER `git rebase -i` (interactive disallowed).

### 6. Re-run tests after rebase

- Run the full test suite (same runner as step 4a)
- If fail: STOP, report. Incoming changes broke something — do not merge.

### 7. Collect branch commits for squash message

- `git log <base>..HEAD --format='%s%n%b' --reverse` — capture all commit subjects + bodies
- Group by topic; extract bullet points for FULL format body

### 8. Generate squash commit message

FULL format:

```
<type>: <issue title or summarized branch work>

- <bullet from commit 1 / AC1>
- <bullet from commit 2 / AC2>
- <bullet from commit 3 / AC3>

Closes #<n>
```

**Type detection** (from branch commits):
- New executable code → `feat:`
- Bug fix patterns (revert, guard, null-check, regression test) → `fix:`
- Logic preserved, structure changed → `refactor:`
- Only `*.md`, `docs/`, `README*` → `docs:`
- Only formatting/whitespace → `style:`
- Only test files → `test:`
- Only config/deps → `chore:`
- Performance-focused → `perf:`

If no issue number: omit `Closes #<n>` line.

### 9. AI-attribution sweep on final message

Regex strip (silently, note in preview if found):
- `Co-Authored-By:` (any value)
- `Generated with`, `Claude Code`, `Anthropic`, `🤖`, `🎯`
- `Assisted-By:`, `Co-Author:`
- Marketing phrases: `Successfully implemented`, `Production-ready`, `Best-in-class`, `Comprehensive`, `Robust`
- First-person on subject line: `^I\s`, `\bI added\b`, `\bI changed\b`

### 10. Preview and await confirmation

Display:

```
## Merge Preview

**From branch:** <name>
**To base:** <base>
**Issue:** #<n> (will be closed) — or "no issue linked"
**Commits to squash:** N
**Type:** <type>
**Pre-merge gates:** all pass ✓

**Squash commit message:**
<final message>

Proceed with squash merge + push? (yes / edit message / abort)
```

WAIT for explicit confirmation. Do NOT auto-merge.

### 11. Execute squash merge

After confirmation:

```bash
git checkout <base>
git merge --squash <branch>
git commit -m "$(cat <<'EOF'
<final message>
EOF
)"
```

If `git commit` fails (hook etc.): report stderr. Do NOT `--amend`. If rollback needed: `git reset --merge` (squash didn't create merge-state — `--abort` won't work).

### 12. Push and cleanup

- `git push origin <base>`
- `git branch -d <branch>` (local delete; `-D` only if user explicitly requests force)
- `git push origin --delete <branch>` (remote delete)
- If worktree was user-owned (step 3): `cd` to main worktree, then `git worktree remove <path>`

### 13. Verify issue closed

If an issue number was provided:
- `gh issue view <n> --json state` → must show `CLOSED`
- If still `OPEN`: report to user; offer `gh issue close <n>` as fallback

### 14. Final report

```
✓ Merged <branch> into <base>
Commit: <short-hash> "<title>"
Issue #<n>: closed ✓ (or "still open — manual close needed")
Branch: deleted (local + remote)
Worktree: cleaned up (or "harness-owned, left intact")
```

## Red Flags (STOP — do not merge)

- Current branch is `main` or `master`
- Working tree dirty (uncommitted changes)
- Detached HEAD (no branch)
- Test suite fails
- Linter fails
- Secret found in branch diff
- AI attribution found in branch commit history (must be cleaned first)
- Rebase produces conflicts user can't resolve in this session
- Tests fail after rebase

## Rules

- NEVER force push to `main` or `master`
- NEVER skip pre-merge verify gates
- NEVER include `Co-Authored-By: Claude` or any AI attribution in the squash message
- NEVER `--no-verify` or `--no-gpg-sign` unless user explicitly requests
- NEVER `--amend` to fix hook failure (create a NEW commit; or `git reset --merge` and start over)
- NEVER `git rebase -i` (interactive disallowed in this skill)
- NEVER auto-resolve merge conflicts — always ask user
- NEVER delete user-uncommitted state
- NEVER cleanup harness-owned worktrees
- ALWAYS use HEREDOC for multi-line commit messages
- ALWAYS show preview + await confirmation before push
- ALWAYS verify issue closed after push (if issue linked)
- ALWAYS re-run tests after rebase
