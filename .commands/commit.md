---
description: Create a well-formatted git commit with conventional message
argument-hint: [message or leave empty for auto-generate]
allowed-tools: [Bash(git:*), Bash(bun:*), Read]
---

# Smart Commit

Create a git commit following project conventions.

## Pre-commit Checks

Before committing, verify:

1. **Run tests**: `bun test`
   - If tests fail → FIX before committing
   - NEVER skip tests

2. **Run linter**: `bun run lint` (if available)
   - Auto-fix what's possible
   - Manual fix the rest

3. **Check for debug code**:
   - No `console.log` (except error handling)
   - No `debugger` statements
   - No commented-out code blocks

## Commit Process

1. **Check status**: `git status`
   - Review what will be committed
   - Ensure no sensitive files (.env, keys, secrets)

2. **Stage changes**: `git add <files>` or `git add -A`

3. **Determine commit type** from changes:
   - `feat:` - New feature
   - `fix:` - Bug fix
   - `refactor:` - Code change that neither fixes nor adds
   - `test:` - Adding or updating tests
   - `docs:` - Documentation only
   - `style:` - Formatting, no code change
   - `chore:` - Maintenance tasks

4. **Create commit message**:
   - If $ARGUMENTS provided, use as base
   - If empty, analyze changes and generate

5. **Format**:
   ```
   type: short description (max 50 chars)

   - Detail 1
   - Detail 2

   Closes #XX (if applicable)
   ```

6. **Commit**: `git commit -m "message"`

## Rules

- NEVER include `Co-Authored-By: Claude` in commits
- NEVER commit without running tests first
- NEVER commit .env, secrets, or credentials
- If on feature branch, simple messages OK
- If squash merging to main, use full format with `Closes #XX`

## After Commit

Report:
- Commit hash (short)
- Files changed count
- Insertions/deletions
