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
- Argument types that marshal: integer, logical, string, NIL, scalar
  f64 (since milestone 2.3, as tag-5 Dyn casillas), Dyn values holding
  one of those, `@` by-reference over a Dyn local (since milestone
  2.2), and Dyn-held arrays READ-ONLY (since milestone 2.4). Statically
  typed arrays, hashes, codeblocks and dates are compile time named
  rejections, and Dyn-float arithmetic in .prg code is the pending
  numeric-tower unification (milestone 2.3 notes).
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

API surface (`extend/hbhbr.h`): every public name and signature is
aligned with the pinned Harbour headers (harbour/core @694428e:
include/hbapi.h and include/hbapiitm.h; the header line is cited next
to each declaration in hbhbr.h). Parameters: `hb_pcount` (hbapi.h:683),
`hb_parinfo` (:628, with `hb_parinfo(0)` = count), `hb_param`
(:630), `hb_parni` (:648), `hb_parnl` (:650), `hb_parl` (:645),
`hb_parc` (:636), `hb_parclen` (:638). Returns: `hb_ret` (:684),
`hb_retl` (:697), `hb_retni` (:699), `hb_retnl` (:700), `hb_retnd`
(:698), `hb_retc` (:685), `hb_retclen` (:689). Items: `hb_itemNew`
(hbapiitm.h:106), `hb_itemRelease` (:140, HB_BOOL), `hb_itemType`
(:145, HB_TYPE), `hb_itemGetNI/NL/ND/L/C` (:98/:99/:96/:94/:86),
`hb_itemGetCLen` (:88 - length; this is the ONLY hb_itemGetCLen),
`hb_itemCopyC` (:82 - buffer copy, min(len,max) bytes, NO terminator),
`hb_itemPutNI/NL/ND/L/C/CL` (:125/:126/:124/:123/:110/:111 - all
return the same PHB_ITEM), `hb_itemReturn` (:141 - COPIES the value;
the item keeps it, oracle-pinned), `hb_xfree` (hbapi.h:490). Arrays:
`hb_arrayLen` (:795), `hb_arrayGetItemPtr` (:809), `hb_parinfa`
(:629), `hb_arrayGetType/NI/NL/ND/L/C/CLen` (:827/:818/:819/:822/
:817/:811/:813). Byref stores: `hb_storc` (:755), `hb_storclen`
(:756), `hb_storl` (:762), `hb_storni` (:763), `hb_stornl` (:764),
`hb_stornd` (:766) - VALUE FIRST, int return (1 written, 0 not
byref). Type-test macros `HB_ISNIL`, `HB_ISCHAR`, `HB_ISNUM`,
`HB_ISLOG`, `HB_ISBYREF` (:232), `HB_ISARRAY` (:233), `HB_ISBLOCK`
(:235). The `HB_IT_*` constants carry Harbour's own values (hbapi.h
:70-100: NIL 0x0, POINTER 0x1, INTEGER 0x2, HASH 0x4, LONG 0x8,
DOUBLE 0x10, DATE 0x20, LOGICAL 0x80, SYMBOL 0x100, STRING 0x400,
MEMOFLAG 0x800, BLOCK 0x1000, BYREF 0x2000, ARRAY 0x8000, ANY
0xFFFFFFFF). HarbourRust's own extensions (no Harbour twin, marked in
hbhbr.h): `hb_extIsNil`, and the one-hop byref read-through inside the
`hb_array*` readers. Harbour has NO `hb_parna`/`hb_parbyref` - the
canonical patterns are `hb_param(i, HB_IT_ARRAY)` + `hb_arrayGet*` and
`HB_ISBYREF(i)`. `hb_parc` returns a NUL-terminated scratch copy valid
until the C function returns (Harbour-like lifetime); use `hb_parclen`
for embedded-NUL-safe access.

Milestone 2.1 (PHB_ITEM item API, 2026-11-13):

- A PHB_ITEM here is a borrowed pointer to an hbc stack casilla (the
  Harbour item ABI is reduced to pointer semantics - named limit).
  `hb_itemNew` copies any source item into a caller-owned casilla
  (freestand alloc); `hb_itemRelease` (HB_BOOL) releases it.
  `hb_itemPut*` overwrite in place, releasing an old owned string;
  `hb_itemGet*` read; `hb_itemType` returns the HB_IT_* type.
  `hb_itemPutL` accepts any nonzero as true. `hb_itemNew(NULL)`
  builds a NIL item.
