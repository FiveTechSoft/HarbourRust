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
- `return` stays at the function top level (`tests/t27_while_return.hb`).

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
return <expr> | return nil closes the function  (top level only)
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
- `exit`/`loop` statements, `for` loops and early returns: `while` runs
  to its condition, and `return` stays at the function top level.
- String comparisons and a first-class boolean: conditions compare
  integers only.
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
