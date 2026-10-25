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
not a dynamic executable            # no libc, no external runtime (own print helpers only)
$ size: 8,984 bytes                 # ELF file size, headers/alignment included

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


---

# Execution evidence - iteration 3 (Windows x86-64 via Wine, 2026-10-25)

Same sandbox. Added `--target=windows`: hbc emits Win64 assembly for the
same subset (same analysis, same internal value convention); only the
process entry and the two print helpers change (kernel32: GetStdHandle /
WriteFile / ExitProcess instead of syscalls). Toolchain for Windows:
`x86_64-w64-mingw32-as` / `-ld` 2.38 (Ubuntu package
binutils-mingw-w64-x86-64, unpacked without installation) + `libkernel32.a`
(Ubuntu package mingw-w64-x86-64-dev). Run host: Wine 10.20
(wine-10.20-amd64-wow64, Kron4ek build), WINEDEBUG=-all. Wine 11.20 crashes
in this container during early init, so 10.20 was used - a limitation of
this sandbox, not necessarily of Wine 11.

## Compiler rebuild (rustc, native binary)
$ rustc -O src/hbc.rs -o hbc        # builds clean, 0 warnings

## Linux regression first (must stay identical)
hola.hb -> same output (resultado de z: / 32 / hola desde una funcion),
ELF still 8,984 bytes; prestamo_roto.hb still rejected at line 5.

## Windows build of the same program
$ ./hbc ejemplos/hola.hb gen/hola_win.s --target=windows
ejemplos/hola.hb -> gen/hola_win.s (2 functions)
$ x86_64-w64-mingw32-as -o gen/hola_win.o gen/hola_win.s
$ x86_64-w64-mingw32-ld -o gen/hola.exe gen/hola_win.o -e _start --subsystem console -lkernel32
$ file gen/hola.exe
PE32+ executable (console) x86-64, for MS Windows        # 5,499 bytes
$ wine gen/hola.exe
resultado de z:
32
hola desde una funcion
$ echo $?
0

## Battery on both targets (outputs must be byte-identical)
positive (compiled and RUN on linux ELF and on windows PE under Wine):
  ejemplos/hola.hb            PASS  (32 + greeting, identical)
  tests/t10_int_copy.hb       PASS  (5 / 5 / -5, identical)
  tests/t11_print_borrows.hb  PASS  (hola / hola / 7, identical)
  tests/t07_unicode_string.hb PASS  (olá, año 🦀, identical)
  arithmetic (14/20/14/i64::MAX) PASS (identical)
negative (hbc itself rejects before codegen, target-independent):
  ejemplos/prestamo_roto.hb   PASS  error: line 5: use of moved value `a`  (both targets)
  tests/t01..t09 battery      PASS  same errors as iteration 2, both targets

## What this does NOT show
- Real Windows: everything Windows-side ran under Wine 10.20 on Linux.
- PE/COFF emission by hbc itself: hbc stops at assembly; mingw-w64
  binutils (C tools) assemble and link.
- Any new language surface: iteration 3 changes targets, not the subset.
  The ownership claims are exactly the iteration 2 claims, no wider.
