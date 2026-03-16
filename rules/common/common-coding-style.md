---
description: "ECC coding style: immutability, file organization, error handling, validation"
alwaysApply: true
---

# Coding Style

## Immutability
- Create new objects, never mutate existing ones
- Use `let` bindings; shadowing is preferred over reassignment

## File Organization
- Many small files > few large files (200-400 lines typical)
- Maximum: 800 lines per file
- One clear responsibility per file

## Error Handling
- Always handle errors explicitly
- Never silently ignore failures
- Use `Result`/`Option` instead of panics

## Input Validation
- Always validate at system boundaries
- Use `validator` crate for request validation
- Fail fast on invalid input

## Code Quality Checklist
- Functions < 50 lines
- No deep nesting > 4 levels
- Descriptive variable names
