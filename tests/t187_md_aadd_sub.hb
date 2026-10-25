// HB-EXACT values (probe m5): AAdd grows the subarray in place
function main()
local a := {{1, 2}, {3, 4}}
AAdd(a[1], 5)
? len(a[1])
? a[1][3]
return nil
