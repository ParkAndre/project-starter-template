# Safe Coding & Change Coordination Rules

> **Note:** These rules help AI assistants make safe, controlled changes to your codebase. They prevent unintended refactoring, protect existing behavior, and ensure explicit approval for risky operations.

---

## Coding Safety Mode

**Current mode for this project:** `[SAFE_MODE / FAST_MODE]`

### SAFE_MODE (default - recommended for production/team projects)
- Requires explicit approval for all significant changes
- Must present Change Plan before implementing
- No refactoring or improvements without explicit request
- Validate all assumptions before proceeding
- Read files completely before editing

### FAST_MODE (for prototyping/greenfield/solo projects)
- Can make reasonable improvements and refactoring
- Still must explain all changes clearly
- Still requires tests and validations
- Can proceed faster with obvious fixes

**To change mode:** Update the mode indicator above in this file and commit.

---

## General Principles

### 1. Scope and Permission

1. **Only change what has been explicitly requested.**
   - Do NOT refactor unrelated files, functions, or modules unless the user clearly asks for it.
   - Do NOT introduce new features, behaviors, or configuration changes "because they seem useful" without confirmation.
   - Do NOT "improve" code style, naming, or structure outside the scope of the current task.

2. **Treat each task/issue as having a strict scope.**
   - If you think something else "should also be fixed/refactored", you MUST:
     - mention it in a separate **"Potential Improvements"** section,
     - explain why it would be beneficial,
     - NOT implement it unless the user explicitly approves.

**Example:**
```
Task: Fix bug in user login validation

✅ CORRECT: Fix only the validation logic bug
❌ WRONG: Also refactor entire auth module, rename functions, add new features
```

---

### 2. No Guessing – Validate Assumptions

1. **Do NOT invent business rules or requirements.**
   - If a requirement or behavior is unclear, you MUST:
     - describe your current understanding in your own words,
     - ask for confirmation before implementing.

2. **Always prefer to ask rather than guess.**
   - If there are multiple plausible interpretations, outline them and ask:
     ```
     I see two possible interpretations:

     Option A: [description]
     Option B: [description]

     Which one is correct?
     ```

3. **Before making significant changes, output a short "Understanding & Plan" section:**
   ```
   Understanding of the request:
   - [What you think needs to be done]

   Files to be changed:
   - file1.js (add new function)
   - file2.js (modify existing logic)

   Planned changes:
   - [Specific change 1]
   - [Specific change 2]

   Assumptions:
   - [Any assumptions you're making]
   ```
   Wait for confirmation if there is any doubt.

---

### 3. Read-Before-Write Rule

**CRITICAL: You MUST read files completely before editing them.**

1. **ALWAYS use Read tool first:**
   - Read the ENTIRE file (not just a snippet)
   - Understand the full context
   - Identify all related code

2. **NEVER edit a file without reading it first in the same conversation.**
   - Exception: If you read it earlier in the same conversation, you may edit it.

3. **For large files:**
   - Read in sections if needed
   - Understand the structure before making changes
   - Verify your change fits the existing patterns

**Why this matters:**
- Prevents accidentally overwriting unrelated code
- Ensures changes fit existing code style
- Avoids breaking dependencies you didn't see

**Example:**
```
❌ WRONG:
User: "Add validation to login function"
AI: *Immediately uses Edit tool*

✅ CORRECT:
User: "Add validation to login function"
AI: *Uses Read tool on auth.js*
AI: *Analyzes existing code*
AI: *Uses Edit tool with proper context*
```

---

### 4. Environment Context Awareness

**You MUST be aware of which environment the code affects.**

#### Environment Classification

1. **PRODUCTION environment:**
   - Live user data
   - Real payments/transactions
   - Cannot tolerate downtime or data loss

2. **STAGING/TEST environment:**
   - Mirrors production
   - Safe for testing
   - Can be reset if needed

3. **DEVELOPMENT/LOCAL environment:**
   - Developer machines
   - Safe for experimentation
   - Isolated from users

#### Environment-Specific Rules

**PRODUCTION (CRITICAL):**
- ❌ NEVER run destructive commands (`DROP TABLE`, `DELETE FROM`, `rm -rf`, etc.)
- ❌ NEVER modify database directly (use migrations only)
- ❌ NEVER disable security features (auth, validation, CSRF)
- ❌ NEVER commit secrets or credentials
- ⚠️ ALWAYS require explicit approval for:
  - Schema changes
  - Data migrations
  - Configuration changes
  - Dependency updates
- ✅ ALWAYS test in staging first

**STAGING:**
- ✅ Can test destructive operations
- ✅ Can reset/rebuild if needed
- ⚠️ Still requires approval for:
  - Major architectural changes
  - Breaking API changes

