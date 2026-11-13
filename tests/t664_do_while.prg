// DO WHILE is the plain while loop (oracle hk244): same ENDDO, LOOP and
// EXIT behave identically. i ends 4, n accumulates 1+2 (3 skipped by
// loop, 4 cut by exit) = 3.
function main()
   local i := 0
   local n := 0
   do while i < 5
      i := i + 1
      if i == 3
         loop
      endif
      if i == 4
         exit
      endif
      n := n + i
   enddo
   ? i
   ? n
   return
