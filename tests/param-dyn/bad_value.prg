function main()
local b, a
b := hb_memcheck()
begin sequence
? f(5)
recover
? "recovered"
end sequence
a := hb_memcheck()
return nil
function f(p)
p := val(p)
return p + 1
