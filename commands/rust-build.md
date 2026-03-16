---
description: Diagnose and fix Rust build errors. Delegates to rust-build-resolver agent for borrow checker, lifetime, and dependency issues.
---

# /rust-build

## What This Command Does
Invokes the `rust-build-resolver` agent to diagnose and fix `cargo build` errors.

## When to Use
- When `cargo build` fails
- For borrow checker errors
- For dependency conflicts

## How It Works
1. Runs `cargo build` to capture errors
2. Identifies error patterns
3. Applies appropriate fixes
4. Verifies the build passes

## Example Usage
```bash
/rust-build

# Fix specific error
/rust-build --error E0502

# Fix dependencies
/rust-build --deps
```

## Error Types Handled
- E0502: Borrow checker violations
- Lifetime annotation errors
- Missing trait implementations
- Cargo dependency conflicts
