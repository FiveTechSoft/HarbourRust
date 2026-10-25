# HarbourRust - proof of concept

**What this is:** a small proof of the idea - Harbour syntax, Rust rules,
native executables. It is not a full compiler and does not claim to be one.

## Iteration 2: the Harbour pipeline no longer touches rustc

Iteration 1 was a syntax front-end on top of the rustc backend: `hbc`
emitted Rust source and rustc (via LLVM) did the type checking, the
ownership checking and the machine code generation.

In this iteration `hbc` does all of that itself for the supported subset,
up to generated assembly (assembling and linking stay with binutils):

| Piece | Who does it | Status |
|---|---|---|
| Tokenizer, parser, AST | `hbc` | Ours |
| Type checking | `hbc` | Ours |
| Ownership / move checking | `hbc` | Ours |
| x86-64 code generation | `hbc` (emits assembly) | Ours |
| Assembler + linker (Linux ELF) | GNU binutils (`as`, `ld`) | Reused (C tools) |
| Assembler + linker (Windows PE) | mingw-w64 binutils + `kernel32` import lib | Reused (C tools) |
| Building `hbc` itself | `rustc` / LLVM | Reused (compiler implementation only) |
| Runtime of produced executables | minimal and ours: two hand-written syscall print helpers. No VM, no libc, no external runtime | Ours |

A Harbour program compiled with `hbc` never passes through rustc or LLVM:
`hbc` stops at generated assembly and the system assembler and linker
(binutils) produce the executable. The produced ELF is statically linked,
has no dynamic section and needs no external runtime - only the two small
print helpers that `hbc` emits into every binary. The `hola` example ELF
file is 8,984 bytes on disk (file size, headers and alignment included).

## Iteration 3: Windows x86-64 output

`hbc --target=windows` emits Win64 assembly for the same subset: the same
tokenizer, parser, type checking and ownership/move checking, the same
internal value convention, and the same two print helpers - but I/O and
process exit call kernel32 (`GetStdHandle` / `WriteFile` / `ExitProcess`)
instead of Linux syscalls. Assembling and linking for Windows use the
mingw-w64 build of GNU binutils (`x86_64-w64-mingw32-as` / `-ld`) with the
`kernel32` import library - the same class of reused C tools as on Linux.
No MSVC, no C runtime: the PE has no CRT startup; `_start` calls
`hbc_fn_main` and then `ExitProcess`.

The produced PE32+ executable runs: `ejemplos/hola.exe` prints `32` and the
greeting under **Wine 10.20 (wow64 build)**, and the full test battery
produces byte-identical output on the Linux and Windows builds of every
program (see EVIDENCIA.md). Running under Wine is not the same as running
on real Windows - that check is still pending.

## Iteration 4: if / else / endif

The subset grows conditional execution: `if <condition> ... [else ...]
endif`, with integer comparisons (`=  <>  !=  <  <=  >  >=`) and arbitrary
nesting. Conditions are expressions, so a call can appear inside them
(`if valor() >= 40`, `tests/t18_if_call_cond.hb`).

Branching keeps the same ownership rules, resolved at compile time:

- Locals declared inside a branch are scoped to that branch; sibling
  branches may reuse a name, and using a branch local after `endif` is a
  compile error (`tests/t19_if_scope.hb`).
- A string moved in one branch counts as moved at the join (like Rust):
  using it after `endif` is rejected (`tests/t14_if_move_after.hb`).
- A string moved in both branches is moved at the join as well
  (`tests/t15_if_move_both.hb`).
- `return` stays at the function top level: a `return` inside an `if`
  block is rejected (`tests/t16_if_return.hb`).
- Comparisons are integer-only in this iteration: comparing strings is
  rejected (`tests/t17_if_str_cmp.hb`). The condition's boolean value
  cannot be stored, printed or returned.

Every new test runs on both targets with byte-identical output, and the
iteration 2/3 battery still passes unchanged (the `hola` Linux ELF is
still 8,984 bytes).

## Iteration 5: while / enddo and assignment

`while <condition> ... enddo` adds loops, and `x := <expr>` adds assignment
to an already-declared local (the loop companion: conditions otherwise
never change). Assignment keeps the declared type, makes a moved variable
live again (as in Rust), and assigning to an undeclared name is a compile
error - new variables still require `local`.

Loop semantics:

- The condition is an integer comparison, as in `if`, re-evaluated on
  every iteration; calls are allowed inside it.
- Body locals are scoped to the body (`tests/t26_while_scope.hb`).
- A variable moved inside the body must be live again at `enddo` (that is,
  reassigned); otherwise the next iteration would use a moved value, so
  `hbc` rejects it (`tests/t24_while_move.hb`, rejected, versus
  `tests/t25_while_move_reassign.hb`, accepted).
