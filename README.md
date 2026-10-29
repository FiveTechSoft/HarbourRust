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
    x := <expr>            assignment to an existing local (same type);
                             Harbour's single `=` in statement position
                             assigns too (oracle hk214); `=` stays a
                             comparison inside expressions
    x++ / x-- / ++x / --x  integer variable expressions: old / new value;
                             writable variables only, overflow is a named
                             controlled limit before store, not wrapping
    ? <expr>               prints
    f(<args>)              a call as a statement: the callee runs and the
                             return value is discarded (an owned string is
                             freed; discarding a dynamic array is rejected)
    if <cond> ... endif    conditional, optional else, nestable
    while <cond> ... enddo loop, re-evaluates the condition each iteration
    for i := <a> to <b> [step <n>] ... next
                             counted loop; n is a non-zero integer literal
    exit                     leaves the innermost loop
    loop                     skips to the next iteration of the innermost loop
    return <expr>            early return: closes the function with a value
return <expr> | return nil closes the function  (a closing top-level return
                             is always required)
// comment             to end of line; also && to end of line, * as
                             the first non-whitespace character of a line,
                             and /* ... */ blocks (mid-line or multi-line,
                             non-nesting; oracle family hk211)
```

Expressions: integer literals, string literals in double quotes
(escapes `\"` and `\\` only - a registered deviation: Harbour treats the
backslash literally) or in single quotes (no escapes, oracle hk213),
identifiers, `+ - * /`, parentheses, 0-argument calls `name()`.
`+` over two strings concatenates into a fresh owned buffer (oracle
hk215; copies both operands - Harbour value semantics). Conditions: the same
expressions combined with `= <> != < <= > >=` (integers only); prefix `!`
is Harbour's `.NOT.` (oracle hk212).
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
forms, token pasting (`##`), the `&` macro operator, `#pragma`. The valid Harbour match markers `<!x!>` and `<*x*>` are also not supported;
our E0010 attribution for these forms is wrong. See experiments/pp-markers for
45 own-source black-box observations. This is not a complete preprocessor port; see docs/PP-F0.md for
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
`len(a)` reads the length. `len()` also accepts
strings (oracle hk217: length in characters); a string parameter under
`len()` still pins as an array (registered limitation). This is the compiler's first heap: mmap on
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
  accepts a flat static literal (materialized as a dynamic
  child), a dynamic call result or a variable - the value
  MOVES in and the source is nulled (hk66/hk67/hk69,
  t387-t393; Harbour would SHARE a variable element -
  registered difference D5/D7 pending the user's contract
  decision; this does NOT implement sharing). Nested
  literals (a fourth level) stay a named compile error.
  Reading a[i] of a three-level array by value stays a
  named compile error.
- `ValType(x)` returns the one-character type tag (hk88-hk92):
  arrays "A", numbers "N", strings "C", NIL "U". Static types
  classify at compile time; a Dyn casilla classifies at runtime
  (scalar casilla tag 0/1/2 -> "N"/"U"/"C"; child-array casilla
  null/non-null -> "U"/"A"). The argument evaluates once with its
  effects and is borrowed, and it works through a borrowed
  middle-array parameter (t409-t412). Unmeasured shapes are named
  compile errors: a[i] of a three-level array, a user call result,
  a hash (t413-t415).
- The borrowed-argument mechanism works one level deeper: f(a[i])
  on a THREE-level array lends the middle cell's address and the
  callee reads, writes, grows and shrinks through it, visible in
  the caller like Harbour's sharing (hk93-hk96, t416-t419, balance
  0) while the borrow still dies at the return (t421/t422 are
  named compile errors; a NIL casilla is the registered
  "Argument error: PARAM" exit 1, t423).
- A static root array can be passed as an argument: the boundary
  materializes a dynamic COPY the callee owns (hk98 shows Harbour
  would SHARE it - registered D5/D7-family difference pending the
  user's decision, t424-t427, balance 0; deeper pins and literal
  arguments are named compile errors, t428/t429).
- A static root array can be RETURNED: the boundary materializes a
  dynamic COPY the caller owns (hk99; matches Harbour observably
  for the measured shape, t430-t432, balance 0; literal returns and
  array temporaries in expression position are named compile
  errors, t433/t434).
- String arrays move as arguments and returns under the same
  contract (hk101 shows Harbour would SHARE them - registered
  D5/D7-family difference, t435/t437, balance 0; caller reuse after
  the move and read-only callee pins are named compile errors,
  t436/t438).
- Hashes move as arguments and returns under the same contract
  (hk11 shows Harbour would SHARE them - registered D5/D7-family
  difference, t439/t440, balance 0; caller reuse, hash literals as
  arguments and read-only callee pins are named compile errors,
  t441-t443).

Robustness fix in passing: `hb_HKeys` with a non-variable
argument used to panic the compiler; it is now the documented
clean error (t345).

