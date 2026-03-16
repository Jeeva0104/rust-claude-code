---
description: "Testing requirements: coverage, naming, structure"
alwaysApply: true
---

# Testing Standards

## Coverage
- Minimum 80% code coverage
- 100% coverage on critical paths (auth, payments, etc.)

## Test Naming
- Pattern: `{subject}_{condition}_{expected_result}`
- Examples: `user_with_invalid_email_returns_error`

## Structure
- Use Arrange / Act / Assert
- One behavior per test
- Mock external dependencies at trait boundaries

## Running Tests
```bash
cargo test                      # all tests
cargo test --lib               # unit only
cargo test --test integration  # integration only
cargo test -- --nocapture      # show output
```
