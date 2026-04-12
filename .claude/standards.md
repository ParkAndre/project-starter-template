# Code Quality & Standards

## Code Cleanup (ALWAYS do after changes)

- Remove unused imports, variables, functions, classes
- Delete commented-out code (git history preserves it)
- Remove debug `console.log` / `print` statements
- Remove dead code paths and completed TODO comments
- Run linter to catch remaining issues

---

## Accessibility

- Use semantic HTML (`<button>`, `<nav>`, `<main>`, `<article>`)
- Make interactive elements keyboard accessible (Tab, Enter, Space, Arrow keys)
- Add ARIA labels where semantic HTML is insufficient
- Ensure color contrast meets WCAG 2.2 AA (4.5:1 normal text, 3:1 large)
- Convey information through text/icons in addition to color
- Provide alt text for images
- Make forms accessible (labels, error messages, focus states)

---

## Logging

- Use structured logging (JSON) with: timestamp, level, requestId, context
- Exclude from logs: passwords, tokens, credit cards, PII, session IDs
- See security.md for security-specific logging requirements
