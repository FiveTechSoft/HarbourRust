// len/shrink HB-EXACT (e2/e3); grown slots read 0: documented i64-model difference (Harbour grows NIL, e1)
function main()
local a := {}
AAdd(a, 1)
AAdd(a, 2)
AAdd(a, 3)
AAdd(a, 4)
AAdd(a, 5)
ASize(a, 8)
? len(a)
? a[7]
ASize(a, 2)
? len(a)
? a[2]
return nil
