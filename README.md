# Claude Config — Project Starter Template

Technology-agnostic Claude Code configuration: security, testing, Git workflow, and custom skills/commands that work in any project.

**Source of truth** for portable AI development tools — install locally for personal use, fork for your team, adapt for other AI tools (Cursor, GitHub Copilot, Aider — see Roadmap).

---

## Quick Start

### Install in a new project

```bash
mkdir my-project && cd my-project
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash
git init && git add . && git commit -m "Initial commit"
```

### Add to an existing project

```bash
cd existing-project
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash
git add CLAUDE.md .claude/ .gitignore && git commit -m "Add starter template"
```

### Verify

Ask Claude Code: *"What are our commit conventions?"* — it should explain the TWO-workflow rule (simple messages on feature branches, full `feat:`/`fix:` format for squash merges).

---

## Architecture

This template uses the **Skills** format (`SKILL.md`) for all AI-driven workflows:

| Format | Location | Status | Use case |
|---|---|---|---|
| **Skills** (`SKILL.md`) | `.claude/skills/<name>/SKILL.md` | Current standard | Rich frontmatter, progressive disclosure (`references/*.md`), per-skill directory |
| **Commands** (`*.md`) | `.claude/commands/<name>.md` | Deprecated | Single file, simpler frontmatter — all 14 commands now migrated to skills |

**Migration complete.** All 14 legacy commands have been rewritten as skills. See `SKILL-UPGRADE-GUIDE.md` for the migration methodology used.

---

## Current Skills (14/14 — migration complete ✓)

| Skill | Location | What it does |
|---|---|---|
| `/analyze <target>` | `.claude/skills/analyze/SKILL.md` | Read-only deep analysis and problem diagnosis. 5 modes (Quick/Standard/Deep/Diagnostic/Comparison), structured findings with confidence levels, mermaid diagrams, hypothesis testing with 3-failure stop rule. Identifies causes; does not propose code changes |
| `/catchup [branch]` | `.claude/skills/catchup/SKILL.md` | Read-only branch context summary. Shows branch, issue, recent commits, changed files, AC progress, uncommitted + stashed changes, last-commit age, suggested next steps. Reads handoff files from `/fix-issue` |
| `/commit` | `.claude/skills/commit/SKILL.md` | Evidence-driven git commit. Intent alignment (message matches diff hunks), secrets scan, AI-attribution sweep, branch-context format (simple vs squash-merge), preview before commit |
| `/e2e [args]` | `.claude/skills/e2e/SKILL.md` | Run Playwright end-to-end tests. Auto-detect package manager + Playwright install + browser availability + webServer config. Three modes (all/file/grep). Structured failure report with Error → Cause → Fix table. Playwright-only (Cypress/Selenium → migration suggest) |
| `/fix-issue <n>` | `.claude/skills/fix-issue/SKILL.md` | End-to-end issue implementation. Triage gate, sub-agent codebase exploration, TDD with RED-gate verification, status discipline (DONE/CONCERNS/CONTEXT/BLOCKED), local squash-merge completion (this project does NOT use GitHub PRs) |
| `/merge [issue]` | `.claude/skills/merge/SKILL.md` | Squash merge feature branch to base + close issue. Pre-merge gates (tests + lint + secrets + AI-attribution), rebase with interactive conflict prompt, re-run tests after rebase, FULL commit format, branch cleanup, verify issue closed |
| `/refactor [path] [apply]` | `.claude/skills/refactor/SKILL.md` | Safe dead-code removal. Per-pattern codes (DEAD-1..7), confidence levels (90+/80-89/<80), commit-before-refactor gate, oscillation guard, preview-first by default |
| `/research <query>` | `.claude/skills/research/SKILL.md` | Web research with cost-graded tool ladder (WebSearch → WebFetch → Playwright MCP). Reconnaissance-then-action, structured sources table, hallucination guard ("retract claims you can't quote"), depth modes (--quick 3 / --deep 10+). Captcha + session reuse |
| `/review` | `.claude/skills/review/SKILL.md` | Code review with 6 parallel specialist agents (correctness+domain, security, reliability, performance, maintainability, test quality). Mitigation discipline, intent alignment, post-fix self-review |
| `/security-scan [mode]` | `.claude/skills/security-scan/SKILL.md` | Diff-only security review with data flow tracing. Confidence ≥8/10, concrete exploit scenarios, hard exclusions list, rationalizations-to-reject table, risk auto-elevation when diff touches auth/crypto/validation |
| `/tdd <AC>` | `.claude/skills/tdd/SKILL.md` | Standalone TDD loop with Iron Law enforcement ("NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST"). RED → Verify RED (runtime vs compile-time) → GREEN (minimal) → optional REFACTOR. Rationalizations-to-reject table, When Stuck decision table |
| `/update-project [--skip-migrate] [--skip-deps]` | `.claude/skills/update-project/SKILL.md` | Sync project with remote. Stash WIP with preview, fetch + rebase pull (interactive conflict prompt), run migrations (Prisma/Drizzle/Django/Laravel/Rails), install dependencies (multi-stack auto-detected), pop stash, structured summary |
| `/update-readme [file]` | `.claude/skills/update-readme/SKILL.md` | Validate README against project reality and fix drift. Source-of-truth scan (package.json scripts, file tree, env vars), DRIFT/MISSING/STALE/OK/UNKNOWN classification, diff-style proposal, surgical Edit (preserves voice + custom sections like Personal Notes + badges) |
| `/verify [mode]` | `.claude/skills/verify/SKILL.md` | Pre-merge quality gate. Multi-stack detection, severity ladder (CRITICAL/MAJOR/MINOR/INFO), always-on safety gates (secrets + AI-attribution + debug-code). Three modes: quick (lint+tests), full (+typecheck+build), strict (+commented-code+coverage) |

