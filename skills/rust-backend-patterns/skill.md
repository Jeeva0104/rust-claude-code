---
name: rust-backend-patterns
description: Rust backend architecture patterns covering AppState design, layered service/repository architecture, trait-based dependency injection, error types, and configuration management.
origin: rust-claude-code
---

# Rust Backend Architecture Patterns

## When to Activate
- Structuring a Rust backend application
- Designing service layers
- Setting up dependency injection
- Managing application configuration

---

## AppState — Shared Application State

```rust
#[derive(Clone)]
pub struct AppState {
    pub db: PgPool,
    pub user_service: Arc<dyn UserService>,
    pub email_service: Arc<dyn EmailService>,
    pub config: Arc<Config>,
}

impl AppState {
    pub async fn new(config: Config) -> Result<Self, AppError> {
        let pool = create_pool(&config.database_url).await?;
        let user_repo = Arc::new(PgUserRepository::new(pool.clone()));
        let email_svc = Arc::new(SmtpEmailService::new(&config.smtp));
        let user_svc = Arc::new(UserServiceImpl::new(user_repo, email_svc.clone()));
        
        Ok(Self {
            db: pool,
            user_service: user_svc,
            email_service: email_svc,
            config: Arc::new(config),
        })
    }
}
```

---

## Layered Architecture

```
Handler → Service → Repository → Database
  (HTTP)  (business)  (data)
```

All layers communicate through traits:

```rust
// Layer 1: Handler (HTTP only, no business logic)
pub async fn register(
    State(state): State<AppState>,
    Json(req): Json<RegisterRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user = state.user_service.register(req).await?;
    Ok((StatusCode::CREATED, Json(UserResponse::from(user))))
}

// Layer 2: Service (business logic)
#[async_trait]
pub trait UserService: Send + Sync {
    async fn register(&self, req: RegisterRequest) -> Result<User, AppError>;
}

pub struct UserServiceImpl {
    repo: Arc<dyn UserRepository>,
    email: Arc<dyn EmailService>,
}

#[async_trait]
impl UserService for UserServiceImpl {
    async fn register(&self, req: RegisterRequest) -> Result<User, AppError> {
        req.validate().map_err(|e| AppError::Validation(e.to_string()))?;
        if self.repo.find_by_email(&req.email).await?.is_some() {
            return Err(AppError::Validation("email taken".into()));
        }
        let hash = hash_password(&req.password)?;
        let user = self.repo.insert(&req.email, &req.name, &hash).await?;
        self.email.send_welcome(&user.email).await?;
        Ok(user)
    }
}

// Layer 3: Repository (data access only)
#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn find_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
    async fn insert(&self, email: &str, name: &str, hash: &str) -> Result<User, AppError>;
}
```

---

## Error Types

```rust
use thiserror::Error;

// Domain errors — specific, typed
#[derive(Error, Debug)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    
    #[error("validation error: {0}")]
    Validation(String),
    
    #[error("unauthorized")]
    Unauthorized,
    
    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),
    
    #[error("internal error: {0}")]
    Internal(#[from] anyhow::Error),
}
```

Use `thiserror` for libraries/domain errors. Use `anyhow` for application-level error propagation.

---

## Configuration Management

```toml
[dependencies]
config = "0.14"
serde = { version = "1", features = ["derive"] }
dotenvy = "0.15"
```

```rust
use config::{Config as ConfigLoader, Environment, File};
use serde::Deserialize;

#[derive(Deserialize, Clone)]
pub struct Config {
    pub database_url: String,
    pub server_port: u16,
    pub jwt_secret: String,
    pub smtp: SmtpConfig,
}

impl Config {
    pub fn load() -> Result<Self, config::ConfigError> {
        ConfigLoader::builder()
            .add_source(File::with_name("config/default").required(false))
            .add_source(File::with_name("config/local").required(false))
            .add_source(Environment::default().separator("__"))
            .build()?
            .try_deserialize()
    }
}
```

---

## Dependency Injection via Traits

```rust
// Test with mock implementations
#[cfg(test)]
mod tests {
    use mockall::mock;
    use super::*;

    mock! {
        UserRepo {}
        #[async_trait]
        impl UserRepository for UserRepo {
            async fn find_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
            async fn insert(&self, email: &str, name: &str, hash: &str) -> Result<User, AppError>;
        }
    }

    #[tokio::test]
    async fn register_duplicate_email_returns_error() {
        let mut mock = MockUserRepo::new();
        mock.expect_find_by_email()
            .returning(|_| Ok(Some(existing_user())));
        
        let svc = UserServiceImpl::new(Arc::new(mock), mock_email());
        let result = svc.register(register_request()).await;
        
        assert!(matches!(result, Err(AppError::Validation(_))));
    }
}
```

---

## Best Practices
- Always use `Arc<dyn Trait>` for injectable dependencies
- Keep handlers thin — delegate all logic to services
- Use a single `AppState` passed to all handlers
- Define `AppError` centrally, implement `IntoResponse` for it
- Load config from environment variables (12-factor app)
- Use `Clone` on `AppState` (it's cheap with `Arc`)
