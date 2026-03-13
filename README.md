# Project Starter Template

Technology-agnostic project guidelines with Claude Code configuration. Provides security best practices, testing requirements, and Git workflow for any tech stack.

---

## Quick Start

### Install in New Project

```bash
mkdir my-project && cd my-project

# Install template
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash

# Initialize git
git init
git add .
git commit -m "Initial commit with project starter template"
```

### Add to Existing Project

```bash
cd existing-project

# Install template
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash

# Commit
git add CLAUDE.md .claude/ .husky/ .gitignore
git commit -m "Add project starter template and guidelines"
```

### Verify It Works

Ask Claude Code: "What are our commit message conventions?"

If Claude answers correctly with the TWO workflow explanation, it's working.

---

## What's Included

```
CLAUDE.md                          # Main config
CLAUDE.local.md.example            # Personal notes template (gitignored)
.gitignore                         # Comprehensive starter template
.claude/
├── security.md                    # Security guidelines (OWASP-based)
├── testing.md                     # TDD workflow & test requirements
├── api-design.md                  # API & logging standards
├── structure.md                   # Project structure conventions
├── database.md                    # Database & migration guidelines
├── standards.md                   # Code quality rules
├── issue-creation.md              # Issue writing guide
├── settings.json.example          # Hooks configuration template (generic)
├── settings-hooks-examples.md     # Per-stack hook & permission examples
└── commands/
    ├── review.md                  # /review - thoughtful code review
    ├── verify.md                  # /verify - pre-PR quality gate
    ├── security-scan.md           # /security-scan - security analysis
    ├── tdd.md                     # /tdd - guided TDD workflow
    ├── fix-issue.md               # /fix-issue - issue to merge workflow
    ├── refactor.md                # /refactor - safe dead code removal
    ├── catchup.md                 # /catchup - branch context summary
    ├── analyze.md                 # /analyze - code and system analysis
    ├── research.md                # /research - web research with Playwright
    ├── update-project.md          # /update-project - git pull, migrations, deps
    ├── commit.md                  # /commit - smart git commit
    ├── merge.md                   # /merge - squash merge to main
    ├── e2e.md                     # /e2e - run Playwright tests
    └── update-readme.md           # /update-readme - validate & update README
.husky/
└── pre-commit.example             # Git pre-commit hook template (multi-stack)
```

**Total: ~3,600 lines of guidelines and commands**

---

## How It Works

**CLAUDE.md is automatically loaded by Claude Code on every conversation.**

When you start Claude Code in your project:
1. Claude finds `CLAUDE.md` in project root
2. Imports files via `@.claude/*.md` syntax
3. Follows these guidelines automatically

**You never need to:**
- Paste guidelines into chat
- Remind Claude about rules
- Reference files manually

---

## Features

### Git Workflow
- GitHub issue-driven development
- Feature branch workflow with squash merging
- Commit message conventions (TWO workflows: branch vs main)

### Security (OWASP ASVS-based)
- Input validation & injection prevention (SQL, XSS, Command, XXE)
- Authentication & session management
- HTTP security headers (with Apache/Nginx/Express examples)
- Rate limiting with specific limits

### Code Quality
- Testing requirements (80% coverage, regression testing)
- Project structure conventions (React/Node, Laravel, Django examples)
- API design standards (RESTful, status codes, pagination)
- Database migration procedures

---

## Custom Commands (Slash Commands)

All commands live in `.claude/commands/` and are loaded automatically by Claude Code.

| Command | Description |
|---------|-------------|
| `/analyze <target>` | Deep analysis of code, components, or problems |
| `/commit [message]` | Smart git commit with conventional message |
| `/merge [issue]` | Squash merge branch to main, close issue |
| `/e2e [test]` | Run Playwright end-to-end tests |
| `/research <topic>` | Web research using Playwright browser |
| `/update-project` | Git pull, migrations, dependency updates |
| `/review` | Thoughtful code review with parallel agents |
| `/verify [mode]` | Pre-PR quality gate (lint, tests, build, secrets) |
| `/security-scan` | Security analysis of changed code (data flow tracing) |
| `/tdd <issue>` | Guided TDD with RED-GREEN-REFACTOR enforcement |
| `/fix-issue <number>` | End-to-end issue implementation workflow |
| `/refactor [path]` | Safe, incremental dead code removal |
| `/catchup` | Branch context summary (read-only) |
| `/update-readme` | Validate README against actual project state and fix drift |

### Creating Custom Commands

Command files use YAML frontmatter + Markdown:

```markdown
---
description: Short description shown in /help
argument-hint: <optional arguments>
allowed-tools: [Tool1, Tool2, Bash(git:*)]
---

# Command Title

Instructions for Claude to follow when this command is invoked.

$ARGUMENTS will be replaced with user input after the command.
```

#### Frontmatter Options

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Shown in help and autocomplete |
| `argument-hint` | No | Placeholder text for arguments |
| `allowed-tools` | No | Tools the command can use (security) |
| `name` | No | Override command name (default: filename) |

