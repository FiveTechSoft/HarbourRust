function emit(n)
?? n+0
return n+0
procedure main()
local s := "outer  "
OutStd(s, 2, .T.)
? s
?? s, 3
if .T.
local t := "left  "
OutStd(t)
else
local t := "right"
OutStd(t)
endif
if .F.
local b := .F.
? b
endif
if .T.
local t := "next"
? t
endif
local nul := Chr(0) + "  "
OutStd(nul, "  ")
OutStd(hb_eol())
OutStd()
IIF(.T., OutStd("lazy  "), OutStd("wrong"))
OutStd(emit(4), s, emit(5))
return
