---
name: rust-verification
description: Rust verification loops using cargo fmt, cargo clippy, and cargo test as CI gates. Includes pre-commit hooks, GitHub Actions configuration, and continuous verification patterns.
origin: rust-claude-code
---

# Rust Verification Loops

## When to Activate
- Setting up CI/CD for a Rust project
- Configuring pre-commit hooks
- Running quality gates before merging

---

## Verification Pipeline

Run in this order — fail fast:

```bash
cargo fmt --check          # 1. formatting
cargo clippy -- -D warnings # 2. linting (warnings = errors)
cargo test                  # 3. all tests
cargo audit                 # 4. security audit
```

---

## Pre-commit Hook

```bash
# .git/hooks/pre-commit
#!/usr/bin/env bash
set -e

echo "Running Rust verification..."

cargo fmt --check || { echo "Run 'cargo fmt' to fix formatting"; exit 1; }
cargo clippy -- -D warnings || { echo "Fix clippy warnings before committing"; exit 1; }
cargo test --quiet || { echo "Tests failed"; exit 1; }

echo "All checks passed!"
```

```bash
chmod +x .git/hooks/pre-commit
```

---

## GitHub Actions CI

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy
      - uses: Swatinem/rust-cache@v2
      
      - name: Format check
        run: cargo fmt --check
      
      - name: Clippy
        run: cargo clippy -- -D warnings
      
      - name: Tests
        run: cargo test
      
      - name: Security audit
        run: |
          cargo install cargo-audit --quiet
          cargo audit
      
      - name: Coverage
        run: |
          cargo install cargo-tarpaulin --quiet
          cargo tarpaulin --fail-under 80
```

---

## Checkpoint Verification

Before each PR merge, run the full suite:

```bash
#!/usr/bin/env bash
# scripts/verify.sh
set -e

echo "=== Rust Verification Suite ==="

echo "1. Formatting..."
cargo fmt --check

echo "2. Linting..."
cargo clippy -- -D warnings

echo "3. Tests..."
cargo test

echo "4. Doc tests..."
cargo test --doc

echo "5. Security audit..."
cargo audit

echo "6. Coverage..."
cargo tarpaulin --fail-under 80 --out Stdout

echo "=== All checks passed! ==="
```

---

## Continuous Verification with cargo-watch

```bash
# Auto-run full verification on change
cargo watch -x "fmt --check" -x "clippy -- -D warnings" -x test

# Lighter loop during development (format + test only)
cargo watch -x fmt -x test
```

---

## Best Practices
- Never merge code that fails `cargo clippy -- -D warnings`
- Run `cargo fmt` before every commit (not just check)
- Use `cargo test --all-features` to test all feature combinations
- Cache Cargo artifacts in CI with `Swatinem/rust-cache`
- Fail CI on any RUSTSEC advisory with severity `high` or `critical`
