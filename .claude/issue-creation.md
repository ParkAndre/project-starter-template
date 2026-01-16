# Issue Creation Guide

Guide for writing well-structured GitHub issues that follow project conventions.

---

## Core Principles

### 1. User Value First
- Order issues by **user journey**, not technical layers
- Ask "What can the user ACCOMPLISH?" not "What can the user SEE?"
- Each issue must deliver **real end-user value**

### 2. WHAT, not HOW
- Describe **observable behavior and outcomes**
- Do NOT prescribe implementation details unless required by project standards

### 3. Granular but Complete
- Each issue = one deployable, testable increment
- Small enough to finish in one PR with tests
- No dead UI: every visible element must work end-to-end

---

## Issue Title Formats

### Feature Issues
Title: `As a [role] I [action]` or `As a [role] I [action] so that [benefit]`

**Rules:**
- `[role]` MUST be an end-user role (e.g., "user", "customer", "visitor")
- FORBIDDEN roles: developer, engineer, architect, admin, system
- "so that" is optional - include only when benefit is non-obvious
- Action must deliver real value

**Good examples:**
- `As a user I search for products` (clear action with outcome)
- `As a user I filter results by price so that I find items in my budget` (non-obvious benefit)
- `As a customer I view my order history`

**Bad examples:**
- `As a user I see the menu` (seeing is not a goal)
- `As a user I view navigation links` (no real value)
- `As a developer I add database tables` (wrong role for Feature)

### Bug Issues
Title: `[Brief description]` with label `bug`

Include in body:
1. Steps to reproduce
2. Expected behavior
3. Actual behavior

### Chore/Infrastructure Issues
Title: Descriptive (no user story format needed)

Examples:
- `Setup CI/CD pipeline`
- `Configure database migrations`
- `Add linting rules`

---

## Issue Sizing

### Too Big If:
- Spans multiple major user flows
- Has > 5 unrelated acceptance criteria
- Cannot be completed with tests in one PR
- Requires multiple unrelated systems at once

### Right Size:
- 0.5–1 day of work (ideally)
- One user-visible outcome that is fully usable
- Tests included, quality gates green

---

## Deploy-Safe Increments (Strict)

Every issue must produce a **deployable increment**:

- ✅ Every UI element works end-to-end
- ✅ No buttons/links that do nothing
- ✅ No placeholder forms without working submit
- ✅ No pages that error or show TODO behavior
- ✅ No unused code (models, endpoints, components)

**Rule:** If functionality isn't ready, don't add the UI element yet.

---

## Issue Body Template

```text
## Goal
<Why we need this and what outcome it enables>

## User Story (Feature issues only)
As a [end-user role] I [action] [so that [benefit]]

## Acceptance Criteria
- [ ] Outcome 1 (observable behavior)
- [ ] Outcome 2
- [ ] Edge case(s) covered
- [ ] Validation errors shown clearly
- [ ] No dead UI: every visible element works
- [ ] Quality gates pass ([YOUR_LINT_COMMAND], [YOUR_BUILD_COMMAND])

## Testing Expectations
- [ ] Test type(s): unit / integration / e2e
- [ ] Test intent: [what behavior must be proven]
- [ ] [YOUR_TEST_COMMAND] passes
- [ ] Coverage not reduced

## Database Changes (if applicable)
- [ ] Schema changes needed? (yes/no)
- [ ] Migration needed? (yes/no)
- [ ] Data constraints (plain language)

## Dependencies
- Blocked by: #XX (if any)
- Blocks: #XX (if any)

Type: Feature | Bug | Enhancement | Chore
```

---

## Sequencing Issues

Order so each stage unlocks the next:

### Stage 1 — Foundations
- Repository setup compliant with conventions
- CI gates working (lint, build, test all green)
- Test infrastructure with at least one smoke test
- Database configured with initial migration

### Stage 2 — Core Domain
- Establish core domain types
- Define service interfaces
- Add unit tests for core business rules

### Stage 3 — Integration Layer
- External service adapters (APIs, providers)
- Contract tests with fixtures
- Error handling and resilience

### Stage 4 — User Flows
- Primary user journeys end-to-end
- E2E tests for critical paths

---

## Good vs Bad Issues

### Bad Traits
- "Use library X / implement with Y" (prescribes HOW)
- Giant scope (multiple flows)
- No tests mentioned
- Dead UI (buttons that do nothing)
- "As a developer I want..." (wrong role)

### Good Traits
- One outcome, testable acceptance criteria
- Test expectations explicit
- Safe to deploy without incomplete UI
- End-user perspective for Features
- Chore type for infrastructure work

---

## Checklist Before Creating

- [ ] Title follows correct format (user story or descriptive)
- [ ] Uses end-user role (not developer/system) for Features
- [ ] WHAT not HOW - no implementation details
- [ ] Granular but deploy-safe - no dead UI
- [ ] Not too big - PR-sized scope
- [ ] Testing expectations included
- [ ] Dependencies listed if any
