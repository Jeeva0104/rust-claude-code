---
description: Review async Rust code for blocking calls, proper runtime usage, and common async pitfalls.
---

# /rust-async-check

## What This Command Does
Reviews async Rust code for common issues like blocking calls, mutex across await, and runtime misuse.

## When to Use
- Writing async Rust code
- Reviewing Tokio-based applications
- Debugging async performance issues

## How It Works
1. Scans for `std::sync::Mutex` in async contexts
2. Checks for blocking operations
3. Reviews spawn_blocking usage
4. Reports select! opportunities

## Example Usage
```bash
/rust-async-check

# Check specific file
/rust-async-check --file src/handlers/api.rs
```

## Checks Performed
- [ ] No `std::sync::Mutex` in async code
- [ ] No blocking operations without `spawn_blocking`
- [ ] Mutex guards dropped before await
- [ ] Appropriate use of `tokio::select!`
