function main()
local x := 0
if ((x++, .T.))
? x
endif
if (IIF(.T., .T., .F.))
? "nested"
endif
return