**DEVELOPMENT:**
- ✅ More freedom to experiment
- ✅ Can make broader changes
- ⚠️ Still must follow testing requirements

#### How to Determine Environment

Check for environment indicators:
```javascript
// Environment variables
process.env.NODE_ENV === 'production'
process.env.APP_ENV === 'production'

// Configuration files
config/production.js
.env.production

// Database names
myapp_production
myapp_staging
myapp_dev
```

**When in doubt, assume PRODUCTION and ask!**

---

### 5. Change Plan Before Code

**Before writing or editing code, you MUST present a change plan.**

1. **Analyze the existing code:**
   - Read relevant files
   - Understand current behavior
   - Identify dependencies

2. **Present a brief Change Plan:**
   ```
   Change Plan:

   Files to modify:
   - src/auth.js: Add email validation
   - src/validators.js: Add isValidEmail helper

   What will be added:
   - Email validation regex
   - Error message for invalid emails

   What will be modified:
   - login() function to check email format

   What will be removed:
   - None

   Impact:
   - Users with invalid email format will see validation error
   - No breaking changes to API
   ```

3. **Only after the user agrees** (or if the request is already crystal clear), proceed to code.

**When you can skip Change Plan:**
- Trivial fixes (typos, obvious bugs)
- User explicitly said "just do it"
- Very small, isolated changes

---

### 6. Dangerous Actions Require Explicit Approval

**For the following actions, you MUST ask for explicit approval first:**

#### Data & Schema
- Deleting files or large sections of code
- Renaming public APIs, functions, classes, or database fields
- Changing data models or database schema
- Dropping tables or columns
- Migrating large amounts of data

#### Configuration & Dependencies
- Modifying configuration that affects other environments or services
- Adding, removing, or upgrading dependencies (see Dependencies section)
- Changing environment variables
- Modifying CI/CD pipelines or deployment configs

#### Architecture & Breaking Changes
- Changing authentication/authorization logic
- Modifying API contracts (request/response formats)
- Refactoring large modules or architectural changes
- Changing error handling or logging behavior

**When proposing such changes, you MUST:**
1. Explain **why** the change is needed
2. Describe the **impact** (what breaks, what changes)
3. Mention **alternatives** considered
4. Wait for the user's explicit **"yes"** before implementing

**Example:**
```
I need to rename the `getUserData()` function to `fetchUserProfile()`
because it better reflects what it does.

Impact:
- 15 files import and use this function
- External API documentation references it
- This is a breaking change for any external consumers

Alternatives:
A) Keep old name, add new name as alias (no breaking change)
B) Rename with deprecation warning first
C) Rename immediately (breaking change)

Which approach should I take?
```

---

### 7. Dependencies Require Approval

**Before adding, removing, or upgrading dependencies, you MUST:**

1. **Explain why the dependency is needed:**
   - What problem does it solve?
   - Why can't we solve it without a dependency?
   - What are the alternatives?

2. **Provide dependency information:**
   ```
   Dependency: lodash@4.17.21

   Why needed:
   - Need utility functions for array manipulation

   Alternatives considered:
   - Write our own utilities (more code to maintain)
   - Use native JS (less readable for complex operations)

   Security:
   - Weekly downloads: 30M+
   - Last updated: 2 months ago
   - Known vulnerabilities: None (checked npm audit)

   Bundle size impact:
   - Full library: 72KB (minified)
   - Using only import: ~4KB (tree-shaken)
   ```

3. **Security checks:**
   - Check npm audit / pip check / composer audit
   - Verify package is actively maintained
   - Check for known vulnerabilities
   - Verify package source is legitimate

4. **Wait for approval** before installing.

**When dependency changes are allowed without asking:**
- Security patches (explicitly fixing CVEs)
- User explicitly requested "update dependencies"

**Red flags (always ask):**
- Package with < 1000 weekly downloads
- Last updated > 2 years ago
- Has known vulnerabilities
- Dramatically increases bundle size
- Has excessive permissions/dependencies

---

### 8. Breaking Changes Protocol

**If a change breaks existing behavior, you MUST follow this protocol:**

1. **Identify the breaking change clearly:**
   ```
   ⚠️ BREAKING CHANGE

   Old behavior:
   - API returned { user: {...} }

   New behavior:
   - API returns { data: { user: {...} } }

   Who is affected:
   - Frontend application
   - Mobile app
   - Third-party API consumers
   ```

2. **Mark it in commit message:**
   ```
   BREAKING CHANGE: Modify user API response format

   Closes #123
   ```

3. **Consider deprecation first:**
   - Can we support both old and new behavior temporarily?
   - Can we add a deprecation warning?
   - What's the migration timeline?

4. **Provide migration guide:**
   ```
   Migration Guide:

   Before:
   const user = response.user;

   After:
   const user = response.data.user;
   ```

