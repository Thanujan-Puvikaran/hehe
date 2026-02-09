# Copilot Instructions (Repository Rules)

## 1) Language
- **English only** across the whole repository:
  - Code identifiers (variables, functions, classes)
  - Comments and docstrings
  - Logs, user-facing strings (unless explicitly required otherwise)
  - Documentation (README, ADRs, etc.)
  - PR titles/descriptions and commit messages

## 2) Architecture & Style
- Follow **SOLID** principles.
- Prefer composition over inheritance when reasonable.
- Keep functions short and single-purpose.
- Avoid hidden side effects.
- Use clear naming: `verbNoun` for functions, `Noun`/`NounService` for classes, `is/has/can` prefixes for booleans.
- No dead code, no commented-out blocks.

## 3) Linting & Formatting (Baseline Rules)
- Do not introduce new lint warnings/errors.
- Keep imports sorted and remove unused imports.
- Avoid `any` (TypeScript) or untyped values unless justified.
- Prefer explicit return types for public functions.
- Prefer early returns over deep nesting.

## 4) Required Function Documentation Comment Format
Every function MUST have a doc comment directly above it.

Use this format (adapt to the language: JSDoc for JS/TS, docstring for Python, XML docs for C#, etc.):

### JS/TS example (JSDoc)
```ts
/**
 * Brief one-line summary of what the function does.
 *
 * @param paramName - Description of the parameter.
 * @returns Description of the return value.
 * @throws ErrorType - When/why it is thrown. (only if relevant)
 * @example
 * // short example usage
 */
```

### Python example (docstring)
```python
# All function/class docstrings MUST use double quotes (""")
# All string literals MUST use double quotes ("")
def func(x: int) -> int:
    """Brief one-line summary.

    Args:
        x: Description.

    Returns:
        Description.

    Raises:
        ValueError: When/why.
    """
    return "result"
```

## 7) Testing Rules (MANDATORY)

Every behavior change **MUST** include unit tests.

Tests must be:
- Deterministic (no real time, no real network, no randomness without seeding)
- Isolated (order-independent)
- Readable (Arrange – Act – Assert)
- Focused (one behavior per test)

Coverage requirements:
- Happy path
- Failure path(s)
- Edge cases

External dependencies MUST be mocked:
- Databases
- File system
- HTTP calls
- Time / system clock

---

## 8) Refactoring Rules (MANDATORY)

- Refactor only when necessary
- Do not mix refactors with feature changes unless explicitly requested
- Preserve existing behavior unless explicitly stated otherwise
- Update tests to reflect refactored code
- Avoid large-scale refactors without prior approval

---

## 9) Copilot Chat Output Format (MANDATORY)

When responding in Copilot Chat, ALWAYS include:

1. Short implementation plan
2. Patch-style code changes per file
3. Tests added or updated
4. Commands to run lint and tests
5. Brief notes or trade-offs

---

## 10) Clarification & Safety Rule (MANDATORY)

If any requirement is unclear:
- Ask for clarification **before** writing code
- Do not guess, infer, or invent behavior
- Prefer explicit confirmation over assumptions
