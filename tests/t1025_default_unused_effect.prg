function main()
local i := 1
local s := "yes"
HB_SYMBOL_UNUSED(i++)
HB_SYMBOL_UNUSED(s)
? i,s
#undef HB_SYMBOL_UNUSED
#define HB_SYMBOL_UNUSED(x) QOut(x)
HB_SYMBOL_UNUSED("override")
return
