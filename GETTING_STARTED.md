# Getting Started with Project Starter Template

Quick guide to using this template in your projects.

---

## 🚀 Installation (3 minutes)

### Step 1: Install Template

In your project directory:

```bash
# Using curl
curl -fsSL https://raw.githubusercontent.com/adevtec/project-starter-template/main/install.sh | bash

# Or using wget
wget -qO- https://raw.githubusercontent.com/adevtec/project-starter-template/main/install.sh | bash
```

This downloads:
- `CLAUDE.md` - Main Claude Code configuration
- `.claude/` - Directory with detailed guidelines (security, testing, API, etc.)
- `.gitignore` - Comprehensive starter template

### Step 2: Customize for Your Project

**Required:**

1. **Open CLAUDE.md** and update the "Common Commands" section:

```bash
# Replace example commands with YOUR actual commands
# For example, if you use npm:
npm run dev       # Start development server
npm run build     # Build for production
npm test          # Run tests
```

**Optional but recommended:**

2. **Review .gitignore** - Add project-specific ignores
3. **Review .claude/*.md files** - Adjust for your tech stack
4. **Update File Placement table** in CLAUDE.md if needed

### Step 3: Commit to Repository

```bash
git add CLAUDE.md .claude/ .gitignore
git commit -m "Add project starter template and guidelines"
git push
```

**Done!** Claude Code will now automatically follow these guidelines.

---

## ✅ Verify It's Working

Start Claude Code in your project and ask:

```
What are our commit message conventions?
```

If Claude answers with your commit guidelines (from CLAUDE.md), it's working! ✨

Try these test questions:
- "What security rules should we follow?"
- "Where should I place utility functions?"
- "What's our testing strategy?"

Claude should answer based on your CLAUDE.md and .claude/*.md files.

---

## 🎯 How Claude Reads These Guidelines

**Automatic, every time!**

1. You start Claude Code in your project directory
2. Claude Code automatically finds `CLAUDE.md`
3. Claude reads it + all imported `.claude/*.md` files
4. Claude follows these rules for the entire conversation

**You never need to:**
- ❌ Paste guidelines into chat
- ❌ Remind Claude about rules
- ❌ Reference the files manually

**Claude just knows!** 🧠

---

## 📝 Updating Guidelines During Development

### Quick Edit (During Conversation)

Press `#` key in Claude Code → Edit CLAUDE.md → Claude reloads it immediately

### Permanent Changes

1. Edit CLAUDE.md or `.claude/*.md` files
2. Commit changes: `git commit -am "Update guidelines: add new rule"`
3. Push to share with team

**Pro tip:** Commit CLAUDE.md changes alongside feature commits so everyone benefits from improved guidelines.

---

## 🔧 Customization Examples

### Example 1: Simple Tool (No Database)

Remove database guidelines:

**In CLAUDE.md, remove:**
```markdown
### Database
@.claude/database.md
```

**Delete file:**
```bash
rm .claude/database.md
```

### Example 2: API-Only Project (No Frontend)

Keep:
- ✅ security.md (authentication, validation)
- ✅ api-design.md (REST conventions)
- ✅ database.md (if using database)
- ✅ testing.md (API tests)

Remove:
- ❌ Accessibility rules from standards.md (no UI)

### Example 3: Team-Specific Standards

**Add to CLAUDE.md:**
```markdown
## Team Conventions

- Use Prettier with 2-space indentation
- Write JSDoc comments for all exported functions
- Prefix private methods with underscore (_methodName)
- Use Conventional Commits format
```

---

## 💡 Tips for Better Guidelines

### 1. Be Specific

❌ Bad: "Write clean code"
✅ Good: "Keep functions under 50 lines. Split large functions into smaller ones."

### 2. Use Examples

❌ Bad: "Use proper commit messages"
✅ Good:
```markdown
Commit message format:
- Features: `As a [role] I [action] so that [benefit]`
- Fixes: `Fix: [description]`

Example: `Fix: Return 401 instead of 500 for invalid tokens`
```

### 3. Use ALWAYS/NEVER for Critical Rules

Claude pays extra attention to these keywords:

```markdown
- ALWAYS use parameterized queries (prevent SQL injection)
- NEVER commit secrets to repository
```

### 4. Keep Main File Short

CLAUDE.md should be ~200 lines. Move details to `.claude/*.md`:

**CLAUDE.md (high-level):**
```markdown
### Security
@.claude/security.md
```

**security.md (detailed):**
```markdown
# Security Guidelines

## SQL Injection Prevention
- ALWAYS use parameterized queries
- Examples for different frameworks: ...
(detailed content here)
```

---

## 🐛 Troubleshooting

### Claude isn't following a guideline

**Solutions:**
1. Make the rule more specific (add examples)
2. Use stronger language (ALWAYS/NEVER)
3. Move it to "Critical Rules Summary" section
4. Verify Claude read it: Ask "What are our [topic] rules?"

### Claude doesn't know about CLAUDE.md

**Causes:**
- You're not in the project directory (cd to project root)
- CLAUDE.md is not in the root directory (move it there)
- File is named wrong (must be exactly `CLAUDE.md`)

**Fix:** Make sure CLAUDE.md is in your project root directory.

### Changes not taking effect

**During conversation:**
- Press `#` key to reload CLAUDE.md

**New conversation:**
- Claude reads CLAUDE.md fresh every time

### Too much context / Claude is slow

**Solutions:**
1. Keep CLAUDE.md under 200 lines
2. Remove unused `.claude/*.md` files
3. Simplify guidelines (remove redundant rules)

---

## 📚 Next Steps

1. ✅ Install template (done!)
2. ✅ Customize CLAUDE.md (done!)
3. ✅ Verify it works (ask Claude test questions)
4. 🎯 **Start coding!** Claude now follows your guidelines automatically
5. 📝 Update guidelines as you discover better patterns
6. 🤝 Share improvements with your team

---

## 🔗 Useful Resources

- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **OWASP ASVS**: https://owasp.org/www-project-application-security-verification-standard/
- **Template README**: See README.md for full documentation
- **GitHub Issues**: Report issues or suggest improvements

---

**Happy coding with Claude!** 🚀
