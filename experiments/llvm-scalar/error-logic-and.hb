function probe(n)
local a := {7,8,9}
local bad := 4
if ((n+0) == 1) .AND. (a[bad] == 0)
? 1
endif
return 0
function main()
? probe(1)
return
