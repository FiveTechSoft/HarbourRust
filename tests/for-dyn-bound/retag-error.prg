procedure Main()
local i,n:=0
n:=Val("2.5")
BEGIN SEQUENCE WITH {|b|Break(b)}
for i:=1 to n
 ? i
 n:="x"
next
RECOVER
 ? "caught",i
END SEQUENCE
return
