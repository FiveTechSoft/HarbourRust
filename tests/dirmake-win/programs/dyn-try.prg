function main()
local d, e, n := 0
d := "dynd" + "ir"
? DIRMAKE(d), DIRMAKE(d)
d := 7
? DIRMAKE(d)
d := NIL
? DIRMAKE(d)
d := .t.
? DIRMAKE(d), DIRMAKE(1.5), DIRMAKE(Date())
try
? DIRMAKE(boom())
catch e
? "caught"
end
? DIRMAKE(), DIRMAKE(NIL)
return nil
function boom()
break("boom")
return "never"
