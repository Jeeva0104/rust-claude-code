---
name: rust-clickhouse
description: ClickHouse analytics patterns for Rust using clickhouse-rs crate including connection setup, batch inserts, query optimization, and time-series data handling.
origin: rust-claude-code
---

# ClickHouse Patterns for Rust

## When to Activate
- Using ClickHouse for analytics in Rust
- Writing time-series data
- Optimizing analytical queries
- Setting up ClickHouse connections

---

## Connection Setup

```toml
[dependencies]
clickhouse = "0.11"
tokio = { version = "1", features = ["full"] }
```

```rust
use clickhouse::{Client, Row};

let client = Client::default()
    .with_url("http://localhost:8123")
    .with_database("analytics")
    .with_user("default")
    .with_password("password");
```

---

## Define Schema with Rows

```rust
use clickhouse::Row;
use serde::{Deserialize, Serialize};
use time::OffsetDateTime;

#[derive(Row, Serialize, Deserialize)]
struct Event {
    #[serde(with = "clickhouse::serde::time::datetime64::nanos")]
    timestamp: OffsetDateTime,
    user_id: u64,
    event_type: String,
    properties: String,  // JSON as String
}
```

---

## Batch Inserts

```rust
use futures::SinkExt;

let mut inserter = client.inserter("events")?
    .with_max_entries(100_000)
    .with_max_duration(Duration::from_secs(5));

for event in events {
    inserter.write(&event).await?;
}

inserter.end().await?;
```

---

## Querying

```rust
let mut cursor = client
    .query("SELECT ?fields FROM events WHERE event_type = ?")
    .bind("click")
    .fetch::<Event>()?;

while let Some(event) = cursor.next().await? {
    println!("{:?}", event);
}
```

---

## Time-Series Aggregations

```rust
#[derive(Row)]
struct HourlyStats {
    hour: u32,
    event_count: u64,
    unique_users: u64,
}

let stats: Vec<HourlyStats> = client
    .query(r#"
        SELECT 
            toHour(timestamp) as hour,
            count() as event_count,
            uniqExact(user_id) as unique_users
        FROM events
        WHERE timestamp >= today()
        GROUP BY hour
        ORDER BY hour
    "#)
    .fetch_all()
    .await?;
```

---

## Best Practices
- Use batch inserts (never insert row-by-row)
- Use appropriate time types (`DateTime64`)
- Partition by date for time-series data
- Use materialized views for common aggregations
- Consider using `LowCardinality(String)` for enum-like columns
