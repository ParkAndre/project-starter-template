# Project Starter Template

A comprehensive, technology-agnostic project starter template with development workflow guidelines, security best practices, and Claude Code configuration. Perfect for starting new projects with solid foundations.

---

## 📋 What Is This?

This is a **reference documentation template** designed to be copied into new projects. It provides:

- **Git workflow** with GitHub issues and branch management
- **Security guidelines** (OWASP ASVS-based: XSS, SQL injection, authentication, cryptography)
- **Testing requirements** and best practices
- **API design standards** (RESTful conventions, error handling, logging)
- **Database guidelines** (migrations, indexing, query optimization)
- **Code quality standards** (structure, accessibility, cleanup rules)
- **Claude Code configuration** (CLAUDE.md with modular imports)

The guidelines are **technology-agnostic** - they apply to any stack (Node.js, PHP, Python, Go, Rust, etc.), with implementation examples provided where helpful.

---

## ⚡ Quick Start

> **👉 New to this template?** See [GETTING_STARTED.md](GETTING_STARTED.md) for a step-by-step guide.

### Install in New Project

```bash
# Create new project directory
mkdir [YOUR_PROJECT_NAME]
cd [YOUR_PROJECT_NAME]

# Install template (using curl)
curl -fsSL https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/project-starter-template/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/project-starter-template/main/install.sh | bash

# Initialize git
git init
git add .
git commit -m "Initial commit with project starter template"
```

### Add to Existing Project

```bash
cd existing-project

# Install template
curl -fsSL https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/project-starter-template/main/install.sh | bash

# Review and customize files (see Customization section below)

# Commit
git add CLAUDE.md .claude/ .gitignore
git commit -m "Add project starter template and guidelines"
```

---

## 📦 What's Included

```
project-starter-template/
├── README.md                  # This file - overview and documentation
├── GETTING_STARTED.md         # Step-by-step setup guide (start here!)
├── CLAUDE.md                  # Main Claude Code config (~200 lines)
├── .gitignore                 # Comprehensive starter .gitignore
├── install.sh                 # Installation script
└── .claude/                   # Modular guideline files
    ├── security.md           # Security best practices (OWASP ASVS-based)
    ├── testing.md            # Testing requirements & workflow
    ├── safe-coding.md        # Change control & safe coding rules (optional)
    ├── api-design.md         # API standards & logging
    ├── structure.md          # Project structure conventions
    ├── database.md           # Database & migration guidelines
    └── standards.md          # Code quality & cleanup rules
```

### File Sizes

```
CLAUDE.md               ~7KB   (200 lines - optimized for Claude Code)
.claude/security.md     ~25KB  (comprehensive security guidelines)
.claude/testing.md      ~15KB  (testing requirements & workflow)
.claude/safe-coding.md  ~12KB  (change control rules - optional)
.claude/api-design.md   ~3KB   (API & logging standards)
.claude/structure.md    ~3KB   (project structure)
.claude/database.md     ~3KB   (database best practices)
.claude/standards.md    ~3KB   (code quality rules)
.gitignore              ~6KB   (comprehensive starter template)
-------------------------------------------
Total:                  ~77KB  (well optimized for context)
```

---

## ✨ Features

### Git Workflow
- ✅ GitHub issue-driven development
- ✅ Feature branch workflow with squash merging
- ✅ Commit message conventions (features, fixes, refactors)
- ✅ Protected main branch workflow

### Security (OWASP ASVS-based)
- ✅ Input validation & sanitization
- ✅ SQL injection prevention (parameterized queries)
- ✅ XSS prevention (output encoding)
- ✅ Authentication & authorization guidelines
- ✅ Session management best practices
- ✅ CSRF protection
- ✅ Cryptography standards (minimum 128-bit security)
- ✅ HTTP security headers (CSP, HSTS, X-Frame-Options, etc.)
- ✅ Secret management (environment variables)
- ✅ Rate limiting guidelines
- ✅ Error handling & logging (no information disclosure)

### Code Quality
- ✅ Project structure conventions
- ✅ Testing requirements (unit, integration, edge cases)
- ✅ API design standards (RESTful, status codes, pagination)
- ✅ Database migration procedures
- ✅ Accessibility guidelines (WCAG AA)
- ✅ Code cleanup checklist

### Claude Code Integration
- ✅ Optimized CLAUDE.md (~200 lines, recommended best practice)
- ✅ Modular design with `@.claude/*.md` imports
- ✅ Concise and scannable for AI context

---

## 🎯 Customization Checklist

After installing the template, customize these files for your project:

### 1. **CLAUDE.md** (Required)

- [ ] Update "Common Commands" section with your actual build/test/dev commands
- [ ] Review and adjust File Placement table to match your project structure
- [ ] Modify Critical Rules if you have project-specific requirements
- [ ] Update Protected Areas list with your critical files/directories

