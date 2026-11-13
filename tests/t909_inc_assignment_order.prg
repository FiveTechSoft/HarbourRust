function main()
local x := 1
local a := {0,0,0,0,0}
a[x] := x++
? x, a[1], a[2], a[3]
a[x++] := ++x
? x, a[1], a[2], a[3], a[4]
return
