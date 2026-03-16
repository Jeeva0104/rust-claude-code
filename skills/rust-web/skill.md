---
name: rust-web
description: Rust web framework patterns for Axum and Actix-web covering handlers, extractors, middleware, shared state, error handling, and the thin handler/service/repository architecture.
origin: rust-claude-code
---

# Rust Web Patterns

## When to Activate
- Building REST APIs in Rust
- Using Axum or Actix-web
- Designing HTTP middleware
- Structuring web application layers

---

## Axum — Router & Handlers

```rust
use axum::{Router, routing::{get, post, delete}};

pub fn create_router(state: AppState) -> Router {
    Router::new()
        .route("/users", get(list_users).post(create_user))
        .route("/users/:id", get(get_user).delete(delete_user))
        .layer(
            ServiceBuilder::new()
                .layer(TraceLayer::new_for_http())
                .layer(CorsLayer::permissive()),
        )
        .with_state(state)
}
```

### Axum Extractors

```rust
use axum::{
    extract::{Path, Query, State, Json},
    response::{IntoResponse, Response},
    http::StatusCode,
};

// Thin handler — delegates all logic to service
pub async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUserRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user = state.user_service.create(payload).await?;
    Ok((StatusCode::CREATED, Json(user)))
}

pub async fn get_user(
    State(state): State<AppState>,
    Path(id): Path<u64>,
) -> Result<Json<UserResponse>, AppError> {
    let user = state.user_service.get(id).await?;
    Ok(Json(UserResponse::from(user)))
}

pub async fn list_users(
    State(state): State<AppState>,
    Query(params): Query<ListParams>,
) -> Result<Json<Vec<UserResponse>>, AppError> {
    let users = state.user_service.list(params).await?;
    Ok(Json(users.into_iter().map(UserResponse::from).collect()))
}
```

### Axum Error Handling

```rust
use axum::response::{IntoResponse, Response};
use axum::http::StatusCode;
use axum::Json;

#[derive(Debug, thiserror::Error)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("validation error: {0}")]
    Validation(String),
    #[error("internal error")]
    Internal(#[from] anyhow::Error),
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, message) = match &self {
            AppError::NotFound(msg) => (StatusCode::NOT_FOUND, msg.clone()),
            AppError::Validation(msg) => (StatusCode::UNPROCESSABLE_ENTITY, msg.clone()),
            AppError::Internal(_) => (StatusCode::INTERNAL_SERVER_ERROR, "internal server error".into()),
        };
        (status, Json(serde_json::json!({"error": message}))).into_response()
    }
}
```

### Axum Shared State

```rust
#[derive(Clone)]
pub struct AppState {
    pub user_service: Arc<dyn UserService>,
    pub db: PgPool,
}

// In main
let state = AppState {
    user_service: Arc::new(UserServiceImpl::new(pool.clone())),
    db: pool,
};
let app = create_router(state);
```

---

## Actix-web Patterns

```rust
use actix_web::{web, App, HttpServer, HttpResponse, Result};

pub async fn create_user(
    state: web::Data<AppState>,
    body: web::Json<CreateUserRequest>,
) -> Result<HttpResponse> {
    let user = state.user_service.create(body.into_inner()).await
        .map_err(|e| actix_web::error::ErrorUnprocessableEntity(e))?;
    Ok(HttpResponse::Created().json(user))
}

#[actix_web::main]
async fn main() -> std::io::Result<()> {
    let state = AppState::new().await;
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(state.clone()))
            .route("/users", web::post().to(create_user))
            .route("/users/{id}", web::get().to(get_user))
    })
    .bind("0.0.0.0:8080")?
    .run()
    .await
}
```

---

## Layered Architecture

```
Request → Handler (thin) → Service (business logic) → Repository (data access)
```

```rust
// Handler — thin, only HTTP concerns
pub async fn create_user(
    State(state): State<AppState>,
    Json(payload): Json<CreateUserRequest>,
) -> Result<impl IntoResponse, AppError> {
    let user = state.user_service.create(payload).await?;
    Ok((StatusCode::CREATED, Json(UserResponse::from(user))))
}

// Service — business logic, uses trait for testability
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
            return Err(AppError::Validation("email already registered".into()));
        }
        let hash = hash_password(&req.password)?;
        self.repo.insert(&req.email, &req.name, &hash).await
    }

    async fn get(&self, id: u64) -> Result<User, AppError> {
        self.repo.find_by_id(id).await?
            .ok_or_else(|| AppError::NotFound(format!("user {id}")))
    }
}

// Repository — data access only
#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn find_by_id(&self, id: u64) -> Result<Option<User>, AppError>;
    async fn find_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
    async fn insert(&self, email: &str, name: &str, hash: &str) -> Result<User, AppError>;
}
```

---

## Middleware

```rust
use tower_http::{
    trace::TraceLayer,
    cors::CorsLayer,
    compression::CompressionLayer,
    auth::RequireAuthorizationLayer,
};

let app = Router::new()
    .merge(public_routes())
    .merge(
        private_routes()
            .layer(RequireAuthorizationLayer::bearer("secret-token"))
    )
    .layer(TraceLayer::new_for_http())
    .layer(CompressionLayer::new())
    .layer(CorsLayer::permissive());
```

---

## Request Validation

```rust
use validator::Validate;
use axum_valid::Valid;

#[derive(Deserialize, Validate)]
pub struct CreateUserRequest {
    #[validate(email)]
    pub email: String,
    #[validate(length(min = 2, max = 100))]
    pub name: String,
}

// Use Valid<Json<T>> extractor — auto-validates
pub async fn create_user(
    Valid(Json(payload)): Valid<Json<CreateUserRequest>>,
) -> Result<impl IntoResponse, AppError> { ... }
```

---

## Best Practices
- Handlers must be thin — no business logic
- All services and repositories behind traits for testability
- Use `AppState` with `Arc<dyn Trait>` for shared services
- Always implement `IntoResponse` for custom error types
- Use `tower-http` layers for cross-cutting concerns
- Set request timeouts at the router level
