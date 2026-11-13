function invalid(n)
local a := {1,2}
return a[n+0] == 0
function relay(b)
return b .AND. invalid(3)
function main()
? If(relay(.T.),1,0)
return