- ORACLE-PINNED (694428e): `hb_itemReturn` COPIES the value into the
  return channel - the item KEEPS its value and `hb_itemGetC` still
  answers afterwards; it is not destructive. `hb_itemCopyC` copies
  min(len, max) bytes WITHOUT a NUL terminator and returns the count;
  `hb_itemGetCLen` is the one-argument length. `hb_itemGetC` on a
  non-string is NULL, on an empty string a NON-NULL alloc; the
  returned copy is released with `hb_xfree`. `hb_itemPut*` return the
  same PHB_ITEM.
- The return channel frees a previous owned string before each new
  value, so repeated `hb_retc*` calls inside one C function no longer
  leak (peak RSS of a 5M-call loop probe: 68 kB, was ~140 MB before
  this fix).
- Named limits: item identity is borrowed - a casilla may be retyped
  by the runtime (Harbour allocates fresh items); no item locking,
  timestamps or serialization; `hb_itemCopyC`/`hb_itemGetCLen` on a
  non-string are 0; no `hb_itemNew` of an array (needs recursive cell
  alloc) until milestone 2.4's write side lands.
- Probes: extend/demo/apiitem.c + apiitem.prg (KEEP/COPYC/GETCEMPTY/
  LOOPRET exercise the pinned semantics; build like the m1 demo).

Milestone 2.2 (@ by reference, 2026-11-13):

- `@x` crosses when x is a Dyn (NIL-able) local; the C side receives a
  marker casilla whose payload is the ADDRESS of the caller's casilla.
  `@` on a statically-typed local or a non-local stays a named
  compile-time rejection.
- hb_par* read through the reference; hb_parinfo ORs HB_IT_BYREF over
  the referred type; test byref with HB_ISBYREF(i) (Harbour's own
  macro, hbapi.h:232 - Harbour has no hb_parbyref). ORACLE-PINNED
  (694428e): parinfo(@string) = 9216 (HB_IT_BYREF|HB_IT_STRING).
- hb_storc/clen/l/ni/nl/nd write the caller's value through the
  reference with Harbour's exact signatures (value first, int
  return), releasing an old owned string payload first; on a
  non-byref argument they are a no-op. ORACLE-PINNED (694428e):
  hb_storc returns 1 over @s and 0 without byref. Strings stored are
  hbc-owned copies the caller's Dyn discipline releases.
- Named limit: hb_stor* over a @ holding a Dyn ARRAY is a registered
  clean rejection (exit 1, named message) - overwriting would orphan
  the array block and freeing needs a recursive walk. Probe:
  extend/demo/apistorref.c + .prg.
- Demo: extend/demo/apiref.c + apiref.prg.

Milestone 2.3 (f64 at the boundary, 2026-11-13):

- A Harbour float literal or expression crosses as a tag-5 Dyn casilla:
  the payload IS the 8 value bits (scalar; no allocation, no metadata).
- `hb_parnd(i)` reads integers as (double) and doubles bit-exact; a
  non-numeric argument answers 0.0. `hb_retnd(d)` returns a double.
- `hb_parnl(i)` on a double truncates like Harbour's (long) read.
- `hb_parinfo(i)` on a double answers HB_IT_DOUBLE (16); HB_ISNUM
  therefore covers doubles.
- ValType of a Dyn-held double is "N".
- Printing a Dyn-held double uses dec 2 (hb_itemPutND's default in
  Harbour) and the HB_DBL_LENGTH width rule (10, or 20 beyond
  +/-9999999999). ORACLE-PINNED against real Harbour (pin 694428e,
  2026-11-13), byte-exact: `?` of an hb_retnd double pads to the
  10-column field with dec 2 ("         3.14"), keeps the trailing
  zero ("         3.50"), and the 20-width rule yields exactly 23
  columns for 12340067895.00; hb_parnl truncates toward zero
  (3.14 -> 3, -3.14 -> -3); hb_parinfo answers 16; HB_ISNUM is .T.
- NOT in this slice: Dyn-float arithmetic in .prg code (`p * 2` where p
  holds a C double) still raises the clean type error; that unification
  is the Dyn numeric tower decision (H2 architecture note).
- Demo: extend/demo/apif64.c + apif64.prg (build like the m1 demo).

