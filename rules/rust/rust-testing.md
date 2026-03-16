---
description: "Rust testing: unit, integration, coverage"
globs: ["**/*.rs"]
alwaysApply: true
---

# Rust Testing

## Unit Tests
- Co-locate with code in `#[cfg(test)]` module
- Use descriptive names

## Integration Tests
- Place in `tests/` directory
- Each file is separate binary

## Async Tests
- Use `#[tokio::test]` for async tests
- Mock at trait boundaries with `mockall`

## Coverage
- Minimum 80% with `cargo-tarpaulin`
- 100% on auth/business logic

## Benchmarks
- Use `criterion` for performance tests
- Place in `benches/` directory
