CREATE CLASS T
   DATA z
ENDCLASS
function main()
   local o
   o := T()
   o:z := 0
   ? 10 / o:z
return nil
