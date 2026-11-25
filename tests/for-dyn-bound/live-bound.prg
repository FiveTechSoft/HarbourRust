procedure Main()
local i,n:=0
n:=Val("4.5")
for i:=1 to n
 ? i
 n:=Val("1.5")
next
? "after",i,n
return
