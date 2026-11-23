function wrong()
local x := NIL
x := "own" + "ed"
return x
function main()
local i,x := NIL
for i := 1 to 100
try
x := "owned"+hb_TToS(hb_SToT("20261123"))+hb_TToS(NIL)
catch
end
try
x := hb_TToS(wrong())
catch
end
next
? "done"
return nil
