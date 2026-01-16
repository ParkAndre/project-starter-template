# CLAUDE.md

> **About this file:** Claude Code automatically reads this file at the start of every conversation. All guidelines here and imported files become Claude's instructions. You never need to manually remind Claude - it already knows!

---

## Development Workflow

### Issue-Driven Development

When asked to change project source code:

1. Ask: "Should we create a GitHub issue for this?"
2. If yes:
   - Create issue: `gh issue create --title "Title" --body "Description"`
   - Create and checkout branch: `gh issue develop <issue-number> --checkout`
   - Implement and commit changes to branch
   - Ask: "Is there anything else you want to change, or should I squash merge this to main and close issue #XX?"
   - If complete:
     - Squash merge: `git checkout main && git merge --squash XX-short-descr`
     - Commit with proper message: `git commit`
     - Push: `git push origin main`

**Note:** If code changes completed first and issue created afterwards, skip branch creation. Create issue with `gh issue create`, commit directly to main with `Closes #XX` in message.

### Issue Templates

**Feature:**
Title: `As a [role] I [can/want to] [action] so that [benefit]`
```
As a [role] I [can/want to] [action] so that [benefit]

Acceptance criteria:
- There is a new menu item called "Logs" in the main menu
- Clicking that takes to /logs which shows a list of events
- The most recent events are on the top
```
Format: One sentence per line, start with capital, simple and testable.

**Bug:** Title: `[Brief description]` | Labels: `bug`
```
1. [Reproduction steps]
Expected: [What should happen]
Actual: [What happens]
```

---

## Commit Guidelines

**IMPORTANT: There are TWO separate commit workflows**

### Workflow 1: Branch Commits (Work in Progress)

Simple, descriptive messages while working on a feature branch. Commit frequently.

**Examples:**
- `Add event history modal UI`
- `Implement move tracking with from/to locations`
- `Fix styling on modal dialog`

**Rules:** Keep it simple, NO "Closes #XX" needed, NO formal format required

### Workflow 2: Squash Merge to Main (Final Commit)

ONLY when squash merging completed feature to main. Creates clean history and closes issue.

**Format:**
- Features: `As a [role] I [action] so that [benefit]\nCloses #XX`
- Fixes: `Fix: [description]\nCloses #XX`
- Refactor: `Refactor: [description]`
- Style: `Style: [description]`

**Examples:**
```
Fix: Return proper error message for unauthorized AJAX requests
Closes #123

- Changed empty array response to include 'Authorization required' message
- Updated error handling middleware
```

```
As a student I can see my learning outcomes
Closes #80
```

**Rules:**
- ALWAYS include `Closes #XX` on separate line when resolving issues
- NEVER include "Co-Authored-By: Claude" or any Claude attribution
- Use detailed commit body for complex changes

**Bad commit messages:** `wip`, `fixed stuff`, `updates`, `changes`

---

## Verification Standards

**NEVER claim something is working unless you have actually verified it:**

- Run the application/tests and confirm no errors
- Check actual outputs and behavior
- If verification fails, report the actual error - don't claim it works

Example: Don't say "Docker is running on port 3000" unless you ran `docker compose up` and verified it started without errors.

---

## Commands

**⚠️ CUSTOMIZE THIS SECTION FOR YOUR PROJECT ⚠️**

```bash
# [YOUR_COMMANDS] - Replace with your actual project commands

# Node.js/Bun:
# npm run dev       # Start development server
# npm run build     # Build for production
# npm test          # Run tests
# npm run lint      # Run linter

# PHP:
# php artisan serve # Start dev server (Laravel)
# composer test     # Run tests
# composer install  # Install dependencies

# Python:
# python manage.py runserver  # Start dev server (Django)
# pytest                      # Run tests
# pip install -r requirements.txt  # Install dependencies

# Go:
# go run .          # Run application
# go test ./...     # Run tests
# go build          # Build binary
```

---

## File Placement

**General Structure (Technology-Agnostic)**

| Component Type | Typical Location |
|----------------|------------------|
| UI Components | `/src/components` or `/src/views` |
| Routes/Controllers | `/src/routes` or `/src/controllers` |
| Business Logic | `/src/services` or `/src/lib` |
| Data Models | `/src/models` or `/src/entities` |
| Utilities | `/src/utils` or `/src/helpers` |
| Type Definitions | `/src/types` or `/src/interfaces` |
| Middleware | `/src/middleware` |
| Configuration | `/src/config` or `/config` |
| Tests | Next to file or `/tests` |
| Database Migrations | `/migrations` or `/db/migrations` |
| Static Assets (bundled) | `/src/assets` |
| Static Files (served) | `/public` or `/static` |

**Stack-Specific Examples:**

<details>
<summary>React/Node.js</summary>

```
src/
├── components/      # React components
├── pages/          # Next.js pages or route components
├── routes/         # Express routes (API)
├── lib/            # Utilities and helpers
├── models/         # Database models (Prisma, TypeORM)
├── types/          # TypeScript types
├── middleware/     # Express middleware
├── hooks/          # Custom React hooks
└── assets/         # Images, fonts
public/             # Static files (favicon, robots.txt)
```
</details>

<details>
<summary>PHP/Laravel</summary>

```
app/
├── Http/
│   ├── Controllers/  # Request handlers
│   └── Middleware/   # HTTP middleware
├── Models/           # Eloquent models
├── Services/         # Business logic
└── View/             # View composers
resources/
├── views/            # Blade templates
└── js/               # Frontend assets
public/               # Publicly accessible files
database/migrations/  # Database migrations
```
</details>

<details>
<summary>Python/Django</summary>

```
app_name/
├── views.py          # Request handlers
├── models.py         # Database models
├── urls.py           # URL routing
├── serializers.py    # API serializers
├── services.py       # Business logic
└── utils.py          # Helper functions
templates/            # HTML templates
static/               # Static files
migrations/           # Database migrations
```
</details>

---

## Imported Guidelines

@.claude/security.md
@.claude/testing.md
@.claude/api-design.md
@.claude/structure.md
@.claude/database.md
@.claude/standards.md
@.claude/issue-creation.md

---

## Critical Rules Summary

### Always
- Create GitHub issues for features and bugs
- Write tests for new features
- Remove console.log and commented code before committing
- Use environment variables for secrets
- Validate user input
- Use parameterized queries (prevent SQL injection)
- Design code to be modular (separate concerns, reusable components)

### Never
- Commit directly to main
- Include "Co-Authored-By: Claude" in commits
- Store secrets in code
- Modify database directly in production
- Expose error details to users
- Trust client-side validation alone

### Protected Areas

**NEVER modify without explicit approval:**
- Database migration files (once committed)
- `.github/workflows/*` (CI/CD configs)
- `package-lock.json` or `bun.lock` (unless updating deps)

**ALWAYS ask before:**
- Changing authentication/authorization logic
- Modifying database schemas
- Adding new dependencies
- Changing API contracts
