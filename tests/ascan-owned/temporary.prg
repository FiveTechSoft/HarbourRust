procedure main()
checks()
? hb_memcheck()
return
procedure checks()
local a:={"X","Y"}
local own:=Upper("x")
? AScan(a,Upper("x")), AScan(a,Upper("z"))
? AScan(a,own), own
? AScan(a,"Y"), AScan(a,"Z")
return
