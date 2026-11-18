// mixed iif keeps a named rejection: an object arm. Independent fixture.
class Obj
endclass
function main()
local o := Obj():New()
local x := iif(.T., o, 1)
return nil
