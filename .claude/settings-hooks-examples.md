# Settings Hooks Examples

Stack-specific hook and permission examples for `.claude/settings.json`.
Copy the relevant snippets into your settings file.

---

## Permissions per Package Manager

Add the permissions matching your package manager to the `permissions.allow` array:

### Node.js (npm)
```json
"Bash(npm:*)", "Bash(npx:*)"
```

### Node.js (Bun)
```json
"Bash(bun:*)", "Bash(bunx:*)"
```

### Node.js (Yarn)
```json
"Bash(yarn:*)"
```

### Node.js (pnpm)
```json
"Bash(pnpm:*)"
```

### Python
```json
"Bash(python3:*)", "Bash(pip:*)", "Bash(pytest:*)", "Bash(ruff:*)"
```

### PHP
```json
"Bash(composer:*)", "Bash(php:*)"
```

### Go
```json
"Bash(go:*)", "Bash(golangci-lint:*)"
```

### Rust
```json
"Bash(cargo:*)"
```

---

## PostToolUse Hooks

### Node.js / TypeScript (Prettier)

Auto-format JS/TS files after edit:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(ts|tsx|js|jsx)$' && npx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

For Bun, replace `npx` with `bunx`.

### Node.js / TypeScript (Auto-test)

Run tests when test files are modified:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.test\\.(ts|tsx|js|jsx)$' && npm test -- \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

For Bun: replace `npm test --` with `bun test`.

### Python (Ruff)

Auto-format Python files after edit:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.py$' && ruff format \"$CLAUDE_FILE_PATH\" 2>/dev/null && ruff check --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

### Python (Auto-test)

Run pytest when test files are modified:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE 'test_.*\\.py$' && pytest \"$CLAUDE_FILE_PATH\" -x --tb=short 2>/dev/null || true"
}
```

### PHP (PHP CS Fixer)

Auto-format PHP files after edit:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.php$' && vendor/bin/php-cs-fixer fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

### PHP (Auto-test)

Run PHPUnit when test files are modified:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE 'Test\\.php$' && vendor/bin/phpunit \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

### Go (gofmt)

Auto-format Go files after edit:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.go$' && gofmt -w \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

### Go (Auto-test)

Run tests when test files are modified:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '_test\\.go$' && go test $(dirname \"$CLAUDE_FILE_PATH\")/... 2>/dev/null || true"
}
```

### Rust (rustfmt)

Auto-format Rust files after edit:

```json
{
  "matcher": "Edit|Write",
  "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.rs$' && rustfmt \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
}
```

---

## Full Example: Node.js + Bun

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git:*)", "Bash(gh:*)",
      "Bash(bun:*)", "Bash(bunx:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(*--force*)",
      "Bash(*> /dev/*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(env|pem|key|secret)$' && echo 'BLOCKED: Cannot write to sensitive files' && exit 2 || exit 0"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(ts|tsx|js|jsx)$' && bunx prettier --write \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      },
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.test\\.(ts|tsx|js|jsx)$' && bun test \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      }
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "false"
  }
}
```

## Full Example: Python

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git:*)", "Bash(gh:*)",
      "Bash(python3:*)", "Bash(pip:*)", "Bash(pytest:*)", "Bash(ruff:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(*--force*)",
      "Bash(*> /dev/*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(env|pem|key|secret)$' && echo 'BLOCKED: Cannot write to sensitive files' && exit 2 || exit 0"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.py$' && ruff format \"$CLAUDE_FILE_PATH\" 2>/dev/null && ruff check --fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      },
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE 'test_.*\\.py$' && pytest \"$CLAUDE_FILE_PATH\" -x --tb=short 2>/dev/null || true"
      }
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "false"
  }
}
```

## Full Example: PHP (Laravel)

```json
{
  "permissions": {
    "allow": [
      "Read", "Write", "Edit", "Glob", "Grep",
      "Bash(git:*)", "Bash(gh:*)",
      "Bash(composer:*)", "Bash(php:*)"
    ],
    "deny": [
      "Bash(rm -rf:*)",
      "Bash(*--force*)",
      "Bash(*> /dev/*)"
    ]
  },
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.(env|pem|key|secret)$' && echo 'BLOCKED: Cannot write to sensitive files' && exit 2 || exit 0"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE '\\.php$' && vendor/bin/php-cs-fixer fix \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      },
      {
        "matcher": "Edit|Write",
        "command": "echo \"$CLAUDE_FILE_PATH\" | grep -qE 'Test\\.php$' && vendor/bin/phpunit \"$CLAUDE_FILE_PATH\" 2>/dev/null || true"
      }
    ]
  },
  "env": {
    "CLAUDE_CODE_ENABLE_TELEMETRY": "false"
  }
}
```
