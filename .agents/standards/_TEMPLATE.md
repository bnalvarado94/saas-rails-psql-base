# Standards: [Technology / Domain]
#
# This file defines conventions and best practices for [technology].
# It is automatically read by skills when the task involves this domain.
#
# HOW TO FILL IT IN:
# - Be specific and prescriptive, not generic
# - Include concrete code examples (DO / DON'T)
# - Document the "why" behind non-obvious decisions
# - Update when the team changes a convention

---

## Structure and organization

<!-- Where files go, how they are named, what belongs in each layer -->

### DO
```
# Example of correct structure
```

### DON'T
```
# Example of what NOT to do
```

---

## Naming conventions

<!-- Naming rules for classes, functions, variables, files -->

| Type | Convention | Example |
|------|-----------|---------|
| Classes | PascalCase | `UserService` |
| Methods | snake_case | `find_by_email` |
| Constants | UPPER_SNAKE | `MAX_RETRIES` |
| Files | snake_case | `user_service.rb` |

---

## Required patterns

<!-- Patterns that must always be followed in this domain -->

### [Pattern 1: name]
**Why:** ...
```
# Example code
```

### [Pattern 2: name]
**Why:** ...
```
# Example code
```

---

## Prohibited patterns

<!-- What must never be done and why -->

### ❌ [Anti-pattern 1]
**Why not:** ...
```
# Code that must NOT exist
```

**Instead:**
```
# Correct code
```

---

## Error handling

<!-- How errors are handled in this domain -->

```
# Standard error handling pattern
```

---

## Testing

<!-- What requires tests, what type, what coverage level -->

- What requires a unit test
- What requires an integration test
- Mocks: when yes, when no
- Factories / fixtures: how to use them

---

## Security

<!-- Security considerations specific to this domain -->

- Required validations
- What must never reach production
- Authorization patterns

---

## Performance

<!-- Expected optimizations, what to avoid -->

- N+1 queries: how to prevent them
- Indexes: when to add them
- Caching: project strategy

---

## References

<!-- Links to official docs, ADRs, architectural decisions -->

- [Official documentation](url)
- [Relevant ADR](link)
