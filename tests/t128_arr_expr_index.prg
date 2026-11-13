// HB-EXACT: expression index read/write; oracle = Harbour -gtstd binary (t128)
function main()
local a := {10, 20, 30}
local i := 1
? a[i + 1]
a[i + 1] := a[i] * 2
? a[2]
return nil
