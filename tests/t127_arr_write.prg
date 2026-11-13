// HB-EXACT: indexed write a[i] := v; oracle = Harbour -gtstd binary (t127)
function main()
local a := {10, 20, 30}
a[2] := 99
? a[2]
return nil
