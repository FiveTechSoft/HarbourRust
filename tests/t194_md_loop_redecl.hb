// OURS-ONLY: loop-body re-declaration of an array of arrays; deep free-old per iteration
function main()
local a := {{1}, {2}}
for i := 1 to 3
  local t := {{i * 10}}
  ? t[1][1]
next
? a[2][1]
? hb_memcheck()
return nil
