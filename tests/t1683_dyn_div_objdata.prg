CREATE CLASS T
   DATA n
   DATA f
ENDCLASS
function main()
   local o
   o := T()
   o:n := 10
   o:f := 7.5
   ? o:n / 4
   ? 10 / o:n
   ? o:f / 2
   ? 10 / o:f
   ? o:n / o:f
return nil