- After the loop, move states join the pre-loop and end-of-body states:
  the body may have run zero times.
- `return` stayed at the function top level; iteration 7 lifted that
  (see below).

## Iteration 6: exit / loop

`exit` leaves the innermost `while`, and `loop` skips to its next
iteration (Harbour's names for `break` and `continue`). Both are
compile errors outside a `while` (`tests/t29_exit_outside.hb`), and the
move checker follows them:

- A variable moved on a path that reaches the next iteration must be
  reassigned before `enddo` **or before `loop`** (`tests/t30_loop_move.hb`,
  rejected).
- A move on a path that leaves via `exit` never reaches the next
  iteration, so it needs no reassignment - Rust accepts the equivalent
  too (`tests/t31_exit_move_ok.hb`, accepted).
- After the loop, move states join the pre-loop state, the fall-through
  end-of-body state, and the state at every `exit`: any of those paths
  may be the one that ran (`tests/t32_exit_move_use.hb`, rejected).

## Iteration 7: early return

`return <expr>` is now allowed inside `if` and `while` blocks: it closes
the function at once with that value (`tests/t16_if_return.hb`,
`tests/t27_while_return.hb`). Rules, mirroring Rust:

- The closing top-level `return` is still required - an early return is
  an extra exit, not a replacement for it.
- Every early return carries a value; bare `return` / `return nil` inside
  a block is rejected (`tests/t33_return_bare_block.hb`).
- All returns of a function must agree on the type
  (`tests/t34_return_type_mix.hb`), and a function that early-returns a
  value cannot close with `return nil` (`tests/t35_return_nil_closing.hb`).
- A string moved into an early return stays moved on that path, so using
  it after the block fails at the join (`tests/t36_return_move_join.hb`).

## Iteration 8: for / next

`for i := <start> to <end> [step <n>] ... next` counts over an integer
range (`tests/t37_for_basic.hb`: up, stepped, counted down with a
negative step, zero-trip). `exit` and `loop` work inside it
(`tests/t42_for_exit_loop.hb`). Deliberate PoC restrictions, several of
them stricter than the analogous Rust constructs:

- The step must be a **non-zero integer literal**, so the counting
  direction is fixed at compile time (`tests/t43_for_step_zero.hb`,
  `tests/t44_for_step_expr.hb`). Harbour allows any expression here.
- Bounds are evaluated once before the loop and must be integers.
- The loop variable is scoped to the loop (`tests/t38_for_scope.hb`),
  may not reuse a name already in scope - this PoC does not shadow,
  unlike Rust (`tests/t39_for_shadow.hb`) - and cannot be assigned
  inside the body (`tests/t40_for_assign_var.hb`).
- The move checker applies the same join rules as in `while`: a variable
  moved in the body must be reassigned before `next`
  (`tests/t41_for_move.hb`). These joins are conservative: they can
  reject programs that would run fine, which is intended
  (`tests/t50_for_return_move.hb` is such a case).
- Advancing the counter past the i64 range ends the loop instead of
  wrapping it (`tests/t45_for_overflow_up.hb`,
  `tests/t46_for_overflow_down.hb`). Without this rule the counter would
  wrap and the loop would not terminate.
- `for`, `to`, `step` and `next` are reserved words now; they can no
  longer be used as identifiers.

Adversarial review note (2026-10-25): the overflow rule above was added
after a review of the first `for` implementation found that
`for i := 9223372036854775806 to 9223372036854775807` did not terminate
(the counter wrapped to i64::MIN and the loop kept going). See
EVIDENCIA.md for the reproduction.

## Iteration 9: string equality in conditions

`=` and `<>` now work on two strings inside `if` / `while` conditions
(`tests/t52_str_eq.hb`, `tests/t97_str_eq_rightlen.hb`). The rule is
Harbour's default `=` (SET EXACT OFF), verified by probe b23: the
comparison runs over the length of the RIGHT operand, with the left
operand read NUL-padded - "abcd" = "abc" is true, "abc" = "abcd" is
false, anything = "" is true; `<>` is its negation. Done by a leaf
assembly routine (`hbc_str_eq`): no allocation, no memory management, no
collation or Unicode awareness of any kind. Harbour's exact `==` is not
in this grammar; SET EXACT is a runtime setting this PoC does not have.
(An earlier revision used exact byte equality - Harbour's EXACT ON rule;
corrected to the default on 2026-10-25.) This is NOT general string
handling; strings remain immutable (ptr, len) values that move on
assignment/return and are borrowed by printing and now by comparison.

- Ordering (`<`, `<=`, `>`, `>=`) works since iteration 10, with the
  same right-operand-length rule (see below). Comparing a string with an integer is a type error
  (`tests/t53_mixed_cmp.hb`).

## Iteration 10: string ordering (Harbour's default semantics)

`<`, `<=`, `>`, `>=` on two strings, via a second leaf routine
(`hbc_str_cmp`, returns -1/0/1). The rule is Harbour's default
(SET EXACT OFF), verified by probe b22 against Harbour itself: the
comparison runs over the length of the RIGHT operand, with the left
operand read NUL-padded past its end - so `"abc" < "abcd"` is true but
`"abcd" > "abc"` is false and `"abcd" <= "abc"` is true (xBase's
asymmetric prefix rule). The first differing byte decides by unsigned
byte value. No collation, no locale, no Unicode awareness: "Z" (0x5A)
sorts before "a" (0x61). (An earlier revision of this PoC used symmetric
byte-wise ordering - Harbour's EXACT ON rule; corrected to the default
on 2026-10-25. SET EXACT itself is a runtime setting this PoC does not
have.) Still not
general string handling: same immutable (ptr, len) values, comparison
borrows. `tests/t17_if_str_cmp.hb` was converted a second time (it now
pins ordering working); `tests/t56_str_order_mixed.hb` pins mixed
string/integer ordering as a type error.
- Comparing borrows both operands: they stay usable and movable after
  (`tests/t54_str_eq_borrows.hb`).
- Cost note: `hbc_str_eq` is emitted into every binary (no dead-code
  elimination in this PoC), so `hola` grew from 8,984 to 9,024 bytes.

## Ownership semantics (what "Rust rules" means here, precisely)

- Strings are `(ptr, len)` values that **move** on assignment and on
  `return`: after `local b := a`, using `a` is a compile error
  (`use of moved value`). Like Rust's `String`.
- Integers are `i64` and **Copy**: after `local b := a`, both remain usable.
  Like Rust's `i64`.
- Printing **borrows**: `? a` leaves a string usable, and it can still be
  moved afterwards.
- All of this is enforced by `hbc` at compile time, with zero runtime cost:
  a move is just a pointer+length copy whose source is invalidated by the
  checker.

## Closed subset (deliberate, fail-closed)

```
function name()            opens a function (main is the entry point)
    local x := <expr>      local variable, type inferred
    x := <expr>            assignment to an existing local (same type)
    ? <expr>               prints
    if <cond> ... endif    conditional, optional else, nestable
    while <cond> ... enddo loop, re-evaluates the condition each iteration
    for i := <a> to <b> [step <n>] ... next
                             counted loop; n is a non-zero integer literal
    exit                     leaves the innermost loop
    loop                     skips to the next iteration of the innermost loop
    return <expr>            early return: closes the function with a value
return <expr> | return nil closes the function  (a closing top-level return
                             is always required)
// comment
```

Expressions: integer literals, string literals (escapes `\"` and `\\` only),
identifiers, `+ - * /`, parentheses, 0-argument calls `name()`. Conditions: the same
expressions combined with `= <> != < <= > >=` (integers only).
Anything outside this grammar is rejected by `hbc` itself. Only a validated
AST is ever analyzed or emitted; no raw user text ever reaches the output.
Integer literals are range-checked (i64).

## What the tests demonstrate

1. A Harbour-syntax program compiles to a native x86-64 ELF and runs:
   `ejemplos/hola.hb` prints `32` and a greeting
   (`tests/t10_int_copy.hb`, `tests/t11_print_borrows.hb` also run).
2. Use after move is rejected at compile time **by hbc itself**:
   `ejemplos/prestamo_roto.hb` fails with
   `error: line 5: use of moved value 'a'`. In iteration 1 this rejection
   came from rustc's borrow checker; now it comes from our own analysis.
   It is still a use-after-move case only - borrowing, references and
   lifetimes beyond "printing borrows" are NOT covered.
3. The Copy vs move distinction works in Harbour syntax
   (`tests/t10_int_copy.hb`).
4. Eight rejection tests (`tests/t01`-`t09`) show the front-end rejecting
   injections and out-of-grammar input, with real line numbers. Unicode
   works inside string literals and is rejected in identifiers without
   panicking.
5. Conditional execution with branch-scoped locals and move checking
   across branch joins (`tests/t13`-`t19`, positive and rejection cases,
   run on the Linux and Windows builds).
6. Loops and assignment with Rust-like move rules across iterations
   (`tests/t20`-`t27`, positive and rejection cases, both builds).

## What is NOT demonstrated

- Borrowing / references / lifetimes as language features (there is no
  reference syntax yet).
- Heap-allocated strings and `Drop`: all strings today are read-only
  literals in `.rodata`; a move copies a pointer and a length, so there is
  nothing to free yet.
- Runtime safety checks: division by zero and `i64::MIN / -1` trap at
  runtime (SIGFPE); arithmetic overflow wraps. There are no bounds or
  overflow checks.
- Performance comparable to C/Rust on real programs: timings here are from
  a toy program.
- Running on real Windows: the Windows build is verified under Wine 10.20
  (wow64) on Linux only. Wine is a reimplementation of the Win32 API, not
  Windows; a real-Windows run remains pending.
- I/O error handling on Windows: the return values of `GetStdHandle` /
  `WriteFile` are not checked; a failed write goes unreported.
- Full Win64 ABI conformance: the alignment and register discipline is
  exercised by the test battery (including a call nested inside an
  arithmetic expression, `tests/t12_call_in_expr.hb`), not proven in
  general.
- A pure-Rust toolchain end to end: the assembler and linker are GNU
  binutils (C), and `hbc` itself is built with rustc/LLVM. Cranelift or a
  self-hosted path remains open.
- A `for` step given as an expression (Harbour allows it; this PoC
  takes only literals so the direction is known at compile time).
- Shadowing: no name may be reused while it is in scope (Rust allows it).
- Wrapping arithmetic: `+`/`-`/`*` on i64 wrap modulo 2^64 (two's
  complement) with no error, so a hand-written `while` counter can
  overflow into an infinite loop. Only the `for` increment is guarded.
- The path joins in the move checker are branch-insensitive: a move on
  one branch of an `if` taints the join even when that branch returns.
  Rust accepts some of these programs; this PoC rejects them on purpose.
- A first-class boolean: comparisons live in conditions only.
- The safety of any grammar extension beyond this subset: each extension
  must re-establish the closed-emission property.

## Reproduce

```sh
mkdir -p gen          # gen/ is not part of the checkout
rustc -O src/hbc.rs -o hbc
./hbc ejemplos/hola.hb gen/hola.s && as -o gen/hola.o gen/hola.s && ld -o gen/hola gen/hola.o && ./gen/hola
./hbc ejemplos/prestamo_roto.hb gen/prestamo.s    # rejected by hbc itself
```

Windows build (needs mingw-w64 binutils and the `kernel32` import library,
e.g. Ubuntu packages `binutils-mingw-w64-x86-64` and `mingw-w64-x86-64-dev`;
running the .exe on Linux needs Wine):

```sh
./hbc ejemplos/hola.hb gen/hola_win.s --target=windows
x86_64-w64-mingw32-as -o gen/hola_win.o gen/hola_win.s
x86_64-w64-mingw32-ld -o gen/hola.exe gen/hola_win.o -e _start --subsystem console -lkernel32
wine gen/hola.exe
```


See [BUILDING.md](BUILDING.md) for the complete build recipe (Linux, Windows .exe output, cross-building `hbc.exe` itself, and running under Wine) and [dist/](dist/) for prebuilt, tested binaries with SHA-256 checksums.

## Preprocessor: integrated (F1+F2+F3, scoped)

hbc runs our own MIT preprocessor automatically on every compile:
`#define` (object-like and function-like), `#undef`, `#ifdef` / `#ifndef` /
`#else` / `#elif` / `#endif`, `#if` with integer conditions and `defined()`,
line continuation with `;` (Harbour's rules: last
non-whitespace character, outside strings),
`#include` (quoted form, relative first, plus the angle form
`<file>` resolved through the `-I` paths only, as in Harbour), `#error`. Written from scratch against the
behavioural baseline in docs/PP-F0.md; src/hpp.rs is a standalone debug
frontend over the same engine.

User-defined commands and translations are supported in a scoped form,
probed against Harbour first: `#command` / `#xcommand` with literal words
(case-insensitive), `<param>` captures, optional `[ ... ]` clauses (nesting included) and
`<x,...>` list captures (inserted via the plain `<x>` result marker, as
Harbour's own headers do), the parenthesized-expression marker `<(x)>`,
and chaining, plus result-side `[ ... ]` optional parts (kept when a
bound marker is inside, dropped whole otherwise, matching Harbour's
observed behaviour); `#uncommand` / `#untranslate` remove a rule by
exact match, one instance at a time, as Harbour does;
`#translate` / `#xtranslate` only in the
call form `NAME( <p> ) => body`, which works inline in expressions, plus
non-call forms at statement start (`#xtranslate` is accepted and behaves
like `#translate`; Harbour's x- priority over a same-pattern plain rule
is NOT emulated, so this is not complete `#xtranslate` support). Macro
names and parameter substitution are case-sensitive, directive names are
not - matching Harbour's observed behaviour. NOT supported: the marker
forms Harbour itself rejects (`<"x">`, `<#x>`), non-call `#translate`
forms, token pasting (`##`), the `&` macro operator, `#pragma`. This is not a complete preprocessor port; see docs/PP-F0.md for
the probe record and the explicit out-of-scope list.
