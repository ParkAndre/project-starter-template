# CLAUDE.md

## Critical Rules

- Use parameterized queries for all database operations
- Store all secrets in environment variables (`.env`)
- Always use feature branches with squash merge to main
- Omit all AI attribution from commits (no Co-Authored-By)
- Verify before claiming — run tests/app, confirm no errors, report actual state

---

## Commands

**CUSTOMIZE FOR YOUR PROJECT**

```bash
# npm run dev / npm test / npm run lint / npm run build
# pytest / python manage.py runserver
# php artisan serve / composer test
# go run . / go test ./... / go build
```

---

## Development Workflow

### Issue-Driven Development

Check `git status` before starting. Uncommitted changes → ask to commit or stash.

When asked to change project source code:

1. Ask: "Should we create a GitHub issue for this?"
2. If no: implement directly on current branch
3. If yes: use `/fix-issue` skill (end-to-end: issue draft → branch → TDD → merge), OR do it manually:
   - Draft issue title and acceptance criteria in Estonian → show to user
   - Wait for approval → translate to English
   - `gh issue create --title "Title" --body "Description"`
   - `gh issue develop <issue-number> --checkout`
   - Implement, then ask: "Should I squash merge to main and close issue #XX?"
   - If complete: rebase → squash merge → push → delete branch (or use `/merge` skill)

If code completed before issue creation: `gh issue create`, then `/commit` (which validates message intent + AI-attribution sweep).

**Related skills:** `/fix-issue` (full workflow), `/commit` (smart commit), `/merge` (squash + close), `/verify` (pre-merge gate), `/catchup` (resume work).

### Branch Naming

`<issue-number>-short-description` (lowercase kebab-case, e.g., `42-add-user-login`)

### Language & Unicode

- Use ASCII in code files
- Preserve correct Unicode in natural-language content (issues, PR text, docs, ä ö ü õ)

---

## Commit Guidelines

**Two separate workflows** (both automated by skills — see Related skills below):

### Branch Commits (Work in Progress)

Simple, descriptive: `Add event history modal UI`, `Fix styling on modal dialog`

Use `/commit` skill — it auto-detects branch context (feature vs main), validates intent (every claim ↔ diff hunk), scans for secrets + AI attribution, shows preview before committing.

### Squash Merge to Main (Final)

- `feat:` / `fix:` / `refactor:` / `style:` prefix
- Include `Closes #XX` on separate line when resolving issues
- Omit all AI attribution

Use `/merge` skill — it runs pre-merge gates (tests + lint + secrets + AI-attribution), rebases with interactive conflict handling, generates FULL conventional commit, pushes + deletes branch + verifies issue closed.

**Note:** **Local `git merge --squash` to main is the only merge workflow** — GitHub Pull Requests are NOT used in this project. The `/merge` skill (and equivalent manual `git checkout main && git merge --squash <branch> && git commit && git push origin main`) is fully authorized and required. Do NOT propose `gh pr create` or draft-PR workflows.

---

## Protected Areas

Ask before modifying:
- Database migration files (once committed), `.github/workflows/*`, lock files
- Authentication/authorization logic, database schemas, API contracts

---

## Imported Guidelines

@.claude/security.md
@.claude/testing.md
@.claude/standards.md

**Reference files** (read when relevant, not auto-loaded):
`.claude/api-design.md`, `.claude/database.md`, `.claude/issue-creation.md`

---

## Critical Rules (Repeated)

- Use parameterized queries for all database operations
- Store all secrets in environment variables (`.env`)
- Always use feature branches with squash merge to main
- Omit all AI attribution from commits (no Co-Authored-By)
- Verify before claiming — run tests/app, confirm no errors, report actual state
