---
description: "Security rules: input validation, secrets, dependencies"
alwaysApply: true
---

# Security Standards

## Input Validation
- Validate all external input at boundaries
- Use parameterized queries (never string interpolation)
- Sanitize file paths

## Secrets Management
- Never hardcode secrets
- Use environment variables
- Use `secrecy` crate for sensitive strings
- Never log secrets

## Dependencies
- Run `cargo audit` regularly
- Fix RUSTSEC advisories promptly
- Minimize dependency tree

## Unsafe Code
- Document with SAFETY comments
- Minimize unsafe blocks
- Get second review for unsafe changes
