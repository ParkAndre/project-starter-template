# Security Guidelines

**Based on OWASP Application Security Verification Standard (ASVS) v5.0.0**

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

## Injection Prevention

```javascript
// BAD
db.query(`SELECT * FROM users WHERE id = ${userId}`)

// GOOD
db.query('SELECT * FROM users WHERE id = ?', [userId])
```

- **XSS**: Use context-appropriate output encoding. React JSX auto-escapes; use DOMPurify for rich content
- **Command injection**: Use parameterized APIs, avoid `exec()` with user input
- **Template injection**: Avoid dynamic template generation with user input
- **XXE**: Disable external entity processing in XML parsers
- **Deserialization**: Use allowlists, avoid deserializing untrusted data
- **CSV injection**: Sanitize formulas in exports
- **Code injection**: Never use `eval()` or dynamic code execution with user input

### Input Validation
- Validate type, length, format on ALL inputs
- Validate file uploads by MIME type AND size
- Validate both client-side (UX) AND server-side (security)

---

## Data Protection

- Classify sensitive data (PII, credentials, financial, health)
- Send sensitive data in request body, not URLs/query strings
- Store passwords, API keys, tokens exclusively in environment variables
- Ensure `.gitignore` includes: `.env`, `.env.local`, `.htpasswd`
- Use separate credentials per environment (dev, staging, production)
- Mask sensitive info in responses unless explicitly requested
- Set `Cache-Control: no-store` for sensitive responses
- Remove metadata from uploaded files before storage

### Password Storage
- Hash with Argon2 (preferred), bcrypt, or scrypt (minimum 10 rounds)
- Validate against top 3,000 common passwords

---

## Authentication

### Password Policy
- Minimum 8 characters (15+ recommended), validate against common password lists
- Allow unrestricted characters, allow paste, process exactly as submitted

### Multi-Factor Authentication
- Implement MFA for sensitive applications
- Use authenticator apps or hardware keys (avoid email as auth factor)
- Limit OTP lifetimes: 10 min email codes, 30 sec TOTPs
- Rate limit MFA endpoints against brute force

### Attack Prevention
- Use consistent error messages ("Invalid credentials") and response times
- Rate limit: login 5/15min, password reset 3/15min per IP

### OAuth/OIDC (if applicable)
- Validate all redirect URIs against allowlist
- Use PKCE for public clients (SPAs, mobile apps)
- Validate ID token `iss`, `aud`, `exp`, `nonce` claims
- Store tokens securely (httpOnly cookies, not localStorage)

### Password Reset
- Use cryptographically secure random for reset tokens
- Maintain MFA requirement during reset flow
- Support revocation of compromised factors

---

## Session Management

- Regenerate session ID after login (prevent fixation)
- Generate tokens with >=128 bits of entropy
- Implement inactivity timeout and absolute lifetime
- Logout must completely invalidate session server-side
- Terminate all sessions when account disabled/deleted
- Re-authenticate before sensitive changes (email, MFA, password)

### Cookie Security
Set all session cookies with: `httpOnly: true`, `secure: true`, `sameSite: 'strict'`

---

## Authorization

- Verify authentication AND permission before processing every request
- Apply principle of least privilege
- Verify authorization server-side (client-side checks are for UX only)
- Re-authenticate for sensitive account modifications

---

---

## JWT Security

- Keep sensitive data out of JWT payload (base64-encoded, not encrypted)
- Validate `alg` header — reject `none` and unexpected algorithms
- Validate `iss`, `aud`, `exp` claims on every request
- Access tokens: <=15 min expiry. Refresh tokens: server-side storage with rotation
- Store tokens in httpOnly cookies (not localStorage)

---

## API Key Security

- Hash stored keys (SHA-256), show full key only once at creation
- Scope keys to specific endpoints/actions, set expiration dates
- Rate limit per key, log usage by key ID (not the key itself)
- Prefix keys for identification: `sk_live_`, `sk_test_`

---

## CSRF Protection

- Protect ALL state-changing requests (POST, PUT, PATCH, DELETE)
- Generate tokens with `crypto.randomBytes(32)` / `bin2hex(random_bytes(32))`
- Store in session, embed in forms, validate server-side
- Use framework middleware: `csrf-csrf` (Express), built-in (Laravel, Django)

---

## HTTP Security Headers

Use `helmet` (Express), security middleware, or set manually:
- `Strict-Transport-Security: max-age=31536000; includeSubDomains`
- `X-Frame-Options: DENY`
- `X-Content-Type-Options: nosniff`
- `Content-Security-Policy: default-src 'self'; frame-ancestors 'none'`
- `Referrer-Policy: strict-origin-when-cross-origin`

### CORS
- Explicitly whitelist allowed origins (avoid `*` wildcard in production)
- Set `Access-Control-Allow-Credentials: true` only when needed

### HTTPS & Transport
- Enforce HTTPS, redirect HTTP to HTTPS
- Enable HSTS with `includeSubDomains; preload`
- Use TLS 1.2 minimum

---

## Rate Limiting

| Endpoint | Limit |
|----------|-------|
| Login | 5/15min per IP |
| Password reset | 3/15min per IP |
| Registration | 5/hour per IP |
| API (authenticated) | 100/min per user |
| API (public) | 20/min per IP |

Return `429 Too Many Requests` with `Retry-After` header.

---

## Error Handling & Logging

- Return generic error messages ("Invalid credentials", "An error occurred")
- Expose no stack traces, file paths, or DB structure to users
- Fail securely (default to deny)
- Log security events: auth attempts, authz failures, input violations
- Include in logs: timestamp (UTC), user ID, IP, request ID
- Exclude from logs: passwords, tokens, credit cards, PII
- Use structured logging (JSON), sanitize user input before logging

---

## Cryptography

**Approved algorithms only:**
- AES-GCM for encryption, SHA-256+ for hashing, bcrypt/Argon2 for passwords
- TLS 1.2+ for transport, `crypto.randomBytes()` / `random_bytes()` for tokens

**Avoid:** MD5, SHA-1, ECB mode, `Math.random()` / `rand()`, custom crypto, hardcoded keys

---

## File & Environment Security

- Validate uploads by content type AND size, store outside webroot
- Disable directory listings
- Keep `.env.example` updated (placeholder values only), validate required env vars at startup
- Use separate credentials per environment
- Run dependency audits regularly (`npm audit`, `composer audit`, `pip-audit`)
