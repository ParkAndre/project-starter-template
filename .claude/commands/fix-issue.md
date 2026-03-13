---
description: End-to-end issue implementation workflow
argument-hint: <issue-number>
allowed-tools: [Bash(git:*), Bash(gh:*), Bash(npm:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(bun:*), Bash(bunx:*), Bash(composer:*), Bash(python3:*), Bash(pytest:*), Bash(go:*), Bash(cargo:*), Bash(make:*), Read, Write, Edit, Glob, Grep, Agent]
---

# Fix Issue

End-to-end issue implementation following project workflow. Takes a GitHub issue from reading to squash merge.

## Usage

- `/fix-issue <number>` — implement a specific GitHub issue
- `/fix-issue` — list open issues and ask which one

## Process

1. **Read the issue:**
   - `gh issue view <number>`
   - Summarize: goal, acceptance criteria, dependencies
   - Check if blocked by other issues

2. **Create branch and start work:**
   - `gh issue develop <number> --checkout`
   - If branch creation fails, create manually: `git checkout -b <number>-short-description`

3. **Plan the implementation:**
   - Enter plan mode
   - Identify files to create/modify
   - Check for existing patterns in the codebase to follow
   - List implementation steps mapped to acceptance criteria
   - Exit plan mode for user approval

4. **Implement with TDD:**
   - For each acceptance criterion:
     - Write test first (RED)
     - Implement minimum code (GREEN)
     - Refactor if needed
   - Commit after each meaningful chunk (use branch commit style)

5. **Verify everything:**
   - Run full test suite — all must pass
   - Check for debug code, commented code, unused imports
   - Verify each AC is met

6. **Offer completion:**
   - Show summary of changes (files modified, tests added)
   - Ask: "Is there anything else to change, or should I squash merge to main and close issue #XX?"
   - If complete:
     - `git checkout main && git merge --squash <branch>`
     - Commit with: `<issue title>\nCloses #XX`
     - NEVER include "Co-Authored-By: Claude" in commit message
     - `git push origin main`
     - Verify issue is closed: `gh issue view <number>`

## Rules

- ALWAYS follow the workflow from CLAUDE.md (issue → branch → implement → merge)
- ALWAYS use TDD (test before implementation) per `.claude/testing.md`
- ALWAYS verify before offering to merge
- Use branch commit messages while working, squash merge message when done
- If issue has no clear acceptance criteria, ask user to clarify before starting
- If implementation reveals the issue scope is too large, suggest splitting
- NEVER push to main directly — always squash merge from branch
