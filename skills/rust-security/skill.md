---
name: rust-security
description: Rust security best practices covering unsafe code review, cargo audit, RUSTSEC advisories, dependency vetting with cargo-deny, and secure coding patterns.
origin: rust-claude-code
---

# Rust Security Patterns

## When to Activate
- Writing or reviewing unsafe code
- Auditing dependencies
- Setting up security CI gates
- Reviewing input handling

---

## unsafe Code Rules

Every `unsafe` block MUST have a comment explaining why it is safe:

```rust
// SAFETY: `ptr` is guaranteed non-null by the caller contract documented
// in the public API. The lifetime 'a ensures the reference is valid.
let value = unsafe { &*ptr };
```

**unsafe checklist before merging:**
- [ ] Is the invariant documented in a `// SAFETY:` comment?
- [ ] Are all pointer dereferences bounds-checked?
- [ ] Are all lifetimes correct?
- [ ] Could this be written in safe Rust instead?
- [ ] Has a second reviewer approved the unsafe block?

---

## cargo audit — Required in CI

```bash
# Install
cargo install cargo-audit

# Run audit
cargo audit

# CI configuration (.github/workflows/security.yml)
- name: Security audit
  run: cargo audit --deny warnings
```

---

## RUSTSEC Policy

- Check https://rustsec.org/ for advisories
- RUSTSEC advisories with severity `high` or `critical` must be resolved within 48 hours
- Use `cargo audit fix` for automatic patching when available
- Pin dependency versions if advisory has no fix yet

---

## cargo-deny — Dependency Policy

```toml
# deny.toml
[advisories]
db-path = "~/.cargo/advisory-db"
db-urls = ["https://github.com/rustsec/advisory-db"]
vulnerability = "deny"
unmaintained = "warn"
yanked = "deny"

[licenses]
allow = ["MIT", "Apache-2.0", "BSD-2-Clause", "BSD-3-Clause"]
deny = ["GPL-3.0"]

[bans]
multiple-versions = "warn"
```

```bash
cargo install cargo-deny
cargo deny check
```

---

## Input Validation

```rust
use validator::Validate;

#[derive(Validate, Deserialize)]
pub struct CreateUserRequest {
    #[validate(email)]
    pub email: String,
    
    #[validate(length(min = 2, max = 100))]
    pub name: String,
    
    #[validate(length(min = 8), custom = "validate_password_strength")]
    pub password: String,
}

// Always validate at system boundaries
pub async fn create_user(
    Json(payload): Json<CreateUserRequest>,
) -> Result<Response, AppError> {
    payload.validate().map_err(AppError::Validation)?;
    // ...
}
```

---

## No unwrap() in Production

```rust
// BAD
let value = some_option.unwrap();
let conn = pool.get().unwrap();

// GOOD
let value = some_option.ok_or(AppError::NotFound("value".into()))?;
let conn = pool.get().map_err(AppError::Database)?;

// In tests only — use expect with descriptive message
let value = some_option.expect("test fixture should always have value");
```

---

## Secrets Management

```rust
use secrecy::{ExposeSecret, Secret};

pub struct Config {
    pub database_url: Secret<String>,
    pub api_key: Secret<String>,
}

// Only expose when needed
let url = config.database_url.expose_secret();
```

- Never log secret values — use `secrecy` crate
- Load secrets from environment, never hardcode
- Use `.env` only for local dev, never commit it

---

## SQL Injection Prevention

```rust
// SAFE — parameterized queries with sqlx
sqlx::query_as!(User, "SELECT * FROM users WHERE email = $1", email)
    .fetch_optional(&pool)
    .await?;

// NEVER string interpolate into queries
// let query = format!("SELECT * FROM users WHERE email = '{}'", email); // UNSAFE
```

---

## Best Practices
- Run `cargo audit` and `cargo deny check` in every CI pipeline
- Review all `unsafe` blocks in code review
- Never store secrets in source code or logs
- Validate all external input at system boundaries
- Use `secrecy` crate for sensitive strings
- Keep dependencies minimal and up-to-date
