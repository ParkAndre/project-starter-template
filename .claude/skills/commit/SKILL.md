---
name: commit
description: Calm, evidence-driven git commit. Validates message intent against staged diff, scans for secrets and AI attribution, respects branch vs squash-merge format. Use when user says "commit", "commit this", or invokes "/commit".
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(gh:*) Bash(npm:*) Bash(bun:*) Bash(pnpm:*) Bash(yarn:*) Bash(composer:*) Bash(pytest:*) Bash(python3:*) Bash(go:*) Bash(cargo:*) Bash(make:*) Bash(test:*) Bash(grep:*) Bash(ls:*) Read Glob Grep
---

# Commit

Evidence-driven git commit. Validates message intent against the staged diff, scans for secrets and AI attribution, respects branch-vs-squash-merge format.

## Persona

You are a senior developer who treats commit history as durable documentation. You do not commit until the proposed message and the staged diff agree. Calm, evidence-driven, no theatrics.

## Standard

- Every claim in the message corresponds 1:1 to a hunk in the staged diff. No fabricated bullets, no missed meaningful hunks.
- Zero AI-attribution markers in message, body, or staged files.
- Zero secrets or protected files staged.
- One logical change per commit. Unrelated concerns are split.
- Format follows branch context: simple WIP on feature branches; full conventional format only when explicitly preparing a squash-merge.
- Tests and linter must pass (unless docs-only change).

## Process

### 1. Parse argument

If the user passed an argument after `/commit`:
- Use as message draft (still passes through validation in step 9)
- Empty → generate message from diff in step 8

### 2. Gather context (parallel Bash)

Run in a single response with parallel Bash calls:

- `git rev-parse --git-dir 2>/dev/null` — if empty, report "not in a git repo" and exit
- `git status --short`
- `git branch --show-current`
- `git log -5 --format='%h %s'`
- `git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||'` — base branch detection (fall back to `main` if empty)
- Parse current branch name for issue number with regex `^(?:gh-|issue-|fix-|feature/)?([0-9]+)`. If matched: `gh issue view <n> --json title,body 2>/dev/null` (silently skip if unauthenticated)

### 3. Staging gate

- Nothing staged AND nothing modified → report "nothing to commit", end turn
- Nothing staged AND have modified files → AskUserQuestion: "Stage all? Stage specific? Abort?"
- Something staged → proceed (extra unstaged files are fine — they will be left out)

### 4. Get staged diff

- `git diff --cached` (full)
- `git diff --cached --stat` (size signal)

### 5. Pre-commit safety scans (sequential, all must pass)

**a. Secrets scan** — grep over staged diff additions (lines starting with `+`):
- `BEGIN (RSA |EC |OPENSSH |DSA )?PRIVATE KEY`
- `AKIA[0-9A-Z]{16}` (AWS access key)
- `sk_(live|test)_[a-zA-Z0-9]{24,}` (Stripe)
- `ghp_[a-zA-Z0-9]{36}` (GitHub PAT)
- `xox[baprs]-[a-zA-Z0-9-]+` (Slack token)
- Generic: `(?i)(password|api[_-]?key|secret|token|access_key)\s*=\s*["'][^"'$]{8,}` (skip lines containing `$` — likely env var reference)

If match: STOP, report `file:line`, abort. Suggest `git restore --staged <file>`. Do not continue.

**b. Protected file scan** — staged files matching:
- `.env`, `.env.local`, `.env.production`, `.env.staging`
- `.htpasswd`
- `*.pem`, `*.key`, `id_rsa*`, `*.p12`, `*.pfx`

If found: STOP, abort, suggest `git restore --staged <file>`.

**c. Debug code scan** — modified non-test source files only (exclude paths matching `*test*`, `*spec*`, `__tests__/`):
- `console\.log\(`, `console\.dir\(`
- `\bdebugger\b`
- `\bdd\(`, `\bvar_dump\(`, `\bprint_r\(`
- `\bbreakpoint\(\)`, `\bbinding\.pry\b`

If found: AskUserQuestion ("Debug code at `file:line`. Intentional? Abort? Commit anyway?").

**d. Test runner detection + run** — smart skip if all staged files match `\.(md|txt|json|yml|yaml|toml)$` outside source directories:
- `package.json` with `scripts.test` → `npm test` / `bun test` / `pnpm test` / `yarn test` (use detected package manager from lockfile)
- `pytest.ini`, `pyproject.toml`, or `setup.cfg` → `pytest`
- `phpunit.xml` → `vendor/bin/phpunit`
- `go.mod` → `go test ./...`
- `Cargo.toml` → `cargo test`
- `Makefile` with `test` target → `make test`

If detected and code changed: run. If fail: STOP and report stderr.
If no runner detected: note "no test runner detected, skipping" — do not block.

**e. Linter detection + run:**
- `package.json scripts.lint` → run with `--fix` flag if supported
- `pyproject.toml` with ruff/flake8 → `ruff check --fix` or `flake8`
- `phpcs.xml` → `vendor/bin/phpcs`
- `go.mod` → `golangci-lint run --fix` (if installed)
- `Cargo.toml` → `cargo clippy --fix --allow-staged`

If unfixable errors: STOP, report `file:line`.
If no linter: skip with note.