---

## Imported Guidelines (auto-loaded by Claude Code)

Imported via `@.claude/*.md` in `CLAUDE.md` — load automatically each session:

| File | Purpose |
|---|---|
| `.claude/security.md` | OWASP ASVS 5.0-based security rules |
| `.claude/testing.md` | TDD workflow, coverage thresholds, edge cases |
| `.claude/standards.md` | Code quality, accessibility, logging |

**Reference files** (on-demand, not auto-imported — read when relevant):
- `.claude/api-design.md` — REST/API conventions
- `.claude/database.md` — Migration and ORM guidance
- `.claude/issue-creation.md` — Bilingual issue draft workflow

---

## File Structure

```
claude-config/
├── CLAUDE.md                                  # Main config (auto-loaded)
├── CLAUDE.local.md.example                    # Personal notes template (gitignored)
├── README.md                                  # This file
├── KOKKUVÕTE.md                               # Estonian methodology + sources
├── SKILL-UPGRADE-GUIDE.md                     # Skill migration methodology (Estonian)
├── install.sh                                 # Bootstrap script
├── .gitignore                                 # Generic starter
└── .claude/
    ├── security.md                            # @import (auto-loaded)
    ├── testing.md                             # @import (auto-loaded)
    ├── standards.md                           # @import (auto-loaded)
    ├── api-design.md                          # On-demand reference
    ├── database.md                            # On-demand reference
    ├── issue-creation.md                      # On-demand reference
    ├── settings.json.example                  # Hooks template
    ├── settings-hooks-examples.md             # Per-stack hook examples
    └── skills/                                # All 14 skills (SKILL.md format)
        ├── analyze/SKILL.md
        ├── catchup/SKILL.md
        ├── commit/SKILL.md
        ├── e2e/SKILL.md
        ├── fix-issue/SKILL.md
        ├── merge/SKILL.md
        ├── refactor/SKILL.md
        ├── research/SKILL.md
        ├── review/SKILL.md
        ├── security-scan/SKILL.md
        ├── tdd/SKILL.md
        ├── update-project/SKILL.md
        ├── update-readme/SKILL.md
        └── verify/SKILL.md
```

---

## How It Works

`CLAUDE.md` loads automatically in every Claude Code conversation in this project. It imports `.claude/security.md`, `.claude/testing.md`, `.claude/standards.md` via `@`-syntax.

Skills in `.claude/skills/<name>/SKILL.md` are discovered automatically and invocable via `/<name>`. Their `disable-model-invocation: true` frontmatter prevents Claude from auto-triggering them — manual invocation only.

Commands in `.claude/commands/` are also discoverable but use the older single-file format.

**You never need to** paste guidelines into chat or remind Claude of rules.

---

## Creating New Skills

A skill is a directory with one `SKILL.md` file:

```markdown
---
name: my-skill
description: Short description. Use when user says X, Y, or Z.
disable-model-invocation: true
allowed-tools: Bash(git:*) Read Glob Grep
---

# My Skill

## Persona
[1 paragraph defining the agent's role and disposition]

## Standard
[5-8 rules the skill enforces]

## Process
[Numbered steps, imperative voice]

## Rules
[NEVER / ALWAYS statements]
```

**Frontmatter notes:**
- `disable-model-invocation: true` — manual `/my-skill` only (recommended for side-effect-heavy skills like commits, merges)
- `disable-model-invocation: false` — Claude can auto-invoke based on `description` (use for utility / read-only skills)
- `allowed-tools` is a **space-separated string** (not array): `Bash(git:*) Bash(npm:*) Read Glob`

**Anthropic recommends keeping SKILL.md under 500 lines** (ideally 200-300). For longer content, split into `references/<topic>.md` files in the same directory and reference from SKILL.md.

See existing skills (`commit`, `fix-issue`, `refactor`, `review`) as concrete examples.

---

## Roadmap

### Skill migration ✓ complete

All 14 commands have been rewritten as skills (analyze, catchup, commit, e2e, fix-issue, merge, refactor, research, review, security-scan, tdd, update-project, update-readme, verify).

