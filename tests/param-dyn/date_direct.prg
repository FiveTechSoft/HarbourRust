function main()
? year(f("01/02/2024"))
return nil
function f(p)
local d := ctod("")
set date american
p := p + ""
d := ctod(p)
p := val(p)
return d
