// HB-EXACT (probe m1): nested literal, two-level reads
function main()
local a := {{1, 2}, {3, 4}}
? a[1][1]
? a[1][2]
? a[2][1]
? a[2][2]
return nil
