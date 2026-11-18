# Classes and objects (v0.7.0)

HarbourRust compiles a bounded Harbour class model to native x86-64 assembly
on Linux. This is an own MIT implementation: no Harbour class library,
runtime or VM code is copied or translated. Real Harbour serves as the test
oracle only. `#include "hbclass.ch"` is accepted and ignored; no Harbour
header content is used. Tag kind 13 is officially in use for objects.

## Admitted subset

Linux x86-64 ordinary assembly backend. `CREATE CLASS` / `CLASS` syntax with
optional `FROM`/`INHERIT` naming one parent (single inheritance). Scalar
`DATA` members with `INIT` values (evaluated lazily, once per instance,
child-first). Methods and `CONSTRUCTOR`s; a class that declares no
constructor answers a default `New()` returning the instance, like Harbour.
An inherited constructor types as the receiver's class, so the
`local d := Dog():New()` idiom works.

```harbour
CREATE CLASS Animal
   DATA name INIT "?"
   METHOD Speak() VIRTUAL
ENDCLASS
METHOD Speak() CLASS Animal
return "..."
CREATE CLASS Dog INHERIT Animal
ENDCLASS
METHOD Speak() CLASS Dog
return "guau"
function Main()
   local d := Dog():New()
   ? d:Speak(), d:name
return nil
```

Object model: a flat per-class method table with hierarchy-wide constant
slots; an override patches the inherited slot in place, so a call is two
loads plus an indirect call with no name lookup. DATA lives at fixed
compile-time offsets in the instance, parent layout first. Instances are
reference counted with a per-class freelist; scalar DATA cannot form
cycles. Assignment and parameter passing share the instance, `==` on
objects is identity, `? o` prints empty and keeps its column separator,
and a NIL object prints NIL, all as measured in real Harbour.

## Verification

`tests/classes/` holds the public differential gate: 26 same-source probes
compiled and run under real Harbour (`694428e1`) and HarbourRust with
byte-identical stdout and stderr, 3 declared-limit probes and 13 named
negatives, 42/42. The landing also kept the full Linux regression manifest
unchanged (only the inherited `t110` remaining) and produced byte-identical
assembly for all class-free positive programs (no contamination), with the
runtime blob clean under AddressSanitizer and UBSan.

## Declared limits (explicit compile-time rejections, never silent)

- `DATA` holds scalars only; object or array members are not yet supported
  (cycle management comes first).
- Single inheritance only; Harbour's multiple inheritance is a named
  rejection.
- Members named like reserved words (for example `METHOD Step()`) are a
  named parser rejection in this increment; Harbour accepts them.
- Compound assignment (`+=` and friends) is outside the supported
  expression subset, as before.
- A message send on a value of statically unknown class is rejected,
  except when the member belongs to exactly one class hierarchy in the
  program: then the receiver is pinned to that hierarchy's root class and
  checked statically. Harbour resolves all of these at runtime.
- Classes were Linux x86-64 only in this increment (v0.7.0). Since the
  16 November 2026 Windows work (see the correction below) the compiler also
  accepts them for `--target=windows`: Wine is the oracle, and the candidate
  has a fixture gate on native Windows (CI). Class compatibility on Mac is
  not established here; compiling is not running.
- `=` as an expression operator remains outside the supported subset
  (pre-existing limitation, unchanged).

## Windows object-output correction (16 November 2026)

Fresh official Harbour GTSTD/Wine evidence shows that `? "x", o` with a
live object must not leave a space before the next newline. The earlier
claim that p_sep's space was an established GTCGI difference is withdrawn.
The focused regression and its evidence scope are documented in
[windows-separators](../tests/classes/windows-separators/README.md).
Native Windows runs only the separator fixtures: the CI step "Object separators on native Windows" in `.github/workflows/native-ci.yml` runs `tests/classes/windows-separators/check.py` against versioned GTSTD fixtures. That is not a full differential class gate. The broader string-only
GTSTD/GTCGI hold/flush mismatch remains open Harbour compatibility debt;
this fix does not change the global console profile or claim full parity.