5. **Update documentation:**
   - API documentation
   - README if needed
   - CHANGELOG (if project uses one)

**Deprecation period approach (preferred):**
```javascript
// Step 1: Support both (with warning)
function getData() {
  console.warn('getData() is deprecated, use fetchData() instead');
  return fetchData();
}

// Step 2: (after 1-2 releases) Remove old function
```

---

### 9. Assumptions Must Be Visible and Checkable

**Whenever you need to make assumptions, you MUST list them explicitly.**

1. **Add an "Assumptions" section to your response:**
   ```
   Assumptions:
   1. Email validation should reject emails without "@" symbol
   2. Password minimum length is 8 characters
   3. User registration does not send confirmation email
   4. Database uses unique constraint on email field
   ```

2. **Do NOT hide assumptions inside the code only.**
   - Don't just add a comment in code
   - State them explicitly in your response

3. **If later you discover an assumption was wrong:**
   - Mention it clearly: "My earlier assumption about X was incorrect"
   - Correct the implementation accordingly
   - Explain the fix

**Common things to state as assumptions:**
- Business rules ("I assume users can only have one active session")
- Data formats ("I assume dates are in ISO 8601 format")
- Validation rules ("I assume usernames are alphanumeric only")
- Behavior edge cases ("I assume empty array should return 0, not error")
- Performance requirements ("I assume < 1000 items in the list")

---

### 10. Respect Existing Behavior and Contracts

1. **Do NOT silently change existing public behavior** unless the task explicitly requires it.
   - Public API responses
   - Function signatures and return values
   - Database schema
   - Configuration defaults
   - Error messages and codes

2. **If a change may affect existing callers/consumers:**
   - Highlight this clearly in your explanation
   - List all affected code/services
   - Propose a safe migration path
   - Wait for approval

**Example of safe vs unsafe changes:**

```javascript
// ❌ UNSAFE - Changes return type
function getUser(id) {
  return user;  // Was: returns User object
}
// After:
function getUser(id) {
  return { user, permissions };  // Now: returns object with user + permissions
}

// ✅ SAFE - Adds new function, keeps old one
function getUser(id) {
  return user;  // Unchanged
}
function getUserWithPermissions(id) {
  return { user, permissions };  // New function
}
```

---

### 11. When in Doubt – Ask, Don't Improvise

**If at any point you are not sure about:**

- Expected business logic
- Correct input/output formats
- Which file/module is the right place for a change
- What the user really wants
- Whether a change is safe
- Environmental impact (dev/staging/prod)

**You MUST stop and ask clarification questions first.**

**Do NOT:**
- "Fill in the gaps" with your own idea of "what makes sense"
- Rewrite large parts of the codebase without a clear request
- Introduce side effects that are not explicitly required
- Assume you understand requirements when they're ambiguous
- Make changes to production-critical code without verification

**Always prioritize:**
- ✅ Safety over cleverness
- ✅ Explicit confirmation over silent assumptions
- ✅ Minimal, well-explained changes over broad refactors
- ✅ Asking questions over guessing answers
- ✅ Preserving existing behavior over "improvements"

---

## Quick Reference: Before Making Any Change

Ask yourself:

1. [ ] Did I read the relevant files completely?
2. [ ] Do I understand what environment this affects (dev/staging/prod)?
3. [ ] Is this change within the scope of the request?
4. [ ] Have I validated my assumptions?
5. [ ] Do I need to present a Change Plan first?
6. [ ] Is this a dangerous action requiring approval?
7. [ ] Does this break existing behavior or contracts?
8. [ ] Am I adding/changing dependencies?
9. [ ] Have I stated my assumptions explicitly?
10. [ ] When in doubt, did I ask instead of guessing?

**If you answered "no" or "unsure" to any question, STOP and address it first.**

---

## Mode-Specific Behavior Summary

| Action | SAFE_MODE | FAST_MODE |
|--------|-----------|-----------|
| Refactor unrelated code | ❌ Ask first | ⚠️ OK if clearly beneficial |
| Change API contracts | ❌ Require approval | ❌ Require approval |
| Add dependencies | ❌ Require approval | ❌ Require approval |
| Fix obvious bugs | ✅ OK (explain fix) | ✅ OK (explain fix) |
| Improve code style | ❌ Ask first | ✅ OK if in scope |
| Rename variables/functions | ❌ Ask first | ⚠️ Private only, not public |
| Database schema changes | ❌ Require approval | ❌ Require approval |
| Production changes | ❌ Require approval | ❌ Require approval |
| Present Change Plan | ✅ Always | ⚠️ For significant changes |
| State assumptions | ✅ Always | ✅ Always |
| Read before write | ✅ Always | ✅ Always |

**Note:** Even in FAST_MODE, dangerous actions still require approval.
