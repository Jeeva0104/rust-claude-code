---
name: rust-deployment
description: Rust deployment patterns covering Docker multi-stage builds, cross-compilation with cross and cargo-zigbuild, release profile optimization, and CI/CD configuration.
origin: rust-claude-code
---

# Rust Deployment Patterns

## When to Activate
- Building Docker images for Rust
- Cross-compiling for different targets
- Optimizing release builds
- Setting up deployment pipelines

---

## Multi-Stage Docker Build

```dockerfile
# Dockerfile
# Stage 1: Builder
FROM rust:1.75-slim-bookworm AS builder

WORKDIR /app
COPY Cargo.toml Cargo.lock ./
COPY src ./src

RUN cargo build --release

# Stage 2: Runtime (distroless for minimal attack surface)
FROM gcr.io/distroless/cc-debian12

COPY --from=builder /app/target/release/myapp /myapp

EXPOSE 8080

ENTRYPOINT ["/myapp"]
```

For glibc compatibility:
```dockerfile
FROM debian:bookworm-slim AS runtime
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /app/target/release/myapp /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/myapp"]
```

---

## Release Profile Optimization

```toml
# Cargo.toml
[profile.release]
opt-level = 3          # max optimization
lto = "thin"           # link-time optimization (thin is faster, full is smaller)
strip = true           # strip symbols
panic = "abort"        # smaller binary, no unwinding
codegen-units = 1      # slower compile, better optimization
```

---

## Cross-Compilation

### Using cross (Docker-based)
```bash
# Install
cargo install cross

# Build for target
cross build --release --target x86_64-unknown-linux-musl

# Available targets: aarch64-unknown-linux-gnu, armv7-unknown-linux-gnueabihf, etc.
```

### Using cargo-zigbuild (faster, no Docker)
```bash
# Install
cargo install cargo-zigbuild

# Build for musl (static binary)
cargo zigbuild --release --target x86_64-unknown-linux-musl

# Build for ARM64
cargo zigbuild --release --target aarch64-unknown-linux-gnu
```

### Static Binary for Alpine
```bash
# Install musl target
rustup target add x86_64-unknown-linux-musl

# Build
RUSTFLAGS='-C target-feature=+crt-static' \
  cargo build --release --target x86_64-unknown-linux-musl
```

---

## GitHub Actions Deployment

```yaml
# .github/workflows/deploy.yml
name: Build and Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: dtolnay/rust-toolchain@stable
      - uses: Swatinem/rust-cache@v2
      
      - name: Build release
        run: cargo build --release
        
      - name: Upload artifact
        uses: actions/upload-artifact@v4
        with:
          name: myapp
          path: target/release/myapp

  docker:
    runs-on: ubuntu-latest
    needs: build
    steps:
      - uses: actions/checkout@v4
      
      - name: Docker Login
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
          
      - name: Docker Build and Push
        run: |
          docker build -t ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }} .
          docker push ${{ secrets.DOCKER_USERNAME }}/myapp:${{ github.sha }}
```

---

## Binary Size Optimization

```bash
# Check binary size
cargo bloat --release

# Profile with cargo-bloat
cargo install cargo-bloat
cargo bloat --release -n 20

# Further optimize with upx (optional, may trigger AV)
upx --best target/release/myapp
```

---

## Health Check Endpoint

```rust
// src/handlers/health.rs
pub async fn health_check() -> impl IntoResponse {
    (StatusCode::OK, Json(json!({"status": "healthy"})))
}

// In Dockerfile HEALTHCHECK
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

---

## Best Practices
- Use distroless or Alpine for runtime images
- Build static binaries with musl for maximum portability
- Use `cross` or `cargo-zigbuild` for easy cross-compilation
- Enable LTO and strip symbols in release builds
- Always have a `/health` endpoint
