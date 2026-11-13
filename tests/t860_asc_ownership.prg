function make(n)
return Chr(n)
function exercise()
   local s := Chr(255)
   local i := 0
   ? Asc(s), Len(s), Asc(make(128)), Asc(Chr(0)), Asc(Chr(65)+"Z")
   ? Asc(AllTrim(" B ")), Asc(IIf(.T., Chr(66), Chr(67)))
   for i := 1 to 1000
      Asc(make(65))
      Asc(AllTrim(" Z "))
      Asc(Chr(65)+Chr(66))
   next
   ? Asc(s), Len(s)
return
function main()
   exercise()
   ? hb_MemCheck()
return
