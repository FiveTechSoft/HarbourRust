procedure main()
   walk()
return
function walk()
   local n := 0
   ? ProcName(n++), n, ProcLine(n++), n
   ? ProcName(-1), ProcLine(-1)
   ? ProcName(99), ProcLine(99)
return nil
