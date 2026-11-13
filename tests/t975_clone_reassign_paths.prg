function take(s)
return Asc(s)
function main()
local s := AllTrim(" a ")
local i := 0
local a := Array(2)
local x := 0
if .T.
? take(s)
s := AllTrim(" b ")
else
? take(s)
s := AllTrim(" c ")
endif
? s
for i := 1 to 2
? take(s)
s := AllTrim(" d ")
next
? s
while .T.
? take(s)
s := AllTrim(" e ")
exit
enddo
? s
for each x in a
? take(s)
s := AllTrim(" f ")
next
? s
return
