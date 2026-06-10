# Security Guidelines

**Based on OWASP Application Security Verification Standard (ASVS) v5.0.0**

Auto-loaded critical rules only. Full guidance (injection prevention, auth, sessions, JWT, API keys, CSRF, headers, rate limits, logging, crypto, file security) lives in `.claude/security-reference.md` — read it when working on security-relevant code; `/security-scan` uses it as its standards reference.

---

## Critical Rules

- Use parameterized queries for ALL database operations
- Validate AND sanitize ALL user input
- Use context-appropriate output encoding (HTML, JS, URL, SQL)
- Hash passwords with bcrypt/scrypt/Argon2 (10+ rounds)
- Use cryptographically secure random for tokens (`crypto.randomBytes()` / `random_bytes()`)
- Implement CSRF protection on all state-changing requests
- Set secure session cookies: `httpOnly`, `secure`, `sameSite`
- Enforce HTTPS in production
- Return generic error messages to users
- Store all secrets in environment variables
- Validate file uploads by content (MIME type), not extension
- Rate limit authentication endpoints
- Verify authorization server-side on every request
- Use parameterized APIs for OS commands (avoid `exec()` with user input)

---

## Related Skills

- **`/security-scan [mode]`** — diff-only security review with data flow tracing, confidence ≥8/10, exploit scenarios
- **`/commit`** — secrets scan on every commit (patterns in `.claude/scan-patterns.md`)
- **`/verify [mode]`** — pre-merge gate with always-on safety scans (secrets + AI-attribution + debug-code)
- **`/review`** — code review's Security agent (one of 6 parallel specialists) catches violations of these rules

`.claude/security-reference.md` is the detailed standards reference; the skills above identify violations of those rules.
