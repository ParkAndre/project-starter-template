# Code Quality & Standards

## Code Quality Principles

- **Self-documenting code** - Use clear, descriptive variable and function names
- **Meaningful names over comments** - `calculateUserTotalPurchases()` instead of `calc()` with comment
- **Single responsibility** - Keep functions small and focused on one task
- **Comments for intent** - Add comments only when code intent isn't obvious from names

---

## Code Cleanup (ALWAYS do after changes)

- Remove unused imports and dependencies
- Delete commented-out code (use git history if needed later)
- Remove unused variables, functions, classes
- Remove debug `console.log` / `print` statements
- Remove dead code paths (unreachable after refactor)
- Update or remove outdated comments
- Remove completed TODO comments
- Run linter to catch unused code
- Check for unused dependencies
- Clean up unused API endpoints
- Remove unused types/interfaces

---

## Documentation

- Update README.md when adding features or changing setup
- Keep `.env.example` updated with all required variables
- Keep API documentation current with implementation
- Include setup instructions for new developers

---

## UI/UX Consistency

- Use consistent spacing (4px, 8px, 16px, 24px, 32px)
- Use design system/component library for consistency
- Keep button styles and colors consistent
- Use consistent loading states (spinners, skeletons)
- Provide feedback for all user actions
- Keep forms consistent (labels, validation, error display)

---

## Accessibility

- ALWAYS make interactive elements keyboard accessible (Tab, Enter, Space, Arrow keys)
- ALWAYS use semantic HTML (`<button>`, `<nav>`, `<main>`, `<article>`)
- ALWAYS add ARIA labels where semantic HTML insufficient
- ALWAYS ensure color contrast meets WCAG AA (4.5:1 normal text, 3:1 large text)
- NEVER rely solely on color to convey information
- ALWAYS provide alt text for images
- ALWAYS ensure forms are accessible (labels, error messages, focus states)

---

## Testing Reminders

- Test edge cases and error conditions
- Use transactions for multi-step database operations
- Provide clear form validation error messages
