// mixed iif keeps a named rejection: a block arm. Independent fixture.
function main()
local x := iif(.T., {|| 1}, "a")
return nil
