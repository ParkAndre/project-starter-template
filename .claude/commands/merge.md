---
description: Squash merge current branch to main and close issue
argument-hint: [issue-number or leave empty to detect from branch]
allowed-tools: [Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(bun:*), Bash(bunx:*), Bash(composer:*), Bash(python3:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*), Bash(make:*), Read, Glob]
---

# Squash Merge to Main

Merge current feature branch to main using squash merge.

## Pre-merge Checklist

1. **Verify not on main**: `git branch --show-current`
   - If on main → STOP and warn user

2. **Run all tests**: Detect test runner from project config and run:
   - `package.json` → check scripts for test command (`npm test`, `bun test`, etc.)
   - `pytest.ini` / `pyproject.toml` → `pytest`
   - `phpunit.xml` → `vendor/bin/phpunit`
   - `go.mod` → `go test ./...`
   - `Cargo.toml` → `cargo test`
   - If any fail → STOP, do not merge

3. **Run linter**: Detect linter from project config and run if available
   - Must pass

4. **Check for uncommitted changes**: `git status`
   - If dirty → commit or stash first

## Get Issue Number

1. If $ARGUMENTS provided → use that
2. Else extract from branch name (e.g., `42-feature-name` → #42)
3. If no issue number found → ask user

## Merge Process

```bash
# 1. Get current branch name
BRANCH=$(git branch --show-current)

# 2. Fetch latest main
git fetch origin main

# 3. Rebase on latest main (resolve conflicts before merging)
git rebase origin/main

# 4. Checkout main
git checkout main

# 5. Pull latest
git pull origin main

# 6. Squash merge
git merge --squash $BRANCH

# 7. Commit with proper message
git commit -m "Type: Description

Closes #XX"

# 8. Push to remote
git push origin main

# 9. Delete feature branch (local)
git branch -d $BRANCH

# 10. Delete feature branch (remote)
git push origin --delete $BRANCH
```

## Commit Message Format

Determine type from changes:
- New feature → `feat: Description`
- Bug fix → `fix: Description`
- Refactor → `refactor: Description`

Always include `Closes #XX` on separate line.

## Rules

- NEVER force push to main
- NEVER skip tests before merge
- NEVER merge without issue number (ask user if missing)
- NEVER include `Co-Authored-By: Claude`
- ALWAYS pull latest main before merge

## After Merge

Report:
- Merged branch name
- Issue number closed
- Commit hash on main
- Confirm branch deleted
