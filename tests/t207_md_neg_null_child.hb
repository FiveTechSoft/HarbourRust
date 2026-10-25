// DIVERGE-FAILMODE: indexing a fresh (null) child is a clean bound error; Harbour shows its dialog
function main()
local a := {{1}, {2}}
ASize(a, 4)
? a[4][1]
return nil
