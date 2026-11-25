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

## Function-local classifications and dead mutation

Test-only follow-up verifies identical local names as immutable concat trees
in one function and I64/fixed-array values in another, repeated calls and
main/function isolation. Dead source/derived mutation after LOOP is still
rejected, not silently erased. Gate total: 9 fresh Harbour/native/LLVM exact
rows and 8 named LLVM rejections. No compiler change in this follow-up.
