# Val: literal conversion evidence and representation decision

Base: a25324dff7abe7f8656068ed081a03c09048047a.
Status: DESIGN AND TEST MODEL ONLY. Val is not usable in HarbourRust after
this package. No compiler source, ABI, runtime helper or builtin admission
is changed. This is not completion of Val, nor a throughput improvement.

Blocked on the owner's numeric/Dyn representation decision, tracked by
`todo-01M68H122N7CVZ15KBQA1WDC3F`. This note does not decide that question.

## Why literal folding is not enough

Harbour Val returns either an integer item or a double item, with width and
decimal metadata derived from its string. The value is more than a number.
The current native I64 channel carries literal/runtime provenance, not an
arbitrary Harbour numeric display width. Mapping Val("1") to Int(1) would
preserve arithmetic but silently print the wrong field width. Mapping all
Val results to F64 would lose integer precision and change type/operations.
Neither is an acceptable fold. Excluding Val("1") while claiming an admitted
Val subset would be a misleading finish of this work, so no such API ships.

Fresh pinned Harbour core694428e1c12f726675b19324d62167fa77d68185 is the oracle.
Relevant source:src/rtl/val.c, src/common/hbstr.c (hb_valStrnToNum),
src/vm/itemapi.c (numeric width normalization), include/hbdefs.h. The test
model was independently written against observed semantics; it is not
copied Harbour implementation or production compiler code.

## What is visible

`tests/val-design/oracle.prg` is the small direct console oracle. Its output
shows literal1 has width10 while Val("1") has width1. A second observation
program records Str default, explicit-picture Transform, bit-and255, and
metadata/Str after +0 and *1. The C observation shim uses Harbour's own
hb_itemGetNLen and numeric item predicates; integer payload is emitted as
an exact decimal string, F64 payload as64-bit hexadecimal. ValType alone
would report N for both and would not establish integer/double identity.

Selected observations (spaces in quoted Str results are meaningful):

| Input | Kind | Width | Dec | Str(Val(input)) | After +0 |
| --- | --- | ---: | ---: | --- | --- |
| "1" | INT | 1 | 0 | "1" | INT,width10,"         1" |
| "         1" | INT | 10 | 0 | "         1" | INT,width10 |
| "1.2xyz" | F64 | 1 | 4 | "1.2000" | F64,width10,dec4 |
| "abc.def" | F64 | 3 | 3 | "  0.000" | F64,width10,dec3 |
| "1e3" | INT | 3 | 0 | "  1" | INT,width10 |
| "0x10" | INT | 4 | 0 | "   0" | INT,width10 |
| "9007199254740993" | INT | 20 | 0 | "    9007199254740993" | exact INT,width20 |

Explicit Transform picture controls its own display width/decimals and does
not preserve the original field. hb_BitAnd consumes the numeric value, not
the display width. +0 restamps width but preserves the measured F64 decimal
metadata. *1 can take a different numeric route: the large integer above
became9007199254740992 in the observed Harbour result while +0 remained
exact. That is evidence for operation-specific rules, not permission to
round the original Val result early. Full raw observation rows are included.

Additional oracle facts: signed input, leading spaces/tab/CR/LF, trailing
suffixes, empty strings, a decimal point without digits, overflow beyond
I64 and unsigned-looking text all have observable metadata behavior. Hex
and exponent syntax must not be delegated to generic strtod/int parsing.
Vertical-tab/form-feed are not the four measured leading whitespace bytes.
Embedded NUL is tested as a byte in a bounded string, not as C termination.

## Concrete representation proposal, not implementation

Keep a conversion result in an abstract front-end descriptor:

```
NumericLiteralResult {
    class: INT | F64,
    payload: exact_i64 | ieee754_binary64_bits,
    width: Harbour numeric field width,
    decimals: Harbour numeric decimal metadata
}
```

