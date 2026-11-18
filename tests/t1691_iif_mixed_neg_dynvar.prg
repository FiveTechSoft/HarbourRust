// mixed iif keeps a named rejection: a Dyn variable arm. Independent fixture.
function main()
local y := NIL
local x := iif(.T., y, 1)
return nil
