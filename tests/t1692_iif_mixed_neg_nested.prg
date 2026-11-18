// mixed iif keeps a named rejection: a nested mixed iif (Dyn arm). Independent fixture.
function main()
local x := iif(.T., iif(.T., "a", 1), 2)
return nil
