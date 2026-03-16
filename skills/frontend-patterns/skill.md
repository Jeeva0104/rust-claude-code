---
name: frontend-patterns
description: Frontend patterns for Rust web apps including Leptos, Yew, and WASM integration with React/Next.js backends.
origin: rust-claude-code
---

# Frontend Patterns for Rust

## When to Activate
- Building Rust frontend with Leptos/Yew
- Integrating Rust WASM with JS
- Setting up full-stack Rust

---

## Leptos (Rust Framework)

```rust
use leptos::*;

#[component]
fn App() -> impl IntoView {
    let (count, set_count) = create_signal(0);
    
    view! {
        <button on:click=move |_| set_count.update(|n| *n += 1)>
            "Count: " {count}
        </button>
    }
}
```

---

## Yew (Rust Framework)

```rust
use yew::prelude::*;

#[function_component(App)]
fn app() -> Html {
    html! {
        <h1>{ "Hello from Yew!" }</h1>
    }
}
```

---

## WASM Integration

```rust
// Expose Rust function to JS
#[wasm_bindgen]
pub fn process_data(input: &str) -> String {
    // Rust processing
    input.to_uppercase()
}
```

---

## Full-Stack Rust Architecture

```
backend/     # Axum/Actix API
frontend/    # Leptos/Yew app
shared/      # Common types (serde)
```