- Codeblocks pass as user-function parameters: `eval` in the callee
  pins the parameter to a block of that arity (hk102: Harbour prints
  42 and returns 44 - our t444 matches exactly; a two-parameter
  shape, t445). A block argument of a different arity and a block
  fed to an integer parameter are named compile errors (t446: the
  conservative exact-arity pin rejects where Harbour would ignore
  extra arguments, probes c7/c7b - registered limitation; t447).
  The block VALUE is copied at the call boundary, so the caller's
  variable stays reusable (t444 prints 10 and balance 0).

- `Array(n, m, k, l)` builds a real four-level value (hk103): len
  at every level, NIL innermost slots, integer reads/writes at the
  fourth level in both the comma and bracket forms (hk104: the
  write evaluates the value first, then the indices left to right;
  hk106: reads left to right), ValType "A"/"U" on the measured
  casillas, balance 0 (t448-t450; new helper hbc_array4m, canaried
  in the ABI harness). Extraction rejections stay named, and five dimensions are a
  named compile error.

- `AAdd(a[i][j][k], x)` / `ASize(a[i][j][k], n)` grow and resize
  the level-3 subarray of a four-level value, in both the comma
  and bracket head forms (hk105: AAdd takes len 2 to 3 with the
  new value in place; ASize shrinking to 1 preserves the first
  element - t454 mirrors it, t456 the bracket form; hk108: AAdd
  evaluates i, then j, then k, then the value, the same
  indices-before-value order measured for the shallower forms -
  t455). Both reject a three-level root with a named compile
  error (t457) and four index levels stay out of this increment
  (t452, repurposed). No new runtime helpers: the generic
  hbc_aadd/hbc_asize operate on the walked level-4 slot; balance
  0 after the owner returns.

- FOR EACH over `a[i][j][k]` on a four-level array borrows the
  level-3 collection for the loop, in both head forms (hk109: the
  elements iterate, the root and the borrowed child survive with
  their lengths - t458, t460 bracket; hk110: the three indices
  evaluate once, left to right, before the first element - t459;
  same eval-once discipline measured for the shallower depths).
  Mutating, moving or growing the root inside the body is a named
  compile error (t462), a shallower root is the accurate named
  rejection (t461), and an out-of-range index at any level is the
  registered bound failure mode, exit 1 (t463; a NIL middle
  casilla cannot occur in this increment's DArr4 - no operation
  nulls one).

- Four-level arrays pass as parameters and return under the MOVE
  contract (hk111: Harbour SHARES the array - the callee's write
  is visible in the caller; registered D5/D7-family difference,
  NO sharing here): the callee reads len at every level and
  writes at the fourth (t464), a returned DArr4 keeps its
  structure (hk112 - t465), the move chains through two callees
  (t467), reassignment frees the old value after the new one
  exists (t470), and `? a` renders empty exactly as Harbour's
  QOut (hk113 - t468). Caller reuse after the move and callee
  reuse after passing the parameter on are named compile errors
  (t466/t469), balance 0 everywhere. This increment also FIXED
  the DArr4 move machinery left incomplete at 33r: the return,
  assignment and call-argument source-slot nulling, the
  callee-side argument copy-in and the caller-side move marking
  all missed DArr4 (a returned or passed four-level array
  crashed or silently mis-ran; those paths had no execution
  tests at 33r - they do now).

- Ownership-transition audit across every supported collection
  type (execution-grounded): reassignment-from-call freeing the
  old value verified live for DArr3, DArrS, Hash and DArr4
  (balance exactly one live array in each probe, Linux and
  Wine); the print-move hole is a named compile error for Hash
  and DArrS; self-assignment `a := a` works on DArr2. No
  soundness hole found outside the DArr4 routes fixed at 33u.
  The audit also closed three DIAGNOSTIC gaps it found: AAdd,
  ASize and indexed assignment on a four-level root (or its
  a[i]) now name the actual limit instead of the misleading
  "`a` is not an array" (t473-t476), and the comma form of a
  two-index AAdd/ASize head, a[1, 2], compiles - measured in
  Harbour (hk115: AAdd(a[1, 2], 9) grows the subarray, ASize
  shrinks it) and routed to the existing, tested AAddSub2 /
  ASizeSub2 machinery (t471 mirrors hk115 with balance 0; t472
  pins the named rejection on a two-level root). The comma form
  previously died with "trailing tokens after expression".

- Static array VARIABLES as whole-array values (a := {1, 2} in a
  local, then a[1] := b / AAdd(a, b) / AAdd(a[1], b)): the checker
  accepted them but codegen only handled the LITERAL path and
  panicked (internal error, three sites). Found by the ownership
  coverage probes, fixed prepublication: the variable's cells are
  COPIED into a fresh dynamic child and the source keeps its
  values (the copy contract of 33l/33m; Harbour SHARES - oracle
  hk116 measures 77 visible through both - registered D5/D7
  difference). t477-t479 pin the copy, the surviving source and
  balance 0.

