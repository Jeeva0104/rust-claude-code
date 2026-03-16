---
name: skill-stocktake
description: Skill inventory and gap analysis for Rust projects. Track which patterns are covered and identify missing skills.
origin: rust-claude-code
---

# Skill Stocktake

## When to Activate
- Starting a new Rust project
- Reviewing existing project skills
- Identifying knowledge gaps

---

## Inventory Template

```markdown
## Rust Skills Inventory

### Language Core [✓]
- [x] Ownership & borrowing
- [x] Lifetimes
- [x] Traits (all types)
- [x] Error handling (Result, Option)

### Async [✓]
- [x] Tokio runtime
- [x] Channels
- [x] Select!

### Web Frameworks [✓]
- [x] Axum
- [ ] Actix-web (gap!)

### Database [△]
- [x] SQLx
- [ ] Diesel (gap!)
- [ ] Connection pooling (weak)

### Deployment [✗]
- [ ] Docker multi-stage
- [ ] Cross-compilation
```

---

## Gap Analysis

| Skill | Needed | Available | Gap |
|-------|--------|-----------|-----|
| Diesel ORM | High | None | CRITICAL |
| WebSockets | Medium | Partial | MEDIUM |
| gRPC/Tonic | Low | None | LOW |

---

## Action Items

1. Create `skills/rust-diesel/` for ORM gap
2. Add `skills/rust-websockets/` for real-time features
