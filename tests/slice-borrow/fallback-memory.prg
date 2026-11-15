function Change(s)
s:="ZZZZZZZZZZ"
return 3

function Main()
Work()
? hb_memcheck()
return nil
function Work()
local s:=Replicate("abcdef",2)
local n:=3
? Left(s,n),Right(s,n),SubStr(s,n,n)
? Left(s,Change(@s)),s
s:=Replicate("abcdef",2)
? Right(s,Change(@s)),s
s:=Replicate("abcdef",2)
? SubStr(s,Change(@s),3),s
s:=Replicate("abcdef",2)
? SubStr(s,2,Change(@s)),s
return nil
