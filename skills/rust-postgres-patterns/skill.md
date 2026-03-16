---
name: rust-postgres-patterns
description: PostgreSQL patterns for Rust applications using SQLx and Diesel including connection pooling, query optimization, JSONB handling, full-text search, and listen/notify.
origin: rust-claude-code
---

# PostgreSQL Patterns for Rust

## When to Activate
- Using PostgreSQL with Rust
- Optimizing queries
- Using PostgreSQL-specific features
- Handling JSONB data

---

## Connection Pool Configuration

```rust
use sqlx::postgres::PgPoolOptions;

let pool = PgPoolOptions::new()
    .max_connections(20)
    .min_connections(5)
    .acquire_timeout(Duration::from_secs(3))
    .idle_timeout(Duration::from_secs(600))
    .max_lifetime(Duration::from_secs(1800))
    .after_connect(|conn, _meta| Box::pin(async move {
        conn.execute("SET TIME ZONE 'UTC'").await?;
        Ok(())
    }))
    .connect(database_url)
    .await?;
```

---

## JSONB Handling

```rust
use serde_json::Value;

// Store JSONB
#[derive(sqlx::FromRow)]
struct Event {
    id: i64,
    data: Value,  // JSONB
}

sqlx::query!(
    "INSERT INTO events (data) VALUES ($1)",
    serde_json::json!({"user_id": 1, "action": "login"})
)
.execute(&pool)
.await?;

// Query JSONB
sqlx::query_as!(
    Event,
    "SELECT * FROM events WHERE data->>'action' = $1",
    "login"
)
.fetch_all(&pool)
.await?;
```

---

## Full-Text Search

```sql
-- Migration
CREATE INDEX idx_users_search ON users 
USING gin (to_tsvector('english', name || ' ' || email));
```

```rust
pub async fn search_users(pool: &PgPool, query: &str) -> Result<Vec<User>, sqlx::Error> {
    sqlx::query_as!(
        User,
        r#"
        SELECT * FROM users 
        WHERE to_tsvector('english', name || ' ' || email) @@ plainto_tsquery('english', $1)
        ORDER BY ts_rank(to_tsvector('english', name || ' ' || email), plainto_tsquery('english', $1)) DESC
        LIMIT 20
        "#,
        query
    )
    .fetch_all(pool)
    .await
}
```

---

## Listen/Notify

```rust
use sqlx::postgres::PgListener;

let mut listener = PgListener::connect_with(&pool).await?;
listener.listen("user_events").await?;

loop {
    let notification = listener.recv().await?;
    println!("Channel: {}", notification.channel());
    println!("Payload: {}", notification.payload());
}
```

---

## Query Optimization

```rust
// Use EXPLAIN ANALYZE
let plan: String = sqlx::query_scalar(
    "EXPLAIN (ANALYZE, FORMAT JSON) SELECT * FROM users WHERE email = $1"
)
.bind(email)
.fetch_one(&pool)
.await?;

// Use covering indexes
sqlx::query!(
    "SELECT id, email FROM users WHERE email = $1",  // index-only scan
    email
)
.fetch_optional(&pool)
.await?;
```

---

## Best Practices
- Use connection pooling (never create connections per-request)
- Create indexes for frequently queried columns
- Use `sqlx prepare` to check queries compile offline
- Use PostgreSQL-specific types: `uuid`, `timestamptz`, `jsonb`, `array`
