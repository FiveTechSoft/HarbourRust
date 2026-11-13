function take(s)
return Asc(s)
function main()
local s := AllTrim(" abc ")
local b := {|n| (take(s),n)}
? Eval(b,1)
return
