// HB-EXACT (probes e4+d1): {} has len 0; AAdd grows; elements read back
function main()
local a := {}
? len(a)
AAdd(a, 10)
AAdd(a, 20)
? len(a)
? a[2]
return nil
