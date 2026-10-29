function edge(n,m)
local a := n+0
local b := m+0
? a+b,a-b,a*b
? a<b,a<=b,a==b,a<>b,a>=b,a>b
? Min(a,b),Max(a,b),hb_bitXor(a,b)
return a+b
function main()
local low := -9223372036854775807
low -= 1
edge(low,-1)
edge(low,1)
edge(9223372036854775807,1)
edge(9223372036854775807,-1)
edge(low,9223372036854775807)
edge(-4294967296,4294967296)
edge(0,0)
edge(-1,-1)
return
