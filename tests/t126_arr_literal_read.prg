// HB-EXACT: array literal + base-1 read; oracle = Harbour -gtstd binary (probe a1, t126)
function main()
local a := {10, 20, 30}
? a[1]
? a[2]
? a[3]
return nil
