function show(x)
   ?? x
return
function exercise()
   local s := Chr(65)
   show(s)
   show(Chr(66))
   show(AllTrim(" C "))
   ? Asc(s)
return
function main()
   exercise()
   ? hb_MemCheck()
return
