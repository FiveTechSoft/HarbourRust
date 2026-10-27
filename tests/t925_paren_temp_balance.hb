function make()
return AllTrim(" abc ")
function main()
local i := 0
for i := 1 to 1000
(make())
(Chr(65))
(AllTrim(" x ") + "z")
next
? hb_memcheck()
return
