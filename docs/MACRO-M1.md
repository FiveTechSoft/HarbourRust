# Precompiled macro literals (M1)

This is a first step toward Harbour macro parity, not a replacement for
Harbour's dynamic macro compiler.

The native compiler accepts `&("1+2")` as a scalar rvalue. The producer of
macro text may contain only string literals, parentheses and literal `+`
concatenation, for example `&("1" + "+2")`. It is never executed or resolved
against caller variables during compilation.

Expanded text has a separate, closed admission check before ordinary type
inference. It admits:

- signed i64 literals and arithmetic whose existing constant fold produces
  an i64 result, including exact integer division and nonzero integer modulo;
- string literals and string `+` concatenation;
- `.T.`, `.F.`, `NIL`, logical NOT/AND/OR over logical values;
- integer comparisons, logical equality/inequality, string `==` and string `$`.

Accepted text lowers to an ordinary scalar expression after this proof.
No runtime parser, macro cache, symbol table or macro evaluator is emitted.
Code generation and ownership checks then use the existing native paths.
The containing expression still runs at its original runtime position. String
concatenation has the same allocation and cleanup behavior as direct syntax.

## Separate scopes

A LOCAL that contains text is not the same as a LOCAL named by the text.
Harbour can read the former, but its expanded macro cannot see the latter.
M1 never resolves a name inside expanded text to a caller LOCAL or STATIC.

`LOCAL c := "1+2"; ? &c` and `? &(c)` remain dynamic and are not supported in
M1, even if a compiler could guess c's value. `&("hidden")` is also outside
M1, even when a caller variable named hidden exists.

## Named capacity limits

Unsupported macros fail with `macro M1 capacity limit`, not a claim that
Harbour rejects the program. This includes names, calls, fields, memvars,
lvalues/statements, dynamic sends, lists, blocks, arrays, hashes, nested macros,
macrotext and text with controls/comment markers. Floats, fractional division,
power, arithmetic overflow to floating point, mixed-type/error-producing
operations, and invalid expanded syntax are not admitted by this first gate.
An otherwise closed but unsupported scalar form is still a capacity limit.

The expanded text is bounded to 65536 bytes, 256 tokens and 64 parenthesis
levels. The literal text producer also has a 64-level parenthesis bound.
These are M1 limits, not Harbour language rules.

A Harbour error from evaluating macro text belongs at runtime and may be
recoverable. M1 does not implement that infrastructure. Such text remains a
capability rejection, including in a never-executed branch, rather than being
misreported as a Harbour syntax/name/type error or silently accepted with
changed behavior. Deferred errors, real MEMVAR scope/storage and the embedded
evaluator belong to later stages. The final objective remains macro parity.

## Developer verification

`tests/macro-m1/check_oracle.py --help` runs same-source ELF and real-PE
Harbour pairs, plain and instrumented, plus named capacity rejections.
`check_contexts.py` covers return/assignment/arguments/control flow and
allocation balance after repeated string results. `check_base_identity.py`
compares original-manifest assembly or diagnostics against BASE. New positive
manifest entries are tested separately from that original-manifest identity
gate. `check_manifest.py` records every raw channel in base64 JSONL.

Raw stdout/stderr/exit are the primary comparison. A CRLF-normalized or legacy
trailing-LF comparison is only a declared secondary column, never a raw pass.
Windows evidence is PE execution under Wine 11, not native Windows evidence.
Mach-O is not runtime-verified by this M1 unit. Original hk369-hk373 sources
have not been recovered, so this increment does not claim a 5/5 result by ID.
