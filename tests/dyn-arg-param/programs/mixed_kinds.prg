// Dyn argument carrying a float, a date and a string to parameters
// that other call sites pin as integers
procedure main(a)
local d, s
a := 7
d := a / 2
s := a * 1.5
? twice(d), twice(4), twice(s)
? pick(d, 1), pick(3, 2)
return
function twice(n)
return 2
function pick(v, w)
? valtype(v), w
return w
