# Update README

Validate README.md against actual project state and fix any drift between documentation and reality.

## Process

1. Read `README.md` fully.
2. Scan the actual project to collect ground truth:
   - File/directory tree (actual structure vs documented structure)
   - Configuration files: ports, URLs, environment variables
   - Available commands: `package.json` scripts, `Makefile` targets, `Cargo.toml`, `pyproject.toml`, `composer.json`, etc.
   - Tech stack: languages, frameworks, dependencies
   - Setup steps: do documented install/build/run commands actually work?
3. Compare README claims against reality. Flag each as:
   - **DRIFT** — README says X, reality is Y
   - **MISSING** — Reality has X, README doesn't mention it
   - **STALE** — README mentions X, but it no longer exists
   - **OK** — README matches reality
4. If no drift found: report "README is up to date" and stop.
5. If drift found: show a summary of all findings to the user and ask for approval before making changes.
6. Update README.md:
   - Fix only the drifted/missing/stale sections
   - Preserve the original language, tone, and formatting style
   - Do NOT rewrite sections that are already accurate
   - Do NOT add sections the user didn't have before
7. Show a final report:
   - What was updated (with before/after)
   - What was already accurate (brief list)

## Rules

- NEVER rewrite the entire README — only fix what's wrong
- NEVER change the writing style or language of the README
- NEVER add new sections unless something important is completely undocumented (ask first)
- ALWAYS show findings and get user approval before editing
- Preserve all custom content (badges, screenshots, links) unless clearly broken