Methodology: `SKILL-UPGRADE-GUIDE.md` — research best practices → plan → write → verify → delete legacy. Each skill has its own `SKILL.md` with frontmatter (name, description, `disable-model-invocation`, tight `allowed-tools`) and an imperative body.

### Multi-AI portability (planned)

Skills are written with portable body content (e.g. "ask user to confirm" instead of "use AskUserQuestion tool", "shell command" instead of "Bash tool"). Future installer scripts will generate adapters:

| Tool | Target | Status |
|---|---|---|
| **Claude Code** (global) | `~/.claude/skills/<name>/SKILL.md` | Manual `cp -r` today; scripted later |
| **Cursor** | `<project>/.cursor/rules/<name>.mdc` | Transform: strip Claude frontmatter, add Cursor frontmatter |
| **GitHub Copilot** | `<project>/.github/copilot-instructions.md` | Concatenate skill bodies |
| **Aider** | `<project>/.aider.conf.yml` `system_prompts` | Extract body, inline |
| **ChatGPT Custom GPTs** | `instructions` field | Manual paste |

Until adapters ship, copy a skill's body (everything below frontmatter) and paste into your other tool's instruction field.

### Other planned items

- `references/<topic>.md` progressive disclosure for skills that exceed 300 lines
- Hook-level enforcement (e.g. PreToolUse hook blocking commits containing `BEGIN PRIVATE KEY`)
- Optional `/simplify` skill for NAMING/SIMPLIFY/MODERN refactors (sibling to dead-code `/refactor`)

---

## Customization

After installing into your project, customize these:

### `CLAUDE.md` (required)
- Fill in your build/test/dev commands under "Commands"
- Add team-specific Critical Rules

### `.gitignore` (recommended)
- Remove rules not applicable to your stack
- Add project-specific patterns

### `.claude/*.md` (optional)
- `security.md` — add project-specific security requirements
- `testing.md` — adjust coverage thresholds
- Delete files you don't need (`database.md` for static sites, etc.)

### `.claude/skills/` (optional)
- Edit existing skills to fit your project's tools
- Add new skills following the format above

---

## FAQ

### Why split into skills + imported guidelines?

**Different things, different formats.** Skills are invocable workflows (`/commit`, `/review`). Guidelines (`security.md`, `testing.md`) are continuously-applied rules. Skills load on invocation; guidelines load on every session.

### How much context does this use per session?

Auto-loaded content (`CLAUDE.md` + 3 imported guidelines) is ~450 lines. Skills load only when invoked. Reference files (`api-design.md`, etc.) load on demand.

### Can I use this with other AI tools (Cursor, Copilot, Aider)?

See Roadmap above. **Today:** copy a skill's body (everything below frontmatter) and paste into your other tool's instruction field. **Future:** installer scripts will automate this per tool.

### Why `skills/` and not `commands/`?

`skills/` is the current Claude Code standard (directory per skill, richer frontmatter — `disable-model-invocation`, `allowed-tools`, `version` — progressive disclosure via `references/*.md`). `commands/` was the older single-file format; this template's 14 commands have all been migrated to `skills/`. The `commands/` directory has been removed entirely — if you need to use the older format in your own project, simply create `.claude/commands/` manually.

### How do I update when the template improves?

```bash
cp CLAUDE.md CLAUDE.md.backup
cp -r .claude .claude.backup
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash
# Merge your Commands section and any custom rules back from backups
```

### Why is `KOKKUVÕTE.md` in Estonian?

It documents the design rationale, sources, and trade-offs behind every decision in this template, in the author's first language. Practical "how to use" content lives in this README (English). Use `KOKKUVÕTE.md` if you want the *why* behind specific choices.

### Why is `SKILL-UPGRADE-GUIDE.md` in Estonian?

Same reason — it's a working methodology document for the migration effort. The principles (research → plan → write → verify) are universal; the prose is Estonian.

### Claude isn't following a rule

1. Make the rule more specific (add a concrete example)
2. Use stronger language (`ALWAYS` / `NEVER`)
3. Move it to "Critical Rules" in `CLAUDE.md`

### Changes not taking effect

- Press `#` in Claude Code to reload `CLAUDE.md`
- New conversations apply changes automatically
- For imported `@.claude/*.md` files: Claude re-reads on each new conversation

---

## Links

- [Claude Code documentation](https://docs.anthropic.com/en/docs/claude-code)
- [Claude Skills documentation](https://code.claude.com/docs/en/skills)
- [Claude sub-agents documentation](https://code.claude.com/docs/en/sub-agents)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)
- [SKILL-UPGRADE-GUIDE.md](./SKILL-UPGRADE-GUIDE.md) — migration methodology (Estonian)
- [KOKKUVÕTE.md](./KOKKUVÕTE.md) — full design rationale + sources (Estonian)

---

Free to use in any project. No attribution needed.