**Find and replace:**
- `[YOUR_PROJECT_NAME]` → Your actual project name
- `[YOUR_COMMANDS]` → Your actual commands (npm/bun/composer/pip/cargo/etc.)

### 2. **.gitignore** (Review)

- [ ] Review included ignores and remove what's not applicable
- [ ] Add project-specific ignore patterns (e.g., `/uploads/`, `/storage/`)
- [ ] Decide whether to commit lock files (see comments in file)

### 3. **.claude/*.md files** (Optional)

Review and customize based on your needs:

- [ ] **security.md** - Add project-specific security requirements
- [ ] **testing.md** - Add your testing framework specifics (Jest, pytest, PHPUnit, etc.)
- [ ] **api-design.md** - Adjust API response format conventions
- [ ] **structure.md** - Update directory structure examples to match your stack
- [ ] **database.md** - Add ORM/query builder specifics (Prisma, SQLAlchemy, Eloquent, etc.)
- [ ] **standards.md** - Add team-specific code standards

### 4. **README.md** (Replace)

- [ ] Replace this README with your actual project README
- [ ] Consider keeping a link to this template in your project docs

### 5. **Install URLs** (If you forked this template)

- [ ] Update install.sh with your GitHub username
- [ ] Update README installation commands with your repository URL

---

## 🚀 How It Works

### Claude Code Integration

**CLAUDE.md is automatically loaded by Claude Code on every conversation.**

When you start Claude Code in your project directory, it:
1. **Automatically finds and reads** `CLAUDE.md` in your project root
2. **Imports all referenced files** using `@.claude/*.md` syntax
3. **Loads everything into Claude's context** before responding to you

This means Claude will **always follow these guidelines** without you needing to remind it.

### The Import Syntax

In CLAUDE.md, this syntax:
```markdown
@.claude/security.md
```

Tells Claude Code to **automatically read and include** that file's contents. All `.claude/*.md` files become part of Claude's instructions.

### What Gets Loaded

When Claude Code starts, it loads:
1. Your main `CLAUDE.md` (~200 lines of workflow and critical rules)
2. All imported files from `.claude/` directory (detailed guidelines):
   - `security.md` - Security best practices
   - `testing.md` - Testing requirements
   - `api-design.md` - API standards
   - `structure.md` - Project structure
   - `database.md` - Database guidelines
   - `standards.md` - Code quality rules

**Total: ~51KB of context loaded automatically on every conversation.**

### Technology-Agnostic Guidelines

The guidelines focus on **principles and patterns** rather than specific frameworks:

- **Security**: OWASP ASVS-based requirements (applies to all languages)
- **Structure**: Conceptual organization (components, routes, models, utilities)
- **Workflow**: Git/GitHub workflow (language-independent)

**Examples** in guidelines use common stacks (Node.js/React, PHP, Python) to illustrate concepts, but the principles apply universally.

### Modular Design

Each `.claude/*.md` file focuses on a specific area:

- Want strict security? Keep `security.md` as-is
- Building an API? Customize `api-design.md`
- No database? Remove `database.md` reference from CLAUDE.md

Mix and match based on your project needs.

---

## 📖 Usage Tips

### For New Projects

1. Install template using Quick Start commands
2. Complete Customization Checklist
3. Initialize your project structure
4. Commit everything: `git add . && git commit -m "Initial setup"`

### For Existing Projects

1. Install template into existing repository
2. Review each file carefully - merge with existing guidelines
3. Don't blindly overwrite existing conventions
4. Keep what works, adopt what improves

### Working with Claude Code

**Claude automatically follows CLAUDE.md - no reminders needed!**

1. **Just start coding** - Claude has already read all your guidelines
2. **Update guidelines live** - Press `#` key to edit CLAUDE.md during conversation
3. **Test if it's working** - Ask Claude: "What are our commit message conventions?" (it should know)
4. **Commit changes** - Update CLAUDE.md as you discover better patterns
5. **Share with team** - Everyone gets the same consistent Claude behavior

**Pro tips:**
- If Claude isn't following a rule, make it more specific in CLAUDE.md
- Add examples to guidelines - Claude learns better from examples
- Use ALWAYS/NEVER for critical rules (Claude pays extra attention)
- Keep CLAUDE.md under 200 lines, move details to `.claude/*.md`

### Team Collaboration

1. Get team buy-in before adopting (review guidelines together)
2. Customize for your team's workflow and standards
3. Keep guidelines updated as practices evolve
4. Use as onboarding documentation for new team members

---

## 🛠️ Technology Examples

While guidelines are technology-agnostic, here are examples of how they apply to different stacks:

