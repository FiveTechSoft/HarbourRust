# HarbourRust - proof of concept

**What this is:** a small proof of the idea - Harbour syntax, Rust rules,
native executables. It is not a full compiler and does not claim to be one.

## Technical transparency (what is ours, what is reused)

| Piece | What it is | Status |
|---|---|---|
| `src/hbc.rs` | Harbour-syntax front-end, written in Rust, compiled to a native binary | Ours, ~450 lines |
| Type checking and ownership/move checking | Done by `rustc` | Reused (backend) |
| Machine code generation | `rustc` via LLVM (LLVM is C++) | Reused (backend) |

Honest label: **a syntax front-end on top of the rustc backend**, not an
independent compiler. The "all Rust" goal is not yet met in the backend:
LLVM is C++. Pure routes (Cranelift, own backend) remain open.

## Closed subset (deliberate, fail-closed)

```
function name()            opens a function (main is the entry point)
    local x := <expr>      local variable, type inferred
    ? <expr>               prints
return <expr> | return nil closes the function
// comment
```

Expressions: integer literals, string literals (escapes `\"` and `\\` only),
identifiers, `+ - * /`, parentheses, 0-argument calls `name()`.
Anything outside this grammar is rejected by the front-end, before rustc.

Type contract: integers are `i64` (emitted with the `i64` suffix), strings are
owned `String` (they move; they do not copy).

## Fail-closed design (what the review fixed)

The front-end is a tokenizer + recursive-descent parser over a closed token
set. Only a validated AST is ever emitted: identifiers are checked (charset,
length, reserved Rust keywords), keywords match whole tokens (so `localfoo`
or `functionevil` are rejected), string literals are re-escaped on emission,
and no raw user text ever reaches the generated Rust. Injection attempts
(raw Rust, `unsafe`, macros, `std::` paths) are rejected by `hbc` itself;
rustc is a second line of defense, not the first. Undefined variables, unknown functions, duplicate `local` declarations
and string arithmetic are also rejected by the front-end.

## What the tests demonstrate

1. A Harbour-syntax program compiles to a native x86-64 ELF and runs
   (`ejemplos/hola.hb` prints `32` and a greeting, zero warnings).
2. A program that uses a variable after moving it is rejected at compile
   time by the borrow checker: `error[E0382]: borrow of moved value`
   (`ejemplos/prestamo_roto.hb`). This demonstrates the **ownership/move**
   rule applied to Harbour syntax. It is a use-after-move case only - it does
   NOT cover borrowing, references or lifetimes, which remain untested.
3. Eight rejection tests (`tests/`) show the front-end itself rejecting
   injections and out-of-grammar input before rustc, with real line numbers.
4. Unicode works inside string literals and is rejected in identifiers
   without panicking.

## What is NOT demonstrated

Performance comparable to C/Rust on real programs (no representative
benchmarks; timings here are from a toy program), coverage of the full Rust
model (borrowing/lifetimes/traits/generics), a standalone backend, and the
safety of any grammar extension beyond this subset - each extension must
re-establish the closed-emission property.

## Reproduce

```sh
rustc -O src/hbc.rs -o hbc
./hbc ejemplos/hola.hb gen/hola.rs && rustc -O gen/hola.rs -o gen/hola && ./gen/hola
./hbc ejemplos/prestamo_roto.hb gen/prestamo_roto.rs && rustc gen/prestamo_roto.rs
```
