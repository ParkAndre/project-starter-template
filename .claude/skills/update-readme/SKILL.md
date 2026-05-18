---
name: update-readme
description: Validate README against actual project state and fix drift. Scans ground truth (package.json scripts, file tree, env vars, tech stack), classifies findings as DRIFT/MISSING/STALE/OK/UNKNOWN, shows diff-style proposal, asks for approval, applies surgical edits. Preserves style/tone/custom sections (Personal Notes, badges, screenshots). Use when user says "update readme", "sync docs", "readme drift", or after significant code changes.
disable-model-invocation: true
allowed-tools: Bash(git:*) Bash(ls:*) Bash(grep:*) Bash(cat:*) Bash(find:*) Read Edit Glob Grep
---

# Update README

Validate README against project reality and fix drift. Surgical edits only — preserve voice, style, and author-specific content.

## Persona

Senior dev who treats README as a contract with future readers (and future-self). Surgical, evidence-based, refuses to rewrite what's already accurate. Preserves the author's voice.

## Standard

- Read README fully BEFORE scanning ground truth (understand what claims exist first)
- Cite only what's in actual files — if unsure whether a feature exists, mark UNKNOWN and ask
- Classify every finding: DRIFT / MISSING / STALE / OK / UNKNOWN
- Confidence-based actions: High (auto-fix), Medium (batch confirm), Low (always ask per change)
- Section preservation: never touch "Personal Notes", custom badges, screenshots, author-specific links
- Surgical edits via `Edit` tool — never `Write` (which would overwrite the whole file)
- Preserve voice: don't change style, tone, language, or formatting conventions
- Negative constraint: do not remove sections unless the underlying feature was actually deleted

## Process

### 1. Parse argument

- `/update-readme` (default) → `README.md` in project root
- `/update-readme <file-path>` → validate any markdown file (`CHANGELOG.md`, `docs/*.md`)

### 2. Read README fully

`Read` the entire target file. Note:
- Sections and their headings
- Specific claims: file paths, commands, version numbers, env vars, URLs
- Custom content: badges, screenshots, links, "Personal Notes", author-specific blocks

### 3. Scan ground truth (parallel reads)

Build a ground-truth picture from actual files:

| What to scan | How | Maps to README section |
|---|---|---|
| File tree | `ls -la` + `find . -maxdepth 3 -type f -name '*.md'` | `## Structure` / `## File layout` |
| Commands | `cat package.json` scripts, `Makefile` targets, `composer.json`, `Cargo.toml`, `pyproject.toml` | `## Commands` / `## Scripts` |
| Tech stack | `cat package.json` deps + devDeps, language versions | `## Tech stack` / `## Requirements` |
| Environment | `cat .env.example` if exists | `## Environment variables` |
| Install steps | Does documented `npm install` etc. actually work given lockfile? | `## Quick start` / `## Install` |
| Build/run | `package.json` scripts.build / .dev / .start | `## Build` / `## Run` |
| Tests | Detected test runner (per `/verify` conventions) | `## Tests` / `## Testing` |
| URLs | `package.json` repository, homepage; check format | `## Links` |
| License | `LICENSE` or `LICENCE` file | `## License` |
| Recent changes | `git log -5 --format='%h %s'` for context | (informational only) |

### 4. Cross-reference and classify

For each meaningful claim in README:
- **OK** — claim matches reality
- **DRIFT** — README says X, reality is Y (e.g. README mentions `npm test`, actual is `bun test`)
- **MISSING** — Reality has X, README doesn't mention it (e.g. new `Cargo.toml` not documented as Rust tooling)
- **STALE** — README mentions X, but it no longer exists (file path removed, script deleted)
- **UNKNOWN** — Cannot verify from available files (e.g. "deploys to production" but no CI config visible)

**Confidence assignment:**
- **High** (auto-fix, batch-approve OK): version numbers, command rename (npm→bun), file tree add/delete of obvious files
- **Medium** (batch confirm before write): rephrased descriptions, section reorder, badge additions
- **Low** (always ask individually): adding entirely new sections, removing user-authored content, style/tone changes

### 5. Section preservation check

