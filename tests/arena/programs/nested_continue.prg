function Main()
local i:=0, j:=0, n:=0
for i:=1 to 3
local outer:="a"+"b"
for j:=1 to 2
local inner:="c"+"d"
n:=n+Len(inner)
loop
next
n:=n+Len(outer)
loop
next
? n
return nil
