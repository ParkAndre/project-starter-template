---
description: Security analysis of changed code (data flow tracing)
allowed-tools: [Bash(git:*), Read, Glob, Grep]
---

# Security Scan

Deep security review of changed code. Complements `/review` with security-specific analysis.

## Usage

`/security-scan` — scan uncommitted or last commit changes

## Process

1. **Get changed code:**
   - `git diff --staged` and `git diff` for uncommitted changes
   - If both empty: `git diff HEAD~1..HEAD` for last commit
   - `git diff --stat` to identify changed files

2. **Read full contents** of all changed files (need complete context, not just diff).

3. **Trace data flows** in changed code. For each user input entry point found:
   - Follow the data through processing, storage, and output
   - Check every step against the categories below

4. **Check these categories** (see `.claude/security.md` for full details):
   - **Injection:** SQL, XSS, command, template injection via user input
   - **Auth:** missing auth checks, client-side only authorization, hardcoded credentials
   - **Data exposure:** sensitive data in logs/errors, secrets in source code
   - **Input validation:** missing validation, type coercion, unvalidated file uploads
   - **Configuration:** CORS wildcard, missing security headers, debug mode in prod

5. **Display findings:**

```
## Security Scan Results

**Scope:** X files changed
**Findings:** X critical, X warning, X info

### [CRITICAL] SQL Injection in user query
**File:** `src/users.ts:42`
**Flow:** request.query.name → db.query() (no parameterization)
**Fix:** Use parameterized query: `db.query('SELECT * FROM users WHERE name = ?', [name])`

### [WARNING] Missing input validation
**File:** `src/api/handler.ts:15`
...
```

## Rules

- ONLY scan changed files — not the entire codebase
- Trace data flows end-to-end (input → processing → output)
- Reference `.claude/security.md` categories when reporting
- Mark uncertain findings as WARNING, not CRITICAL
- Include specific fix suggestions for every finding
- Do NOT modify code — only report
