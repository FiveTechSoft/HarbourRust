# Execution evidence (Linux x86_64 sandbox, 2026-10-25)

Toolchain installed locally for the PoC: rustc 1.99.1 (58cf8f9c3 2026-10-13).

## Front-end build (Rust, native binary)
$ rustc -O src/hbc.rs -o hbc        # builds clean, ELF x86-64

## Positive case: ejemplos/hola.hb -> gen/hola.rs -> native ELF
$ ./hbc ejemplos/hola.hb gen/hola.rs
ejemplos/hola.hb -> gen/hola.rs (2 functions)

Generated Rust:
    fn saludo() -> String {
        let s = String::from("hola desde una funcion");
        return s;
    }
    fn main() {
        let x = 10i64;
        let y = 3i64;
        let z = (x * y) + 2i64;
        println!("{}", String::from("resultado de z:"));
        println!("{}", z);
        println!("{}", saludo());
    }

$ rustc -O gen/hola.rs -o gen/hola   # 0 warnings
$ ./gen/hola
resultado de z:
32
hola desde una funcion

## Negative case: use after move (ejemplos/prestamo_roto.hb)
Generated Rust:
    fn main() {
        let a = String::from("hola");
        let b = a;
        println!("{}", a);
    }

$ rustc gen/prestamo_roto.rs
error[E0382]: borrow of moved value: `a`
error: aborting due to 1 previous error
-> rejected at compile time. Demonstrates ownership/move only,
   NOT borrowing/references/lifetimes.

## Front-end rejection tests (hbc rejects BEFORE rustc; inputs never executed)
tests/t01_injection_colons.hb   `? std::fs::read("/etc/passwd")`
    error: line 2: ':' without '=' (col 10)
tests/t02_injection_unsafe.hb   `local x := unsafe { 1 }`
    error: line 2: character not allowed `{` (U+007B)
tests/t03_injection_macro.hb    `? 1); println!("{}", 2`
    error: line 2: character not allowed `;` (U+003B)
tests/t04_unicode_ident.hb      `local ñ := 1`
    error: line 2: character not allowed `ñ` (U+00F1)   (no panic)
tests/t05_keyword_boundary.hb   `localfoo x := 1`
    error: line 2: statement not in the subset (Ident("localfoo"))
tests/t06_undefined_var.hb      `? y`
    error: line 2: undefined variable `y`
tests/t08_type_error.hb         `local b := a + 1` with `a` a string
    error: line 3: arithmetic requires integers
tests/t09_duplicate_local.hb    `local x := ...` declared twice
    error: line 3: duplicate local `x``

## Unicode string accepted and runs
tests/t07_unicode_string.hb  `? "olá, año 🦀"`  ->  prints: olá, año 🦀

## Reading
- Ownership/move enforcement reaches Harbour-syntax programs through the
  rustc backend. Borrowing/lifetimes are not exercised by this PoC.
- Compilation (~0.1s) and run (~1ms) timings belong to a toy program and are
  not evidence of comparable performance on real workloads.
