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

## Iteration 11: fixed-size integer arrays

`local a := {10, 20, 30}` creates a fixed-size array of integers, stored
inline in the stack frame (no heap, no GC): `? a[i]` reads, `a[i] := v`
writes. Indexing is Harbour's base 1, probed against Harbour (a[1] is the
first element; both a[0] and a[N+1] fail). A constant index out of range
is a compile error; a runtime-computed index out of range prints Harbour's
wording (`Bound error: array access`) and exits with code 1 - Harbour
itself opens an interactive error dialog there (observed hanging even
with stdin at EOF), so the failure MODE is a registered difference while
the error CONDITION is the same. Assignment copies the whole array: Rust
`[i64; N]` is Copy, verified against rustc (mutating the copy leaves the
source intact); Harbour shares a reference instead - a registered MODEL
difference, not a bug. Explicit limits of this increment: integer elements
only, fixed size from the literal, one index level, no array parameters or
return values, no whole-array printing, no empty literal, no `len()`,
no mixed types. Battery: tests t126-t139 (4 byte-exact vs compiled
Harbour, 1 MODEL, 1 DIVERGE-FAILMODE, 8 negatives).

## Iteration 12: codeblocks without captures

`local b := {|x| x + 1}` creates a codeblock: a code pointer (no heap,
no captures in this increment), invoked with the built-in `eval(b, 5)`.
The body is a comma-separated expression list and returns its last
expression, as Harbour does. Extra `eval` arguments are evaluated and
ignored (Harbour's behaviour, probed); missing arguments are a compile
error. Capturing function locals is the next increment. Battery:
t150-t160, seven byte-exact against compiled Harbour.

## Iteration 15 - NIL as a true tagged value (v2c)

NIL is a real value with its own tag: the tagged union `Ty::Dyn` -
{tag, payload} in 16 bytes (tag 1 = NIL, tag 0 = an i64 payload;
rax=tag, rdx=payload in registers). The first v2c representation
(i64::MIN sentinel, published at cd8cf17) collided with a valid
integer and evaluated NIL-held-in-a-variable operations numerically;
it was rejected and replaced. No integer is reserved: i64::MIN is an
ordinary value again and coexists with NIL in the same array (t213).
All oracle-grounded (probes n1/n2/n3 against compiled Harbour):

- `x := NIL` stores {1, 0}; `? x` prints `NIL` (no field padding).
  Reassignment flips the tag in place (`y := NIL` then `y := 5`).
- `return nil` / `return NIL` RETURN NIL (n1c: `? f()` prints NIL).
  A function closing with `return nil` is usable in an expression
  (t35/t104 re-purposed). MIXED returns are supported: `return 7` in
  one branch and `return nil` in another unify to the tagged union
  (n2: g(1) is 7, g(0) is NIL, g(1)+2 is 9) in either source order
  (t217/t219); an early `return nil` inside a block is a value return
  now, like any other.
- NIL flows through assignments out of arrays (`x := a[i]`),
  parameters, returns and temporaries, and across if/while joins
  without losing the tag (t214-t216, t221).
- `ASize` grows flat dynamic arrays with NIL {1, 0} (e1: grown slots
  print `NIL`, compare .F. against 0); a DArr2 still grows with the
  empty child (m-probes).
- Dynamic array elements are tagged {tag, payload}: reads are Dyn,
  writes tag integers in ({0, v}) and copy Dyn values. Fixed-size
  arrays stay tagless [i64; N] (t222).
- Comparisons: `NIL = NIL` is .T., `NIL = 0` and `"" = NIL` are .F.,
  `NIL != 0` and `NIL != ""` are .T. (n1). Equality on tagged values
  dispatches on the tags at runtime (hbc_dyn_eq). `=` / `#` against a
  string fold to .F./.T. but BOTH operands still evaluate left to
  right (t223: calls run, effects preserved).
- Arithmetic, ordering and indexing on a NIL VALUE are a Harbour type
  error: its interactive dialog cannot be probed headless, so the PoC
  prints "Type error: NIL used as a number" and exits 1 (t218, t220 -
  registered failure-mode difference, same error condition, like the
  bound-error dialog). Ordering a NIL LITERAL stays a compile error
  (t212).

Battery: 225/225 green on Linux x86-64 and Wine (t35/t104/t165 updated
to the Harbour behaviour; t211 rewritten from probe n1c; new
t208-t223). Design: docs/DESIGN-nil-tag.md.

## Iteration 14 - arrays of dynamic arrays (v2b)

- `local a := {{1, 2}, {3, 4}}` compiles: nested literals, two-level reads
  `a[i][j]` and the Harbour comma form `a[i, j]` (identical in Harbour -
  probe m2), two-level writes `a[i][j] := v`, `len` at both levels,
  `AAdd(a[i], x)` / `ASize(a[i], n)` on a subarray.
- Ownership: inserting `AAdd(a, b)` or assigning `a[1] := b` MOVES the child
  into the parent - Harbour's `b := a[1]` extraction aliases the shared
  subarray (probe m4) and `AAdd(a[1], x)` mutates what `b` sees (probe m5);
  both are registered MODEL divergences. Extraction `b := a[1]` is rejected
  in this increment (indexed borrows only: a[i][j], len(a[i]), AAdd/ASize on
  a[i] - Harbour's aliasing has no single-owner equivalent yet).
- Evaluation order is probe-matched (m7): a nested write evaluates the
  value, then the outer index, then the inner index; AAdd/ASize on a[i]
  evaluate the target index first. The parent cannot move while an index is
  evaluated (static error), and overwriting a child frees the old one once,
  after the new value exists (no double free).
- ASize shrink drops the removed children observably (Harbour m8 shows the
  reduction; it does not reveal Harbour's internal lifetime). Our recursive
  destructor frees children then parent - proven by alloc-identity
  (hb_memcheck balance 0 across function boundaries), not inferred from
  output.
- Limit explicit at that increment: arrays of arrays were not function
  parameters, returns, or print arguments; they pass and return since
  iteration 21 (move semantics). Three-level nesting, mixed literals,
  direct printing and `ASize` before pinning remain compile errors.
- Two v2a fixes landed with it: `a[i] := v` on flat dynamic arrays (a
  checker gap, never battery-tested before - now t193 differential) and the
  epilogue preserving the return value across frees (latent clobber).
- Battery t183-t207; 209 tests green on Linux x86-64 and Wine (WoW64).

## Iteration 13: dynamic integer arrays (first heap)

`local a := {}` creates a dynamic array of integers: `AAdd(a, x)` and
`ASize(a, n)` are built-in statements that grow/resize in place,
`len(a)` reads the length. This is the compiler's first heap: mmap on
Linux (failure = negative errno, checked), HeapAlloc on Windows, an
8-byte capacity header before the data, doubling growth, checked
overflow, OOM abort with a clean message. Ownership is Rust's model
made physical: one owner per array; assignment, call and return MOVE
and null the source slot; the checker tracks moved state statically
(branch joins union the moved flags; a value moved inside a loop body
and not reassigned is a compile error; use of a moved value - including
as AAdd/ASize target - is rejected), and slots are zero-init with
null-safe freeing, so codegen needs no path tracking and every
allocation is freed exactly once at its owner's epilogue, overwrite or
re-declaration - no GC, no reference counting, no shared aliases (Harbour's sharing, probes d6-d9/e9, is a
registered MODEL difference). Nested dynamic
arrays, hashes and codeblock captures are NOT in this increment.
Battery: t164-t176 (178/178 green on Linux and Wine), including
alloc/free balance 0 across function boundaries (t166) and the pinned
compile-time rejections.

## Iteration 16 - allocation registry harness and instrument mode

The munmap length fix (all free sites pass the tagged element size 16;
an under-unmap leak for blocks spanning more than one page) is pinned
by an allocation registry: hbc_alloc records (base, bytes) and hbc_free
verifies the exact unmap length and liveness, so a wrong size, an
unknown block or a double free aborts with a clean message (t224-t228,
negative control included). The registry is emitted only with
`--instrument`, the battery's build mode: normal compilation carries no
registry and no 16384-entry limit. Freed entries are reused (t229:
20000 alloc/free cycles) and exhaustion stops clean (t230: "Out of
memory", exit 1). OS free results are checked in every build: a failed
munmap or HeapFree prints "Internal error: OS free failed" and exits 1,
so a registry match can never mask an OS-level failure. t230 also
exposed a pre-existing off-by-one in the OOM message length (15 vs 14
bytes on both targets), fixed with t230 as its regression. The harness
verifies exact size, liveness and OS results on the paths the battery
exercises - it is not a proof of absence of leaks on unexercised paths.
Battery: 232/232 green on Linux x86-64 and Wine.

## Iteration 17 - hashes v1

String-keyed hash maps: `{k => v, ...}` and `{=>}` literals, `h[k] := v`
writes (value evaluated before the key - probe h4), `h["k"]` reads and
`len(h)`, all verified against compiled Harbour oracles. Keys are
case-sensitive byte strings compared with their length (h3b; prefix
keys stay distinct, h12; the empty string is an ordinary key, h10).
Duplicate keys in one literal overwrite in place (h8) and each literal
pair evaluates its key before its value (h9 - the opposite of
`h[k] := v`). A missing-key read is Harbour's BASE/1132 dialog, which
hangs headless (h3/h3c): the registered failure mode is a clean
"Bound error: array access" with exit 1 (t234/t235), not a compat
success. Values are tagged scalars (integer or NIL). Ownership follows
the same Rust model as arrays: assignment MOVES the hash and nulls the
source (use-after-move is a compile error, t241); keys are copied into
owned allocations on insert, the block grows doubling from 4 pairs
(t243), and the epilogue frees every key copy and the block - balance 0
across a function boundary under the instrumented registry (t242).
Insertion order is preserved internally by construction but is NOT
claimed verified: without hb_HKeys or iteration there is no observable
order. Harbour accepts NUL-embedded keys via chr(0) (h11); hbc has no
chr(), so NUL keys are not provable end-to-end - only the byte-with-
length comparison is implemented. Rejected with clean errors in this
increment: hash parameters and returns, whole-hash printing, non-string
keys, non-scalar values, hb_HKeys and iteration. Design notes and the
oracle inventory: docs/DESIGN-hashes.md. Battery: 246/246 green on
Linux x86-64 and Wine.

## Iteration 18 - Array() constructor

`Array(n)` and `Array(n, m)`, verified against compiled Harbour
oracles (a0, avar, aadd, a3d, aneg, a0args). `Array(n)` builds a
dynamic array of n NIL slots (t245/t247, single dimension from an
expression in t248); `Array(n, m)` builds n children of m NILs each
(t246 mirrors oracle avar, including a nested write and read back).
The result follows the same ownership rules as array literals:
assignment MOVES it, the epilogue frees it, and the alloc/free balance
across a function boundary reads 0 under the instrumented registry
(t253). `AAdd` keeps working on a constructed array (t249, oracle
aadd). Registered failure modes, not compat claims: Harbour answers
`Array()` and `Array(-1)` with dialogs that hang headless (BASE/1111,
BASE/1131); hbc rejects the first at compile time (t252) and answers
the second with a clean "ASize: negative size" runtime error, exit 1
(t250). Harbour supports three and more dimensions (oracle a3d);
hbc rejects them with a compile error in this increment (t251).
Constructor edges verified against oracles: zero rows (az0a, t255),
zero columns (az0b, t256), dimensions evaluated left to right and
exactly once (aevord, t257), AAdd appending at len+1 on a nested
child (anadd, t258); the allocation-overflow guard is ours, without
a headless oracle (t259). This iteration also fixed the internal
helper ABI: the Windows hbc_free2 / hbc_aadd / hbc_asize clobbered
callee-saved registers that every other helper (both targets)
preserves; they now save and restore them, the ABI is documented in
docs/BATTERY.md, and tests/abi_harness.sh (asm canaries across every
helper route, wired into the battery, negative control verified)
guards it. Battery: 261/261 green on Linux x86-64 and Wine, plus the
ABI harness on both targets.

## Iteration 19 - grown-casilla NIL repair

The registered "Array parent grown NIL vs null" difference is
repaired against oracles n1-n7. An ASize-grown casilla of an array of
arrays is Harbour's NIL (not an empty child): it prints NIL (n1,
t262), and len / AAdd / ASize
on it are Harbour's BASE/1111, BASE/1123 and BASE/2023 dialogs, which
hang headless (n2, n6, n7) - here they are clean errors
"Argument error: LEN / AADD / ASIZE", exit 1 (t263-t265, registered
failure modes, not compat successes). Assigning an array into the
casilla works, including an i64 literal, which converts to a
Dyn-element child (n3, t266, and the rewritten t191), and the sibling
casilla stays NIL. To keep NIL casillas distinguishable from real
empty arrays, `{}` and empty children now own a header-only block
(cap 0) - observable behavior unchanged (len({}) == 0, e4) and the
instrumented registry verifies the new allocation/free sizes on the
tested paths (t191). `Array(n, 0)` children are real empty arrays
(az0b, t256). Battery: 266/266 green on Linux x86-64 and Wine, plus
the ABI harness on both targets.

## Iteration 29 - mutable string arrays, parameters and returns

The two limitations iteration 28 shipped with are closed (they were
PoC scope, never ownership requirements):

- The array from `hb_HKeys` - and any `{}` grown with string
  elements - is MUTABLE: `AAdd(k, s)` appends an owned copy (a
  rodata value is copied, an owned value moves in) and `k[i] := s`
  overwrites an element, freeing the old owned copy once the new one
  exists (oracle hk7, written for this increment: the hash is
  unaffected; t307 mirrors it byte for byte; t308 pins the same
  behaviour for a `{}` pinned by string AAdds, including a
  self-insert `AAdd(a, a[2])`, which is safe because reads copy).
  ASize on it stays a named compile error (t315).
- Arrays of strings and owned strings are function PARAMETERS and
  returns, under the established move contract: the callee owns the
  value, the caller's slot is nulled, using it after the call is a
  compile error (t310, t313). String parameters are now uniformly
  owned: a rodata argument is copied at the call boundary, an owned
  argument moves (t311, t312); a function returning its string
  parameter on one path and a literal on another unifies to an
  owned return, with a copy emitted at the literal return point
  (t314). Oracle hk8 registers Harbour's behaviour for the same
  shape: the array is SHARED (the callee's mutation is visible
  without any return) - the deliberate move-vs-share difference
  already registered (pr2/pr5 family), pending the user's contract
  decision; t309 shows the explicit move round-trip. A string array
  passed to a parameter pinned to a flat integer array is a genuine
  type mismatch (t303, repurposed; t304 now pins a non-string AAdd
  element).

The sweep caught a pre-existing hole: a comparison between an owned
string and any other value fell through to the numeric arm, which
compared pointers and leaked the temporary. Comparisons with owned
strings now byte-compare on both targets and free temporaries after
the call (covered by t311/t314 through the pinned parameter
comparisons). No new helpers: hbc_strcpy, hbc_aadd, hbc_free and
hbc_sfree were already covered by the ABI canary harness, which
still passes on both targets. Battery: 313/313 green on Linux
x86-64 and Wine, plus the ABI harness on both targets.

## Iteration 28 - hb_HKeys: hash keys as an owned array of strings

`hb_HKeys(h)` returns the keys of a hash as a new array, in
insertion order and with their original case (oracles hk4-hk6,
written for this increment against the core libraries only, no
contrib: insertion order and case preserved; an overwrite keeps its
position and updates the value; keys that differ only in case are
two keys - the case-sensitive dedup already registered in h3b/t235;
an empty hash yields a zero-length array). HGetKeys from libxhb is
a different surface and is NOT wired as an alias. The argument must
be a hash; anything else is an explicit compile error.

The result is a read-only array of strings (DArrS): each key is an
owned copy, so it stays valid after the hash is destroyed and after
the keys array is reassigned (t301: a kept element is compared
against the hash again after freeing the array - no use-after-free).
An element read `k[i]` yields an owned heap string (StrOwn,
distinct from a read-only-data string) that its owner frees; prints
of an element free the temporary copy, while an element still
stored in the array is not freed by the print. The move rules are
the established ones: use after move is a compile error (t302,
t305), and a function that returns the keys array transfers
ownership (t306, balance 0). Out of scope, all explicit compile
errors: writing through the array (AAdd/ArrSet on it, t304) and
passing it or a StrOwn as a parameter (t303 - the same precedent
as hash parameters).

Three new shared helpers, both targets, each with an entry in the
ABI canary harness (callee-saved registers, stack balance and
alignment checked after every call): `hbc_hkeys` builds the array,
`hbc_sfree` frees it, `hbc_strcpy` copies one string. t298 mirrors
hk4 and adds writes, reassignments and a registry balance of 0
(wrap pattern); t299 mirrors hk5; t300 mirrors hk6. Battery:
304/304 green on Linux x86-64 and Wine, plus the ABI harness on
both targets.

## Iteration 27 - three-level arrays as parameters (move)

A DArr3 can now be a function parameter or a return value, under the
same move contract as two levels (iteration 21): the callee becomes
the owner, the caller's slot is nulled, and using it after the call
is a compile error (t295). Passing through a chain of callees moves
the value along (t296, balance 0). Oracle pr9 registers Harbour's
semantics for the same program: the object is SHARED (the callee's
write is visible to the caller) - the deliberate difference already
registered for two levels (pr2/pr5), pending the user's contract
decision. Evidence pinning a parameter: p[i][j][k], len(p[i][j]),
AAdd/ASize(p[i][j], ...), or a call whose signature asks for a
three-level array. The same mirror run caught a pre-existing hole
at ALL depths: a `? consume(a)` print statement never applied the
argument moves, so the caller kept using the moved value (strings
moved inline, arrays did not). Fixed and pinned with t297 (two
levels) and t295 (three). Battery: 295/295 green on Linux x86-64
and Wine, plus the ABI harness on both targets.

## Iteration 26 - class syntax parser (runtime pending)

The class surface PARSES now: CREATE CLASS Name [INHERIT Base] ...
ENDCLASS with DATA name [INIT expr] and METHOD name(params)
[CONSTRUCTOR] declarations, METHOD ... CLASS Name definitions, and
the message-send syntax (o:name, o:name(args), chains, ::name,
Self, `==` lexed for identity). The runtime representation is NOT
implemented: every program with a class is rejected with an
explicit error after parsing (t290), multiple inheritance is its
own error (t291, oracle cl21: Harbour accepts it), class scopes
PROTECTED/HIDDEN are their own (t292, oracle cl8: Harbour enforces
them at runtime), `==` identity is its own (t293, oracles
cl7/cl19). The parser is ours (MIT); the hbclass.ch macros were
only observed as oracles, never copied. Semantics probed and
registered so far (sondas_ac/classes, cl1-cl21): sharing on
assignment and parameter passing, Self chains, per-instance INIT,
constructor not auto-run, method-over-DATA precedence, instance
dispatch with override, child-first INIT order, lax arity,
identity, cycles usable, unknown message/data errors (headless
dialogs). Battery: 291/291 green on Linux x86-64 and Wine, plus
the ABI harness on both targets.

## Iteration 25 - Array() with three dimensions

`Array(n, m, k)` now builds a full three-level value (oracle pr7,
written for this increment: `len` is n/m/k at each level, the
innermost slots read NIL, a later `a[i][j][k] := v` write works).
The constructor composes: one new helper `hbc_array3m` builds n
children, each a complete `Array(m, k)` from the existing
`hbc_arraym`. The edge cases have their own oracles: a zero
dimension in any of the three positions yields the same shape
Harbour builds, including a real empty child array (len 0, not NIL)
when the middle dimension is 0 (pr7b, t287); a negative interior
dimension is the registered clean error even when the outer count
is 0 (Harbour raises BASE/1131 there, its dialog hangs headless -
pr7c, t289); the three dimension expressions evaluate once, left
to right (pr7d, t288). A huge allocation ends the Harbour
process with a kill signal (pr7e, exit 137; the cause - OOM-killer
or another limit - is not confirmed without a kernel/cgroup log,
so the probe registers only "process killed"). hbc fails cleanly
on the same condition, verified without real memory pressure: the
arithmetic guards in hbc_asize (capacity cap and signed-multiply
overflow both route to hbc_oom) and a bounded process (address
space capped at 256 MB: Array(40000, 40000, 40000) prints "Out
of memory" and exits 1 in under a second). t286 pins
the compile error for a fourth dimension; t251, the old "3
dimensions unsupported" negative, is retired. `hbc_array3m` has
its own ABI canary block in the harness. t285 mirrors pr7 with
registry balance 0 after the owner returns. Battery: 287/287
green on Linux x86-64 and Wine, plus the ABI harness on both
targets.
Out of scope, all explicit compile errors: three-level parameters
(until iteration 27), a fourth index level or dimension, mixed literals.

## Iteration 24 - AAdd and ASize at the third level

`AAdd(a[i][j], x)` and `ASize(a[i][j], n)` grow and resize the
innermost subarray in place (oracles pr8/pr8b, written for this
increment: AAdd evaluates i, then j, then the value; ASize
evaluates i, then j, then the size - indices BEFORE the value,
the same order as two-level AAdd/ASize; measured, not inferred).
t281 mirrors pr8 and t284 mirrors pr8b: the
grow makes `len(a[1][1])` 3 with the new value in place and every
other length unchanged, the shrink drops the tail, a later grow
leaves the fresh slots reading NIL, and the registry balance is 0
after the owning function returns (t284 adds the ASize order). A null child at either level is
the clean AAdd/ASize error; out-of-range indices are the clean
bound error. t282/t283 pin the compile errors on a two-level
value. The statement surface accepts `a[i][j]` heads with full
index expressions (an index containing brackets, `a[b[1]]`, still
parses as the two-level form - t192 keeps that pinned). Battery:
283/283 green on Linux x86-64 and Wine, plus the ABI harness on
both targets. Out of scope, all explicit compile errors:
three-level parameters (until iteration 27), Array() with three
dimensions, a fourth index level, mixed literals.

## Iteration 23 - writes at the third level and a return chain

`a[i][j][k] := v` now compiles for an array of arrays of arrays
(oracle pr6: after `a[1][1][2] := 99` on {{{1, 2}}, {{3}}}, the read
is 99 and every length is unchanged; t277 mirrors it). The value
evaluates first, then the indices left to right (probe m7 order);
each level is bounds checked and a null child pointer is a clean
bound error, the same rule as reads. Writes to a two-level value
through three indices are a compile error naming the depth (t278),
as is a fourth index level (t279). t280 pins the ownership rule for
a chain of returns (mk -> mid -> use): a function that RETURNS a
three-level value never frees it (the move nulls its slot), only
the final owner frees, with a read after each transfer and
registry balance 0 on both targets. Battery: 279/279 green on
Linux x86-64 and Wine, plus the ABI harness on both targets.
Out of scope, all explicit compile errors: AAdd/ASize at level 3,
three-level parameters (until iteration 27), Array() with three
dimensions, a fourth index level, mixed literals.

## Iteration 22 - three levels of nesting (arrays of arrays of arrays)

Literals like `{{{1, 2}}, {{3}}}` now compile to a third nesting
level (oracle pr4: `len(a)` = 2, `len(a[1])` = 1, `len(a[1][1])` =
2, `a[1][1][2]` = 2; t275 mirrors it). Reads, `len` at each level
and three-level bounds-checked indexing work; a three-level value
returns from a function with the same move contract as iteration 21
(t276: the callee's slot is nulled on return, the caller's epilogue
frees the whole value, registry balance 0 on both targets).

Two implementation decisions worth naming:

- The type is an explicit `DArr3` variant, not a recursive type:
  the checker knows the depth statically, so a fourth index level is a
  compile error with a named limit, not silent misbehavior (a
  three-level parameter compiles since iteration 27, under the move
  contract). A generic recursive
  structure was considered and set aside for this PoC: it would
  need runtime depth tracking the current slot model does not have.
- The FREE side is generic: one new helper `hbc_rfree(ptr, len,
  depth)` frees any depth >= 2 by recursion (depth 2 reduces to the
  existing `hbc_free2`), so depth 4+ needs no new helper even though
  the type checker does not admit it yet. The ABI harness now wraps
  a live DArr2 in a pair block and frees it through `hbc_rfree`
  under canary + alignment checks on both targets.

The iteration also repaired a latent bug the new balance test
surfaced: three-level locals were never registered in the
free-slot table, so their slots were not zero-initialized at entry
(a re-declaration could free stack garbage - the registry harness
caught it - and the epilogue leaked the whole value). The
declaration/assignment move-out nulling now covers `DArr3` sources
too. t200 (the old "depth 3 unsupported" negative) is retired:
depth 3 is supported now. Battery: 275/275 green on Linux x86-64
and Wine, plus the ABI harness on both targets. Out of scope, all
explicit compile errors: ASize/AAdd/ArrSet at level 3, three-level
parameters, a fourth index level, mixed literals.

## Iteration 21 - nested arrays as parameters and returns

Arrays of arrays now pass as function arguments and return from
functions, under the existing ownership contract (oracles pr1-pr5):
a parameter MOVEs - the caller's variable is moved out at the call
(use after the call is a compile error, t273) and the callee owns
and frees the value (t271 mirrors pr1: `len(a)` and `len(a[1])` in
the callee); a returned nested array transfers ownership to the
caller, whose epilogue frees it (t272 mirrors pr3). The callee can
mutate its own moved value, including AAdd on a child (t274, with
registry balance 0 across param consumption and return). Parameter
inference pins an array of arrays from `p[i][j]`, `len(p[i])`,
AAdd/ASize on `p[i]` or writes; whole-array evidence (`len(p)`)
merges with nested evidence into the nested type (pr1). Harbour
SHARES the reference instead (pr2: a callee write `a[1][1] := 99`
is visible in the caller; pr5: a callee AAdd is visible in the
caller) - that sharing is the standing deliberate model difference,
registered, with the user's contract decision still pending; it is
not implemented here. Battery: 274/274 green on Linux x86-64 and
Wine, plus the ABI harness on both targets.

## Iteration 20 - casilla vs NIL comparison

The pending n4 comparison is repaired: a grown casilla compares
against NIL with `=` (oracle n8: `a[3] = NIL` after the grow is .T.,
a live child is .F., and an empty child `{}` is .F. - it owns a
header block, t267). The borrow reads the child pointer; it never
extracts the subarray. The index expression evaluates exactly once,
bounds-checked (t268: a call in the index runs once), and NIL on the
left (`NIL = a[3]`) works too. Harbour's exact-equality `==` is not
tokenized in the subset, so the tests use `=`, which Harbour answers
identically for NIL (n8). `Array(3, 0)` rows are real empty arrays,
so `a[1] = NIL` is .F. (t269), and shrinking an array of arrays to
length 0 with ASize frees every child with registry balance 0 - no
leak, no double free (t270). Battery: 270/270 green on Linux x86-64
and Wine, plus the ABI harness on both targets.

## Iteration 30 - hashes as parameters and returns, ASize on string arrays

Two more PoC limitations closed (scope, never ownership
requirements):

- Hashes pass as function parameters and return from functions.
  The value MOVES: the caller's slot is nulled, the callee owns
  the hash, frees it at exit, or hands it back with `return p`
  (oracles hk11/hk12, Harbour core libraries only, `-gtstd`;
  t316 prints byte-identical values to hk11 via the explicit
  move round-trip; t317 mirrors hk12 exactly). Harbour SHARES
  the hash on a call - the callee's writes are visible without
  any return (hk11) - which stays the registered difference
  family D5/D7, pending the user's contract decision. This is
  the current limitation vs the sharing decision: two different
  things. Pin evidence: a string key (`p["k"] := v`, `? p["k"]`)
  pins the hash; `len(p)` alone would pin a flat array, and the
  two merge to the hash pin - `len` of a hash is its pair count
  (hk11; t322). A hash parameter the callee does not return is
  freed at its exit (t318: balance 0).
- `ASize` on an array of strings: shrink keeps the first
  elements and frees the removed copies (t319 mirrors the
  shrink half of oracle hk13); resizing to the same length is a
  no-op and shrinking to 0 frees every copy (t320). GROWING an
  array of strings is a clean runtime error in this increment -
  Harbour grows with NIL casillas (hk13 prints NIL) - exit 1
  with a named message (t321). ASize on the hash itself stays a
  named compile error (t315 repurposed).

Battery: 322/322 on Linux x86-64 and Wine, plus the ABI harness.
No new helpers (the ASize change extends the existing hbc_asize
kind flag; string frees go through the already-canaried
hbc_free).

## Iteration 31 - ASize growth on string arrays: NIL casillas like Harbour

The last ASize difference is closed: growing an array of strings
fills with NIL casillas, exactly like Harbour (oracles hk13-hk15,
Harbour core libraries only, `-gtstd`):

- `ASize(k, n)` with n > len grows with {NIL} casillas; `? k[i]`
  on one prints NIL (t324 mirrors hk14 byte for byte, t325);
  `AAdd` after growth appends past them (t326 mirrors hk15).
- Overwriting a grown casilla with `k[i] := s` works - the old
  null payload is skipped and the casilla retagged (hk14, in
  t324); shrinking after growth frees the live copies and skips
  the NIL ones (t327: balance 0).
- Reading a grown casilla in a STRING context (assignment,
  comparison, argument) is a clean runtime error with exit 1
  (t321 repurposed): Harbour yields NIL there - its typing is
  dynamic and the target variable would BECOME NIL - while the
  static owned string cannot. Registered failure mode, same
  condition, not a compat success.

- Printing a WHOLE array or hash variable (`? h`, `? a`) prints
  nothing, exactly like Harbour (oracles hk16/hk20/hk21/hk24;
  t328, t329): the separators between items are still emitted
  and QOut space-trims the END of the line (hk22/hk24/hk25),
  so a trailing string item - literal, variable or string-array
  element - loses its trailing spaces while interior spacing is
  preserved byte for byte (t330, t331). Printing borrows the
  variable (hk23: still usable afterwards). Two registered
  limits of this increment, not general fidelity: only a
  VARIABLE prints empty this way (a constructing temporary is a
  named compile error, t332), and a trailing ALL-SPACES string
  still leaves the separator before it - exact fidelity there
  needs a buffered line.

Battery: 330/330 on Linux x86-64 and Wine, plus the ABI harness.
No new helpers (the empty-render path pushes a dead pair; the
line-end trim is an inline backward scan before hbc_print_str).

## Iteration 33: for each / next

`for each <var> in <collection> ... next` iterates a flat or
string dynamic array, a static array or a hash (oracles
hk17-hk32): array elements one by one, hash VALUES in insertion
order, grown NIL casillas as NIL (t333-t337, t342, t343). The
EACH keyword is required - `for x in a` is Harbour's E0030
(t338) - and the loop variable must already exist, or Harbour
stops with BASE/1003 (hk19, t339). Inside the body the variable
is the current element as a tagged value (Dyn): printable,
comparable against NIL and integers, usable in arithmetic
(t343). The collection is a VARIABLE the loop borrows: it stays
alive afterwards (hk26) and an early `return` from the body is
safe (t342). The pre-loop value of the variable is restored
when the loop ends, naturally or via `exit` (hk28/hk29) - the
outer slot is never written.

Registered limits of this increment, not general fidelity:

- Harbour writes an assignment to the loop variable THROUGH to
  the current element (hk32); here assigning to it is a named
  compile error (t340).
- The collection cannot be modified, moved or grown inside its
  own loop - the borrowed (pointer, count) pair would dangle
  (t341).
- The element value borrows from the collection, so it cannot
  escape: returning it, copying it to another local, passing it
  to a function or storing it into a collection are named
  compile errors (t346-t348).
- Ordering the loop variable against a string works byte-wise
  over the right operand's length (hk36/hk39/hk40/hk43/hk51,
  t355-t357/t360/t361, same hbc_str_cmp as b22), on either
  operand side. Equality/inequality against a string works with
  Harbour's own prefix rule (hk33/hk37, t344/t349/t362, same
  hbc_str_eq as b23); a NIL casilla answers .F./.T. (hk35,
  t350), and a NUMERIC element against a string
  is Harbour's BASE/1071/1072 (hk34/hk38, dialogs that hang
  headless) - here a clean "Argument error: =" / "Argument
  error: <>" exit 1 (t351/t352, registered failure modes);
  ordering a NIL or numeric casilla against a string is the
  same kind of registered failure mode for BASE/1073-1076
  (hk41/hk42/hk44-hk50, t358/t359). NIL and integer
  comparisons work (t337/t342). Inline branch labels in
  emitted code now come from a per-emission unique counter
  (LBL_ID) - fixed numeric labels caused two silent
  miscompares.
- Temporary collections work (call results: hb_HKeys(h),
  Array(n) or a user function returning an array or a hash -
  hk52/hk55/hk56, t363-t366): the temporary is OWNED by the
  loop in a registered slot, zeroed by the prologue, freed if
  non-null on statement re-entry and freed by the epilogue on
  every exit path (natural, `exit`, `return`; balance 0,
  t364/t365). Nested collections a[i] work (hk53/hk54): the
  subarray is BORROWED from the root owner for the loop - the
  index expression evaluates once, effects included (t368),
  the cell is bounds-checked and loaded, and the root stays
  alive after the loop (t367). Mutating, growing or moving
  the root or the borrowed child inside the loop is a named
  compile error (t370-t372). Iterating a NIL casilla exits
  with Harbour's BASE/1068 text "Argument error: array
  access" (t369; in Harbour the dialog hangs headless - a
  registered failure mode, not exact equivalence).
  `exit`/`return` inside the loop own nothing; the epilogue
  frees the root as usual (t373, balance 0).
- Depth 3 works the same way (hk60-hk64): a[i][j] borrows the
  innermost child, both index expressions evaluate once
  (t375), each level is bounds-checked, the root survives
  (t374), growing the borrowed child, writing through the
  root or moving it inside the loop are named compile errors
  (t376-t378), and `exit`/`return` own nothing (t379,
  balance 0).
- ASize grows a three-level root and the middle a[i] with
  NIL casillas (hk65/hk68, t380-t386): shrink frees the
  removed children RECURSIVELY (new hbc_asize kind 3 calling
  hbc_rfree; balance 0), and iterating a grown NIL casilla
  at depth 3 is the BASE/1068-text clean exit 1 (t381/t383;
  in Harbour the dialog hangs headless - a registered
  failure mode, not exact equivalence). AAdd on the middle
  with array elements (hk66/hk67 measured) stays pending.
  Reading a[i] of a three-level array by value stays a
  named compile error.

Robustness fix in passing: `hb_HKeys` with a non-variable
argument used to panic the compiler; it is now the documented
clean error (t345).

Battery: 383/383 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.
