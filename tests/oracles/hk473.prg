procedure main()
local n := 0
? Min(3, 8), Max(3, 8), Min(-4, 0), Max(-4, 0)
? Min(.T.,.F.), Max(.T.,.F.)
? Min(Side(@n, 2), Side(@n, 1)), n
? Max(Side(@n, 2), Side(@n, 1)), n
? Min(1.0, 1.000), Max(1.0, 1.000)
? Min(2.50, 1.000), Max(2.50, 1.000)
? Min(10000000000,10000000001), Max(10000000000,10000000001)
return
function Side(n,x)
n++
return x+0
