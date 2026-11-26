// Dyn argument holding a float (a % on an untyped LOCAL) passed to a
// parameter another call site pins as an integer
function main(y)
local x, z
y := 2026
x := y % 19
z := y / 8
? f(x)
? f(z)
? f(1)
? k(x)
? k(nil)
? k("s")
return nil
function f(b)
return 7
function k(v)
? valtype(v)
return v
