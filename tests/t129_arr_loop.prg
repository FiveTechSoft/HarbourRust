// HB-EXACT: array fill inside a for loop + multi-item QOut; oracle = Harbour -gtstd binary (t129)
function main()
local a := {0, 0, 0}
for i := 1 to 3
  a[i] := i * i
next
? a[1], a[2], a[3]
return nil
