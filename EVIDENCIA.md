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

---

# Iteration 3 fixes after external review (2026-10-25)

Two real Win64 bugs were caught on review of the emitted assembly and are
fixed and re-verified:

1. hbc_print_i64 (Windows) used %rsi as the digit cursor. %rsi is
   NONVOLATILE in the Win64 ABI and was not saved. Fixed: the cursor is now
   %r10 (volatile); the helpers touch only volatile registers plus the
   saved rbp.
2. Expressions kept the left operand with `push %rax` while evaluating the
   right operand. A call nested in the right operand (`1 + valor()`) then
   broke 16-byte stack alignment for every Win64 call under it, even with a
   16-byte-rounded frame. Fixed: on Windows the lhs goes into a 16-byte
   stack slot (`sub $16, %rsp` / `mov %rax, (%rsp)`), so every call site
   keeps ABI alignment. Linux codegen is unchanged (syscalls have no such
   requirement; the ELF is still 8,984 bytes).

Also: `_start` now aligns the stack explicitly (`and $-16, %rsp`) instead of
assuming the loader's convention, and the kernel32 return values are
documented as unchecked (no I/O error handling in this PoC).

Regression test added: tests/t12_call_in_expr.hb (a printing function
called inside arithmetic, both operand positions). Run on both targets:

$ ./hbc tests/t12_call_in_expr.hb gen/t12.s --target=windows && x86_64-w64-mingw32-as -o gen/t12.o gen/t12.s && x86_64-w64-mingw32-ld -o gen/t12.exe gen/t12.o -e _start --subsystem console -lkernel32 && wine gen/t12.exe
en valor
41
en valor
41
en valor
80

Linux ELF output byte-identical. Generated assembly checked: every nested
call site now sits between `sub $16, %rsp` and `add $16, %rsp`. Full
positive battery (hola, t10, t11, unicode, arithmetic) and the negative
battery re-run after the fixes: identical outputs on both targets.
hola.exe is still 5,499 bytes. Wine 10.20 wow64, exit code 0.

---

# Iteration 4: if / else / endif (2026-10-25)

New surface: if/else/endif with integer comparisons (`= <> != < <= > >=`),
nesting, calls inside conditions, branch-scoped locals, and move checking
across branch joins. Parser, ownership analysis and codegen all changed;
the iteration 2/3 battery is re-run plus seven new tests.

New tests (each compiled and run, or rejected, on BOTH targets - Linux ELF
and Windows PE under Wine 10.20):

positive (byte-identical output on both targets):
  tests/t13_if_else.hb       PASS  big / exactly seven / eq / ne / ne2 ok / lt / 42
  tests/t15_if_move_both.hb  PASS  hola / fin   (moved in both branches => moved at join)
  tests/t18_if_call_cond.hb  PASS  v / si       (call inside the condition)
negative (hbc itself rejects before codegen, exit 1, both targets):
  tests/t14_if_move_after.hb PASS  error: line 8: use of moved value
  tests/t16_if_return.hb     PASS  return inside an `if` block rejected
  tests/t17_if_str_cmp.hb    PASS  comparisons require integers (strings rejected)
  tests/t19_if_scope.hb      PASS  undefined variable `z` (branch local after endif)

Full regression after the change (iteration 2 + 3 battery):
  positive: hola, t10, t11, t07 (unicode), t12 (call in expr), arithmetic
  negative: prestamo_roto, t01-t09
  ALL PASS, byte-identical on both targets. The hola Linux ELF is still
  8,984 bytes. In t13's Win64 assembly every call site sits between
  `sub $16, %rsp` and `add $16, %rsp` (9 checked).

## What this does NOT show
- Loops: there is still no iteration statement; `if` is the only control
  flow beyond calls.
- String comparisons and a first-class boolean: conditions compare i64
  only; the condition value cannot be stored, printed or returned.
- `return` remains top-level; early returns are rejected.
- Same caveat as iteration 3: the Windows side ran under Wine 10.20, not
  real Windows.

---

# Iteration 5: while / enddo and assignment (2026-10-25)

New surface: `while <cond> ... enddo` loops and `x := <expr>` assignment.
Assignment requires an existing local, keeps its declared type, and makes a
moved variable live again. Loop move rule: a variable moved in the body
must be reassigned before `enddo` (the next iteration would otherwise use
a moved value); post-loop state joins pre-loop and end-of-body.

New tests (each compiled and run, or rejected, on BOTH targets - Linux ELF
and Windows PE under Wine 10.20):

positive (byte-identical output on both targets):
  tests/t20_assign.hb              PASS  1 / 5 / hola / adios / de nuevo
  tests/t23_while_count.hb         PASS  1 / 2 / dos / 3 / fin / cero viajes
  tests/t25_while_move_reassign.hb PASS  x / y / y
