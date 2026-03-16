---
name: tdd-workflow
description: Language-agnostic test-driven development workflow applied to Rust. Red-green-refactor cycle with cargo test.
origin: rust-claude-code
---

# TDD Workflow

## When to Activate
- Starting any new feature
- Fixing bugs (reproduce with test first)
- Refactoring existing code

---

## The Cycle

```
┌─────────┐    ┌──────────┐    ┌──────────┐
│   RED   │ -> │  GREEN   │ -> │ REFACTOR │
│         │    │          │    │          │
│ Write   │    │ Minimal  │    │ Apply    │
│ failing │    │ code to  │    │ idioms   │
│ test    │    │ pass     │    │          │
└─────────┘    └──────────┘    └──────────┘
      ^                                │
      └────────────────────────────────┘
```

---

## Rust-Specific Adaptations

1. **Use `cargo test`** — integrated test runner
2. **Mock traits** — use `mockall` for dependencies
3. **Test modules** — co-locate with code
4. **Async tests** — use `#[tokio::test]`

---

## Anti-Patterns to Avoid

- Writing implementation before test
- Testing implementation details
- Ignoring compiler warnings in tests
- Not running tests before commit

---

## Commit Checklist
- [ ] `cargo test` passes
- [ ] New code has tests
- [ ] Tests describe behavior, not implementation
