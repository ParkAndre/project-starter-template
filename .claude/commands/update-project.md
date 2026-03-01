---
name: update-project
description: Updates project by stashing changes, pulling latest from remote, restoring stashed changes, running database migrations, and updating dependencies.
allowed-tools: Bash(git:*), Bash(npm:*), Bash(bun:*), Bash(bunx:*), Bash(npx:*), Bash(yarn:*), Bash(pnpm:*), Bash(mysql:*), Bash(python3:*), Bash(pip:*), Bash(composer:*), Bash(php:*), Bash(go:*), Bash(cargo:*), Read, Glob
---

# Update Project

This skill automates the complete project update workflow.

## Steps to Execute

Follow these steps in order:

### 1. Stash Current Changes

```bash
git stash push -m "auto-stash before update"
```

Note: If there are no changes to stash, this is fine - continue to next step.

### 2. Fetch and Prune

Fetch all remote changes and remove stale remote-tracking branches:

```bash
git fetch --prune
```

### 3. Pull Latest from Remote

First, determine the current branch:

```bash
git branch --show-current
```

Then pull with rebase:

```bash
git pull origin <current-branch> --rebase
```

### 4. Pop Stashed Changes

```bash
git stash pop
```

Note: If there was no stash or stash is empty, this will show an error - that's fine, continue.

### 5. Run Database Migrations

Check for and run migrations based on project type:

**For Prisma (prisma/schema.prisma exists):**
```bash
npx prisma migrate deploy
# or: bunx prisma migrate deploy
```

**For Drizzle (drizzle.config.ts exists):**
```bash
npx drizzle-kit push
# or: bunx drizzle-kit push
```

**For Django (manage.py exists):**
```bash
python3 manage.py migrate
```

**For Laravel (artisan exists):**
```bash
php artisan migrate
```

**For Rails (bin/rails exists):**
```bash
bin/rails db:migrate
```

**For Go/GORM or other:**
- Check for migration files in `migrations/`, `db/migrations/`
- Inform user about available migrations

Only run migration commands if the relevant config files exist.

### 6. Update Dependencies

Detect and run appropriate command:

**Node.js (package.json exists):**
```bash
# Check for lock file to determine package manager
npm install    # if package-lock.json
bun install    # if bun.lockb
yarn install   # if yarn.lock
pnpm install   # if pnpm-lock.yaml
```

**Python (requirements.txt exists):**
```bash
pip install -r requirements.txt
```

**Python Poetry (pyproject.toml with poetry):**
```bash
poetry install
```

**PHP/Composer (composer.json exists):**
```bash
composer install
```

**Go (go.mod exists):**
```bash
go mod download
```

**Rust (Cargo.toml exists):**
```bash
cargo build
```

### 7. Summary

After completing all steps, provide a brief summary:
- Whether stash was needed and restored
- What was pulled (commits behind/ahead)
- Which migrations were run (if any)
- Which dependencies were updated

## Error Handling

- If `git pull` fails due to conflicts, inform the user and don't proceed with stash pop
- If migrations fail, show the error and let user decide how to proceed
- If dependency install fails, show the error but continue with summary
