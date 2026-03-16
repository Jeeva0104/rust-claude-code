---
name: article-writing
description: Long-form technical writing for Rust. Documentation, tutorials, and blog posts without generic AI tone.
origin: rust-claude-code
---

# Article Writing for Rust

## When to Activate
- Writing Rust tutorials
- Creating documentation
- Authoring blog posts
- Explaining Rust concepts

---

## Structure Template

```markdown
# Title

## The Problem
What issue does this solve?

## The Solution
Show the approach with code.

## Why It Works
Explain Rust mechanics.

## Common Pitfalls
What mistakes to avoid.

## Further Reading
Links to docs.rs, RFCs.
```

---

## Code-First Approach

Start with working code, then explain:

```rust
// Show the solution first
let result = vec.iter().filter(|x| **x > 5).collect::<Vec<_>>();

// Then explain why this is idiomatic
```

---

## Voice Guidelines
- Use "we" and "our" — inclusive
- Avoid "simply", "just", "obviously"
- Show errors before solutions
- Be specific about versions
