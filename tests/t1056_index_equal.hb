procedure main()
local a := { 1, 2 }, b := {{ 3 }}, h := { "x" => 4 }, n := 1
a[1] = 7
b[1][1] = 8
h["x"] = 9
a[n++] = 11
? a[1], a[2], b[1][1], h["x"], n
? a[1] = 11, b[1][1] = 8, h["x"] = 9
return
