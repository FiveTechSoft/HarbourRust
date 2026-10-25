# Execution evidence - iteration 2 (Linux x86_64 sandbox, 2026-10-25)

Toolchain: rustc 1.99.1 (builds `hbc` only), GNU as 2.38, GNU ld 2.38.
No Harbour program passes through rustc or LLVM in this iteration.

## Compiler build (Rust, native binary)
$ rustc -O src/hbc.rs -o hbc        # builds clean, 0 warnings, ELF x86-64

## Positive case: ejemplos/hola.hb -> assembly -> native ELF
$ ./hbc ejemplos/hola.hb gen/hola.s
ejemplos/hola.hb -> gen/hola.s (2 functions)
$ as -o gen/hola.o gen/hola.s && ld -o gen/hola gen/hola.o
$ ./gen/hola
resultado de z:
32
hola desde una funcion

$ file gen/hola
ELF 64-bit LSB executable, x86-64, statically linked
$ ldd gen/hola
not a dynamic executable            # no libc, no runtime
$ size: 8,984 bytes                 # machine code + string data

Generated assembly is readable; `hbc_fn_saludo` stores the (ptr, len) of its
string in two stack slots and returns them in %rax/%rdx. The print helpers
are hand-written syscall routines (write + exit), no library calls.

## Negative case: use after move, rejected BY HBC (not rustc)
$ ./hbc ejemplos/prestamo_roto.hb gen/prestamo.s
error: line 5: use of moved value `a` (strings move on assignment; they do not copy)
exit code 1 - rejected before any code is generated.

Iteration 1 got this same rejection from rustc's borrow checker (E0382);
now it comes from hbc's own ownership analysis. Still use-after-move only;
borrowing/references/lifetimes are not covered (see README).

## Copy vs move (tests/t10_int_copy.hb) - runs
    local a := 5
    local b := a      # i64 is Copy: `a` stays usable
    ? a               # 5
    ? b               # 5
    ? a - 10          # -5   (signed printing works, incl. i64::MIN edge by construction)

## Printing borrows (tests/t11_print_borrows.hb) - runs
    local a := "hola"
    ? a               # borrows; does not move
    local b := a      # now `a` moves into `b`
    ? b               # hola

## Arithmetic sanity - runs
    ? 2 + 3 * 4                  -> 14   (precedence)
    ? (2 + 3) * 4                -> 20   (parentheses)
    ? 84 / 2 / 3                 -> 14   (left associativity)
    ? 9223372036854775807        -> 9223372036854775807  (i64 max)

## Rejection battery (hbc rejects before codegen; inputs never executed)
tests/t01_injection_colons.hb   error: line 2: ':' without '=' (col 10)
tests/t02_injection_unsafe.hb   error: line 2: character not allowed `{` (U+007B)
tests/t03_injection_macro.hb    error: line 2: character not allowed `;` (U+003B)
tests/t04_unicode_ident.hb      error: line 2: character not allowed `ñ` (U+00F1)   (no panic)
tests/t05_keyword_boundary.hb   error: line 2: statement not in the subset (Ident("localfoo"))
tests/t06_undefined_var.hb      error: line 2: undefined variable `y`
tests/t08_type_error.hb         error: line 3: arithmetic requires integers
tests/t09_duplicate_local.hb    error: line 3: duplicate local `x`
integer literal 9223372036854775808
                                error: line 2: integer literal out of range (i64)
                                (iteration 1 delegated this to rustc; now hbc checks it)

## Unicode string accepted and runs
tests/t07_unicode_string.hb  `? "olá, año 🦀"`  ->  prints: olá, año 🦀
(strings are emitted as raw UTF-8 .byte sequences; no assembler escaping)

## Known limits observed
- Division by zero and i64::MIN / -1 trap at runtime (SIGFPE); no runtime
  checks are emitted.
- hbc's own codegen bug found during this iteration (string local length
  read from the wrong stack slot) was caught by running the compiled
  examples and fixed before publishing; the compiled outputs above are the
  fixed version.

## Timing (toy program; NOT evidence about real workloads)
compile hola.hb: ~2 ms (hbc) + ~6 ms (as+ld); run: ~1 ms.
