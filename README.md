# rust-claude-code

A Rust-specific Claude Code plugin — agents, skills, rules, and commands for idiomatic Rust development.

## Overview

This plugin provides:
- **2 Agents**: `rust-reviewer`, `rust-build-resolver`
- **34 Skills**: 16 Rust-specific + 18 ported from ECC
- **8 Rules**: 3 common + 5 Rust-specific
- **4 Commands**: `rust-review`, `rust-test`, `rust-build`, `rust-async-check`

## Quick Start

### Option 1: Plugin Marketplace (when available)
```bash
/plugin marketplace add Jeeva0104/rust-claude-code
/plugin install rust-claude-code@rust-claude-code
```

### Option 2: Manual Install
```bash
git clone https://github.com/Jeeva0104/rust-claude-code.git
cd rust-claude-code
./install.sh
```

## Skills

### Rust-Specific (16)
| Skill | Description |
|-------|-------------|
| `rust-patterns` | Ownership, borrowing, **traits**, error handling |
| `rust-coding-standards` | rustfmt, clippy, naming conventions |
| `rust-testing` | cargo test, proptest, criterion benchmarks |
| `rust-security` | unsafe blocks, cargo audit, RUSTSEC |
| `rust-async` | Tokio, async/await, channels, select! |
| `rust-web` | Axum, Actix-web, handlers, middleware |
| `rust-database` | SQLx, Diesel, connection pools |
| `rust-backend-patterns` | Service/repo layering, AppState |
| `rust-tdd` | Test-driven development workflow |
| `rust-verification` | cargo check, clippy gates, CI |
| `rust-deployment` | Docker, cross-compilation, release |
| `rust-api-design` | REST API design principles |
| `rust-database-migrations` | sqlx migrate, diesel migrations |
| `rust-postgres-patterns` | PostgreSQL with SQLx/Diesel |
| `rust-docker-patterns` | Multi-stage Docker builds |
| `rust-clickhouse` | ClickHouse analytics |

### Ported from ECC (18)
See skills directory for: continuous-learning, security-review, deep-research, tdd-workflow, article-writing, content-engine, market-research, investor-materials, investor-outreach, crosspost, frontend-patterns, frontend-slides, liquid-glass-design, and more.

## Agents

### rust-reviewer
Expert Rust code reviewer for ownership, lifetimes, traits, and idioms.

### rust-build-resolver
Fixes borrow checker errors, lifetime issues, and Cargo conflicts.

## Commands

- `/rust-review` — Comprehensive code review
- `/rust-test` — Run tests with coverage
- `/rust-build` — Diagnose build errors
- `/rust-async-check` — Review async code

## Rules

Common rules (always apply):
- `common-coding-style` — Immutability, file organization
- `common-testing` — Coverage, naming, structure
- `common-security` — Input validation, secrets

Rust-specific rules (apply to `.rs` files):
- `rust-coding-style` — rustfmt, clippy, naming
- `rust-patterns` — Ownership, traits, error handling
- `rust-security` — unsafe, cargo audit
- `rust-testing` — Test layout, coverage
- `rust-hooks` — Pre/post edit hooks

## Examples

See `examples/rust-api-CLAUDE.md` for a full Axum + SQLx project setup.

## License

MIT
