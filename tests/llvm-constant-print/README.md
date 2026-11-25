# LLVM printing of immutable borrowed constant trees

Own MIT increment. Direct print items resolve immutable local bindings in
pure concat/ASCII Chr trees through the existing constant-only resolver.
No string value ABI, allocation, ownership, return/argument or mutable/owned
string admission. The earlier failed probes found existing console bugs;
those were separately fixed before this increment. Only current exact
runs count. Formatted/inline/raw output retain their existing semantics.

Two positive sources x native/LLVM traced/untraced = 6 fresh Harbour
byte-exact triples, plus 4 named LLVM rejections for mutable/owned values.
NUL/controls/UTF8/empty/space/concat/loops/raw/formatted interleaving covered.
Broad current evidence is listed in the package summary. Windows runtime
and Darwin runtime not asserted. No RC/numeric-division policy change.
No push/publication/workflow/rebase. Oracle commit
694428e1c12f726675b19324d62167fa77d68185. MIT upstream examples are
specifications only; Julio Ponce examples credited, no cambio.diff copy.

## Print-only IIf selection

The existing print-only IIf pointer/length selection now accepts immutable
borrowed constant concat trees, not only literal branch strings. Both arms
must resolve at compile time; an owned arm stays rejected even when the
condition is literal true. Condition effects execute once; no branch string
expression or general string ABI is introduced. New gate total: 9 exact
fresh Harbour/native/LLVM rows and 6 named LLVM rejections.

## Nested print-only IIf

Pure immutable leaves may be selected by nested print-only IIf trees.
Conditions are lowered as branches, only reached conditions execute, once.
Pointer/length slots are entry allocas, not string objects or an ABI change.
Every leaf is checked structurally before lowering, including unreachable
owned leaves (still rejected). Gate now 12 fresh exact rows and 8 named
LLVM rejections. Nested both-side choices, increments, empty/NUL, raw and
formatted output, and repeated loop execution are checked.

## Lazy error canaries

Test-only: unselected nested conditions contain runtime lower/upper bound
errors and minimum-overflow-sensitive increment of maxI64. No such condition
runs; reached branches remain exact against fresh Harbour. Gate total now
15 exact rows plus 8 named LLVM rejections. No compiler change.

## Direct literal NIL print items

Direct NIL in ?, ??, QOut, QQOut and OutStd is fixed text NIL, using the
existing string renderer. No scalar NIL, local/parameter/return ABI or mixed
IIf selection is admitted. Two own MIT cases compare native and both LLVM
modes byte-exactly against fresh Harbour, including nested print evaluation,
separators, empty/trailing-space strings, logical/numeric neighbours and effects.
