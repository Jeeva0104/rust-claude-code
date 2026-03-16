---
name: blueprint
description: Project blueprints and scaffolding for Rust applications. Templates for web APIs, CLI tools, and async services.
origin: rust-claude-code
---

# Project Blueprints

## When to Activate
- Starting a new Rust project
- Scaffolding a new module
- Setting up project structure

---

## Web API Blueprint

```
my-api/
├── Cargo.toml
├── Dockerfile
├── docker-compose.yml
├── .env.example
├── .github/
│   └── workflows/
│       └── ci.yml
├── migrations/
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── config.rs
│   ├── error.rs
│   ├── state.rs
│   ├── handlers/
│   │   ├── mod.rs
│   │   └── users.rs
│   ├── services/
│   │   ├── mod.rs
│   │   ├── user_service.rs
│   │   └── user_service_impl.rs
│   ├── repositories/
│   │   ├── mod.rs
│   │   ├── user_repo.rs
│   │   └── user_repo_impl.rs
│   └── models/
│       ├── mod.rs
│       └── user.rs
└── tests/
    └── integration_tests.rs
```

---

## CLI Tool Blueprint

```
my-cli/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── cli.rs        # clap definitions
│   ├── commands/     # command implementations
│   └── config.rs
└── tests/
    └── cli_tests.rs
```

---

## Scaffolding Commands

```bash
# Create new project from blueprint
cargo new my-api --bin
cd my-api

# Add dependencies
cargo add tokio axum sqlx serde serde_json thiserror anyhow

# Create directories
mkdir -p src/{handlers,services,repositories,models}
mkdir -p migrations tests
```
