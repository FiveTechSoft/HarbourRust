function main()
local s := hb_eol()
#ifdef __PLATFORM__WINDOWS
? Len(hb_eol()) == 2, Asc(hb_eol()) == 13
#else
? Len(hb_eol()) == 1, Asc(hb_eol()) == 10
#endif
? ValType(s)
return
