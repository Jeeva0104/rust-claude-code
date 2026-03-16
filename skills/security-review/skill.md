---
name: security-review
description: Security checklist adapted for Rust projects covering unsafe code, dependency audits, input validation, and secrets management.
origin: rust-claude-code
---

# Security Review for Rust

## When to Activate
- Before deploying to production
- During security audits
- Reviewing PRs with unsafe code

---

## Checklist

### Code Security
- [ ] No `unwrap()` in production paths
- [ ] All `unsafe` blocks have SAFETY comments
- [ ] Input validation at all boundaries
- [ ] Secrets never logged or exposed

### Dependency Security
- [ ] `cargo audit` passes (no RUSTSEC advisories)
- [ ] `cargo deny check` passes
- [ ] No unused dependencies

### Database Security
- [ ] All SQL queries are parameterized
- [ ] No SQL injection vectors
- [ ] Proper connection limits set

### Deployment Security
- [ ] Docker image runs as non-root
- [ ] No secrets in Docker layers
- [ ] Health check endpoint exists

---

## Review Template

```markdown
## Security Review: [Feature]

### Unsafe Code
- [ ] Documented with SAFETY comment
- [ ] Reviewed by second person

### Dependencies
- `cargo audit`: PASS / FAIL
- RUSTSEC issues: [list if any]

### Input Handling
- [ ] All external input validated
- [ ] Size limits enforced
```
