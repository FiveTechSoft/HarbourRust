function f(x)
return (1, x) + 2
function main()
local x := 0
local b := {|n| (1, Eval({|m| m+1}, n))}
? (1, f(2)), x
? Eval(b, 5)
? (1.5, 2.5) * (x++, 2), x
? (x++, .F.) .OR. (x++, .T.), x
return
