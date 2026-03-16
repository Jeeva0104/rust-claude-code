---
description: "Rust hooks: pre-edit cargo check, post-edit clippy"
globs: ["**/*.rs"]
alwaysApply: false
---

# Rust Hooks

## Pre-Edit
```bash
cargo check
```
Fast syntax and type checking.

## Post-Edit
```bash
cargo fmt
cargo clippy -- -D warnings
```
Format and lint after changes.

## Pre-Commit
```bash
cargo test --lib  # quick unit tests
cargo fmt --check
```

## CI Pipeline
```bash
cargo fmt --check
cargo clippy -- -D warnings
cargo test
cargo audit
```