- ValType over first- and second-level casillas of a four-level
  root (hk114, byte-measured with the hk117 marker probe): "A"
  for a live child array at either level, with the index walk
  evaluated once in order; byte-identical to the Harbour oracle
  (t480). Deeper levels were already covered by hk103.

- FOR EACH over a[i][j] of a four-level root (hk118/hk119,
  byte-measured): the loop variable is a BORROWED flat child
  array (checker types it DArr, codegen uses the DArrRef borrow
  layout - the slot holds the current casilla address). x[j]
  reads, x[j] := v writes THROUGH the shared casilla (visible in
  the caller, hk119), ValType(x) is "A"; the outer variable is
  restored after the loop, naturally or via `exit`. Reseat,
  return, pass and grow are named compile-time rejections.
  t481/t482 are byte-identical to the oracle binaries;
  t483-t485 pin the restrictions and the restore. Nested loops
  over two middles of the same root write through independently
  (t486, byte-identical to oracle hk120). The borrow
  aliases the root's casillas: a write through the loop
  variable is visible reading the root directly, mid-loop
  and after (t487, byte-identical to oracle hk121). `exit`
  inside the inner of two nested middle loops still completes
  the outer loop (t488, hk122), and a later loop over the same
  middle re-borrows it and sees the writes (t489, hk123) -
  both byte-identical to their oracles.

`==` (exact/identity comparison) enters measured scope: between
integers it compares like `=` (hk124; t490, and t293 repurposed
from the old rejection), and between two one-level dynamic array
VARIABLES it is reference identity - a==a .T., a==b .F. even with
equal contents (hk126; t491). `=` on arrays stays a named
rejection (Harbour raises a runtime error dialog, no headless
oracle - hk125 hangs after `==` answers .T./.F.); `==` on static
arrays, strings, deeper arrays, codeblocks and NIL keeps named
rejections (t492): Harbour compares array REFERENCES while our
static arrays are frame copies (D5/D7 family), so an element
compare would answer .T. where Harbour answers .F. Object
identity (cl7/cl19) stays class-gated. Between STRINGS `==` is the
exact comparison (hk124: "a"=="a" .T., "a"=="a " .F., "a "=="a" .F.
- not the prefix rule of `=`; t493) via the new leaf helper
hbc_str_xeq, canaried in the ABI harness on both targets. Against NIL
identity and equality coincide (hk128: NIL==NIL .T., NIL==1/1==NIL/
NIL=="" all .F.; hk129: casilla == NIL answers like `=` - live child
.F., NIL casilla .T.; t494/t495), so `==` reuses the `=` codegen
paths (constant folds, tag dispatch, casilla read). Nested dynamic
array VARIABLES answer identity as well (hk130 for depth 2, hk135
for depths 3 and 4: a==a .T., a==b .F. even with equal contents;
t496/t498/t499 - the frame slot's first qword is the heap pointer
at every implemented depth). hk130's third shape (a==c after c:=a)
is unreachable here by design: assignment MOVES (difference family
D5/D7), so t496 covers only the same-variable and distinct-variable
shapes; the oracle label must not be read as the alias case passing.
Codeblock `==` was admitted at iteration 39 for same-arity variable
pairs and RETRACTED at 39b: later oracles showed Harbour's block
identity is per EVALUATION (hk136: make()==make() is .F.; hk137:
the same literal assigned in two loop iterations is .F.), while our
slot holds a per-literal STATIC pointer that would answer .T. there.
Those shapes are unreachable in today's dialect (blocks cannot be
returned, Dyn cannot be reassigned to Block), but admitting the
operator would bake in a model known to diverge, so `==` on
codeblocks stays a named, truthful rejection (t497 neg).

Dynamic CASILLAS answer `==` by runtime tag dispatch (iteration 40):
string x string is the exact byte compare (hk141, symmetric; hk143
between two casillas - content, not identity), number x number the
value compare (hk138), NIL x NIL .T. and NIL x payload .F. (hk140);
mixed number x string raises Harbour's BASE/1070 (hk139/hk139b/
hk139c/hk142 - error dialog, hangs headless, no oracle), a clean
named exit 1 here: registered failure mode, not exact equivalence.
New leaf helper hbc_dynxeq_dd (canaried in the ABI harness on both
targets) plus the noreturn hbc_dynxeq_error stub; t500-t504 run on
Linux and Wine. The string-casilla shapes measured in hk132/hk133
use indexed-assignment storage that this PoC does not implement
(dynamic-array elements stay tagged int/NIL scalars there); the
expressible producer - FOR EACH over hb_HKeys - is what t500/t501
exercise, exactly as measured in hk141/hk143.

Hash VARIABLES also answer identity (iteration 41; hk134: h==h .T.,
h==k .F. even with equal contents - same slot-pointer model as the
arrays; t505). The BASE/1070 failure mode covers every measured
mixed order (hk142: string casilla == int; hk144: int == string
casilla; hk139b: numeric casilla == string literal - all hang
headless; t504/t506/t507 posx). The hk132/hk133 answers also hold on the expressible string-array surface (iteration 43): Harbour builds the cells with Array(2) and indexed assignment - syntax this PoC rejects, since dynamic-array elements stay tagged int/NIL scalars there - while the dedicated DArrS surface ({} + AAdd, indexed overwrite with the old copy freed) reproduces the measured answers exactly (hk132: 1/0/0/1 as t508; hk133: 1/0/1 as t509); mixed-type arrays stay a named rejection.

