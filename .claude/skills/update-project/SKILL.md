---
name: update-project
description: Sync project with remote — stash WIP → fetch + rebase pull → pop stash → run migrations (Prisma/Drizzle/Django/Laravel/Rails) → install dependencies (multi-stack auto-detected). Pre-flight checks (in repo, remote reachable), preview before stash, conflict handling on rebase, smart skip for missing tools, structured summary. Use when user says "update project", "sync", "pull latest", or invokes "/update-project".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(npm:*) Bash(npx:*) Bash(bun:*) Bash(bunx:*) Bash(yarn:*) Bash(pnpm:*) Bash(python3:*) Bash(pip:*) Bash(poetry:*) Bash(composer:*) Bash(php:*) Bash(go:*) Bash(cargo:*) Bash(ls:*) Bash(test:*) Read Glob
---

# Update Project

Sync local project with remote. Stash WIP safely, rebase pull, run migrations, install dependencies, restore WIP. Multi-stack auto-detected. Structured summary.

## Persona

Senior dev who keeps the local environment in sync with remote — without losing WIP. Calm, confirms before destructive actions (stash with content, migrations), reports each step's outcome.

## Standard

- Pre-flight: verify git repo, verify remote reachable, detect base branch
- Preview WIP before stash — user sees what's being stashed
- Use `git pull --rebase` (clean linear history)
- Conflict handling on rebase: 3 options (resolve interactively / abort + merge / abort entirely)
- Smart skip: missing config = SKIP with note, not FAIL
- Confirmation before running migrations (user should know what changes apply)
- Structured summary: step-by-step status table

## Process

### 1. Parse argument

- `/update-project` (default) → all steps
- `/update-project --skip-migrate` → skip step 6 (migrations)
- `/update-project --skip-deps` → skip step 7 (dependencies)
- `/update-project --skip-migrate --skip-deps` → just git operations

### 2. Pre-flight checks (parallel Bash)

- `git rev-parse --git-dir 2>/dev/null` — verify in repo (else "not in a git repo", exit)
- `git branch --show-current` — current branch
- `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` — base branch (fallback `main`)
- `git remote get-url origin 2>/dev/null` — verify remote exists
- `git ls-remote origin HEAD > /dev/null 2>&1` — verify remote reachable (network check)
- `git status --short` — uncommitted state preview

### 3. Stash WIP (with preview)

If `git status --short` is empty → SKIP stash, jump to step 4.

If WIP present:
- Show preview: file list + diff stat (`git diff --stat` + `git diff --cached --stat`)
- Confirm: "Stash these N changes before update? (yes / abort)"
- If yes: `git stash push -u -m "auto-stash before /update-project"`
  - `-u` flag includes untracked files (often forgotten)
- If abort: end turn

### 4. Fetch and prune

```bash
git fetch --prune
```

Captures remote changes + removes stale remote-tracking branches.

Report: "N commits behind, M ahead" (from `git rev-list --count <current>..origin/<current>` and reverse).

### 5. Pull with rebase

```bash
git pull origin <current-branch> --rebase
```

**Conflict handling** if rebase produces conflicts:
- STOP, list conflict files via `git status`
- Ask user: "(a) Resolve interactively in editor (I'll wait), (b) abort rebase + use merge instead, (c) abort entirely"
- **(a)**: wait for "resolved" signal → `git rebase --continue`
- **(b)**: `git rebase --abort`, then `git pull origin <current-branch> --no-rebase` (merge commit is OK here)
- **(c)**: `git rebase --abort`, restore stash (step 8), end turn

NEVER `--no-edit`. NEVER `git rebase -i` (interactive disallowed).

### 6. Run migrations (skip if `--skip-migrate`)

Detect (parallel reads):

| Config file | Migration command |
|---|---|
| `prisma/schema.prisma` | `<runner> prisma migrate deploy` (runner = `bunx` if `bun.lockb` else `npx`) |
| `drizzle.config.*` | `<runner> drizzle-kit push` |
| `manage.py` (Django) | `python3 manage.py migrate` |
| `artisan` (Laravel) | `php artisan migrate` |
| `bin/rails` (Rails) | `bin/rails db:migrate` |
| Raw SQL in `migrations/` or `db/migrations/` | Inform user, do NOT auto-run |

For each detected:
- **Check for pending migrations first** where possible:
  - Prisma: `<runner> prisma migrate status`
  - Django: `python3 manage.py showmigrations --plan | grep '\[ \]'`
- If pending: confirm with user before running (could be DB schema change with data impact)
- Run; capture exit code + stderr
- FAIL → STOP step 6, but continue to step 7 (deps can still install)

If no config detected: SKIP with note "no migration config found".

### 7. Install dependencies (skip if `--skip-deps`)

Detect from lockfile / config:

| Detected | Command |
|---|---|
| `package.json` + `bun.lockb` / `bun.lock` | `bun install` |
| `package.json` + `pnpm-lock.yaml` | `pnpm install` |
| `package.json` + `yarn.lock` | `yarn install` |
| `package.json` + `package-lock.json` | `npm install` |
| `package.json` only (no lock) | `npm install` (default) |
| `requirements.txt` | `pip install -r requirements.txt` |
| `pyproject.toml` with `[tool.poetry]` | `poetry install` |
| `composer.json` | `composer install` |
| `go.mod` | `go mod download` |
| `Cargo.toml` | `cargo build` |

Multiple stacks → run all detected (e.g. Node + Python monorepo).

For each: capture exit code; FAIL → record but continue to remaining stacks.

### 8. Pop stash (if step 3 stashed)

If a stash was created in step 3:

```bash
git stash pop
```

If pop fails (conflict): STOP, show conflict files, instruct user to resolve manually. Do NOT auto-resolve.

### 9. Summary

Output structured table:

```markdown
## Project Updated

| Step | Status | Detail |
|---|---|---|
| Pre-flight | ✓ | repo, remote reachable, branch: <name> |
| Stash WIP | ✓ / SKIPPED | N files stashed / nothing to stash |
| Fetch + prune | ✓ | N branches pruned |
| Pull (rebase) | ✓ / SKIPPED / CONFLICT | M commits pulled / already up to date / conflict resolved |
| Migrations | ✓ / SKIPPED / FAIL | <tool> N migrations applied / no config / error details |
| Dependencies | ✓ / SKIPPED / FAIL | <package manager> updated / no config / error details |
| Pop stash | ✓ / SKIPPED / CONFLICT | restored / no stash / conflict — resolve manually |

**Net result:** <one-line summary>

- N commits pulled
- M migrations applied
- Dependencies updated for <stack list>

**Next steps:**
- Run `/verify quick` to confirm everything works
- If stash pop had conflicts: resolve in editor, then `git add` + `git commit` (or continue working in WIP)
```

## Rules

- NEVER stash without preview + confirmation when WIP is present
- NEVER `git pull` without `--rebase` (clean history preferred)
- NEVER `--no-edit`, NEVER `git rebase -i`
- NEVER auto-resolve merge conflicts (always ask user)
- NEVER skip pre-flight checks (in-repo + remote reachable)
- NEVER pop stash on a dirty working tree from rebase conflict (could cause double-conflict)
- NEVER auto-run migrations without showing pending changes first (where detectable)
- ALWAYS use `-u` flag on `git stash push` (include untracked files)
- ALWAYS detect package manager from lockfile (never hardcode `npm install`)
- ALWAYS continue to remaining steps after a single step's FAIL (need full picture)
- ALWAYS report exit code + step status in summary
- ALWAYS suggest `/verify quick` as next step after successful update
