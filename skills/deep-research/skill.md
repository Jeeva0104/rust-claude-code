---
name: deep-research
description: Research-first development for Rust. Use docs.rs, crates.io, RFCs, and the Rustonomicon before implementation.
origin: rust-claude-code
---

# Deep Research for Rust

## When to Activate
- Choosing between similar crates
- Understanding unsafe Rust
- Learning advanced patterns
- Evaluating async runtimes

---

## Research Sources

| Source | Use For |
|--------|---------|
| docs.rs | Crate documentation |
| crates.io | Crate comparison, download stats |
| lib.rs | Alternative crate index |
| rust-lang/rust | RFCs, std lib source |
| The Rustonomicon | Unsafe Rust, dark corners |
| Rust By Example | Learning patterns |
| This Week in Rust | Ecosystem updates |

---

## Crate Evaluation Matrix

```markdown
| Crate | Downloads | Maintenance | Unsafe | License |
|-------|-----------|-------------|--------|---------|
| sqlx | High | Active | No | MIT/Apache |
| diesel | High | Active | No | MIT/Apache |
```

---

## Research Before Choosing

```rust
// Before picking an HTTP client:
// 1. Compare reqwest vs hyper vs surf
// 2. Check: async runtime compatibility
// 3. Check: feature flags needed
// 4. Check: MSRV (minimum supported Rust version)
```

---

## Best Practices
- Always check when crate was last updated
- Review open issues for blockers
- Check for unsafe code with `cargo geiger`