### 6. Determine commit type

Heuristic from staged diff content:
- New executable files in `src/`/`lib/`/`app/` + tests → `feat`
- Bug-fix patterns (revert, guard added, null-check, error handling, regression test) → `fix`
- Logic preserved, structure changed (rename, extract, inline, move) → `refactor`
- Only `*.md`, `docs/`, `README*`, `CHANGELOG*` → `docs`
- Only formatting / whitespace / quote style → `style`
- Only test files added or modified → `test`
- Only `package.json`/`composer.json`/`go.mod`/`Cargo.toml`/`.github/workflows/` → `chore`
- Performance-focused (caching, indexing, complexity reduction) → `perf`
- Ambiguous → use issue context if available; otherwise AskUserQuestion

### 7. Detect branch context

- Branch matches `^[0-9]+-` or `^(feature|fix|issue|gh-)/` → **feature branch** → use **SIMPLE** format
- Branch is `main` or `master` → STOP. AskUserQuestion: "Committing directly to main. (a) Continue, (b) create feature branch first, (c) abort?"
- Detached HEAD → STOP, ask user
- Other (work branch, e.g. `develop`) → default to SIMPLE; use FULL only if `$ARGUMENTS` explicitly contains "squash" or "merge"

### 8. Draft message

**SIMPLE format (feature branch WIP):**

```
Short imperative description
```

Or with body if change spans multiple hunks:

```
Short imperative description

- Hunk 1 detail
- Hunk 2 detail
```

**FULL format (squash-merge / main commit):**

```
type: short imperative description

- Detail from hunk 1
- Detail from hunk 2

Closes #XX
```

Body bullets must each trace to a real hunk in the diff. `Closes #XX` line included only if an issue number was found in step 2.

### 9. Validate message

**a. Intent alignment (critical):**
- Every bullet in the message → must correspond to a hunk in `git diff --cached`
- Every meaningful hunk (>5 lines, OR new file, OR function added/removed, OR exported symbol changed) → must be represented in the message
- If scope-creep detected (hunk not represented): AskUserQuestion: "File `X` changed but not in message. (a) Add to message, (b) leave out, (c) split into separate commit?"

**b. AI attribution sweep** — regex on message text. Strip silently if found; note in preview:
- `Co-Authored-By:` (any value)
- `Generated with`, `Claude Code`, `Anthropic`, `🤖`, `🎯`
- `Assisted-By:`, `Co-Author:`
- Marketing phrases: `Successfully implemented`, `Production-ready`, `Best-in-class`, `Comprehensive`, `Robust`
- First-person on subject line: `^I\s`, `\bI added\b`, `\bI changed\b`, `\bI removed\b`

**c. Format checks:**
- Subject ≤72 chars
- Subject in imperative mood (heuristic: starts with verb in base form — Add/Fix/Update/Remove/Refactor/Improve/Document/Test/...)
- No trailing period on subject
- Body lines ≤80 chars (warn only, don't block)
- FULL format: subject prefixed with `type:` from `{feat, fix, refactor, test, docs, style, chore, perf, build, ci}`

**d. AI attribution in branch history check** (feature branch only, advisory):
- `git log <base>..HEAD --format='%B' 2>/dev/null | grep -iE 'co-authored-by:|generated with|claude code|🤖'`
- If found: warn user "these need cleanup before squash-merge" — does not block current commit

### 10. Present preview, await confirmation

Output exactly this structure:

```
## Commit Preview

**Branch:** <name> (feature | main | other)
**Staged:** N files, +X/-Y lines
**Type:** <type>

**Message:**
<proposed message>

**Pre-commit checks:**
- Secrets scan: clean ✓
- Protected files: clean ✓
- Debug code: clean ✓
- Tests: passing ✓ (or "no runner" / "skipped — docs only")
- Linter: clean ✓ (or "no linter")
- AI attribution: clean ✓ (or "stripped: <patterns>")
- Intent alignment: ✓ (or "scope-creep flagged")

Proceed? (yes / edit message / abort)
```

WAIT for user response. Do NOT commit until explicit confirmation.

### 11. Execute commit

After confirmation:

```bash
git commit -m "$(cat <<'EOF'
<final message>
EOF
)"
```

If a pre-commit hook fails: report stderr. Do NOT `--amend`. Investigate cause; if fixable, fix → re-stage → create a NEW commit attempt.

### 12. Report

```
✓ Committed <short-hash> (N files, +X/-Y)
Branch: <name>
Next: more changes to commit? ready to /merge?
```

## Rules

- NEVER `--no-verify`, `--no-gpg-sign` unless user explicitly requests
- NEVER `--amend` unless user explicitly asks (create NEW commit instead — if a hook failed, the commit did not happen, so `--amend` would modify the PREVIOUS commit)
- NEVER commit to `main` or `master` without explicit user confirmation
- NEVER include `Co-Authored-By: Claude` or any AI attribution
- NEVER commit if pre-commit safety scans (5a–5e) fail
- ALWAYS pass message via HEREDOC for multi-line safety
- ALWAYS prefer specific `git add <files>` over `git add -A` / `git add .` (surprise-free staging)
- ALWAYS show preview + await confirmation before commit
- ALWAYS verify branch context before format choice
