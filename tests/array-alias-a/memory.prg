function Copia(p)
local a := iif(p == NIL, {},p)
AAdd(a,9)
return Len(a)
function Falla(p,fail)
local n := Len(p)
if fail
Break("expected")
endif
return n+1
function Total(p,fail)
local i,n := 0
for i := 1 to Len(p)
n += Falla(p[i],fail .and. i == 2)
next
return n
function main()
local i,a := {},b := {},hits := 0,n := 0
AAdd(a,0)
AAdd(b,"uno")
AAdd(b,"cuatro")
for i := 1 to 100
n += Copia()+Copia(a)+Total(b,.F.)
try
n += Total(b,.T.)
catch
hits++
end
next
? Len(a),hits,n,a[101]
return nil