Iteration 44 extends `=`/`#` between two DYNAMIC casillas (hbc_dyn_eq):
two string casillas now compare by CONTENT with Harbour's prefix rule
over the right operand's length (oracle hk145: nested FOR EACH over the
same hb_HKeys array - .T./.F./.F./.T. then .F./.F. for `#`; before this
fix they answered .T. for ANY two string casillas by tag alone, a real
divergence caught by the probe). A string casilla against an integer
casilla is Harbour's BASE/1071 "Argument error: =" (hk146 - the dialog
hangs headless, so no headless oracle): clean named exit 1 through the
existing hbc_dyncmp_eq_error stub, registered failure mode, not exact
equivalence (t511 posx). A string casilla against a NIL casilla is .F.
in both directions, no error (hk147; t512). t510/t512 run on Linux and
Wine.

Iteration 45 adds ORDERING between two Dyn casillas (new leaf helper
hbc_dynxcmp, canaried in the ABI harness on both targets): string x
string compares byte-wise over the right operand's length (oracle
hk148: <: .F./.T./.F./.F., >: .F./.F./.T./.F., <=: .T./.T./.F./.T.,
>=: .T./.F./.T./.T.; t513) - before this fix the Dyn x Dyn ordering
path clean-exited on any non-integer casilla. String x integer is the
per-operator Harbour condition BASE/1073/1075/1074/1076 (hk149-hk152
- dialogs hang headless, no oracle): clean named exit 1 via the
existing hbc_dyncmp_*_error stubs, registered failure modes
(t514-t517 posx). NIL in an ordering comparison keeps the registered
type-error failure mode.

Iteration 46 adds hb_HValues(h) (core hb_HValues; oracles hk153/hk154):
a NEW array with the hash's value casillas in insertion order - tagged
int/NIL scalars copied cell by cell, independent of the hash (hk153:
writing the result does not touch the hash; hk154: an earlier snapshot
does not see later growth; empty hash gives an empty array). New
runtime helper hbc_hvalues (same overflow rule as hbc_hkeys), canaried
in the ABI harness on both targets; the hash is borrowed. t518/t519
reproduce the oracles on Linux and Wine; t520 checks the result is
freed by the DArr epilogue (balance 0, own ownership check, same
pattern as t298 - not a Harbour oracle).

Iteration 47 adds hb_HDel(h, key) (core hb_HDel; oracles hk155/hk156):
removes the key's entry - len drops, iteration and lookups skip it, a
missing key (including "") is a no-op, and a deleted key re-added lands
at the END because the remaining entries keep their order (hk156). New
runtime helper hbc_hdel frees the hash-owned key copy and shifts the
remaining entries down; canaried in the ABI harness on both targets; the
lookup key is only borrowed. t521 reproduces hk155 byte for byte on
Linux and Wine; t522 verifies hk156's order and no-op facts with the
values read back through literal keys (the oracle's interleaved h[k]
read with a Dyn `for each` variable stays a named limit of this
increment - reads take Str/StrOwn keys); t523 checks the deleted key
copies are freed (balance 0, own ownership check, same pattern as t298 -
not a Harbour oracle); t524 rejects a non-hash target at compile time.

Iteration 48 adds hb_HHasKey(h, key) (core hb_HHasKey; oracle hk157):
byte-exact, case-sensitive membership - present keys answer true,
missing/prefix/different-case keys and the empty hash answer false, ""
is an ordinary key, and a key deleted with hb_HDel stops answering true.
The dialect has no logical type (its `if` takes only comparisons), so
the PoC surface answers 1/0 - the oracle's .T./.F. printing is the
registered boolean rendering family. New leaf runtime helper
hbc_hhaskey (no allocation, hash and key only read), canaried in the
ABI harness on both targets. t525 reproduces the oracle's nine answers
as 1/0 on Linux and Wine; t526 adds the empty-hash and
borrowed-variable-key cases; t527 rejects a non-hash target at compile
time.

Iteration 49 adds hb_HGet(h, key [, default]) (core hb_HGet; oracles
hk158a-e): an existing key yields its value casilla with or without the
default (hk158a/e); an existing NIL value stays NIL - the default never
overrides it (hk158c). A
MISSING key is the same BASE/1132 condition as an h[k] read miss:
Harbour shows its dialog and hangs headless even WITH a default
(hk158a/b/d), so the PoC prints "Bound error: array access" and exits 1
- the registered failure mode, never a compat success. The default IS
always evaluated - its effects fire on present, NIL and even missing
keys, before the error (hk158f1/f2/f3, t531) - but its value is
discarded: it never rescues a miss and never overrides an existing NIL
(hk158b/c). Reuses the
existing hbc_hget helper (read-only lookup), now with a dedicated ABI
canary on both targets. t528 reproduces the measured reads on Linux and
Wine; t529 pins the missing-key failure mode (exit 1); t530 rejects a
non-hash target at compile time.

