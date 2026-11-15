function Work()
local s:=Replicate("aBzZ019!",513)
local alias:=Left(s,Len(s))
local u:=Upper(s)
local l:=Lower(s)
s:="changed"
? Len(u),Len(l),Asc(u),Asc(l),Asc(alias),Asc(Right(u,1)),Asc(Right(l,1))
? Left(u,8),Left(l,8),Left(alias,8),s
? Upper(""),Lower(""),Upper(Lower("aAzZ")),Lower(Upper("aAzZ"))
return nil
function Main()
Work()
return nil
