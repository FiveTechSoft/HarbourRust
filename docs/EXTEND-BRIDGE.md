# Extend-System bridge (C API) - milestone 1, Linux

HarbourRust calls C extension functions through a thin bridge: the
Harbour side declares the function `EXTERNAL`, the C side defines it
with `HB_FUNC`, and the link joins the hbc-generated object, the
extension object and `hbhbr.o` (the bridge runtime). All of our side is
own MIT code (`extend/hbhbr.h`, `extend/hbhbr.c`, the emitted thunk and
dispatcher); Harbour's hbmk2 is the user's external tool, never copied.

## Harbour side

```
EXTERNAL HBR_ADD, HBR_SHOUT        // file scope, comma-separated list

function main()
   ? hbr_add(20, 3)                // calls the C HBR_ADD
   return nil
```

- Any arity: omitted arguments read NIL in C (`hb_pcount` reports the
  supplied count), like Harbour.
- A name also defined in the file is inert: the Harbour definition wins
  (same rule as `REQUEST` of a local symbol).
- Argument types that marshal in this increment: integer, logical,
  string, NIL and Dyn values holding one of those. Arrays, hashes,
  codeblocks, floats, dates and `@` by-reference arguments are compile
  time named rejections; a Dyn-held array fails at runtime with the
  registered clean type error.
- Strings cross as owned clones made at the boundary; the C side only
  borrows them during the call. Values returned with `hb_retc`/
  `hb_retclen` arrive as owned strings the Harbour caller releases with
  the usual Dyn discipline: no leaks, no double frees, no aliasing.

## C side

```c
#include "hbhbr.h"

HB_FUNC( HBR_ADD )
{
    hb_retnl( (long) hb_parni( 1 ) + (long) hb_parni( 2 ) );
}
```

Milestone-1 API (`extend/hbhbr.h`): `hb_pcount`, `hb_parinfo` (with
`hb_parinfo(0)` = count), `hb_param`, `hb_extIsNil`, `hb_parni`,
`hb_parnl`, `hb_parl`, `hb_parc`, `hb_parclen`, and the return family
`hb_ret`, `hb_retl`, `hb_retni`, `hb_retnl`, `hb_retc`, `hb_retclen`;
type-test macros `HB_ISNIL`, `HB_ISCHAR`, `HB_ISNUM`, `HB_ISLOG`; the
`HB_IT_*` constants carry Harbour's own values so extension code tests
types identically. `hb_parc` returns a NUL-terminated scratch copy valid
until the C function returns (Harbour-like lifetime); use `hb_parclen`
for embedded-NUL-safe access.

Oracle-pinned semantics (contrast against real Harbour, 2026-11-13):

- `hb_parc`/`hb_parclen` on a non-string argument (number, NIL,
  omitted) return `NULL`/`0` - extension code does compare against
  NULL.
- `hb_param(i, HB_IT_ANY)` is non-NULL for an argument PRESENT with
  value NIL and NULL for an omitted one; `hb_param(i, HB_IT_NIL)` is
  NULL in both (HB_IT_NIL is 0, same as Harbour).
- `hb_retc(NULL)` / `hb_retclen(NULL, 0)` return the EMPTY string
  (ValType "C"), not NIL.
- `hb_parinfo` types a whole number HB_IT_INTEGER inside the 32-bit
  range (42 -> 2, 2147483647 -> 2, -2147483648 -> 2) and HB_IT_LONG
  beyond it (2147483648 -> 8, -2147483649 -> 8).

Function names are matched case-insensitively (Harbour names are
case-insensitive); write the HB_FUNC name in uppercase by convention.

## Build

```
# bridge runtime (once; freestanding, no libc)
gcc -c -O2 -ffreestanding -fno-stack-protector -Iextend extend/hbhbr.c -o hbhbr.o

# program + extension
hbc app.hb app.s --target=linux
as -o app.o app.s
gcc -c -O2 myext.c -Iextend -o myext.o
ld -o app app.o myext.o hbhbr.o
```

With the official external hbmk2 (verified 2026-11-13 on the pinned
toolchain):

```
hbmk2 myext.c app.o hbhbr.o -nohblib \
      -ldflag=-nostdlib -ldflag=-no-pie -ldflag=-Wl,-e,_start -o app
```

Caution when checking an hbmk2 run: `hbmk2 file.hb` as the FIRST
argument RUNS the file as a script with Harbour and can fake a PASS on
stdout. Always verify the produced binary (existence, format, run),
never the trace alone. `.hb` sources are compiled by `hbc` + `as`
first; hbmk2 receives the resulting `.o` files (also listable in an
official `.hbp`).

## Not in milestone 1 (named limits)

- Doubles/f64 (Dyn tag 5 stays reserved), dates, arrays, hashes and
  codeblocks across the boundary; `@` by-reference (`hb_parbyref`);
  callbacks into Harbour code (`hb_vmEvalBlock`); `hb_errRT` error
  recovery. Each fails closed at compile time or as a registered clean
  runtime error.
- Windows: the bridge is Linux-only in this increment (hbc rejects
  `EXTERNAL` with `--target=windows`).
- Embedded C (`#pragma BEGINDUMP`/`ENDDUMP`): hbc rejects it with an
  explicit diagnostic - hbc has no C stage. Future milestone through
  hbmk2: extract the C block and compile it as a separate unit (the
  flow Harbour users already follow with a C compiler), linking the
  result through this same bridge.
- An extension object that calls libc needs libc at link time; the
  default flow is no-libc, so milestone-1 extensions are freestanding C
  (as is `hbhbr.o`).

## Mechanics (for reviewers)

- hbc marshals each argument to a 16-byte Dyn casilla `{tag, payload}`
  (tags: 0/9 integer, 1 NIL, 2/3/4 borrowed/logical/owned string;
  string payload points at bytes, length word at payload-8), pushes
  them left to right, adds an argc slot and calls a per-symbol thunk
  `hbc_fn_<name>`, which forwards name/argc/argv to `hbc_ext_dispatch`.
- `HB_FUNC(NAME)` places a `{name, fnptr}` entry in the `hbhbr_funcs`
  linker section; the dispatcher walks it between the GNU-ld-provided
  `__start_hbhbr_funcs`/`__stop_hbhbr_funcs` bounds and calls the match
  with a SysV-aligned stack. An unmatched name is a clean exit-1
  diagnostic (`error: external function not found: NAME` + callstack).
- `hbhbr.o` keeps the bridge state (argc/argv/return slot) and the
  hb_parc scratch arena (freed after each call); `hb_retclen` copies
  through the runtime's own `hbc_strcpy`, so the returned string is an
  ordinary hbc-owned string.
