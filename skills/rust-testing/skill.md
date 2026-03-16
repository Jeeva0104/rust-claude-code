---
name: rust-testing
description: Rust testing patterns covering unit tests, integration tests, mocking with mockall, property-based testing with proptest, benchmarks with criterion, and coverage with cargo-tarpaulin.
origin: rust-claude-code
---

# Rust Testing Patterns

## When to Activate
- Writing tests for Rust code
- Setting up test infrastructure
- Configuring benchmarks
- Measuring code coverage

---

## Unit Tests

Co-locate unit tests with the code they test:

```rust
// src/services/user_service.rs
pub fn validate_email(email: &str) -> bool {
    email.contains('@') && email.contains('.')
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn valid_email_passes() {
        assert!(validate_email("alice@example.com"));
    }

    #[test]
    fn email_without_at_fails() {
        assert!(!validate_email("notanemail.com"));
    }

    #[test]
    #[should_panic(expected = "index out of bounds")]
    fn panics_on_bad_index() {
        let v = vec![1, 2, 3];
        let _ = v[10];
    }
}
```

---

## Integration Tests

Place in `tests/` directory — each file is a separate test binary:

```rust
// tests/user_api.rs
use my_crate::{AppState, create_app};

#[tokio::test]
async fn test_create_user() {
    let state = AppState::test().await;
    let app = create_app(state);
    
    let response = app
        .oneshot(Request::post("/users").body(Body::from(
            r#"{"email":"test@example.com","name":"Test"}"#,
        )).unwrap())
        .await
        .unwrap();

    assert_eq!(response.status(), StatusCode::CREATED);
}
```

---

## Async Tests

```rust
#[tokio::test]
async fn test_async_operation() {
    let result = fetch_data().await;
    assert!(result.is_ok());
}

// With custom runtime config
#[tokio::test(flavor = "multi_thread", worker_threads = 2)]
async fn test_concurrent() { ... }
```

---

## Mocking with mockall

```rust
use mockall::{automock, predicate::*};

#[automock]
pub trait UserRepository {
    async fn find_by_id(&self, id: u64) -> Result<Option<User>, DbError>;
    async fn insert(&self, user: &NewUser) -> Result<User, DbError>;
}

#[tokio::test]
async fn test_user_service_get() {
    let mut mock_repo = MockUserRepository::new();
    mock_repo
        .expect_find_by_id()
        .with(eq(1u64))
        .times(1)
        .returning(|_| Ok(Some(User { id: 1, name: "Alice".into() })));

    let service = UserService::new(Arc::new(mock_repo));
    let user = service.get(1).await.unwrap();
    assert_eq!(user.name, "Alice");
}
```

---

## Property-Based Testing with proptest

```rust
use proptest::prelude::*;

proptest! {
    #[test]
    fn parse_doesnt_crash(s in "\\PC*") {
        let _ = parse_input(&s);
    }

    #[test]
    fn encode_decode_roundtrip(data in prop::collection::vec(any::<u8>(), 0..1000)) {
        let encoded = encode(&data);
        let decoded = decode(&encoded).unwrap();
        prop_assert_eq!(data, decoded);
    }
}
```

---

## Benchmarks with criterion

```toml
# Cargo.toml
[dev-dependencies]
criterion = { version = "0.5", features = ["html_reports"] }

[[bench]]
name = "my_benchmark"
harness = false
```

```rust
// benches/my_benchmark.rs
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn benchmark_sort(c: &mut Criterion) {
    let data: Vec<i32> = (0..1000).rev().collect();
    
    c.bench_function("sort 1000 items", |b| {
        b.iter(|| {
            let mut d = black_box(data.clone());
            d.sort();
        })
    });
}

criterion_group!(benches, benchmark_sort);
criterion_main!(benches);
```

Run: `cargo bench`

---

## Test Coverage with cargo-tarpaulin

```bash
# Install
cargo install cargo-tarpaulin

# Run coverage
cargo tarpaulin --out Html --output-dir coverage/

# CI threshold
cargo tarpaulin --fail-under 80
```

---

## Cargo Test Flags

```bash
cargo test                          # run all tests
cargo test --lib                    # unit tests only
cargo test --test integration_test  # specific integration test file
cargo test user                     # filter by name
cargo test -- --nocapture           # show println! output
cargo test -- --test-threads=1      # run single-threaded (useful for DB tests)
cargo test -- --ignored             # run #[ignore]d tests
```

---

## Test Helpers & Fixtures

```rust
// tests/helpers/mod.rs
pub struct TestDb {
    pub pool: PgPool,
    pub container: DockerContainer,
}

impl TestDb {
    pub async fn new() -> Self {
        // spin up test postgres
    }
}

impl Drop for TestDb {
    fn drop(&mut self) {
        // cleanup
    }
}
```

---

## Best Practices
- Test names should describe behavior: `user_with_invalid_email_returns_validation_error`
- Use Arrange / Act / Assert structure
- Test one behavior per test function
- Use `#[ignore]` for slow/external tests; run separately in CI
- Mock at trait boundaries — this is why trait-based design matters
- Aim for 80%+ coverage; 100% on critical paths
