# Rust API — CLAUDE.md Example

## Project Overview

**Stack**: Axum + SQLx + Tokio + PostgreSQL

**Architecture**: Thin handlers → Service traits → Repository traits

## Critical Rules

### Ownership
- Use references over clones
- Don't fight the borrow checker—restructure

### Traits
- All services and repositories are trait-based
- Use `Arc<dyn Trait>` for dependency injection
- Implement standard traits: `Debug`, `From`, `Default`

### Error Handling
- Libraries: `thiserror`
- Applications: `anyhow`
- No `unwrap()` in production

### Async
- No blocking in async context—use `spawn_blocking`
- Don't hold `Mutex` guards across await
- Prefer channels over shared state

### Testing
- Unit tests co-located with code
- Mock traits with `mockall`
- Integration tests in `tests/`

## File Structure

```
my-api/
├── Cargo.toml
├── src/
│   ├── main.rs
│   ├── lib.rs
│   ├── config.rs
│   ├── error.rs          # AppError
│   ├── state.rs          # AppState
│   ├── handlers/
│   │   ├── mod.rs
│   │   └── users.rs      # Thin handlers
│   ├── services/
│   │   ├── mod.rs
│   │   ├── user_service.rs      # Trait
│   │   └── user_service_impl.rs # Implementation
│   ├── repositories/
│   │   ├── mod.rs
│   │   ├── user_repo.rs         # Trait
│   │   └── user_repo_impl.rs    # Implementation
│   └── models/
│       ├── mod.rs
│       └── user.rs
└── tests/
    └── integration_tests.rs
```

## Key Patterns

### Handler (Thin)
```rust
pub async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUserRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user = state.user_service.create(payload).await?;
    Ok((StatusCode::CREATED, Json(UserResponse::from(user))))
}
```

### Service Trait
```rust
#[async_trait]
pub trait UserService: Send + Sync {
    async fn create(&self, req: CreateUserRequest) -> Result<User, AppError>;
    async fn get(&self, id: u64) -> Result<User, AppError>;
}

pub struct UserServiceImpl {
    repo: Arc<dyn UserRepository>,
}

#[async_trait]
impl UserService for UserServiceImpl {
    async fn create(&self, req: CreateUserRequest) -> Result<User, AppError> {
        if self.repo.find_by_email(&req.email).await?.is_some() {
            return Err(AppError::Validation("email taken".into()));
        }
        let hash = hash_password(&req.password)?;
        self.repo.insert(&req.email, &req.name, &hash).await
    }
}
```

### Repository Trait
```rust
#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn find_by_id(&self, id: u64) -> Result<Option<User>, AppError>;
    async fn find_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
    async fn insert(&self, email: &str, name: &str, hash: &str) -> Result<User, AppError>;
}

pub struct PgUserRepository {
    pool: PgPool,
}

#[async_trait]
impl UserRepository for PgUserRepository {
    async fn find_by_id(&self, id: u64) -> Result<Option<User>, AppError> {
        sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", id as i64)
            .fetch_optional(&self.pool)
            .await
            .map_err(AppError::Database)
    }
}
```

### Error Type
```rust
use thiserror::Error;
use axum::response::{IntoResponse, Response};

#[derive(Error, Debug)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("validation error: {0}")]
    Validation(String),
    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, msg) = match &self {
            AppError::NotFound(m) => (StatusCode::NOT_FOUND, m.clone()),
            AppError::Validation(m) => (StatusCode::UNPROCESSABLE_ENTITY, m.clone()),
            AppError::Database(_) => (StatusCode::INTERNAL_SERVER_ERROR, "db error".into()),
        };
        (status, Json(json!({"error": msg}))).into_response()
    }
}
```

### AppState
```rust
#[derive(Clone)]
pub struct AppState {
    pub user_service: Arc<dyn UserService>,
    pub db: PgPool,
}

impl AppState {
    pub async fn new(config: Config) -> Result<Self, AppError> {
        let pool = create_pool(&config.database_url).await?;
        let repo = Arc::new(PgUserRepository::new(pool.clone()));
        let svc = Arc::new(UserServiceImpl::new(repo));
        
        Ok(Self {
            user_service: svc,
            db: pool,
        })
    }
}
```

## Running

```bash
# Dev
cargo watch -x run

# Test
cargo test

# Build release
cargo build --release
```
