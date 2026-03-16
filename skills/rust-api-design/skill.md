---
name: rust-api-design
description: REST API design principles applied to Rust projects including resource naming, versioning, request/response types with serde, and OpenAPI generation with utoipa.
origin: rust-claude-code
---

# Rust API Design

## When to Activate
- Designing REST APIs in Rust
- Structuring request/response types
- Setting up API versioning
- Generating OpenAPI documentation

---

## RESTful Resource Naming

```rust
// GOOD — resource-based
Router::new()
    .route("/users", get(list_users).post(create_user))
    .route("/users/:id", get(get_user).put(update_user).delete(delete_user))
    .route("/users/:id/orders", get(list_user_orders))

// BAD — action-based (RPC style over HTTP)
Router::new()
    .route("/getUser", get(get_user))
    .route("/createUser", post(create_user))
```

---

## Versioning Strategies

### URL Path Versioning (Recommended)
```rust
Router::new()
    .nest("/api/v1", v1_routes())
    .nest("/api/v2", v2_routes())

fn v1_routes() -> Router {
    Router::new()
        .route("/users", get(v1_list_users))
}
```

### Header Versioning (Alternative)
```rust
async fn api_handler(
    headers: HeaderMap,
) -> Response {
    match headers.get("API-Version") {
        Some(v) if v == "v2" => v2_handler().await,
        _ => v1_handler().await,
    }
}
```

---

## Request/Response Types

```rust
use serde::{Deserialize, Serialize};
use validator::Validate;

// Request with validation
#[derive(Deserialize, Validate)]
pub struct CreateUserRequest {
    #[validate(email)]
    pub email: String,
    
    #[validate(length(min = 2, max = 100))]
    pub name: String,
    
    #[serde(default)]
    pub role: Option<Role>,
}

// Response with serialization
#[derive(Serialize)]
pub struct UserResponse {
    pub id: u64,
    pub email: String,
    pub name: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub avatar_url: Option<String>,
    pub created_at: String,
}

// Pagination
#[derive(Deserialize, Validate)]
pub struct ListParams {
    #[validate(range(min = 1, max = 100))]
    #[serde(default = "default_limit")]
    pub limit: i64,
    
    #[serde(default)]
    pub offset: i64,
}

fn default_limit() -> i64 { 20 }

#[derive(Serialize)]
pub struct PaginatedResponse<T> {
    pub data: Vec<T>,
    pub total: i64,
    pub limit: i64,
    pub offset: i64,
}
```

---

## OpenAPI with utoipa

```toml
[dependencies]
utoipa = { version = "4", features = ["axum_extras"] }
utoipa-swagger-ui = { version = "6", features = ["axum"] }
```

```rust
use utoipa::OpenApi;
use utoipa_axum::routes;

#[derive(OpenApi)]
#[openapi(
    paths(
        create_user,
        get_user,
        list_users,
    ),
    components(
        schemas(CreateUserRequest, UserResponse, AppError)
    ),
    tags(
        (name = "users", description = "User management")
    )
)]
struct ApiDoc;

// Add route annotations
#[utoipa::path(
    post,
    path = "/api/v1/users",
    request_body = CreateUserRequest,
    responses(
        (status = 201, description = "User created", body = UserResponse),
        (status = 422, description = "Validation error", body = ErrorResponse),
    )
)]
pub async fn create_user(...) -> Result<..., AppError> { ... }

// Serve Swagger UI
let app = Router::new()
    .merge(SwaggerUi::new("/swagger-ui").url("/api-docs/openapi.json", ApiDoc::openapi()));
```

---

## Error Response Format

```rust
#[derive(Serialize)]
pub struct ErrorResponse {
    pub error: ErrorDetail,
}

#[derive(Serialize)]
pub struct ErrorDetail {
    pub code: String,
    pub message: String,
    #[serde(skip_serializing_if = "Option::is_none")]
    pub field: Option<String>,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let (status, error) = match self {
            AppError::NotFound(msg) => (
                StatusCode::NOT_FOUND,
                ErrorDetail { code: "NOT_FOUND".into(), message: msg, field: None }
            ),
            AppError::Validation(msg) => (
                StatusCode::UNPROCESSABLE_ENTITY,
                ErrorDetail { code: "VALIDATION_ERROR".into(), message: msg, field: None }
            ),
            _ => (
                StatusCode::INTERNAL_SERVER_ERROR,
                ErrorDetail { code: "INTERNAL_ERROR".into(), message: "internal server error".into(), field: None }
            ),
        };
        (status, Json(ErrorResponse { error })).into_response()
    }
}
```

---

## Best Practices
- Use plural nouns for resources: `/users`, not `/user`
- Use URL path versioning: `/api/v1/...`
- Always validate input at the boundary
- Return consistent error formats
- Use `#[serde(rename_all = "camelCase")]` for JSON conventions
- Generate OpenAPI docs from code with utoipa
