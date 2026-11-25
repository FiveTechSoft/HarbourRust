# LLVM immutable constant concat initializers

Own MIT increment. A LOCAL initialized by a pure concat tree may use earlier
immutable constant string locals. Chains resolve into compile-time bytes.
Existing frontend concat reads leave source locals usable; no direct alias
assignment route is added. Direct string aliases still follow frontend move
policy. No owned/mutable/return/argument string admission or string ABI.
Derived and source string reassignment remain named LLVM rejections.

Two positive sources x native/LLVM traced/untraced = 6 fresh Harbour exact
triples; 6 named LLVM rejections. Empty/NUL/UTF8, multi-declaration chains,
Len/Asc/At/Empty/char predicates/$/==/printing and loop observations covered.
Broad current evidence is listed in the package summary. No RC or numeric
array division policy change. No push/publication/workflow/rebase.
Harbour oracle694428e1c12f726675b19324d62167fa77d68185. MIT examples are
specifications only; Julio Ponce examples credited, no cambio.diff copy.
