---
name: rust-async
description: Async Rust patterns covering Tokio runtime, async/await, futures, channels, select!, shared state, and avoiding common async pitfalls.
origin: rust-claude-code
---

# Async Rust Patterns

## When to Activate
- Writing async Rust code
- Using Tokio or async-std
- Designing concurrent systems
- Diagnosing async performance issues

---

## Tokio Runtime Setup

```rust
// Binary entry point
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // async code here
    Ok(())
}

// Custom runtime (for fine-tuned control)
fn main() {
    tokio::runtime::Builder::new_multi_thread()
        .worker_threads(4)
        .enable_all()
        .build()
        .unwrap()
        .block_on(run());
}
```

---

## async fn and .await

```rust
// Declare async functions
async fn fetch_user(id: u64) -> Result<User, AppError> {
    let user = db.find(id).await?;
    user.ok_or(AppError::NotFound(format!("user {id}")))
}

// Await multiple futures concurrently (NOT sequentially)
// BAD — sequential (waits for each before starting next)
let a = fetch_a().await?;
let b = fetch_b().await?;

// GOOD — concurrent
let (a, b) = tokio::join!(fetch_a(), fetch_b());
```

---

## Spawning Tasks

```rust
// Spawn independent task (fire and forget)
let handle = tokio::spawn(async move {
    process_data(data).await
});

// Await the result
let result = handle.await??; // first ? for JoinError, second for task error

// Spawn multiple and collect
let handles: Vec<_> = items
    .into_iter()
    .map(|item| tokio::spawn(async move { process(item).await }))
    .collect();

let results: Vec<_> = futures::future::join_all(handles).await;
```

---

## Channels

```rust
use tokio::sync::{mpsc, oneshot, broadcast, watch};

// mpsc — multiple producers, single consumer
let (tx, mut rx) = mpsc::channel::<Message>(100);
tokio::spawn(async move { tx.send(msg).await.unwrap(); });
while let Some(msg) = rx.recv().await { process(msg); }

// oneshot — single value, one-shot response
let (tx, rx) = oneshot::channel::<Response>();
tx.send(response).unwrap();
let response = rx.await.unwrap();

// broadcast — multiple consumers
let (tx, _) = broadcast::channel::<Event>(16);
let mut rx1 = tx.subscribe();
let mut rx2 = tx.subscribe();
tx.send(event).unwrap();

// watch — latest value only
let (tx, rx) = watch::channel(initial_value);
tx.send(new_value).unwrap();
let current = rx.borrow().clone();
```

---

## tokio::select! — Concurrent Branches

```rust
tokio::select! {
    result = fetch_primary() => {
        // primary completed first
        handle_result(result)
    }
    result = fetch_fallback() => {
        // fallback completed first
        handle_result(result)
    }
    _ = tokio::time::sleep(Duration::from_secs(5)) => {
        // timeout
        Err(AppError::Timeout)
    }
}
```

---

## spawn_blocking — CPU-Bound Work

Never block the async executor with CPU-intensive work:

```rust
// BAD — blocks the executor thread
async fn compute() {
    let result = heavy_computation(); // blocks!
}

// GOOD — offload to thread pool
async fn compute() -> Result<Output, AppError> {
    tokio::task::spawn_blocking(|| {
        heavy_computation()
    })
    .await
    .map_err(|e| AppError::Internal(e.to_string()))?
}
```

---

## Shared State

```rust
use std::sync::Arc;
use tokio::sync::Mutex;

// Arc<Mutex<T>> for shared mutable state
#[derive(Clone)]
pub struct AppState {
    pub db: Arc<PgPool>,
    pub cache: Arc<Mutex<HashMap<String, Value>>>,
}

// Prefer channels over Mutex for producer/consumer patterns
// Prefer Arc<RwLock<T>> when reads far outnumber writes
use tokio::sync::RwLock;
let data = Arc::new(RwLock::new(HashMap::new()));
let read = data.read().await;
let mut write = data.write().await;
```

---

## Common Pitfalls

```rust
// PITFALL 1: Holding a Mutex guard across .await
// BAD
let guard = mutex.lock().await;
some_async_fn().await; // guard held across await = potential deadlock
drop(guard); // too late

// GOOD
{
    let guard = mutex.lock().await;
    let value = guard.clone();
} // guard dropped before await
some_async_fn_with(value).await;

// PITFALL 2: Using std::sync::Mutex in async context
// Use tokio::sync::Mutex for async code

// PITFALL 3: Not using .await on futures (silently dropped)
// BAD
fetch_data(); // future created but never awaited
// GOOD
fetch_data().await;
```

---

## Timeouts

```rust
use tokio::time::{timeout, Duration};

let result = timeout(
    Duration::from_secs(30),
    fetch_external_api(),
)
.await
.map_err(|_| AppError::Timeout)?;
```

---

## Best Practices
- Use `tokio::join!` for concurrent independent futures
- Use `tokio::spawn` for truly independent background tasks
- Use `spawn_blocking` for any synchronous/CPU-heavy work
- Prefer channels over shared `Mutex` for coordination
- Never hold a `Mutex` guard across an `.await` point
- Always set timeouts on external calls