| Guideline | Node.js/Express | PHP/Laravel | Python/Django | Go | Rust/Actix |
|-----------|----------------|-------------|---------------|-----|-----------|
| **Parameterized Queries** | Prisma/TypeORM | Eloquent ORM | Django ORM | sqlx | diesel/sqlx |
| **Password Hashing** | bcrypt/argon2 | password_hash() | bcrypt/Argon2 | bcrypt | argon2/bcrypt |
| **CSRF Protection** | csurf middleware | Built-in | Built-in | Custom/middleware | actix-csrf |
| **Input Validation** | zod/joi/yup | Form Requests | Django Forms | validator | validator |
| **Environment Vars** | dotenv | vlucas/phpdotenv | python-decouple | godotenv | dotenv |

**All follow the same principles** - only implementation differs.

---

## 📚 Documentation Files

- **README.md** (this file) - Template overview and comprehensive documentation
- **GETTING_STARTED.md** - Quick start guide for first-time users (start here!)
- **CLAUDE.md** - Main Claude Code configuration file (auto-loaded by Claude)
- **GITHUB_SETUP_GUIDE.md** - GitHub CLI setup instructions
- **.claude/*.md** - Modular guideline files (security, testing, API, etc.)

---

## 🔄 Updating the Template

To update this template in existing projects:

```bash
# Backup your customizations
cp CLAUDE.md CLAUDE.md.backup
cp -r .claude .claude.backup

# Reinstall latest version
curl -fsSL https://raw.githubusercontent.com/[YOUR_GITHUB_USERNAME]/project-starter-template/main/install.sh | bash

# Manually merge your customizations back
# (especially Common Commands section and project-specific rules)
diff CLAUDE.md.backup CLAUDE.md
```

---

## ❓ FAQ

### How does Claude Code read these guidelines?

**Automatically!** Claude Code looks for `CLAUDE.md` in your project root and loads it at the start of every conversation. The `@.claude/*.md` syntax imports additional files. You never need to manually paste or remind Claude about the guidelines.

### Will Claude always follow these rules?

**Yes, but with caveats:**
- Claude reads CLAUDE.md on **every new conversation** (each time you start Claude Code)
- If you edit CLAUDE.md during a conversation, press `#` to reload it
- More specific rules work better than vague ones
- Examples help Claude understand what you want
- Use **ALWAYS** and **NEVER** for critical rules (Claude pays extra attention to these)

### What if Claude ignores a guideline?

1. **Make it more specific** - Add an example showing what you want
2. **Move it higher** - Put critical rules in the "Critical Rules Summary" section
3. **Use stronger language** - "ALWAYS" and "NEVER" work better than "should"
4. **Test it** - Ask Claude directly: "What are our security rules?" to verify it read them

### Can I use this without Claude Code?

**Partially.** CLAUDE.md is designed for Claude Code, but you can:
- Use it as project documentation for your team
- Share it with other AI coding assistants (they may not auto-load it though)
- Adapt it for other workflows

The `.claude/` directory structure and `@` import syntax are Claude Code specific features.

### Do I need all the .claude/*.md files?

**No!** Customize based on your project:
- Building a simple tool? Remove `database.md` and `api-design.md`
- No tests? Remove `testing.md` (though we recommend keeping it!)
- Public website? Keep `security.md` and `accessibility` rules

Just remove the `@.claude/filename.md` line from CLAUDE.md if you don't need it.

### How do I verify Claude read the guidelines?

Ask Claude directly:
- "What are our commit message conventions?"
- "What security rules should we follow?"
- "Where should I place utility functions?"

If Claude answers correctly citing your CLAUDE.md rules, it's working!

### Can I use this in multiple projects?

**Yes!** That's the point. Install in each project and customize per project:
- Core rules stay the same (security, testing)
- Project-specific rules differ (commands, structure)
- Team benefits from consistent guidelines across projects

---

## 🤝 Contributing

This is a personal starter template, but feel free to:
- Fork and customize for your own use
- Suggest improvements via issues or pull requests
- Create your own variants for specific stacks

---

## 📝 License

Free to use in all your projects. No attribution needed.

---

## 🔗 Useful Links

- **Claude Code Documentation**: https://docs.claude.com/en/docs/claude-code
- **OWASP ASVS**: https://owasp.org/www-project-application-security-verification-standard/
- **GitHub CLI**: https://cli.github.com/

---

## 💡 Philosophy

This template follows these principles:

1. **Start with good defaults** - Security and quality from day one
2. **Technology-agnostic** - Focus on principles, not frameworks
3. **Practical over perfect** - Guidelines you'll actually follow
4. **Modular and customizable** - Take what you need, leave what you don't
5. **AI-friendly** - Optimized for Claude Code and other AI assistants
6. **Team-friendly** - Clear, documented, and collaborative

---

**Made for developers who want to start projects the right way.**

Last updated: 2025-11-22
