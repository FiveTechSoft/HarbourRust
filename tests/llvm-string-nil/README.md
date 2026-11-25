# LLVM immutable constant string against NIL

Own MIT bounded increment: =, ==, != between one NIL and one immutable
borrowed constant string/tree yield false,false,true respectively, in either
operand order. Only pure compile-time bytes are folded; owned/mutable/effect
expressions still follow previous rejections, not evaluation erasure. Existing
numeric/logical NIL comparisons stay unchanged. No general NIL storage,
string value ABI, ownership or RC policy change.

Two sources x native/LLVM traced/untraced = 6 fresh Harbour exact triples;
6 named LLVM rejections. Empty/NUL/concat/both orders/operators/logical/IF/
IIf/Empty/loop contexts covered. Broad evidence in package summary.
No push/publication/workflow/rebase. Oracle commit
694428e1c12f726675b19324d62167fa77d68185. MIT upstream examples are
specifications only; Julio Ponce examples credited, no cambio.diff copy.

## Literal NIL pair

Two literal NIL operands compare equal for = and ==, unequal for !=.
This adds only constant logical results, not NIL local storage, return,
parameter or general value ABI. A LOCAL initialized to NIL remains rejected.
Gate total9fresh Harbour/native/LLVM exact rows and8named LLVM rejections.
Local logical bindings, NOT/AND/IF/IIf/Empty contexts covered. No compiler
policy, ownership or RC change beyond the narrow comparison lowering.
