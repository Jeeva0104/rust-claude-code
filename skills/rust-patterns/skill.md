---
name: rust-patterns
description: Idiomatic Rust patterns covering ownership, borrowing, lifetimes, traits, error handling, and iterators for robust and efficient Rust code.
origin: rust-claude-code
---

# Rust Core Patterns

## When to Activate
- Writing new Rust code
- Reviewing existing Rust code
- Designing Rust APIs or libraries
- Refactoring Rust modules
- Choosing between trait approaches

---

## Ownership & Borrowing

### Move Semantics
```rust
let s1 = String::from("hello");
let s2 = s1; // s1 is moved, no longer valid
// println!("{}", s1); // ERROR: value borrowed after move

// Clone when you need both
let s3 = String::from("hello");
let s4 = s3.clone(); // explicit deep copy
```

### References & Borrowing Rules
- One mutable reference OR many immutable references — never both
- References must always be valid (no dangling references)

```rust
fn calculate_length(s: &String) -> usize {
    s.len() // borrow, not move
}

fn change(s: &mut String) {
    s.push_str(", world");
}
```

### Copy vs Clone
```rust
// Copy types (stack-only): i32, f64, bool, char, tuples of Copy types
let x = 5;
let y = x; // copied, x still valid

// Non-Copy types need explicit .clone()
let v1 = vec![1, 2, 3];
let v2 = v1.clone();
```

---

## Traits — Primary Focus

### Defining and Implementing Traits
```rust
pub trait Animal {
    fn name(&self) -> &str;
    fn sound(&self) -> String;
    
    // Default implementation
    fn describe(&self) -> String {
        format!("{} says {}", self.name(), self.sound())
    }
}

struct Dog {
    name: String,
}

impl Animal for Dog {
    fn name(&self) -> &str {
        &self.name
    }
    fn sound(&self) -> String {
        "woof".to_string()
    }
}
```

### impl Trait vs dyn Trait vs Generic Bounds

```rust
// Generic bound — monomorphized at compile time (preferred for performance)
fn make_sound<T: Animal>(animal: &T) {
    println!("{}", animal.sound());
}

// impl Trait — syntactic sugar for generics in fn args/return
fn make_sound(animal: &impl Animal) {
    println!("{}", animal.sound());
}

// dyn Trait — dynamic dispatch, heap allocation, runtime polymorphism
fn make_sounds(animals: &[Box<dyn Animal>]) {
    for a in animals {
        println!("{}", a.sound());
    }
}
```

### Object Safety Rules
A trait is object-safe (usable as `dyn Trait`) when:
- No methods return `Self`
- No generic type parameters on methods

```rust
// NOT object-safe
trait Clone {
    fn clone(&self) -> Self; // returns Self
}

// Object-safe
trait Drawable {
    fn draw(&self);
    fn bounding_box(&self) -> (f64, f64, f64, f64);
}
```

### Blanket Implementations
```rust
// Implement a trait for all types that implement another trait
impl<T: Display> ToString for T {
    fn to_string(&self) -> String {
        format!("{}", self)
    }
}

// Custom blanket impl
trait Printable: Display {
    fn print(&self) {
        println!("{}", self);
    }
}
impl<T: Display> Printable for T {}
```

### Standard Traits to Implement

```rust
use std::fmt;

// Display — human-readable output
impl fmt::Display for Point {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

// From/Into — type conversions
impl From<(f64, f64)> for Point {
    fn from((x, y): (f64, f64)) -> Self {
        Point { x, y }
    }
}
// Into is automatically derived from From
let p: Point = (1.0, 2.0).into();

// Default — sensible zero value
#[derive(Default)]
struct Config {
    timeout: u64,  // defaults to 0
    retries: u32,  // defaults to 0
}

// Iterator — custom iteration
impl Iterator for Counter {
    type Item = u32;
    fn next(&mut self) -> Option<Self::Item> {
        if self.count < 5 {
            self.count += 1;
            Some(self.count)
        } else {
            None
        }
    }
}
```