Iteration 50 adds hb_HSet(h, key, value) (core hb_HSet; oracles
hk159/hk160/hk161): the functional hash write - append grows len, an
existing key is overwritten in place, NIL roundtrips (hk159). It
evaluates KEY first, THEN the value (hk161) - the OPPOSITE order of
h[k] := v (h4), measured, never inferred. The call returns the hash
itself (hk160: ValType "H"); like AAdd, the statement form is the PoC
surface and the return value is out of scope (registered; printing it
in Harbour renders an empty line - printing a hash is not in this
dialect). Reuses hbc_hput; an owned key temporary is freed right after
the call (t533: wrap + memcheck balance 0, own ownership check, not an
oracle). t532 reproduces hk159's write semantics on Linux and Wine;
t533 pins the evaluation order; t534 rejects a non-hash target at
compile time.

Iteration 51 adds hb_HPos(h, key) (core hb_HPos; oracles
hk162/hk163): the entry's 1-based position among the LIVE entries in
insertion order, 0 when the key is absent ("" is an ordinary key with
no special meaning - hk162). Positions COMPACT after an hb_HDel and a
re-added key goes last (hk163). The new hbc_hpos helper is a leaf that
only reads the hash and the key (canaried in the ABI harness on both
targets); an owned key temporary is freed right after the call (t542:
wrap + memcheck balance 0, own ownership check, not an oracle). t540
reproduces hk162 on Linux and Wine, t541 the compaction of hk163, and
t543 rejects a non-hash target at compile time.

Iteration 52 fixes a real leak found by ownership probing:
hb_HHasKey(h, key) never freed an OWNED key temporary (e.g. an
hb_HKeys element copy - a genuine StrOwn); the balance went 1 over.
The lookup now frees it right after the helper returns, the same
pattern hb_HGet/hb_HSet/hb_HPos already used (t544 pins it with a
genuine element-copy key; a function returning a literal types Str,
not StrOwn, so t533/t535/t542 were rewritten to exercise the free
path with genuine owned temporaries - their expected outputs are
unchanged). No Harbour behaviour changes: this is our own ownership
check (hb_memcheck), not an oracle.

Iteration 53 fixes the same leak pattern in hb_HDel(h, key): an
OWNED key temporary (a genuine StrOwn, e.g. an hb_HKeys element copy)
was never freed around the delete - the balance went 1 over. The
statement now frees it right after hbc_hdel returns (t545 pins the fix
with a genuine element-copy key, balance 0). The StrOwn review matrix
is complete: hash READS by index (h[k]) and indexed writes (h[k] := v)
already freed their temporaries; hb_HGet/hb_HSet/hb_HPos were verified
clean in the 52; hb_HHasKey and hb_HDel were the only two leaking
callers. These are our own ownership checks (hb_memcheck), not Harbour
oracles.

Iteration 54 adds hb_HMerge(dst, src) (core hb_HMerge; oracles
hk164/hk165): every source entry is upserted into the target in
insertion order - the source WINS on an overlapping key and the key
keeps its position, new keys append at the end (hk164); the source is
never mutated, an empty source is a no-op and an empty target just
receives copies (hk165). The call returns the target hash (hk165:
ValType "H"); like hb_HSet, the statement form is the PoC surface and
the return value is out of scope (registered). Both arguments are hash
VARIABLES in this surface (hk165's inline empty-literal form is a
named surface limit, not a semantic difference). The new hbc_hmerge
helper upserts through hbc_hput, copying every key and value
(canaried in the ABI harness on both targets). t546 reproduces hk164
on Linux and Wine, t547 the hk165 edges, t548/t549 reject non-hash
arguments at compile time.

