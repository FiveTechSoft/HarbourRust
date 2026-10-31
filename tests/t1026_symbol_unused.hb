// HB_SYMBOL_UNUSED(s): a read-only mention, evaluates nothing, moves
// nothing (multiarg family; Harbour's std-header macro is a builtin
// statement here - HR has no preprocessor).
function main()
local i := 1
HB_SYMBOL_UNUSED(i)
? i
return
