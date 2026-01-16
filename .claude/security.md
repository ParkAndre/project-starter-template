# Security Guidelines

**Based on OWASP Application Security Verification Standard (ASVS) v5.0.0**

> **Note:** Code examples (Node.js, PHP, Python) are illustrative. Adapt to your specific stack.

---

## Critical Rules (ALWAYS follow)

- Use parameterized queries for ALL database operations
- Validate AND sanitize ALL user input
- Use context-appropriate output encoding (HTML, JS, URL, SQL)
- Hash passwords with bcrypt/scrypt/Argon2 (10+ rounds)
- Use cryptographically secure random for tokens
- Implement CSRF protection on state-changing requests
- Set secure session cookies: `httpOnly`, `secure`, `sameSite`
- Enforce HTTPS in production
- Return generic error messages to users
- Store secrets in environment variables only
- Validate file uploads by content (MIME), not extension
- Rate limit authentication endpoints
- Verify authorization server-side
- NEVER use `eval()` or dynamic code execution with user input

---

## Data Protection

### Data Classification
- Identify and classify sensitive data (PII, credentials, financial, health)
- Document protection requirements per classification level
- Define data retention policies with automated deletion
- NEVER send sensitive data in URLs/query strings

### Secret Management
- NEVER store passwords, API keys, tokens in plain text
- Use environment variables (`process.env.SECRET`, `$_ENV['SECRET']`)
- Ensure `.gitignore` includes: `.env`, `.env.local`, `.htpasswd`, `config.php`
- Use separate credentials per environment (dev, staging, production)

### Password Storage
- Hash with bcrypt, scrypt, or Argon2 (minimum 10 rounds):
  - PHP: `password_hash($password, PASSWORD_ARGON2ID)`
  - Node.js: `bcrypt.hash(password, 10)` or `argon2.hash(password)`
- NEVER store password hints or security questions
- Validate against top 3,000 common passwords

### Sensitive Data Handling
- Mask sensitive info unless explicitly requested
- Remove metadata from uploaded files before storage
- Set `Cache-Control: no-store` for sensitive responses
- Use `Clear-Site-Data` header on logout
- NEVER send to third-party analytics

---

## Input Validation & Injection Prevention

### Output Encoding by Context
- **HTML**: Escape `<`, `>`, `&`, `"`, `'`
- **JavaScript/JSON**: Use proper JSON encoding
- **URL**: Use URL encoding or base64url
- **SQL**: Use parameterized queries (never encoding)
- **OS commands**: Use parameterized commands

### Injection Prevention

**SQL Injection:**
```javascript
// ❌ BAD
db.query(`SELECT * FROM users WHERE id = ${userId}`)

// ✅ GOOD
db.query('SELECT * FROM users WHERE id = ?', [userId])
```

**XSS Prevention:**
- PHP: `htmlspecialchars($input, ENT_QUOTES, 'UTF-8')`
- React: JSX auto-escapes; use DOMPurify for rich content
- Node.js: Use `validator`, `xss`, or `DOMPurify`

**Other injections:**
- **Command**: Use parameterized APIs, avoid `exec()` with user input
- **XXE**: Disable external entity processing in XML parsers
- **Template**: Avoid dynamic template generation with user input
- **CSV**: Sanitize formulas in exports
- **Deserialization**: Use allowlists, avoid deserializing untrusted data

### Input Validation
- Validate type, length, format on ALL inputs
- Validate file uploads by MIME type AND size
- Validate both client-side (UX) AND server-side (security)

---

## Authentication

### Password Policy
- Minimum 8 characters (15+ recommended)
- Validate against common password lists
- Allow unrestricted characters (no complexity rules)
- Allow paste in password fields
- Process exactly as submitted (no trimming)

### Multi-Factor Authentication
- Implement MFA for sensitive applications
- NEVER use email as authentication factor
- Limit OTP lifetimes: 10 min for email codes, 30 sec for TOTPs
- Rate limit MFA endpoints against brute force

### Attack Prevention
- Prevent user enumeration:
  - Consistent error messages ("Invalid credentials")
  - Consistent response times
- Rate limiting:
  - Login: 5 attempts / 15 min
  - Password reset: 3 attempts / 15 min
  - Use `express-rate-limit` (Node.js) or Redis-based limiting

### Password Reset
- Use cryptographically secure random for reset tokens
- Don't bypass MFA during reset
- Support revocation of compromised factors

---

## Session Management

### Cookie Security
```javascript
// Express.js
app.use(session({
  cookie: {
    httpOnly: true,    // Prevent JS access
    secure: true,      // HTTPS only
    sameSite: 'strict' // CSRF protection
  }
}));
```

