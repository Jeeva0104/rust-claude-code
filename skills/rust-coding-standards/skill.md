---
name: rust-coding-standards
description: Rust coding standards covering rustfmt, clippy, naming conventions, module organization, and visibility rules for consistent, idiomatic Rust codebases.
origin: rust-claude-code
---

# Rust Coding Standards

## When to Activate
- Setting up a new Rust project
- Reviewing Rust code for style
- Configuring CI linting pipelines
- Onboarding new Rust developers

---

## Formatting — rustfmt

Always use `rustfmt`. Never manually format code.

```toml
# rustfmt.toml
edition = "2021"
max_width = 100
tab_spaces = 4
use_small_heuristics = "Default"
imports_granularity = "Module"
group_imports = "StdExternalCrate"
```

Run: `cargo fmt` (format) / `cargo fmt --check` (CI gate)

---

## Linting — Clippy

Run clippy with warnings as errors in CI:
```bash
cargo clippy -- -D warnings
```

Recommended lint config in `Cargo.toml` or `lib.rs`:
```rust
#![deny(clippy::all)]
#![warn(clippy::pedantic)]
#![allow(clippy::module_name_repetitions)]
```

---

## Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Functions, methods, variables | `snake_case` | `get_user`, `user_id` |
| Types, structs, enums, traits | `CamelCase` | `UserService`, `AppError` |
| Constants, statics | `SCREAMING_SNAKE_CASE` | `MAX_RETRIES` |
| Modules, files | `snake_case` | `user_service.rs` |
| Crates | `kebab-case` | `my-crate` |
| Lifetimes | Short lowercase | `'a`, `'db`, `'static` |
| Type parameters | Single uppercase or descriptive | `T`, `E`, `K`, `V`, `Item` |

---

## Module Organization

```
src/
├── lib.rs          # library root, re-exports public API
├── main.rs         # binary entry point (thin — delegates to lib)
├── error.rs        # AppError definition
├── config.rs       # configuration types
├── models/
│   ├── mod.rs
│   ├── user.rs
│   └── order.rs
├── services/
│   ├── mod.rs
│   └── user_service.rs
├── repositories/
│   ├── mod.rs
│   └── user_repo.rs
└── handlers/       # HTTP handlers (thin)
    ├── mod.rs
    └── users.rs
```

### File Size Guidelines
- Target: 200–400 lines per file
- Maximum: 800 lines (split if exceeded)
- Each file should have a single clear responsibility

---

## Visibility Rules

```rust
pub struct User { ... }        // public to all
pub(crate) fn internal() {}   // public within crate
pub(super) fn parent_only() {} // public to parent module
fn private() {}               // private (default)
```

**Rule**: Keep visibility as restricted as possible. Only `pub` what external consumers need.

---

## Documentation

```rust
/// Creates a new user with the given email.
///
/// # Errors
/// Returns [`AppError::Validation`] if email is invalid.
/// Returns [`AppError::Database`] if the insert fails.
///
/// # Examples
/// ```
/// let user = UserService::create("alice@example.com").await?;
/// ```
pub async fn create(email: &str) -> Result<User, AppError> { ... }
```

- Document all `pub` items
- Include `# Errors` section on fallible functions
- Include `# Panics` section if the function can panic
- Run `cargo doc --no-deps --open` to verify

---

## Code Quality Checklist
- [ ] Functions < 50 lines
- [ ] No nesting > 4 levels deep
- [ ] No `unwrap()` in non-test code
- [ ] All `pub` items have doc comments
- [ ] `cargo fmt --check` passes
- [ ] `cargo clippy -- -D warnings` passes
- [ ] No dead code (`#[allow(dead_code)]` only with comment explaining why)
