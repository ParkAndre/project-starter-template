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
git add CLAUDE.md .claude/ .commands/ .gitignore
git commit -m "Add project starter template and guidelines"
```

### Verify It Works

Ask Claude Code: "What are our commit message conventions?"

If Claude answers correctly with the TWO workflow explanation, it's working.

---

## What's Included

```
CLAUDE.md                  # Main config (~260 lines)
.gitignore                 # Comprehensive starter template
.claude/
├── security.md            # Security guidelines (~340 lines, OWASP-based)
├── testing.md             # Testing requirements (~190 lines)
├── api-design.md          # API & logging standards (~120 lines)
├── structure.md           # Project structure conventions (~76 lines)
├── database.md            # Database & migration guidelines (~72 lines)
├── standards.md           # Code quality rules (~65 lines)
└── issue-creation.md      # Issue writing guide (~183 lines)
.commands/
├── README.md              # Commands installation guide
├── analyze.md             # /analyze - code and system analysis
├── research.md            # /research - web research with Playwright
└── update-project.md      # /update-project - git pull, migrations, deps
```

**Total: ~1,300 lines of guidelines**

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

Optional slash commands for Claude Code:

| Command | Description |
|---------|-------------|
| `/analyze <target>` | Deep analysis of code, components, or problems |
| `/research <topic>` | Web research using Playwright browser |
| `/update-project` | Git pull, migrations, dependency updates |

See `.commands/README.md` for installation instructions.

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
- [ ] Decide on lock files (see comments in file)

### .claude/*.md (Optional)

- [ ] **security.md** - Add project-specific security requirements
- [ ] **testing.md** - Add your test framework specifics (`[YOUR_TEST_COMMAND]`)
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

~1,100 lines total. Claude Code handles this well. If you notice slowness, remove unused `.claude/*.md` files.

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
