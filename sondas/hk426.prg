#include "std.ch"
function say()
? "effect"
return 7
function main()
local x := 1
local s := "abc"
local a := {1,2}
HB_SYMBOL_UNUSED(x)
HB_SYMBOL_UNUSED(s)
HB_SYMBOL_UNUSED(a)
(x++)
(say())
(AllTrim(" tmp "))
? x, s, a[1]
return