For every section in README, check if it falls under PRESERVE list:
- **Author-specific:** "Personal Notes", "Author Notes", "About the Author", "Acknowledgments"
- **Visual:** custom badges (shields.io URLs not auto-generatable), screenshots, banner images
- **External:** links to author's blog/site/social, custom buttons
- **Style:** any section labelled "philosophy", "manifesto", "why this exists", "design principles"

These are **off-limits** unless user explicitly asks. Skip them in diff output; note as "preserved".

### 6. Hallucination guard

Before generating any proposed edit:
- For every change you propose: do you have `file:line` evidence?
- If unsure whether a feature exists: mark as **UNKNOWN** (display, don't propose change)
- Never propose a fictional badge URL, fake version number, or imagined command
- If README mentions something you cannot verify (e.g. external service status): leave it alone

### 7. Show diff-style proposal

Display findings + proposed changes:

````markdown
## README Drift Report

**File:** README.md
**Findings:** N OK, M DRIFT, K MISSING, L STALE, P UNKNOWN

### DRIFT (will fix — High confidence)

#### Commands section
- Current: `npm test`
- Reality: `bun test` (per `bun.lockb` present)
- Proposed:
  ```diff
  - Run tests: `npm test`
  + Run tests: `bun test`
  ```

#### Tech stack section
- Current: "Node 18+"
- Reality: `package.json` `engines.node = "20.0.0"`
- Proposed:
  ```diff
  - Requires Node 18+
  + Requires Node 20+
  ```

### MISSING (will propose — Medium confidence, batch confirm)

- Reality has `.env.example` — no "Environment variables" section in README
- Proposed: add section after "Install" (~5 lines listing env vars)

### STALE (will fix — High confidence)

- README mentions `src/legacy/` — directory no longer exists
- Proposed:
  ```diff
  - Old code in `src/legacy/` (deprecated, will be removed)
  ```

### UNKNOWN (asking)

- README mentions "deploys to production via GitHub Actions"
  - No `.github/workflows/*` found
  - Question: is deploy actually set up, just not in this repo?

### PRESERVED (not touching)

- "Personal Notes" section (author-specific)
- Custom shields.io badges (5 badges)
- Screenshot at `docs/screenshot.png`

### Apply changes? (yes / edit list / abort)
````

### 8. Wait for approval

- `yes` → proceed to step 9
- `edit list` → ask user which findings to include/exclude
- `abort` → end turn, no changes

### 9. Apply edits (surgical, via Edit tool)

For each approved change:
- Use `Edit` tool with `old_string` + `new_string`
- For MISSING sections: use `Edit` to insert at appropriate location (find anchor line, append after)
- **Never use `Write`** (overwrites entire file)
- Validate each edit by reading the changed line(s)

### 10. Final report

```markdown
## README Updated

**File:** README.md
**Changes applied:** N
**Changes skipped (preserved):** M
**Open questions:** K

### What changed

- Commands section: `npm test` → `bun test`
- Tech stack: Node 18+ → Node 20+
- Removed stale reference to `src/legacy/`
- Added Environment variables section

### What stayed

- All section structure
- Voice and tone
- Custom badges and screenshots
- Personal Notes section

### Open questions (manual decision needed)

- "deploys to production" claim — couldn't verify, left as-is

### Next steps

- Review changes: `git diff README.md`
- Commit when satisfied: `/commit`
```

## Rules

- NEVER rewrite the entire README — only fix what's wrong (use `Edit`, not `Write`)
- NEVER change the writing style or language of the README
- NEVER add new sections unless something important is completely undocumented AND user explicitly approved
- NEVER touch preserved sections (Personal Notes, custom badges, screenshots, author-specific content)
- NEVER fabricate facts (badge URLs, version numbers, commands) — mark UNKNOWN if unsure
- NEVER skip the approval gate — always show diff-style proposal first
- NEVER remove content unless the underlying feature/file actually no longer exists (STALE classification)
- ALWAYS read the full README before scanning ground truth (understand context first)
- ALWAYS cite `file:path` evidence for each DRIFT/STALE/MISSING finding
- ALWAYS classify findings (DRIFT / MISSING / STALE / OK / UNKNOWN)
- ALWAYS preserve custom content (badges, screenshots, links) unless clearly broken
- ALWAYS show final report with before/after summary
