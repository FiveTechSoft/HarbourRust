procedure main()
   local n
   local values := {2147483647,2147483648,4294967295,4294967296,4294967297,-2147483648,-2147483649,-4294967296,9223372036854775807}
   for n := 1 to 9
      ? ProcName(values[n]), ProcLine(values[n])
   next
return