This is a semantic record only. It is not an enum added to the compiler,
not a chosen register/stack layout and not an ABI extension. A future owner
of the numeric representation decision must select an approved mapping and
prove how width survives copy, assignment, parameter passing, return, Dyn
boxing/unboxing, containers and formatting. Each operation needs an explicit
preserve/restamp rule backed by an oracle; +0 is not a general rule for *1.

Do not overload the current I64 provenance bit with width, use an external
address-keyed side table, convert integers to F64, or silently route everything
through NumLocal. Those would change consumers or lifetime/alias semantics
without the outstanding design decision. No representation-preparation code
is needed to keep this descriptor documented and tested.

Lowering is a separate gate:until a mapping exists, all abstract Val tuples
must be rejected before codegen. The test-only `lower_literal` rejects every
otherwise parsed input with a named parked-lowering error. It does NOT add
a compiler Val builtin that later fails, and does not replace the current
compiler's unknown-function diagnostic. Nonliteral inputs are rejected by
the model as requiring constant byte strings. Compiler admission remains
unchanged and Val cannot be used by an application after this patch.

## Parser-level experimental gate

`tests/val-design/literal_model.py` models the literal byte conversion into
that abstract descriptor. No code in src/ imports it, no generated native
value is emitted, and no user expression is folded. It is deliberately an
experimental semantic model, not a runtime parser or a committed future
implementation language/algorithm choice.

`check.py` builds fresh real Harbour with the small observation shim:
280 fixed/seeded cases compare exact kind, integer payload/F64 bits, width
and decimals. Cases cover signs, whitespace, suffixes, dots, decimal values,
hex/exponent lookalikes, I64 boundary/overflow, >2^53 precision, NUL/0xFF and
seeded malformed text. Every one of280 otherwise parsed descriptors must
then fail the named lowering guard. Six further test-only parser bounds/
input-kind rejections are asserted. The consumer program has29 observation
rows, including exact Str/Transform strings and post-arithmetic metadata.

The experimental model bounds inputs to4096 bytes, finite F64 and at most17
places of decimal metadata. Those are test-model bounds, NOT Harbour or
compiler language limits. It does not claim full arbitrary-length/nonfinite
Val parsing. A model mismatch fails the gate rather than granting codegen.
The underlying I64 identity is grouped as INT, not a promise that Harbour's
internal small-integer and long subtypes share an ABI. No code was changed
in the pinned Harbour source; the shim reads its public item APIs only.

Reproduce from this patch:

```sh
python3 tests/val-design/check.py --hbmk2 /path/to/pinned/hbmk2 \
  --output /tmp/val-design-new
```

Output must be new. The gate compiles its own oracle, compares full tuples,
and writes raw oracle/consumer JSON plus summary. The C shim and model are
readable sources; no compiled executable is shipped. `git diff BASE -- src`
is empty. A full native battery is not rerun because there is no compiler or
runtime modification, and no native pass is implied by the design tests.

## Limits and outcome

Val remains unavailable. No literal fold is installed, no runtime parser,
no I64 ABI/metadata change, no I64-as-F64 substitution, no NumLocal/Dyn
integration, no benchmark of nonexistent native Val and no claim to full
Val compatibility. Width is demonstrably observable in default output/Str;
integer precision beyond2^53 excludes the always-F64 shortcut. That is the
reason the implementation is parked, not an unhandled implementation detail.

The delivered model/gate records the required conversion semantics so the
representation decision can proceed without re-discovering those facts.
Any future fold must match the original bytes and preserve the chosen
representation across consumers; passing this model alone is insufficient.
Val's runtime/ABI decision stays linked to the open numeric/Dyn decision.

The current string queue therefore closes as Space/StrTran admitted subsets
plus Val parked with explicit evidence, NOT "all strings complete". Next
assigned independent work is StrTran occurrence start/count arguments4/5,
beginning with its own Harbour oracle. Space F64 truncation and allocator
>64KiB remain separate prioritization decisions. The optional StrTran
proc-metadata safe-builtin micro-change is not mixed into this package.