- A double's DECIMAL COUNT crosses with the value (it rides in the tag
  word's high bits of the tag-5 casilla, an internal representation
  invisible through the masked hb_* API): echoing a literal 3.5 back
  through hb_itemReturn prints "3.5" byte-exact like the native `?
  3.5`, while a C-constructed double (hb_retnd / hb_itemPutND) keeps
  the dec-2 default. ORACLE-PINNED (694428e, HBR_ECHO row of the
  combined round). Probe: extend/demo/apiecho.c + apiecho.prg.

Milestone 2.4 (arrays, read-only, 2026-11-13):

- A Dyn-held array (tag 8: element count at payload-8, 16-byte
  {tag,payload} cells at payload) crosses as its BORROWED casilla. The
  caller keeps ownership; the C side never frees, resizes or stores.
- `hb_itemType` / `hb_parinfo` report HB_IT_ARRAY ("A");
  `hb_param(i, HB_IT_ARRAY)` is non-NULL, other type masks NULL.
- The canonical Harbour pattern works unchanged: `a = hb_param(i,
  HB_IT_ARRAY)` then `hb_arrayLen(a)` (0 on a non-array, an empty
  array or NULL), `hb_arrayGetNL/L/ND/NI/C/CLen/Type(a, n)` (1-based)
  or `hb_arrayGetItemPtr(a, n)` plus the milestone-2.1 item API -
  NULL on an out-of-range index. `hb_parinfa(i, 0)` is the length and
  `hb_parinfa(i, n)` the element's HB_IT_* type. (Harbour has no
  `hb_parna`; it was dropped from this surface.) The `hb_array*`
  readers follow ONE byref hop, so the same code works on `@a`.
- Named limits of 2.4: STATICALLY TYPED arrays (DArr slots keep
  CAPACITY at payload-8, not the count - marshalling them as tag 8
  would lie about the layout) stay compile-time named rejections;
  array mutation, resize, `hb_itemNew` of an array and array return
  values are not in this increment; NESTED Dyn-held arrays cannot be
  built on the .prg side yet (a `{1, {7, 8}}` literal into a Dyn local
  is a named rejection), so the tag-6 subarray recursion of
  `hb_arrayGetItemPtr` shares the verified flat path but has no
  end-to-end probe in this slice.
- Demo: extend/demo/apiarr.c + apiarr.prg (build like the m1 demo).

Milestone 2.5 (callbacks: codeblocks across the bridge, 2026-11-13):

- A codeblock argument whose body returns an INTEGER crosses as a
  tag-7 Dyn casilla {7, codeptr}; hb_itemType / hb_parinfo report
  HB_IT_BLOCK ("B", 0x1000) and HB_ISBLOCK(i) answers true. A
  NIL-returning block is a compile-time named rejection (the C side
  cannot tell a raw i64 from the NIL Dyn pair without compile-time
  knowledge, so the boundary enforces BRet::Int).
