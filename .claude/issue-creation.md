# Issue Creation Guide

Guide for writing well-structured GitHub issues that follow project conventions.

**Note:** The `/fix-issue` skill applies this guide automatically when creating new issues (Estonian draft → user approves → translate to English → `gh issue create`). For end-to-end workflow (issue → branch → TDD → merge), use `/fix-issue` instead of manual `gh issue create`. This document is the reference both for the skill and for manual issue authoring.

---

## Core Principles

1. **User Value First** — Order by user journey, not technical layers. Ask "What can the user ACCOMPLISH?" not "What can the user SEE?"
2. **WHAT, not HOW** — Describe observable behavior and outcomes, not implementation details
3. **Granular but Complete** — Each issue = one deployable, testable increment. One PR with tests. Every visible element works end-to-end

---

## Issue Title Formats

### Feature Issues
Title: `As a [role] I [action]` or `As a [role] I [action] so that [benefit]`

Rules:
- `[role]` MUST be an end-user role (user, customer, visitor, admin)
- Use end-user roles exclusively (not developer, engineer, architect, system)
- "so that" is optional — include only when benefit is non-obvious

Examples:
- `As a user I search for products`
- `As a user I filter results by price so that I find items in my budget`
- `As a customer I view my order history`

### Bug Issues
Title: `[Brief description]` with label `bug`

Include: reproduction steps, expected behavior, actual behavior.

### Chore/Infrastructure Issues
Title: Descriptive (no user story format needed). Examples: `Setup CI/CD pipeline`, `Configure database migrations`

---

## Issue Sizing

**Too big if:** spans multiple user flows, has >5 unrelated ACs, cannot finish in one PR with tests.

**Right size:** 0.5-1 day of work, one user-visible outcome, tests included.

---

## Deploy-Safe Increments

Every issue must produce a deployable increment:
- Every UI element works end-to-end
- No buttons/links that do nothing
- No placeholder forms without working submit
- No pages that error or show TODO behavior

**Rule:** If functionality is not ready, do not add the UI element yet.

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
- [ ] Every visible element works end-to-end
- [ ] Quality gates pass

## Testing Expectations
- [ ] Test type(s): unit / integration / e2e
- [ ] Test intent: [what behavior must be proven]
- [ ] Tests pass, coverage not reduced

## Database Changes (if applicable)
- [ ] Schema changes needed? (yes/no)
- [ ] Migration needed? (yes/no)

## Dependencies
- Blocked by: #XX (if any)
- Blocks: #XX (if any)

Type: Feature | Bug | Enhancement | Chore
```

---

## Bilingual Workflow (Estonian -> English)

1. **Draft in Estonian** — Show the user the issue title and acceptance criteria in Estonian
2. **Wait for approval** — Let the user review, correct, or approve the draft
3. **Translate to English** — Once approved, translate the full issue to English
4. **Push to GitHub** — Create the issue on GitHub in English only

Rules:
- The user reviews and edits in Estonian (their language)
- GitHub always receives English content
- Keep the same structure and meaning when translating
- Wait for user approval before pushing to GitHub

---

## Checklist Before Creating

- [ ] Title follows correct format (user story or descriptive)
- [ ] Uses end-user role for Features
- [ ] WHAT not HOW — no implementation details
- [ ] Deploy-safe — no dead UI
- [ ] PR-sized scope
- [ ] Testing expectations included
- [ ] User has approved the Estonian draft
- [ ] English translation matches the approved draft
