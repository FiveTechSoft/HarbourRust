procedure main()
local a := 1.000, b := 1.0, n := 0
? Min(a,b), Max(a,b), Min(-0.000,-0.0), Max(-0.000,-0.0)
? Min(FSide(@n, 2.50), FSide(@n, 1.000)), n
? Max(FSide(@n, -2.50), FSide(@n, -1.000)), n
? Min(5,Min(2,3)), Max(Max(2,3),5)
return
function FSide(n, v)
n++
return v + 0.0