- The hb_eval* family mirrors the pinned header exactly
  (hbapiitm.h:57-68): HB_EVALINFO is a CALLER-ALLOCATED struct
  { HB_USHORT paramCount; PHB_ITEM pItems[10]; } (HB_EVAL_PARAM_MAX_
  9), not an opaque pointer. hb_evalNew(&info, pBlock) -> HB_BOOL
  (0 on a non-block item), hb_evalPutParam(&info, pItem) appends one
  INTEGER parameter (anything else is a named rejection with exit 1;
  the 10th parameter returns HB_FALSE - Harbour's own frame limit),
  hb_evalLaunch(&info) runs the block and returns the integer result
  as a NEW OWNED item, hb_evalRelease(&info) clears the frame.
- The block runs through hbc_blk_launch, a standalone asm trampoline
  with an explicit ABI (rdi=codeptr, rsi=value array, rdx=count): it
  pushes the 16-byte {value, meta=0} slots left to right with hbc's
  own block convention (param k of n at 16*(n-k)(%rbp)) and restores
  its rbp-anchored frame BY ADDRESS, so nothing the block clobbers
  can unbalance the caller. Read-only like the rest of the bridge:
  the block runs within the C function's lifetime, no state persists.
- Probes: extend/demo/apieval.c + apieval.prg (2-integer eval round
  trip, parinfo 4096, HB_ISBLOCK), apievalnil.prg (compile-time
  rejection), apievalbad.c + apievalbad.prg (runtime named rejection).

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
- `hb_itemType` of a double is HB_IT_DOUBLE (16). A @string argument:
  `hb_parinfo` = 9216 (HB_IT_BYREF | HB_IT_STRING), `hb_itemType` =
  HB_IT_STRING (1024).
- `hb_storc` returns 1 over a byref argument and 0 on a non-byref one
  (the whole hb_stor* family shares the value-first, int-returning
  shape).

Function names are matched case-insensitively (Harbour names are
case-insensitive); write the HB_FUNC name in uppercase by convention.

## Build

```
# bridge runtime (once; freestanding, no libc)
gcc -c -O2 -ffreestanding -fno-stack-protector -Iextend extend/hbhbr.c -o hbhbr.o

# program + extension
hbc app.prg app.s --target=linux
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

Caution when checking an hbmk2 run: `hbmk2 file.prg` as the FIRST
argument RUNS the file as a script with Harbour and can fake a PASS on
stdout. Always verify the produced binary (existence, format, run),
never the trace alone. `.prg` sources are compiled by `hbc` + `as`
first; hbmk2 receives the resulting `.o` files (also listable in an
official `.hbp`).

### Windows (milestone 2.6)

The same sources build for `--target=windows` with a mingw-w64
cross toolchain (no CRT anywhere: hbc emits kernel32 calls and
`hbhbr.o` imports VirtualAlloc/VirtualFree, GetStdHandle+WriteFile and
ExitProcess directly):

```
x86_64-w64-mingw32-gcc -c -O2 -ffreestanding -fno-stack-protector \
    -Iextend extend/hbhbr.c -o hbhbr.o
hbc app.prg app.s --target=windows
x86_64-w64-mingw32-as -o app.o app.s
x86_64-w64-mingw32-gcc -c -O2 myext.c -Iextend -o myext.o
x86_64-w64-mingw32-ld -o app.exe app.o myext.o hbhbr.o \
    -e _start --subsystem console -lkernel32
```

Porting notes an extension author must know: `HB_LONG`/`HB_ULONG`/
`HB_SIZE` are 64-bit on BOTH targets (Windows `long` is 32-bit - LLP64,
so the bridge widens its own types there, like Harbour does); a block
call from C crosses through the Win64 variant of the hbc_blk_launch
trampoline (the C caller's rdi/rsi are saved across the block - hbc
code uses them internally); and the per-symbol thunk keeps the Win64
32-byte shadow space over the two C calls it makes. Behaviour is
byte-identical with the Linux build on the whole extend/demo suite
(each demo's stdout, stderr and exit code compared, CRLF aside).

## Not in milestone 1 (named limits)

- Dates and hashes across the boundary; array mutation, resize and
  array return values; codeblocks with non-integer results and eval
  parameters beyond integers; `hb_errRT` error recovery.
  (Scalar f64 crossed in milestone 2.3; `@` over Dyn locals in 2.2;
  Dyn-held arrays read-only in 2.4; integer-result codeblocks and the
  hb_eval* family in 2.5.)
  Named limit of 2.2: `hb_param` on a byref argument returns the
  MARKER casilla and the item API (`hb_itemType`, `hb_itemNew`, ...)
  is not supported on that handle in this increment - use the
  hb_par*/hb_stor* families, which read and write through. Each fails closed at compile time or as a registered clean
  runtime error.
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
- `HB_FUNC(NAME)` defines the global symbol `HBHBR_FN_<NAME>` and the
  hbc thunk calls it directly (H2.0 decision): a missing C function is
  a LINK error naming the symbol, like Harbour/hbmk2. For
  compatibility, `HB_FUNC` also places a `{name, fnptr}` entry in the
  `hbhbr_funcs` linker section; objects emitted by a pre-2.0 hbc carry
  their own section-walk dispatcher (between the GNU-ld-provided
  `__start_hbhbr_funcs`/`__stop_hbhbr_funcs` bounds) and keep working
  against new hbhbr.o
  with a SysV-aligned stack. An unmatched name is a clean exit-1
  diagnostic (`error: external function not found: NAME` + callstack).
- `hbhbr.o` keeps the bridge state (argc/argv/return slot) and the
  hb_parc scratch arena (freed after each call); `hb_retclen` copies
  through the runtime's own `hbc_strcpy`, so the returned string is an
  ordinary hbc-owned string.
