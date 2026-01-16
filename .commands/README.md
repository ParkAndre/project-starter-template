# Claude Code Commands

Custom slash commands for Claude Code. Invoke with `/command-name`.

## Available Commands

| Command | Trigger | Description |
|---------|---------|-------------|
| [analyze](analyze.md) | `/analyze <target>` | Deep analysis of code, components, or problems |
| [commit](commit.md) | `/commit [message]` | Smart git commit with conventional message |
| [merge](merge.md) | `/merge [issue]` | Squash merge branch to main, close issue |
| [e2e](e2e.md) | `/e2e [test]` | Run Playwright end-to-end tests |
| [research](research.md) | `/research <topic>` | Web research using Playwright browser |
| [update-project](update-project.md) | `/update-project` | Git pull, migrations, dependencies |

## Installation

### Option 1: Copy to User Commands (Global)

Copy command files to your Claude commands folder:

```bash
# Create commands folder if it doesn't exist
mkdir -p ~/.claude/commands

# Copy commands
cp .commands/*.md ~/.claude/commands/
```

Commands will be available in all projects.

### Option 2: Project-Level Commands

Keep commands in `.commands/` folder and reference in project settings:

```bash
# Create project settings if not exists
echo '{}' > .claude/settings.json
```

Add to `.claude/settings.json`:
```json
{
  "commands": [
    ".commands/analyze.md",
    ".commands/commit.md",
    ".commands/merge.md",
    ".commands/e2e.md",
    ".commands/research.md",
    ".commands/update-project.md"
  ]
}
```

## Requirements

### analyze.md
- Works with any project
- Uses Claude Code built-in tools (Read, Glob, Grep, Bash)

### commit.md
- Works with any git repository
- Runs tests before committing (requires test setup)

### merge.md
- Works with any git repository
- Requires GitHub CLI (`gh`) for issue closing
- Runs tests before merging

### e2e.md
- Requires **Playwright** installed: `bun add -d @playwright/test`
- Initialize: `bunx playwright install`

### research.md
- Requires **Playwright MCP server** installed
- Install: `bunx @anthropic-ai/claude-code-mcp add playwright`
- Without Playwright, use built-in `WebSearch` tool instead

### update-project.md
- Works with any project
- Auto-detects package manager (npm, bun, yarn, pnpm, composer, pip, etc.)
- Auto-detects migration tool (Prisma, Drizzle, Django, Laravel, Rails)

## Creating Custom Commands

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

### Frontmatter Options

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Shown in help and autocomplete |
| `argument-hint` | No | Placeholder text for arguments |
| `allowed-tools` | No | Tools the command can use (security) |
| `name` | No | Override command name (default: filename) |

### Tool Patterns

```yaml
# Specific tools
allowed-tools: [Read, Write, Glob]

# Bash with command patterns
allowed-tools: [Bash(git:*), Bash(npm:*)]

# MCP tools
allowed-tools: [mcp__playwright__browser_navigate, mcp__playwright__browser_snapshot]
```

## Example: Custom Command

`.commands/lint-fix.md`:
```markdown
---
description: Run linter and auto-fix issues
allowed-tools: [Bash(npm:*), Bash(bun:*), Read]
---

# Lint and Fix

Run the project linter with auto-fix enabled.

1. Detect linter (eslint, prettier, biome)
2. Run with --fix flag
3. Report what was fixed
```

Then invoke with `/lint-fix`.