### derive Macros — Use Liberally
```rust
#[derive(Debug, Clone, PartialEq, Eq, Hash)]
struct UserId(u64);

#[derive(Debug, Clone, serde::Serialize, serde::Deserialize)]
struct User {
    id: UserId,
    name: String,
    email: String,
}
```

### Builder Pattern with Traits
```rust
pub trait Builder {
    type Output;
    fn build(self) -> Result<Self::Output, BuildError>;
}

#[derive(Default)]
pub struct UserBuilder {
    name: Option<String>,
    email: Option<String>,
}

impl UserBuilder {
    pub fn name(mut self, name: impl Into<String>) -> Self {
        self.name = Some(name.into());
        self
    }
    pub fn email(mut self, email: impl Into<String>) -> Self {
        self.email = Some(email.into());
        self
    }
}

impl Builder for UserBuilder {
    type Output = User;
    fn build(self) -> Result<User, BuildError> {
        Ok(User {
            name: self.name.ok_or(BuildError::MissingName)?,
            email: self.email.ok_or(BuildError::MissingEmail)?,
        })
    }
}
```

### Newtype Pattern with Trait Delegation
```rust
use std::ops::Deref;

struct Meters(f64);

impl Deref for Meters {
    type Target = f64;
    fn deref(&self) -> &f64 {
        &self.0
    }
}

impl fmt::Display for Meters {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "{}m", self.0)
    }
}
```

### Trait Objects for Polymorphism
```rust
// Store heterogeneous types implementing same trait
pub struct EventBus {
    handlers: Vec<Box<dyn EventHandler>>,
}

impl EventBus {
    pub fn register(&mut self, handler: Box<dyn EventHandler>) {
        self.handlers.push(handler);
    }
    
    pub fn dispatch(&self, event: &Event) {
        for handler in &self.handlers {
            handler.handle(event);
        }
    }
}
```

---

## Error Handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("not found: {0}")]
    NotFound(String),
    #[error("database error: {0}")]
    Database(#[from] sqlx::Error),
    #[error("validation failed: {field} — {message}")]
    Validation { field: String, message: String },
}

// Use ? operator for propagation
pub async fn get_user(id: u64) -> Result<User, AppError> {
    let user = db.find_user(id).await?; // sqlx::Error auto-converts via From
    user.ok_or_else(|| AppError::NotFound(format!("user {id}")))
}
```

### Option Combinators
```rust
let name: Option<String> = get_name();

// Prefer combinators over match for simple cases
let upper = name.map(|n| n.to_uppercase());
let len = name.as_ref().map(|n| n.len()).unwrap_or(0);
let result = name.ok_or(AppError::NotFound("name".into()))?;
let fallback = name.unwrap_or_else(|| "anonymous".to_string());
```

---

## Pattern Matching

```rust
match user.role {
    Role::Admin => grant_all_access(),
    Role::Editor => grant_edit_access(),
    Role::Viewer | Role::Guest => grant_read_access(),
}

// if let for single variant
if let Some(user) = find_user(id) {
    process(user);
}

// while let for iterative unwrapping
while let Some(task) = queue.pop() {
    execute(task);
}

// Destructuring structs
let User { name, email, .. } = user;
```

---

## Lifetimes

```rust
// Explicit lifetime when returning reference tied to input
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct holding references
struct Parser<'a> {
    input: &'a str,
    pos: usize,
}
```

---

## Best Practices
- Prefer `impl Trait` over `Box<dyn Trait>` when return type is single concrete type
- Use `Arc<dyn Trait>` for shared ownership of trait objects
- Implement `Display` instead of custom `to_string()` methods
- Use `From`/`Into` instead of manual conversion methods
- Derive `Debug` on all public types
- Avoid `unwrap()` in library code; use `expect()` only in tests or with descriptive messages
