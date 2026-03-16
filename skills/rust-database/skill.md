---
name: rust-database
description: Rust database patterns with SQLx and Diesel covering compile-time query verification, connection pools, repository trait pattern, and migration strategies.
origin: rust-claude-code
---

# Rust Database Patterns

## When to Activate
- Setting up database access in Rust
- Writing SQLx or Diesel queries
- Designing repository layer
- Configuring connection pools

---

## SQLx — Compile-Time Verified Queries

```toml
[dependencies]
sqlx = { version = "0.7", features = ["postgres", "runtime-tokio", "macros", "uuid", "chrono"] }
```

```rust
// query_as! — compile-time verified, maps to struct
#[derive(sqlx::FromRow)]
pub struct User {
    pub id: i64,
    pub email: String,
    pub name: String,
    pub created_at: chrono::DateTime<chrono::Utc>,
}

pub async fn find_by_id(pool: &PgPool, id: i64) -> Result<Option<User>, sqlx::Error> {
    sqlx::query_as!(
        User,
        "SELECT id, email, name, created_at FROM users WHERE id = $1",
        id
    )
    .fetch_optional(pool)
    .await
}

pub async fn insert(pool: &PgPool, email: &str, name: &str) -> Result<User, sqlx::Error> {
    sqlx::query_as!(
        User,
        "INSERT INTO users (email, name) VALUES ($1, $2) RETURNING id, email, name, created_at",
        email,
        name
    )
    .fetch_one(pool)
    .await
}
```

### Connection Pool Setup

```rust
use sqlx::postgres::PgPoolOptions;

pub async fn create_pool(database_url: &str) -> Result<PgPool, sqlx::Error> {
    PgPoolOptions::new()
        .max_connections(20)
        .min_connections(5)
        .acquire_timeout(Duration::from_secs(3))
        .idle_timeout(Duration::from_secs(600))
        .connect(database_url)
        .await
}
```

---

## Repository Trait Pattern

```rust
use async_trait::async_trait;

#[async_trait]
pub trait UserRepository: Send + Sync {
    async fn find_by_id(&self, id: i64) -> Result<Option<User>, AppError>;
    async fn find_by_email(&self, email: &str) -> Result<Option<User>, AppError>;
    async fn insert(&self, req: &NewUser) -> Result<User, AppError>;
    async fn update(&self, id: i64, req: &UpdateUser) -> Result<User, AppError>;
    async fn delete(&self, id: i64) -> Result<(), AppError>;
}

pub struct PgUserRepository {
    pool: PgPool,
}

#[async_trait]
impl UserRepository for PgUserRepository {
    async fn find_by_id(&self, id: i64) -> Result<Option<User>, AppError> {
        sqlx::query_as!(User, "SELECT * FROM users WHERE id = $1", id)
            .fetch_optional(&self.pool)
            .await
            .map_err(AppError::Database)
    }
    // ...
}
```

---

## Transactions

```rust
pub async fn transfer(pool: &PgPool, from: i64, to: i64, amount: Decimal) -> Result<(), AppError> {
    let mut tx = pool.begin().await.map_err(AppError::Database)?;
    
    sqlx::query!("UPDATE accounts SET balance = balance - $1 WHERE id = $2", amount, from)
        .execute(&mut *tx)
        .await
        .map_err(AppError::Database)?;
    
    sqlx::query!("UPDATE accounts SET balance = balance + $1 WHERE id = $2", amount, to)
        .execute(&mut *tx)
        .await
        .map_err(AppError::Database)?;
    
    tx.commit().await.map_err(AppError::Database)?;
    Ok(())
}
```

---

## Diesel ORM

```toml
[dependencies]
diesel = { version = "2.1", features = ["postgres", "r2d2", "chrono"] }
```

```rust
use diesel::prelude::*;

#[derive(Queryable, Selectable)]
#[diesel(table_name = crate::schema::users)]
pub struct User { pub id: i32, pub email: String, pub name: String }

#[derive(Insertable)]
#[diesel(table_name = users)]
pub struct NewUser<'a> { pub email: &'a str, pub name: &'a str }

// Query
pub fn find_user(conn: &mut PgConnection, user_id: i32) -> QueryResult<User> {
    users::table.find(user_id).first(conn)
}

// Insert
pub fn create_user(conn: &mut PgConnection, email: &str, name: &str) -> QueryResult<User> {
    diesel::insert_into(users::table)
        .values(NewUser { email, name })
        .get_result(conn)
}
```

---

## Best Practices
- Always use parameterized queries — never string interpolate
- Use `query_as!` macro for compile-time verification with SQLx
- Design repository as a trait for testability (mockable)
- Use connection pools — never create per-request connections
- Wrap multi-step DB operations in transactions
- Set `acquire_timeout` to fail fast on pool exhaustion
