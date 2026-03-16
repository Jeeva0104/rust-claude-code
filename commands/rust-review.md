---
description: Run a comprehensive Rust code review using the rust-reviewer agent. Checks ownership, lifetimes, traits, error handling, and clippy compliance.
---

# /rust-review

## What This Command Does
Invokes the `rust-reviewer` agent to perform a thorough code review on Rust files.

## When to Use
- Before creating a PR
- After significant refactoring
- When learning Rust patterns
- For security-sensitive code review

## How It Works
1. Scans all `.rs` files in the project
2. Applies the Rust Review Checklist
3. Reports issues by severity
4. Suggests idiomatic fixes

## Example Usage
```bash
/rust-review

# Review specific file
/rust-review --file src/services/user.rs

# Review with focus on unsafe code
/rust-review --focus unsafe
```

## Output Format
```markdown
## Summary
Reviewed 12 files, found 3 issues.

## Critical
- src/lib.rs:42: use-after-move in loop

## Warnings
- src/api.rs:15: unwrap() on Result

## Suggestions
- Use `Arc<Mutex<T>>` instead of `Rc<RefCell<T>>` for thread safety
```