#### Tool Patterns

```yaml
# Specific tools
allowed-tools: [Read, Write, Glob]

# Bash with command patterns
allowed-tools: [Bash(git:*), Bash(npm:*)]

# MCP tools
allowed-tools: [mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot]
```

---

## Automation (Hooks & Pre-commit)

### Claude Code Hooks

Hooks run automatically during Claude's operations:

```bash
# Copy template and customize for your stack
cp .claude/settings.json.example .claude/settings.json
```

See `.claude/settings-hooks-examples.md` for per-stack examples:
- **Node.js/TS**: Prettier auto-format, auto-test
- **Python**: Ruff format/lint, pytest auto-test
- **PHP**: PHP CS Fixer, PHPUnit auto-test
- **Go**: gofmt, auto-test
- **Rust**: rustfmt

The base template includes:
- Block writes to sensitive files (`.env`, `.pem`, `.key`)

### Git Pre-commit Hook

Tests run automatically before every commit:

```bash
# Copy and enable
cp .husky/pre-commit.example .husky/pre-commit
chmod +x .husky/pre-commit

# Then uncomment your stack's section in .husky/pre-commit
```

For Node.js projects using Husky:
```bash
npm install -D husky && npx husky init
# or: bun add -d husky && bunx husky init
```

### Personal Notes (CLAUDE.local.md)

For personal preferences not committed to git:

```bash
cp CLAUDE.local.md.example CLAUDE.local.md
```

This file is gitignored - use for local environment notes, current focus, debugging.

---

## Customization Checklist

After installing, customize these files for your project:

### CLAUDE.md (Required)

- [ ] Update "Commands" section with your actual build/test/dev commands
- [ ] Review File Placement table - match your project structure
- [ ] Modify Critical Rules if you have project-specific requirements

**Find and replace:**
- `[YOUR_COMMANDS]` → Your actual commands

### .gitignore (Review)

- [ ] Review included ignores - remove what's not applicable
- [ ] Add project-specific patterns (e.g., `/uploads/`, `/storage/`)
- [ ] Decide on lock files (see Optional section in file)

### .claude/*.md (Optional)

- [ ] **security.md** - Add project-specific security requirements
- [ ] **testing.md** - Replace `[YOUR_TEST_COMMAND]` with your actual commands
- [ ] **api-design.md** - Adjust response format conventions
- [ ] **structure.md** - Update examples to match your stack
- [ ] **database.md** - Add ORM specifics (Prisma, Eloquent, etc.)
- [ ] **standards.md** - Add team-specific code standards

### Remove Unused Guidelines

If not using a database:
```markdown
# In CLAUDE.md, remove this line:
@.claude/database.md
```
Then delete `.claude/database.md`.

### Add Team-Specific Rules

Add to CLAUDE.md:
```markdown
## Team Conventions

- Use Prettier with 2-space indentation
- Prefix private methods with underscore
```

---

## FAQ

### Why separate files instead of one big CLAUDE.md?

**Modularity.** You can:
- Remove guidelines you don't need (e.g., database.md for static sites)
- Update security guidelines without touching workflow rules
- Keep CLAUDE.md focused on project-specific config

### How much context does this use?

~3,600 lines total. Claude Code handles this well. If you notice slowness, remove unused `.claude/*.md` files.

### Can I use this with other AI coding tools?

The guidelines are written for Claude Code's `@import` syntax. Other tools may need the content pasted directly or adapted to their format.

### Why no TypeScript/React/Laravel-specific rules?

**Technology-agnostic by design.** The principles (security, testing, structure) apply to any stack. Stack-specific examples are included where helpful.

### How do I update when the template improves?

```bash
# Backup your customizations
cp CLAUDE.md CLAUDE.md.backup
cp -r .claude .claude.backup

# Reinstall
curl -fsSL https://raw.githubusercontent.com/ParkAndre/project-starter-template/main/install.sh | bash

# Merge back your Commands section and any custom rules
```

---

## Troubleshooting

### Claude isn't following a guideline

1. Make the rule more specific (add examples)
2. Use stronger language (ALWAYS/NEVER)
3. Move it to "Critical Rules Summary" section in CLAUDE.md

### Claude doesn't know about CLAUDE.md

- Ensure CLAUDE.md is in project root (not a subdirectory)
- File must be named exactly `CLAUDE.md` (case-sensitive)
- You must be in the project directory when starting Claude Code

### Changes not taking effect

- Press `#` in Claude Code to reload CLAUDE.md
- Changes apply automatically in new conversations
- For imported files, Claude Code re-reads on each conversation

### Too slow / too much context

- Remove unused `.claude/*.md` files
- Simplify rules that are obvious (Claude already knows basic security)
- Keep custom additions concise

---

## Links

- [Claude Code Documentation](https://docs.anthropic.com/en/docs/claude-code)
- [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/)

---

Free to use in all projects. No attribution needed.
