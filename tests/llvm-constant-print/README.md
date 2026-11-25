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
