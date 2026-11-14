procedure main()
   local n := -1
   local v := 5
   ? ProcName(n), ProcLine(n), ProcName(9223372036854775807), ProcLine(9223372036854775807)
   ? ProcName(level()), ProcLine(level())
   specialize(@v)
   early()
   ? ProcName(0), ProcName(1), ProcLine(1), v
return
function level()
return 0
function specialize(v)
   ? ProcName(0), ProcName(1), ProcLine(1)
   v := v + 1
return nil
function early()
   if .T.
      return nil
   endif
return nil
