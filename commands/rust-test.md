---
description: Run Rust tests with coverage reporting. Checks for missing tests and reports coverage metrics.
---

# /rust-test

## What This Command Does
Runs `cargo test` with optional coverage analysis using cargo-tarpaulin.

## When to Use
- Before committing changes
- To verify test coverage
- CI pipeline check

## How It Works
1. Runs `cargo test --all-features`
2. Checks for test coverage with cargo-tarpaulin
3. Reports missing test coverage
4. Suggests test additions

## Example Usage
```bash
/rust-test

# Run with coverage
/rust-test --coverage

# Check specific module
/rust-test --lib services
```

## Output Format
```
Test Results: 45 passed, 0 failed
Coverage: 82%

Missing Coverage:
- src/auth.rs: login() (no error path tests)
```
