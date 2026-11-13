function make(n)
return Chr(n)
function exercise()
   local s := make(65)
   local n := Len(Chr(66))
   ? s, n
   s := Chr(67)
   ? s, Len(Chr(0)+Chr(255)), Len(s)
return
function main()
   exercise()
   ? hb_MemCheck()
return