Iteration 61 adds hb_HGetDef(h, key [, default]),
hb_HSetDef(h, key [, default]) and hb_HCopy(src, dst [, start
[, count]]) (core hb_HGetDef / hb_HSetDef / hb_HCopy; oracles
hk194-hk196d). hb_HGetDef is hb_HGet without the miss error: a
hit returns the value, a miss returns the default WITHOUT adding
the key - or NIL with no default (hk194) - so the HGet-miss
dialog family never arises here. hb_HSetDef is an expression
with an effect: an absent key is added (the default, or NIL
with none) and returned; a present key returns its stored value
and is overwritten ONLY when the stored Dyn tag differs from
the default's (hk196: same tag keeps; hk196b: stored NIL +
integer default overwrites; hk196d - measured this iteration:
a present key with NO default is always kept). hb_HCopy is a
statement that upserts the src range [start, start+count) into
dst through hbc_hput: new keys append, existing ones are
overwritten, untouched dst entries survive (hk195); start
0/missing is 1, start > len and count 0 are no-ops, a long
count clips at len (hk195b/hk195c). A NEGATIVE start is
Harbour's BASE/1123 dialog family (hk195d, probed this
iteration) - the registered clean bound-error exit, never a
compat target. hb_HCopy(h, h) - Harbour's runtime self-copy
error 9020 (hk195b) - is a named COMPILE-TIME rejection in
this dialect, since aliases cannot arise. New helpers:
hbc_hsetdef (frame-based; the add/keep/overwrite decision via
hbc_hget + hbc_hput) and hbc_hcopy (frame-based; the ranged
upsert loop over hbc_hput); hb_HGetDef needs no helper - its
codegen calls hbc_hget and falls back to the saved default
cells on a miss. t589 reproduces hk194 (hit, miss with and
without default, no auto-add); t590 the owned-key-copy path
(ks[i] borrowed and freed, wrap + memcheck = 0); t591 a
Dyn-cell default from an array element; t592 hk196; t593
hk196b (NIL overwrite, NIL add without default); t594 hk196d
(present key, no default); t595 hk195 (slice, edges, upsert);
t596/t597 hk195b/hk195c (no-op edges, clip); t598 the named
self-copy rejection.

Iteration 62 adds Harbour logicals as a real type (oracles hk197-hk204,
measured against core at 694428e1): the dotted words .T. and .F.
(literals), .AND. / .OR. / .NOT. (operators) - case-insensitive, no
inner spaces, closing dot required (hk199c: .NOT..F. is valid). Every
comparison now PRODUCES a logical (ValType "L", printed as .T./.F. -
hk198), so `? 1 = 1` prints .T. like Harbour, not 1. Logicals store in
variables, pass as parameters and return from functions (hk204);
.AND./.OR. short-circuit by effects (hk203); the lexer speaks dotted
words and the parser adds and_expr/or_expr precedence levels above
comparisons. Rejections are differentiated and measured: bare
AND/OR/NOT words are not operators in Harbour either (E0030, hk199) -
a named compile-time error, not a silent keyword; trailing tokens
after an expression stay the generic parser error; a logical compared
against a non-logical under `=`/`#`/`==` is Harbour's BASE/1071
(hk202) and stays a compile-time rejection here. Ordering comparisons
on logicals are unmeasured and stay rejected. Parameter inference is
body-only, so a bare returned logical parameter is not inferable
(registered limit; t602 shapes the identity through `.AND. .T.`).

Iteration 62b closes the Dyn side of logicals (oracles hk201 and
hk205-hk208e, same pinned core): array and hash casillas carry a new
tag 3 (logical), so a tagged cell can hold .T./.F. end to end. The
write paths tag it: AAdd growth, casilla overwrite (a[i] := .T.,
h[k] := .T.), hash literals ({ "a" => .T. }), hb_HSetDef values,
hb_HGetDef defaults, hb_HScan search values and hb_HFill fill values.
A flat literal mixing logicals and integers ({ .T., .F., 1 })
materializes as a dynamic tagged array (hk201) - restricted to all-
literal elements in this increment, a registered limit. The read
paths honor it: printing shows .T./.F., ValType says "L"
(hash casillas included; a missing key is Harbour's BASE/1132-family
error condition - hk209, the dialog hangs headless - so it takes the
registered clean bound-error exit, not a silent "U" read), hb_HClone and hb_HValues preserve logical cells,
and hb_HCopy (source first, hk208e) copies them. Two runtime fixes
came with the tag: hbc_dyn_eq compared only tags for nonzero
non-string tags, so .T. = .F. was wrongly .T. - it now compares
payloads (t608 pins both directions); and a Dyn in condition
position (IF/WHILE, .AND./.OR./.NOT. operands, the condition of a
comparison-free jump) materializes through a new hbc_dyn_to_log:
a logical cell keeps its payload; NIL, an integer or a string cell
in condition position is Harbour's error condition (hk210, the
dialog hangs headless) and takes the registered clean exit 1 here. A Dyn compared against a logical
(`h["b"] = .T.`) dispatches at runtime through the same equality
helper. The 62 scope note stands: the builtin flag APIs (hb_HHasKey,
hb_HCaseMatch, IsAlpha and family) KEEP their registered 1/0
integer surface - hk205's hb_HHasKey prints .T. in Harbour, 1 here,
registered.
Scope note: the logical type covers literals, comparisons and the
dotted operators - the builtin flag APIs (hb_HHasKey, hb_HCaseMatch,
IsAlpha and family) KEEP their registered 1/0 integer surface (their
.T./.F. in Harbour is the long-standing boolean rendering family).
A consequence to register: comparing such a flag against 1 yields
.T. here, while Harbour's logical-returning original raises
BASE/1071 on the mixed comparison (the hk202 family, from the
integer-flag surface).
t599 reproduces hk197 (literals, printing, ValType); t600 hk198
(comparisons produce logicals); t601 hk203 (short-circuit by
effects); t602 hk204 (parameters and returns); t606 hk199c/hk200
(case-insensitive dotted forms, .NOT..F.); t607 a logical variable
reassigned and branched on; t608 hk201 (mixed literal, Dyn logical
equality both ways); t609 hk205 (hash writes and comparisons);
t610 hk206 (hb_HSetDef overwrite on tag difference, hb_HScan finds
a logical); t611 hk207 (hb_HClone/hb_HValues preserve logicals);
t612 the AAdd/ArrSet part of hk208; t613 hk208e (hb_HCopy source-
first, hb_HFill with a logical); t614 the alloc/free balance of
logical-casilla structures (wrap + memcheck 0 after the owners are
freed); t615/t616 pin the missing-key
error contract (ValType and plain read, hk209/hk209b - clean
bound-error exit 1, never a silent read); t617 the NIL-casilla
condition contract (hk210 - clean exit 1 via hbc_dyn_to_log); t618
a bare logical casilla branching in if/while; t603/t604/t605 pin
the three rejection
families.

