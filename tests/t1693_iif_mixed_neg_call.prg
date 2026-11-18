// mixed iif keeps a named rejection: a Dyn call arm. Independent fixture.
function g()
local y := NIL
return y
function main()
local x := iif(.T., g(), "a")
return nil
