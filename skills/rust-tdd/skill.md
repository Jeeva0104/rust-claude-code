---
name: rust-tdd
description: Test-driven development workflow for Rust using cargo test — write failing tests first, implement minimal code, refactor with Rust idioms.
origin: rust-claude-code
---

# Rust TDD Workflow

## When to Activate
- Starting any new Rust feature
- Fixing bugs (write a test that reproduces the bug first)
- Refactoring existing Rust code

---

## The Cycle: Red → Green → Refactor

### Step 1 — Red: Write a Failing Test First

```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parse_valid_email_succeeds() {
        let result = Email::parse("alice@example.com");
        assert!(result.is_ok());
    }

    #[test]
    fn parse_email_without_at_fails() {
        let result = Email::parse("notanemail");
        assert!(matches!(result, Err(EmailError::InvalidFormat)));
    }
}
```

Run: `cargo test` → should FAIL (type doesn't exist yet)

### Step 2 — Green: Minimal Implementation

```rust
#[derive(Debug, thiserror::Error)]
pub enum EmailError {
    #[error("invalid email format")]
    InvalidFormat,
}

pub struct Email(String);

impl Email {
    pub fn parse(s: &str) -> Result<Self, EmailError> {
        if s.contains('@') {
            Ok(Email(s.to_string()))
        } else {
            Err(EmailError::InvalidFormat)
        }
    }
}
```

Run: `cargo test` → should PASS

### Step 3 — Refactor: Apply Rust Idioms

```rust
impl Email {
    pub fn parse(s: &str) -> Result<Self, EmailError> {
        let s = s.trim();
        let parts: Vec<&str> = s.splitn(2, '@').collect();
        
        match parts.as_slice() {
            [local, domain] if !local.is_empty() && domain.contains('.') => {
                Ok(Email(s.to_string()))
            }
            _ => Err(EmailError::InvalidFormat),
        }
    }
    
    pub fn as_str(&self) -> &str {
        &self.0
    }
}
```

Run: `cargo test` → still PASS

---

## Watch Mode

```bash
# Install cargo-watch
cargo install cargo-watch

# Auto-run tests on file change
cargo watch -x test

# Run specific test on change
cargo watch -x "test email"
```

---

## Test Naming Convention

```rust
// Pattern: {subject}_{condition}_{expected_result}
#[test] fn parse_valid_email_returns_ok() {}
#[test] fn parse_empty_string_returns_invalid_format_error() {}
#[test] fn user_service_create_duplicate_email_returns_validation_error() {}
#[test] fn transfer_insufficient_funds_returns_balance_error() {}
```

---

## Bug Fix TDD Flow

1. Write a test that **reproduces the bug**:
```rust
#[test]
fn parse_email_with_leading_spaces_succeeds() {
    // Bug: "  alice@example.com" was failing
    assert!(Email::parse("  alice@example.com").is_ok());
}
```
2. Run test → RED (confirms bug)
3. Fix the bug
4. Run test → GREEN
5. Add edge case tests

---

## Async TDD

```rust
#[tokio::test]
async fn user_service_get_nonexistent_returns_not_found() {
    let mut mock_repo = MockUserRepository::new();
    mock_repo
        .expect_find_by_id()
        .returning(|_| Ok(None));
    
    let svc = UserServiceImpl::new(Arc::new(mock_repo));
    let result = svc.get(999).await;
    
    assert!(matches!(result, Err(AppError::NotFound(_))));
}
```

---

## Best Practices
- Never write implementation before the test
- Keep each test focused on one behavior
- Mock external dependencies (DB, APIs) at trait boundaries
- Use descriptive test names that read like sentences
- Run `cargo test` before every commit
