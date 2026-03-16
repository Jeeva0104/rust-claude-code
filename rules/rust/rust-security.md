---
description: "Rust security: unsafe, cargo audit, RUSTSEC"
globs: ["**/*.rs", "**/Cargo.lock"]
alwaysApply: true
---

# Rust Security

## Unsafe Code
- Every `unsafe` block MUST have SAFETY comment
- Keep unsafe blocks minimal
- Requires second review

## Dependencies
- Run `cargo audit` in CI
- Fix HIGH/CRITICAL RUSTSEC within 48 hours
- Use `cargo deny` to enforce policy

## SQL Injection
- Always use parameterized queries
- Never string-interpolate into SQL

## Panic Safety
- No `unwrap()` on external input
- Validate before unwrapping
