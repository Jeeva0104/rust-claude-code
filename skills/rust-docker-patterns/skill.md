---
name: rust-docker-patterns
description: Docker patterns for Rust applications including multi-stage builds, cache optimization, distroless images, health checks, and docker-compose for development.
origin: rust-claude-code
---

# Docker Patterns for Rust

## When to Activate
- Dockerizing Rust applications
- Optimizing build times
- Setting up development environments
- Configuring production deployments

---

## Multi-Stage Build (Production)

```dockerfile
# Build stage
FROM rust:1.75-slim-bookworm AS builder

WORKDIR /app

# Cache dependencies
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release
RUN rm -rf src

# Build application
COPY src ./src
RUN cargo build --release

# Runtime stage (distroless)
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/target/release/myapp /myapp

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/myapp"]
```

---

## Docker Compose for Development

```yaml
# docker-compose.yml
version: "3.8"

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
      - cargo-cache:/usr/local/cargo/registry
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/myapp
      - RUST_LOG=debug
    depends_on:
      - db

  db:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  cargo-cache:
  postgres_data:
```

---

## Cache Optimization

```dockerfile
# Build dependencies separately (cache layer)
COPY Cargo.toml Cargo.lock ./
RUN mkdir src && echo 'fn main() {}' > src/main.rs
RUN cargo build --release && rm -rf src

# Build actual code
COPY src ./src
RUN cargo build --release
```

---

## Health Checks

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/target/release/myapp /usr/local/bin/

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1

ENTRYPOINT ["/usr/local/bin/myapp"]
```

---

## Best Practices
- Use multi-stage builds for smaller images
- Cache dependencies separately from source code
- Use distroless or Alpine for production
- Never run as root in containers
- Include health checks
- Use .dockerignore to exclude target/, .git/, etc.
