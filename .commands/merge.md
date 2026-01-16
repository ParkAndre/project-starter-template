---
description: Squash merge current branch to main and close issue
argument-hint: [issue-number or leave empty to detect from branch]
allowed-tools: [Bash(git:*), Bash(gh:*), Bash(bun:*)]
---

# Squash Merge to Main

Merge current feature branch to main using squash merge.

## Pre-merge Checklist

1. **Verify not on main**: `git branch --show-current`
   - If on main → STOP and warn user

2. **Run all tests**: `bun test`
   - If any fail → STOP, do not merge

3. **Run linter**: `bun run lint` (if available)
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

# 3. Checkout main
git checkout main

# 4. Pull latest
git pull origin main

# 5. Squash merge
git merge --squash $BRANCH

# 6. Commit with proper message
git commit -m "Type: Description

Closes #XX"

# 7. Push to remote
git push origin main

# 8. Delete feature branch (local)
git branch -d $BRANCH

# 9. Delete feature branch (remote, optional)
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
