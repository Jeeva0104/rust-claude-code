---
description: "Rust coding style: rustfmt, clippy, naming conventions"
globs: ["**/*.rs", "**/Cargo.toml"]
alwaysApply: true
---

# Rust Coding Style

## Formatting
- Always run `cargo fmt`
- Use rustfmt.toml for project-wide config

## Linting
- Run `cargo clippy -- -D warnings`
- No warnings in committed code

## Naming
| Item | Convention | Example |
|------|-----------|---------|
| Functions, vars | snake_case | `get_user`, `user_id` |
| Types, traits | CamelCase | `UserService`, `Clone` |
| Constants | SCREAMING_SNAKE | `MAX_RETRIES` |
| Modules | snake_case | `user_service.rs` |
| Lifetimes | 'a, 'db | `'a`, `'static` |

## Visibility
- Use most restrictive visibility possible
- Prefer `pub(crate)` over `pub`
