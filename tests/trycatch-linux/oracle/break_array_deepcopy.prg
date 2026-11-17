function main()
   local d := { 1, 2, 3 }
   local e
   begin sequence
      break(d)
   recover using e
      e[1] := 99
   end sequence
   ? d[1], e[1]
return nil