```php
// PHP
ini_set('session.cookie_httponly', 1);
ini_set('session.cookie_secure', 1);
ini_set('session.cookie_samesite', 'Strict');
```

### Session Lifecycle
- Regenerate session ID after login (prevent fixation)
- Generate tokens with ≥128 bits of entropy
- Implement two timeouts:
  - **Inactivity timeout**: Re-auth after idle period
  - **Absolute lifetime**: Re-auth regardless of activity

### Session Termination
- Logout must completely invalidate session
- Terminate all sessions when account disabled/deleted
- Allow users to view and terminate active sessions
- Re-authenticate before sensitive changes (email, MFA, password)

---

## Authorization

- Verify authentication AND permission before processing
- Principle of least privilege
- NEVER trust client-side authorization
- Always verify server-side
- Re-authenticate for sensitive account modifications

---

## CSRF Protection

- Protect ALL state-changing requests (POST, PUT, PATCH, DELETE)
- Generate secure tokens:
  - PHP: `bin2hex(random_bytes(32))`
  - Node.js: `crypto.randomBytes(32).toString('hex')`
- Store in session, embed in forms as hidden field
- Validate server-side before processing
- Use middleware: `csurf` (Express), Laravel/Symfony built-in

---

## HTTP Security Headers

```apache
# Apache (.htaccess)
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
Header always set X-Frame-Options "DENY"
Header always set X-Content-Type-Options "nosniff"
Header always set Referrer-Policy "strict-origin-when-cross-origin"
Header always set Permissions-Policy "geolocation=(), microphone=(), camera=()"
```

```nginx
# Nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Frame-Options "DENY" always;
add_header X-Content-Type-Options "nosniff" always;
```

```javascript
// Express.js - use helmet
const helmet = require('helmet');
app.use(helmet());
```

### Content Security Policy
```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' https://trusted-cdn.com;
  style-src 'self' 'unsafe-inline';
  img-src 'self' data: https:;
  frame-ancestors 'none';
```

Start restrictive, gradually allow trusted sources. Test thoroughly.

---

## CORS

- NEVER use `'*'` wildcard in production
- Explicitly whitelist origins:
  ```javascript
  // Express.js
  app.use(cors({
    origin: ['https://example.com', 'https://app.example.com'],
    credentials: true
  }));
  ```
- Set `Access-Control-Allow-Credentials: true` only when needed

---

## HTTPS & Transport

- Enforce HTTPS in production
- Redirect HTTP to HTTPS:
  - Apache: `RewriteEngine` with HTTPS check
  - Nginx: `return 301 https://$server_name$request_uri;`
  - Express: `express-sslify` middleware
- Enable HSTS: `max-age=31536000; includeSubDomains; preload`
- Use TLS 1.2 minimum (disable 1.0/1.1)

---

## Cryptography

**Use only:**
- AES-GCM for encryption (authenticated encryption)
- SHA-256+ for hashing
- bcrypt/Argon2 for passwords
- TLS 1.2+ for transport
- `crypto.randomBytes()` / `random_bytes()` for tokens

**NEVER use:**
- MD5, SHA-1 (compromised)
- ECB mode (patterns leak)
- Custom crypto implementations
- `Math.random()` / `rand()` for security
- Hardcoded keys in source code

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

```javascript
// Express.js
const rateLimit = require('express-rate-limit');
app.use('/login', rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5
}));
```

---

## Error Handling & Logging

### Errors
- NEVER expose stack traces, paths, DB structure to users
- Return generic messages:
  - "Invalid credentials" (not "Password incorrect")
  - "An error occurred" (not specific DB errors)
- Fail securely (default to deny)

### Logging
- Log security events: auth attempts, authz failures, violations
- Include: timestamp (UTC), user ID, IP, request ID
- NEVER log: passwords, tokens, credit cards, PII
- Use structured logging (JSON)
- Sanitize user input before logging (prevent log injection)

---

## File Security

- Validate uploads by content type, not extension
- Limit file sizes (e.g., 5MB images, 10MB documents)
- Store outside webroot
- Disable directory listings:
  - Apache: `Options -Indexes`
  - Nginx: `autoindex off;`
- Protect config files (`.env`, `.htpasswd`)

---

## Environment Management

- Different credentials per environment
- Keep `.env.example` updated (placeholder values only)
- Validate required env vars at startup (fail fast)
- Use `.env.local` for local secrets (git ignored)

---

## Dependency Management

- Run audits regularly:
  - `npm audit` / `yarn audit`
  - `composer audit`
  - `pip-audit`
- Review packages before adding
- Minimize dependency count
- Keep dependencies updated