Iteration 63a opens the upstream examples front: PROCEDURE is a
function keyword (Harbour semantics; a RETURN <expr> inside one is a
registered difference, unmeasured) and identifiers are
case-insensitive, normalized at the token level - MAIN/Main/main,
QOut/qout and locals in any casing are one name (t619). Message
casing in two existing neg expectations (t88, t603) follows the
normalization; semantics unchanged. hello.prg from the upstream
test suite (core 694428e1) is the FIRST original program that
compiles and runs byte-identical to Harbour. Forward references
(call before definition) remain the next registered blocker.
Battery: 623/623 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.


Iteration 60 adds hb_HClear(h) and hb_HFill(h, value) (core
hb_HClear / hb_HFill; oracles hk191-hk193): hb_HClear empties the
hash - every key copy is freed, the data block is released and the
slot goes back to (0, 0), leaving the hash reusable (hk191: a new
write after the clear works; a read on a cleared hash is the
registered HGet-miss dialog family, not a compat target). The
CaseMatch flag resets to the default case-sensitive on the next
write after a clear (hk193: hb_HCaseMatch is .T. again and a
mismatched-case lookup no longer hits), and clearing an empty or
already-cleared hash is a no-op. hb_HFill overwrites the VALUE of
every entry with the given one - keys, count and insertion order
survive (hk192: an integer over everything including a stored NIL,
NIL over everything); filling an empty hash is a no-op. Both are
statements in the PoC surface (their return values stay out of it,
like hb_HDel's); a non-hash argument is a named compile-time
rejection in this increment, as is a non-integer/non-NIL fill value.
New helpers: hbc_hfill (leaf, no allocation, writes the {tag,
payload} pair into every entry) and hbc_hclear (frame-based: frees
every key copy, releases the block through hbc_hfreeblock, resets
the slot); both are canaried in the ABI harness on both targets and
hbc_hclear's frees are exercised against the instrumented
allocation registry. t584 reproduces hk191/hk193 on Linux and Wine
(clear, reuse, flag reset); t585 hk192 (fill over integers and a
stored NIL, NIL fill, empty-hash no-op); t586 is the ownership
check (clear of owned key copies, wrap + memcheck = 0, own check);
t587/t588 are the named rejections (non-hash clear target,
non-scalar fill value).


Iteration 59 adds hb_HDelAt(h, n) (core hb_HDelAt; oracles
hk187-hk190): removes the entry AT the 1-based insertion-order
position n - positions compact and insertion order is preserved
(hk187), deleting the only entry empties the hash (hk190). The
statement is the PoC surface (the returned hash is out of it, like
hb_HDel's). EVERY out-of-range position (0, past the end, negative)
is Harbour's BASE/1187 dialog, which hangs headless (hk189, separate
binaries): the registered dialogo-sin-oraculo family - the PoC takes
the same clean bound-error exit, never a compat success. A float
position truncates in the oracle (hk190) and stays outside this
dialect's numeric syntax. The CaseMatch flag is irrelevant:
matching is positional. New frame-based helper hbc_hdelat (shared
blob, both targets) frees the deleted entry's key copy, shifts the
entries above down and drops the live count; canaried in the ABI
harness on both targets. t580 reproduces hk187/hk190 on Linux and
Wine; t581 is the ownership check (deleted key copy freed, wrap +
memcheck = 0); t582/t583 are the named rejections (non-hash target,
non-integer position). Measured note: hb_HPairAt returns a MIXED
{key, value} array (hk188: ValType "A", {"ab", 42}), outside this
increment's array support, so it stays out of the surface -
verified, not assumed.

Battery: 579/579 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.

Iteration 58 adds hb_HKeyAt(h, n) and hb_HValueAt(h, n) (core
hb_HKeyAt/hb_HValueAt; oracles hk184-hk186): the key / value
casilla at the 1-based insertion-order position n (positions COMPACT
after a delete - hk186; a stored NIL comes back as NIL - hk185).
EVERY out-of-range position (0, past the end, negative) is Harbour's
BASE/1187 dialog, which hangs headless (hk184/hk185, separate
binaries): the registered dialogo-sin-oraculo family - the PoC takes
the same clean bound-error exit as an h[k] miss, never a compat
success. Float indices truncate in the oracle (hk186) and stay
outside this dialect's numeric syntax. New leaf helpers
hbc_hkeyat/hbc_hvalueat (shared blob, both targets) are canaried in
the ABI harness on both targets. hb_HKeyAt returns an OWNED copy of
the key (hbc_strcpy): it survives the hash (t576, wrap + memcheck =
0, own ownership check). t574/t575 reproduce hk184-hk186 on Linux
and Wine; t577-t579 are the named rejections (non-hash target,
non-integer position).

Battery: 575/575 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.

Iteration 57 adds hb_HScan(h, value [, start]) (core hb_HScan;
oracles hk178-hk183): the 1-based position in insertion order of
the first entry whose VALUE equals the argument, 0 when absent; the
optional start is inclusive and scans from that position
(hk178/hk180), and an omitted start, NIL or an explicit 0 all scan
from the first entry while a negative start or one past the last
entry finds nothing - no error (hk179/hk182). Values are the tagged
int/NIL scalars of this increment: a stored NIL matches a NIL
argument (hk180); float start truncation (hk183) is outside the
dialect's numeric syntax. The CaseMatch flag is irrelevant to
hb_HScan in this increment - it compares VALUES, and string values
are outside the measured scope (registered limit, no claim). A
missing value argument is Harbour's BASE/1123 dialog (hk182): the
registered dialogo-sin-oraculo family, never a compat target. New
leaf helper hbc_hscan (shared blob, both targets) is canaried in
the ABI harness on both targets. t568-t570 reproduce hk178-hk180 on
Linux and Wine; t571-t573 are the named rejections (non-hash target,
non-integer start, string scan value).

Battery: 569/569 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.

Iteration 56 adds hb_HCaseMatch(h) and hb_HSetCaseMatch(h, flag)
(core hb_HCaseMatch/hb_HSetCaseMatch; oracles hk169-hk176): a per-hash
key-matching flag, default SENSITIVE (the getter prints 1/0 - the
dialect has no logical type; the oracle's .T./.F. is the registered
boolean rendering family). In insensitive mode lookups (h[k] read and
write, hb_HGet, hb_HHasKey, hb_HPos, hb_HDel, hb_HSet) and hb_HMerge
into that hash match keys case-insensitively, acting on the LAST
insertion-order match (hk171/hk172/hk174); a case-variant write
overwrites in place WITHOUT changing len and the stored key keeps its
original casing (hk170); hb_HMerge obeys the DESTINATION's flag - the
source's flag is irrelevant (hk175); hb_HClone propagates the flag,
even for an empty flagged hash (hk173/hk176). The flag lives in the
hash data block's new 16-byte header [flags][capacity], released by
the new per-target hbc_hfreeblock; folding is ASCII letters only -
the measured scope of the oracles (registered limit). One registered
edge: hb_HGet on a MISSING key stays the named failure family already
registered (hk177 confirmed the dialog also fires in insensitive
mode); no claim is made for non-ASCII case folding. New helpers
hbc_hcasematch/hbc_hsetcasematch are canaried in the ABI harness on
both targets, which also exercises hbc_hfreeblock on a header-only
block. t556-t563 reproduce hk169-hk176 on Linux and Wine; t564 checks
owned key temporaries through the insensitive compare path and full
balance including a header-only block (wrap + memcheck = 0, own
ownership check); t565-t567 are the named rejections (non-hash target,
non-integer flag, subscript target).

Battery: 563/563 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.

Iteration 55 adds hb_HClone(h) (core hb_HClone; oracles
hk166/hk167): a NEW hash whose entries are copied - fully
independent in both directions (writes on the original do not cross
into the clone, writes on the clone do not cross into the original,
hk166) in the same insertion order with NIL values preserved; an
empty hash clones to an empty one (hk167). Scope of "independent":
the entry KEYS (re-copied strings) and the scalar integer/NIL values
- the only value types this increment admits in hashes; composite
values (arrays or hashes as values) are not supported here
(registered limit), so no claim is made about nested structures. The new hbc_hclone helper
re-copies every key and value through hbc_hput (canaried in the ABI
harness on both targets); the source is borrowed. t550 reproduces
hk166 on Linux and Wine, t551 the order/NIL/empty edges of hk167,
t552 the independent freeing of clone and source (balance 0, own
ownership check), t553 rejects a non-hash target. The same iteration
covers two hb_HMerge edges asked in review: self-merge hb_HMerge(h,
h) is a clean no-op (hk168: len, values and positions unchanged;
t554), and merged entries stay valid after the SOURCE hash is freed
(t555: deep key copies, balance 0, own check).

Battery: 551/551 manifest cases on Linux x86-64 and Wine, plus
the ABI harness.