negative (rejected by hbc itself before codegen, exit 1, both targets):
  tests/t21_assign_undeclared.hb   PASS  assignment to undeclared variable
  tests/t22_assign_type.hb         PASS  type mismatch in assignment
  tests/t24_while_move.hb          PASS  moved in body, not reassigned before enddo
  tests/t26_while_scope.hb         PASS  undefined variable `z` (body local after enddo)
  tests/t27_while_return.hb        PASS  return inside a `while` block rejected

Full regression (iteration 2-4 battery, positive and negative): ALL PASS,
byte-identical on both targets; the hola Linux ELF is still 8,984 bytes.
t05 keeps its original error wording (the identifier-led-line rejection
absorbs it).

## What this does NOT show
- `for` loops, early returns.

# Iteration 6: exit / loop (2026-10-25)

Harbour's `exit` / `loop` (Rust's `break` / `continue`) inside `while`.
The move checker became control-flow aware: blocks report whether they
can fall through, `exit` records the move state at its site, and the
post-loop state joins pre-loop + fall-through + every exit site.

positive (byte-identical output on Linux x86-64 and under Wine):
- tests/t28_exit_loop.hb - exit at i = 3 prints "1 2 salido"; two `loop`
  skips print "1 3 5 fin"
- tests/t31_exit_move_ok.hb - move on an exit-only path is accepted
  (prints "hola fuera")

negative (rejected by hbc itself before codegen, exit 1, both targets):
- tests/t29_exit_outside.hb - "exit outside a `while` loop"
- tests/t30_loop_move.hb - moved before `loop`, no reassignment
- tests/t32_exit_move_use.hb - the exit path counts as moved after the loop

Full 32-case battery re-run after the change: 32/32 pass, `hola` Linux
ELF still 8,984 bytes. Not yet: `for` loops, early returns.

# Iteration 7: early return (2026-10-25)

`return <expr>` inside `if` / `while` blocks. Codegen already jumped to
the shared per-function epilogue, so the change is parser + checker: the
parser takes nested returns as statements, and the checker enforces that
all returns of a function agree on the type.

semantic change (documented, deliberate): tests/t16_if_return.hb and
tests/t27_while_return.hb pinned the old rejection ("return inside a
block is not in the PoC yet"); they now pin the new positive behavior.

positive (byte-identical output on Linux x86-64 and under Wine):
- tests/t16_if_return.hb - early return inside if prints "100"
- tests/t27_while_return.hb - early return inside while prints "21"

negative (rejected by hbc itself before codegen, exit 1, both targets):
- tests/t33_return_bare_block.hb - bare `return` inside a block
- tests/t34_return_type_mix.hb - "return type mismatch"
- tests/t35_return_nil_closing.hb - early value return, closing nil
- tests/t36_return_move_join.hb - moved into an early return, used after

Full 36-case battery re-run after the change: 36/36 pass, `hola` Linux
ELF still 8,984 bytes. Not yet: `for` loops.

# Iteration 8: for / next (2026-10-25)

Counted loops `for i := <start> to <end> [step <n>] ... next`. Bounds
evaluate once into hidden slots; the step is restricted to a non-zero
integer literal so the counting direction is fixed at compile time (one
comparison in the emitted code, no runtime sign check). `exit` / `loop`
inside `for` reuse the iteration-6 label threading, and the move checker
treats the body exactly like a `while` body (join at `next` and at every
`exit`). The joins are conservative by design: they may reject programs
that would run fine.

minor wording change (documented): the "`exit`/`loop` outside a `while`
loop" errors now read "outside a `while` loop or `for` loop", absorbing
the old pinned substrings so t29/t30 keep passing unchanged.

8 new tests (none converted):
positive (byte-identical output on Linux x86-64 and under Wine):
- tests/t37_for_basic.hb - up, step 2, step -1 countdown, zero-trip
- tests/t42_for_exit_loop.hb - loop skips i = 2, exit at i = 5

negative (rejected by hbc itself before codegen, exit 1, both targets):
- tests/t38_for_scope.hb - loop variable used after `next`
- tests/t39_for_shadow.hb - loop variable reuses a name in scope
- tests/t40_for_assign_var.hb - assignment to the loop variable
- tests/t41_for_move.hb - moved in body, not reassigned before `next`
- tests/t43_for_step_zero.hb - step 0
- tests/t44_for_step_expr.hb - non-literal step

Full 44-case battery re-run after the change: 44/44 pass, `hola` Linux
ELF still 8,984 bytes. Not yet: string comparisons / first-class
boolean, function parameters, expression step, shadowing.



- Full Rust assignment semantics: assignment re-lives a moved variable and
  cannot change its type; there is still no Drop (strings are read-only
  literals).
- Same caveat as before: the Windows side ran under Wine 10.20, not real
  Windows.
