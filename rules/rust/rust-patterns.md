---
description: "Rust patterns: ownership, traits, error handling"
globs: ["**/*.rs"]
alwaysApply: true
---

# Rust Patterns

## Ownership
- Prefer references over cloning
- Use `Clone` explicitly when needed
- Don't fight the borrow checker—restructure instead

## Traits — MANDATORY
- Define behavior with traits, not concrete types
- Use `impl Trait` for single type returns
- Use `dyn Trait` for heterogeneous collections
- Implement standard traits: `Debug`, `Display`, `From`, `Default`
- Use `#[derive(...)]` liberally

## Error Handling
- Libraries: use `thiserror` for custom errors
- Applications: use `anyhow` for easy propagation
- Never use `unwrap()` in production
- Use `expect()` with descriptive messages in tests only

## Async
- Don't block the executor—use `spawn_blocking`
- Don't hold Mutex guards across await points
- Use channels over shared state when possible
